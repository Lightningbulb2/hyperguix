#!@bash@
# `sudo' for run.sh, started by radmin-vpn: hands the command to the
# launcher's sudo broker, which runs it with the real sudo, so that all of
# them share the broker's sudo time stamp (see radmin-vpn).  Without a
# broker, it is just sudo.
dir=${RADMIN_SUDO_BROKER:-}
broker=${RADMIN_SUDO_BROKER_PID:-}
if [ -z "$dir" ] || [ ! -p "$dir/req" ] || ! kill -0 "$broker" 2>/dev/null; then
    exec "${RADMIN_REAL_SUDO:-/run/setuid-programs/sudo}" "$@"
fi

# One request at a time; the answer comes back on "resp", tagged with our PID.
exec 9>>"$dir/lock"
@flock@ 9
exec 8<>"$dir/resp"
{ printf '%s\n%s\n' "$$" "$#"; printf '%s\0' "$@"; } > "$dir/req"
while :; do
    if IFS=' ' read -r -t 5 pid rc <&8; then
        [ "$pid" = "$$" ] && exit "$rc"
    elif ! kill -0 "$broker" 2>/dev/null; then
        exit 1
    fi
done
