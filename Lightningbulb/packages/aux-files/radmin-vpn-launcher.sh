#!@bash@
# radmin-vpn -- start Radmin VPN for Linux (upstream's run.sh), the way
# upstream's AppImage entry point (packaging/AppRun) does, minus the bundled
# Wine.  Installed by the radmin-vpn-linux package of the Lightningbulb channel.
#
#   radmin-vpn [run.sh options]  start Radmin VPN; if it is already running,
#                                bring up its window instead
#   radmin-vpn --stop            quit Radmin VPN: stops the GUI, the service
#                                and tap_bridge and removes the TAP device
#                                (what closing upstream's run.sh does)
#
# Root: run.sh calls sudo for every privileged step, from several processes
# (itself, its netsh relay, the keep-alive).  Without a terminal, sudo keeps
# one time stamp per parent process, so each of those asked for the password
# again.  Here every one of those calls goes through a "sudo broker": one
# process of ours that runs them all, so they share one time stamp and the
# password is asked once.  The broker only runs the commands run.sh needs
# (ip/sysctl/nmcli on the radminvpn0 device, modprobe tun, the netsh relay's
# ip commands), so it can't be used to run anything else as root.
set -euo pipefail

DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/radmin-vpn-linux"
mkdir -p "$DATA_DIR"
export WINEPREFIX="$DATA_DIR/wineprefix"
export BUILD_DIR="@lib@"
export RADMIN_DATA_DIR="$DATA_DIR"
RUN_SH="@share@/run.sh"
RADMIN_DIR="$WINEPREFIX/drive_c/Program Files (x86)/Radmin VPN"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}"
PID_FILE="$RUNTIME_DIR/radmin-vpn-linux.pid"
LOG_FILE="$DATA_DIR/run.log"

# PID of the run.sh that is running Radmin VPN, if any.  Instances started by
# older versions of this package have no PID file.
running_pid() {
    local pid
    pid=$(cat "$PID_FILE" 2>/dev/null || true)
    if [ -n "$pid" ] && grep -qa 'radmin-vpn-linux/run\.sh' "/proc/$pid/cmdline" 2>/dev/null; then
        echo "$pid"
        return 0
    fi
    # -o: run.sh's subshells (the netsh relay) have the same command line.
    pgrep -o -u "$(id -u)" -f '/share/radmin-vpn-linux/run\.sh' || return 1
}

if [ "${1:-}" != "--stop" ] && pid=$(running_pid); then
    # Radmin's GUI is single-instance: a second one shows the window of the
    # running one (also when it is hidden in the tray) and exits.  Use the
    # Wine of the running instance (it may be from an older version of this
    # package), and never update the prefix under it.
    path=$(tr '\0' '\n' < "/proc/$pid/environ" 2>/dev/null | sed -n 's/^PATH=//p')
    cd "$RADMIN_DIR"
    PATH="${path:-$PATH}" GUIX_WINE_UPDATING=1 WINEDEBUG=-all \
        WINEDLLOVERRIDES="winemenubuilder.exe=d" \
        wine RvRvpnGui.exe >/dev/null 2>&1 || true
    exit 0
fi

BROKER_DIR=$(mktemp -d "$RUNTIME_DIR/radmin-vpn-sudo.XXXXXX")
KEEPALIVE_PID=""
BROKER_PID=""
cleanup() {
    [ -n "$KEEPALIVE_PID" ] && kill "$KEEPALIVE_PID" 2>/dev/null || true
    [ -n "$BROKER_PID" ] && kill "$BROKER_PID" 2>/dev/null || true
    rm -rf "$BROKER_DIR"
    local pid
    pid=$(cat "$PID_FILE" 2>/dev/null || true)
    if [ -n "$pid" ] && ! kill -0 "$pid" 2>/dev/null; then rm -f "$PID_FILE"; fi
    return 0
}
trap cleanup EXIT

