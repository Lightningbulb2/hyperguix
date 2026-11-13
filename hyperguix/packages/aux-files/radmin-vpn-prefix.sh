#!@bash@
# Called by run.sh (radmin-vpn-linux package) once Radmin VPN is installed in
# $WINEPREFIX.
#
# Fonts: Radmin's GUI asks for "MS Shell Dlg 2" everywhere, which Wine maps to its
# own Tahoma.  That Tahoma has embedded bitmaps for small sizes, so the GUI's
# labels (the PC name, the status) came out jagged, with pixels missing.
# Install Arial (Microsoft's, from nonguix) in the prefix, register it like
# Windows does and map the dialog fonts to it.
#
# ClientSideGraphics=N for the GUI: it keeps a 22x22 transparent (layered)
# window mapped at the bottom-right corner of the primary monitor.  With
# Wine's default client-side drawing, Xwayland showed it as an opaque white
# square there (over the panel's clock in COSMIC), although its X contents
# are transparent (unmapping and mapping it again fixes it, so the
# compositor seems to keep its first, undrawn buffer).  Drawn server-side,
# it is transparent from the start.
#
# Done again only when this changes.
set -eu
fonts="@arial@/share/fonts/truetype"
settings="$fonts gui-clientsidegraphics=n"
stamp="$WINEPREFIX/.radmin-vpn-settings"
[ "$(cat "$stamp" 2>/dev/null)" = "$settings" ] && exit 0
rm -f "$WINEPREFIX/.radmin-vpn-fonts"   # where the previous version kept it

install -m 644 "$fonts"/*.ttf "$WINEPREFIX/drive_c/windows/Fonts/"
reg=$(mktemp --suffix=.reg)
trap 'rm -f "$reg"' EXIT
cat > "$reg" <<'EOF'
REGEDIT4

[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Fonts]
"Arial (TrueType)"="Arial.ttf"
"Arial Bold (TrueType)"="Arialbd.ttf"
"Arial Bold Italic (TrueType)"="Arialbi.ttf"
"Arial Italic (TrueType)"="Ariali.ttf"

[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\FontSubstitutes]
"MS Shell Dlg"="Arial"
"MS Shell Dlg 2"="Arial"

[HKEY_CURRENT_USER\Software\Wine\AppDefaults\RvRvpnGui.exe\X11 Driver]
"ClientSideGraphics"="N"
EOF
WINEDEBUG=-all wine reg import "$(wine winepath -w "$reg" 2>/dev/null)" >/dev/null 2>&1
echo "$settings" > "$stamp"
