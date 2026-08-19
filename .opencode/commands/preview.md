---
description: Render a scene resource to PNG with the editor and inspect it
---
Rendering an editor preview of `$1` (a collection, game object, gui, model or other scene resource; path without a leading slash). Requires Defold >= 1.13.1.

!`p=$(cat .internal/editor.port 2>/dev/null); if [ -z "$p" ]; then echo "Defold editor is not running with this project open."; else mkdir -p build/automation && out="build/automation/preview.png" && code=$(curl -sS -o "$out" -w '%{http_code}' "http://127.0.0.1:$p/preview/$1?width=${2:-1280}&height=${3:-720}") && echo "HTTP $code -> $out"; fi`

Read `build/automation/preview.png` and evaluate it against the requested criteria. Remember an editor preview is not a running-game screenshot: it does not show runtime-spawned objects or post-processing.
