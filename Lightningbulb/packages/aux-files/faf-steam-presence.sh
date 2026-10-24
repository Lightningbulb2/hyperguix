#!@bash@
# faf-steam-presence LIBSTEAM_API.SO GAME_PID -- the FAF client's Steam status
# helper for nonguix's Steam (FAF_STEAM_PRESENCE_COMMAND).  Runs
# faf-steam-presence-helper inside the running Steam container, for as long as
# the game GAME_PID runs.  The client passes its host libsteam_api.so; the
# container gets the unpatched copy shipped next to the helper.  The client
# logs what this prints when it ends without a status.
game="$2"
[ -n "$game" ] || { echo "usage: faf-steam-presence LIBRARY GAME_PID" >&2; exit 2; }
kill -0 "$game" 2>/dev/null || { echo "the game ($game) is not running" >&2; exit 3; }

steam=$(@pgrep@ -u "$(@id@ -u)" -f '/ubuntu12_32/steam( |$)' | @head@ -n 1)
[ -n "$steam" ] || { echo "Steam is not running" >&2; exit 6; }

# The container's home is the sandbox directory on this side.  Put the helper
# where both sides see it.
sandbox="${GUIX_SANDBOX_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/guix-sandbox-home}"
inside_home=$(@tr@ '\0' '\n' < "/proc/$steam/environ" | @sed@ -n 's/^HOME=//p')
[ -n "$inside_home" ] || { echo "cannot read the Steam container's environment" >&2; exit 6; }
dir=.cache/faforever-steam-presence
@mkdir@ -p "$sandbox/$dir"
@install@ -m 755 @helper@ "$sandbox/$dir/faf-steam-presence-helper"
@install@ -m 644 @library@ "$sandbox/$dir/libsteam_api.so"

# stdin stays open until the game exits; the helper then signs out.
@tail@ --pid="$game" -f /dev/null |
  @nsenter@ -t "$steam" -U -m -p -i --preserve-credentials --wd=/ -- \
    "$inside_home/$dir/faf-steam-presence-helper" "$inside_home/$dir/libsteam_api.so"
