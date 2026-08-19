---
description: Clear the build cache, then build and run via the Defold editor
---
Clean build result (use only when an ordinary build behaves inconsistently or seems to miss changes):

!`p=$(cat .internal/editor.port 2>/dev/null); if [ -z "$p" ]; then echo "Defold editor is not running with this project open."; else curl -sS -X POST -w '\nHTTP %{http_code}\n' "http://127.0.0.1:$p/command/clean-build"; fi`

Fix any reported issues at their `resource` path and source `range`, then build again.
