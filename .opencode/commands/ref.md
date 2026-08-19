---
description: Search the Defold API reference bundled with the running editor
---
API reference matches for `$ARGUMENTS` from the running editor (version-exact; whitespace = AND, `|` = OR):

!`p=$(cat .internal/editor.port 2>/dev/null); if [ -z "$p" ]; then echo "Defold editor is not running - fall back to the defold-api-fetch skill."; else curl -sS --get --data-urlencode "q=$ARGUMENTS" "http://127.0.0.1:$p/ref"; fi`

Use only functions, messages and properties that appear above. If nothing matches, the API does not exist in this Defold version - do not invent one.
