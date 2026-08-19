---
description: Look up Defold manuals/API docs from the official LLM endpoints
---
Topic to research: $ARGUMENTS

Live manual index:

!`curl -sS https://defold.com/llms/manuals.md`

Live API index:

!`curl -sS https://defold.com/llms/apis.md`

Pick the one or two most relevant pages and fetch those Markdown URLs directly. Do not fetch https://defold.com/llms-full.txt - it is for offline indexing only and will flood the context. For version-exact signatures of the installed editor, prefer /ref (the `/ref` command).
