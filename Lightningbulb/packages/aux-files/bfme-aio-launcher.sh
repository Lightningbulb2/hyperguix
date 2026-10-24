#!@bash@
# BFME All In One Launcher under Wine, in its own prefix (bfme-aio-launcher
# package of the Lightningbulb channel).
#   bfme-aio-launcher [ARGS]   start the launcher
#   bfme-aio-launcher --stop   end the launcher and the games, whatever state
#                              they are in (wineserver -k)
#   bfme-aio-launcher --stop-game  end the games only
#   BFME_WINEPREFIX  prefix to use (default: $XDG_DATA_HOME/bfme-aio-launcher/prefix)
#   BFME_WINE        wine executable (default: wine64-wow64, PE builtins)
#   BFME_DXVK=1      use DXVK (Direct3D 9-11 over Vulkan) instead of WineD3D
#   BFME_DPI         Windows DPI (default 96, i.e. 100%).  The launcher scales
#                    its whole UI with its window, whatever the DPI, so this
#                    only matters for other programs (and DPI-unaware games
#                    may get scaled by Wine when it is not 96).
#   BFME_VIRTUAL_DESKTOP  where the games run (the launcher is a normal
#                    window either way):
#                    auto (default)  in a Wine virtual desktop as big as the
#                                    primary monitor, shown fullscreen on it
#                                    (wine64-wow64 creates it there);
#                    WIDTHxHEIGHT    in a virtual desktop of that size, in a
#                                    normal window;
#                    off             in their own fullscreen window, which
#                                    cosmic-comp puts on the monitor Wine
#                                    chose (the X11 primary).
#                    The desktop,
#                    "BFME", is set for the game programs in AppDefaults;
#                    wine64-wow64 is patched so that this works when the
#                    launcher starts them.
# Drive D: is $XDG_DATA_HOME/bfme-aio-launcher/games, for the game installs;
# C: is the prefix's own drive_c.
set -e
data="${XDG_DATA_HOME:-$HOME/.local/share}/bfme-aio-launcher"
export WINEPREFIX="${BFME_WINEPREFIX:-$data/prefix}"
wine="${BFME_WINE:-@wine@}"
dxvk="@dxvk@"
fonts="@fonts@"
# Don't let Wine put menu entries/icons for the launcher's shortcuts into
# ~/.local/share/applications; this package provides its own entry.
overrides="winemenubuilder.exe=d"

notify() {
  zenity --notification --text="$1" 2>/dev/null || echo "$1" >&2
}

# The programs the games run as; their windows are named after them.
games="lotrbfme.exe lotrbfme2.exe lotrbfme2ep1.exe game.dat"

case "${1:-}" in
  --stop)
    server="$(dirname "$wine")/wineserver"
    [ -x "$server" ] || server=wineserver
    exec "$server" -k ;;
  --stop-game)
    [ -f "$WINEPREFIX/system.reg" ] || exit 0
    for game in $games; do
      GUIX_WINE_UPDATING=1 WINEDEBUG=-all "$wine" taskkill /f /im "$game" \
        >/dev/null 2>&1 || true
    done
    exit 0 ;;
esac

if [ ! -f "$WINEPREFIX/system.reg" ]; then
  notify "Setting up the Wine prefix for the BFME All In One Launcher..."
  mkdir -p "$WINEPREFIX"
  WINEDLLOVERRIDES="$overrides" "$wine" wineboot -i
  # Keep the prefix self-contained: Wine links Desktop, Documents etc. to
  # the folders in $HOME, and the launcher drops a shortcut on the desktop.
  for dir in "$WINEPREFIX"/drive_c/users/*/; do
    for f in Desktop Documents Downloads Music Pictures Videos Templates; do
      if [ -L "$dir$f" ]; then
        rm -f -- "${dir:?}$f"
        mkdir -p -- "$dir$f"
      fi
    done
  done
  # WPF's Direct3D path is the least reliable part of WPF under Wine.
  WINEDLLOVERRIDES="$overrides" "$wine" reg add \
    'HKCU\Software\Microsoft\Avalon.Graphics' \
    /v DisableHWAcceleration /t REG_DWORD /d 1 /f >/dev/null
fi

# Settings kept in the prefix, re-applied only when they change.
# - winemenubuilder off in the registry too, so no Wine process in this
#   prefix (prefix updates, the games) adds menu entries;
# - the DPI;
# - Arial, Times New Roman and Courier New, installed and registered like
#   on Windows.  WPF looks fonts up through DirectWrite, which only sees
#   fonts registered in the prefix, and when a text needs a font the
#   launcher doesn't bring (its error popups and message boxes ask for
#   Consolas or Segoe UI) WPF falls back to Arial -- and terminates the
#   process ("Unrecoverable system error") if there is no Arial.
# - the virtual desktop (see above).
dpi="${BFME_DPI:-96}"
desktop="${BFME_VIRTUAL_DESKTOP:-auto}"
case "$desktop" in
  auto)
    modes=$(xrandr --query 2>/dev/null || true)
    desktop=$(printf '%s\n' "$modes" |
                sed -n 's/^[^ ]* connected primary \([0-9]*x[0-9]*\)+.*/\1/p' | head -n 1)
    [ -n "$desktop" ] ||
      desktop=$(printf '%s\n' "$modes" |
                  sed -n 's/^[^ ]* connected \([0-9]*x[0-9]*\)+.*/\1/p' | head -n 1)
    [ -n "$desktop" ] || desktop=1920x1080 ;;
  off|no|0) desktop=off ;;
  [1-9]*x[1-9]*) ;;
  *) notify "BFME_VIRTUAL_DESKTOP=$desktop: expected auto, off or WIDTHxHEIGHT"
     exit 1 ;;
