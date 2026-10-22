#!@bash@
# Called by run.sh (radmin-vpn-linux package) once Radmin VPN is installed in
# $WINEPREFIX.
#
# Radmin's GUI asks for "MS Shell Dlg 2" everywhere, which Wine maps to its
# own Tahoma.  That Tahoma has embedded bitmaps for small sizes, so the GUI's
# labels (the PC name, the status) came out jagged, with pixels missing.
# Install Arial (Microsoft's, from nonguix) in the prefix, register it like
# Windows does and map the dialog fonts to it.  Done again only when the
# fonts change.
set -eu
fonts="@arial@/share/fonts/truetype"
stamp="$WINEPREFIX/.radmin-vpn-fonts"
[ "$(cat "$stamp" 2>/dev/null)" = "$fonts" ] && exit 0

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
EOF
WINEDEBUG=-all wine reg import "$(wine winepath -w "$reg" 2>/dev/null)" >/dev/null 2>&1
echo "$fonts" > "$stamp"