# ---- Askpass: a zenity (or kdialog) password dialog, as in AppRun ----
if [ -z "${SUDO_ASKPASS:-}" ] && [ -n "${DISPLAY:-${WAYLAND_DISPLAY:-}}" ]; then
    ASKPASS_SHIM="$BROKER_DIR/askpass"
    if command -v zenity >/dev/null 2>&1; then
        printf '#!/bin/sh\nzenity --password --title="Radmin VPN" --text="$1" 2>/dev/null\n' > "$ASKPASS_SHIM"
    elif command -v kdialog >/dev/null 2>&1; then
        printf '#!/bin/sh\nkdialog --title "Radmin VPN" --password "$1" 2>/dev/null\n' > "$ASKPASS_SHIM"
    fi
    [ -s "$ASKPASS_SHIM" ] && { chmod +x "$ASKPASS_SHIM"; export SUDO_ASKPASS="$ASKPASS_SHIM"; }
fi

if [ "${1:-}" = "--stop" ]; then
    if pid=$(running_pid); then
        # run.sh does the whole cleanup (wineserver -k, tap_bridge, TAP
        # device) when it exits, with the sudo broker of its launcher.
        kill -TERM "$pid"
        for _ in $(seq 1 100); do
            kill -0 "$pid" 2>/dev/null || exit 0
            sleep 0.2
        done
        echo "radmin-vpn: run.sh ($pid) did not exit" >&2
        exit 1
    fi
    # Nothing running: clean up whatever a crashed run left behind.
    wineserver -k 2>/dev/null || true
    pkill -u "$(id -u)" -x tap_bridge 2>/dev/null || true
    if ip link show radminvpn0 >/dev/null 2>&1; then
        sudo ${SUDO_ASKPASS:+-A} -p "Radmin VPN: password to remove the radminvpn0 device:" \
             ip link delete radminvpn0
    fi
    exit 0
fi

# ---- The sudo broker ----
REAL_SUDO=$(command -v sudo) || { echo "[-] sudo not found" >&2; exit 1; }
mkfifo -m 600 "$BROKER_DIR/req" "$BROKER_DIR/resp"

# Whether the broker may run "sudo ARGS...": sudo options run.sh and this
# script use, then one of run.sh's commands.
ip_allowed() {
    [ "${1:-}" = "-6" ] && shift
    case "${1:-} ${2:-}" in
        "link set"|"link delete") [ "${3:-}" = radminvpn0 ] || return 1 ;;
        "addr add"|"addr flush"|"route add"|"route replace"|"route append"|"maddr add"|"tuntap add") ;;
        *) return 1 ;;
    esac
    local arg prev="" device=""
    for arg in "$@"; do
        case "$arg" in netns|exec|vrf|master|-*) return 1 ;; esac
        if [ "$prev" = dev ]; then
            [ "$arg" = radminvpn0 ] || return 1
        fi
        [ "$arg" = radminvpn0 ] && device=1
        prev=$arg
    done
    [ -n "$device" ]
}
relay_allowed() {
    # The netsh relay's commands: "ip ... radminvpn0 [2>/dev/null]; ...".
    local part
    local -a parts words
    IFS=';' read -r -a parts <<< "$1"
    for part in "${parts[@]}"; do
        read -r -a words <<< "$part"
        [ ${#words[@]} -eq 0 ] && continue
        [ "${words[-1]}" = "2>/dev/null" ] && unset 'words[-1]'
        case "${words[*]}" in *">"*) return 1 ;; esac
        [ "${words[0]:-}" = ip ] && ip_allowed "${words[@]:1}" || return 1
    done
}
sudo_allowed() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -A|-n|-v) shift ;;
            -p) shift 2 || return 1 ;;
            --) shift; break ;;
            -*) return 1 ;;
            *) break ;;
        esac
    done
    [ $# -eq 0 ] && return 0            # sudo -v: refresh the time stamp
    local arg
    # Plain words only; the relay's shell commands also have ";" and ">".
    for arg in "$@"; do
        case "$arg" in "") return 1 ;; esac
        if [ "$1 ${2:-}" = "sh -c" ] && [ "$arg" = "${3:-}" ]; then
            case "$arg" in *[!A-Za-z0-9._:/\ \;\>-]*) return 1 ;; esac
        else
            case "$arg" in *[!A-Za-z0-9._:/=-]*) return 1 ;; esac
        fi
    done
    case "$1" in
        true|dmesg) [ $# -eq 1 ] ;;
        modprobe) [ "$*" = "modprobe tun" ] ;;
        ip) ip_allowed "${@:2}" ;;
        sysctl) [ $# -eq 3 ] && [ "$2" = -w ] &&
                    case "$3" in net.ipv4.conf.radminvpn0.*=*) true ;; *) false ;; esac ;;
        nmcli) [ "$*" = "nmcli device set radminvpn0 managed no" ] ;;
        sh) [ $# -eq 3 ] && [ "$2" = -c ] && relay_allowed "$3" ;;
        *) false ;;
    esac
}