esac
settings="menubuilder-off dpi=$dpi fonts=$fonts game-desktop=$desktop black-desktop"
applied="$WINEPREFIX/.bfme-aio-launcher-settings"
if [ "$(cat "$applied" 2>/dev/null)" != "$settings" ]; then
  WINEDLLOVERRIDES="$overrides" "$wine" reg add \
    'HKCU\Software\Wine\DllOverrides' \
    /v winemenubuilder.exe /t REG_SZ /d '' /f >/dev/null
  WINEDLLOVERRIDES="$overrides" "$wine" reg add \
    'HKCU\Control Panel\Desktop' \
    /v LogPixels /t REG_DWORD /d "$dpi" /f >/dev/null
  # No desktop for everything (older versions of this script set one).
  WINEDLLOVERRIDES="$overrides" "$wine" reg delete \
    'HKCU\Software\Wine\Explorer' /v Desktop /f >/dev/null 2>&1 || true
  for game in $games; do
    if [ "$desktop" = off ]; then
      WINEDLLOVERRIDES="$overrides" "$wine" reg delete \
        "HKCU\\Software\\Wine\\AppDefaults\\$game\\Explorer" /v Desktop /f \
        >/dev/null 2>&1 || true
    else
      WINEDLLOVERRIDES="$overrides" "$wine" reg add \
        "HKCU\\Software\\Wine\\AppDefaults\\$game\\Explorer" \
        /v Desktop /t REG_SZ /d BFME /f >/dev/null
    fi
  done
  # Its window is titled "BFME - Wine desktop", with WM_CLASS "bfme".
  if [ "$desktop" != off ]; then
    WINEDLLOVERRIDES="$overrides" "$wine" reg add \
      'HKCU\Software\Wine\Explorer\Desktops' \
      /v BFME /t REG_SZ /d "$desktop" /f >/dev/null
  fi
  # A plain black desktop: no Windows blue, no icons for the shortcuts the
  # launcher puts on the (prefix's) desktop.
  WINEDLLOVERRIDES="$overrides" "$wine" reg add \
    'HKCU\Control Panel\Colors' /v Background /t REG_SZ /d '0 0 0' /f >/dev/null
  WINEDLLOVERRIDES="$overrides" "$wine" reg add \
    'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' \
    /v NoDesktop /t REG_DWORD /d 1 /f >/dev/null
  for dir in $fonts; do
    for f in "$dir"/*.ttf; do
      install -m 644 "$f" "$WINEPREFIX/drive_c/windows/Fonts/"
    done
  done
  while IFS='|' read -r name file; do
    WINEDLLOVERRIDES="$overrides" "$wine" reg add \
      'HKLM\Software\Microsoft\Windows NT\CurrentVersion\Fonts' \
      /v "$name (TrueType)" /t REG_SZ /d "$file" /f >/dev/null
  done <<'EOF'
Arial|Arial.ttf
Arial Bold|Arialbd.ttf
Arial Bold Italic|Arialbi.ttf
Arial Italic|Ariali.ttf
Times New Roman|Times.ttf
Times New Roman Bold|Timesbd.ttf
Times New Roman Bold Italic|Timesbi.ttf
Times New Roman Italic|Timesi.ttf
Courier New|cour.ttf
Courier New Bold|courbd.ttf
Courier New Bold Italic|courbi.ttf
Courier New Italic|couri.ttf
EOF
  echo "$settings" > "$applied"
fi
rm -f "$data/applied"                 # where older versions kept it

# D: is where the games go, in a folder that's easy to find.
mkdir -p "$data/games"
ln -sfn "$data/games" "$WINEPREFIX/dosdevices/d:"

# The launcher counts a game as installed as soon as its folder exists, and
# creates the (empty) folder before installing anything; an install that
# was interrupted early leaves the game "installed" with nothing to start.
# The launcher always installs to <drive>:\BFME1, BFME2 or RotWK.
for dir in "$WINEPREFIX/drive_c" "$data/games"; do
  for game in BFME1 BFME2 RotWK; do
    rmdir -- "$dir/$game" 2>/dev/null || true
  done
done

# Icons for the games' windows, from the games: the .desktop files of this
# package that name these windows use them.  Only redone when an .exe
# changes (the launcher patches them).
icons="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor"
extract_icon() {                        # NAME EXE...
  local name="$1" exe="" candidate tmp png size
  shift
  for candidate in "$@"; do
    [ -f "$candidate" ] && { exe="$candidate"; break; }
  done
  [ -n "$exe" ] || return 0
  [ "$exe" -nt "$data/icons/$name" ] || return 0
  tmp=$(mktemp -d)
  if wrestool -x -t 14 -o "$tmp" "$exe" 2>/dev/null &&
     icotool -x -o "$tmp" "$tmp"/*.ico 2>/dev/null; then
    # NAME_N_WxHxDEPTH.png: copied by increasing depth, so that the
    # deepest of each size stays.
    for png in $(cd "$tmp" && ls -- *.png | sed 's/.*x\([0-9]*\)\.png$/\1 &/' |
                   sort -n | cut -d ' ' -f 2); do
      size=$(echo "$png" | sed 's/.*_\([0-9]*x[0-9]*\)x[0-9]*\.png$/\1/')
      mkdir -p "$icons/$size/apps"
      cp "$tmp/$png" "$icons/$size/apps/$name.png"
    done
  fi
  rm -rf "$tmp"
  mkdir -p "$data/icons"
  touch "$data/icons/$name"
}
for dir in "$data/games" "$WINEPREFIX/drive_c"; do
  extract_icon bfme-rotwk "$dir/RotWK/lotrbfme2ep1.exe"
  # BFME I and II start game.dat, so their windows are "game.dat".
  extract_icon bfme-game "$dir/BFME2/lotrbfme2.exe" "$dir/BFME1/lotrbfme.exe"
  # The virtual desktop's window.
  extract_icon bfme-desktop "$dir/RotWK/lotrbfme2ep1.exe" \
               "$dir/BFME2/lotrbfme2.exe" "$dir/BFME1/lotrbfme.exe"
done

if [ "${BFME_DXVK:-0}" = 1 ]; then
  sys="$WINEPREFIX/drive_c/windows"
  for dll in d3d9 d3d10core d3d11 dxgi; do
    cp -f "$dxvk/share/dxvk/lib/$dll.dll" "$sys/system32/$dll.dll"
    cp -f "$dxvk/share/dxvk/lib32/$dll.dll" "$sys/syswow64/$dll.dll"
  done
  overrides="$overrides;d3d9,d3d10core,d3d11,dxgi=n,b"
  # Its log, which it otherwise writes to the working directory or next to
  # the game.
  dxvk_cache="${XDG_CACHE_HOME:-$HOME/.cache}/bfme-aio-launcher/dxvk"
  mkdir -p "$dxvk_cache"
  export DXVK_LOG_PATH="${DXVK_LOG_PATH:-$dxvk_cache}"
fi
export WINEDLLOVERRIDES="$overrides${WINEDLLOVERRIDES:+;$WINEDLLOVERRIDES}"

appdata=$("$wine" cmd /c 'echo %APPDATA%' 2>/dev/null | tr -d '\r')
appdata=$("$wine" winepath -u "$appdata" 2>/dev/null)
appdir="$appdata/BFME All In One Launcher"
exe="$appdir/AllInOneLauncher.exe"

# Before the first game install the launcher runs Microsoft's DirectX 9
# redistributable (DXSETUP), unless this flag says it has, behind a
# "Windows needs permission for this step" notice that stays up for a
# minute or two with no sign of progress.  Under Wine that's pointless:
# Wine has its own d3dx9, d3dcompiler, xinput, xaudio etc., and loads them
# rather than the DLLs DXSETUP copies into system32.
mkdir -p "$appdata/BFME Workshop/Config"
flag="$appdata/BFME Workshop/Config/dx_version.flag"
[ -e "$flag" ] || printf 'v1\n0' > "$flag"

# First start: what upstream's installer does.  Later updates are done by
# the launcher itself.
if [ ! -f "$exe" ]; then
  mkdir -p "$appdir"
  hash=$(curl -fsSL 'https://bfmeladder.com/api/applications/versionHash?name=all-in-one-launcher&version=main')
  notify "Downloading the BFME All In One Launcher (about 280 MB)..."
  curl -fL --retry 3 -o "$exe.part" \
    'https://arena-files.bfmeladder.com/application-builds/all-in-one-launcher-main'
  if [ "$(md5sum "$exe.part" | cut -d' ' -f1)" != "$hash" ]; then
    rm -f "$exe.part"
    notify "BFME All In One Launcher: download corrupted, try again."
    exit 1
  fi
  mv "$exe.part" "$exe"
fi

cd "$appdir"
exec "$wine" "$exe" "$@"
