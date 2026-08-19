---
description: Read the Defold editor console output
---
Current editor console (`lines` is the text, `regions` marks errors, eval results and resource references):

!`p=$(cat .internal/editor.port 2>/dev/null); if [ -z "$p" ]; then echo "Defold editor is not running with this project open."; else curl -sS "http://127.0.0.1:$p/console"; fi`

$ARGUMENTS