# Runs the requests of the `sudo' shim (see radmin-vpn-sudo) one at a time.
# Every sudo it starts is its child, so they all share one time stamp.
sudo_broker() {
    set +e
    local client n i arg rc out err
    local -a args
    exec </dev/null
    while :; do
        exec 3<"$BROKER_DIR/req" || exit 1
        if ! { IFS= read -r client && IFS= read -r n; } <&3 ||
           ! [[ $client =~ ^[0-9]+$ && $n =~ ^[0-9]+$ ]]; then
            exec 3<&-
            continue
        fi
        args=()
        for ((i = 0; i < n; i++)); do
            IFS= read -r -d '' arg <&3 || break
            args+=("$arg")
        done
        exec 3<&-
        if [ ${#args[@]} -eq "$n" ] && sudo_allowed "${args[@]}"; then
            # Output goes where the caller's goes (a pipe, the log...).
            out="/proc/$client/fd/1" err="/proc/$client/fd/2"
            { : >>"$out"; } 2>/dev/null || out=/dev/null
            { : >>"$err"; } 2>/dev/null || err=/dev/null
            # exec, so that sudo's parent is this process.
            ( exec "$REAL_SUDO" ${SUDO_ASKPASS:+-A} "${args[@]}" >>"$out" 2>>"$err" )
            rc=$?
        else
            echo "radmin-vpn: refusing to run as root: ${args[*]}" >&2
            rc=1
        fi
        exec 4<>"$BROKER_DIR/resp"
        printf '%s %s\n' "$client" "$rc" >&4
        exec 4>&-
    done
}


sudo_broker &
BROKER_PID=$!
export RADMIN_SUDO_BROKER="$BROKER_DIR" RADMIN_SUDO_BROKER_PID="$BROKER_PID"
export RADMIN_REAL_SUDO="$REAL_SUDO"
# run.sh, its relay and the keep-alive below find the shim first.
export PATH="@shim@:$PATH"

# ---- Prime sudo + background keep-alive ----
SUDO_PROMPT="Radmin VPN needs root for TAP device and routes. Password:"
[ -z "${SUDO_ASKPASS:-}" ] && echo "[*] $SUDO_PROMPT"
sudo -p "$SUDO_PROMPT" -v || { echo "[-] sudo required" >&2; exit 1; }
( while sleep 50; do sudo -n -v 2>/dev/null || exit; done ) &
KEEPALIVE_PID=$!

export RADMIN_SUDO_PRIMED=1   # tells run.sh to skip its own sudo -v

# ---- Run, with the output duplicated to a log file ----
: > "$LOG_FILE"
# The inner shell records its PID (that of run.sh, which it becomes) for
# `radmin-vpn --stop'.
bash -c 'echo $$ > "$1"; shift; exec bash "$@"' radmin-vpn "$PID_FILE" "$RUN_SH" "$@" 2>&1 \
    | tee -a "$LOG_FILE"
