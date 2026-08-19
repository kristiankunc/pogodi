---
description: Build and run the project via the running Defold editor
---
Build result from the Defold editor HTTP API (HTTP 200 = built and launched, 422 = compile errors, 403 = command not active, no output = editor not running):

!`p=$(cat .internal/editor.port 2>/dev/null); if [ -z "$p" ]; then echo "Defold editor is not running with this project open (.internal/editor.port missing)."; else curl -sS -X POST -w '\nHTTP %{http_code}\n' "http://127.0.0.1:$p/command/build"; fi`

If `success` is false, fix every issue at its `resource` path and source `range`, then run this build again. Never edit files under `build/`, `.internal/` or `.deps/`.
