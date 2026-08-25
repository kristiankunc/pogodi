#!/bin/sh
# Usage: tools/defold.sh [-s|--scale 1.65|165%|192dpi] [editor args...]
set -e

SRC="${DEFOLD_HOME:-/opt/Defold}"
RUNDIR="${XDG_DATA_HOME:-$HOME/.local/share}/defold-scaled"
SCALE="${DEFOLD_SCALE:-200%}"

while [ $# -gt 0 ]; do
	case "$1" in
		-s|--scale) SCALE="$2"; shift 2 ;;
		--scale=*) SCALE="${1#--scale=}"; shift ;;
		*) break ;;
	esac
done

mkdir -p "$RUNDIR"
cmp -s "$SRC/Defold" "$RUNDIR/Defold" || cp "$SRC/Defold" "$RUNDIR/Defold"
ln -sfn "$SRC/packages" "$RUNDIR/packages"
sed "s|^vmargs = |vmargs = -Dglass.gtk.uiScale=$SCALE,|" "$SRC/config" > "$RUNDIR/config"
nohup "$RUNDIR/Defold" "$@" >/dev/null 2>&1 &
disown
echo "Defold editor launched in background (pid $!)"
