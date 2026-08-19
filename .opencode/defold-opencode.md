# opencode notes for this Defold project

Supplements `AGENTS.md` (which is tool-agnostic). These are opencode-specific.

## Reading dependency code in `.deps/`

`.deps/` is git-ignored, but the `.ignore` file re-includes it for ripgrep, so both `grep`
and `glob` can see it. Keep both lines (`!.deps` and `!.deps/**`) in `.ignore`: without the
first one the directory stays hidden from `glob`.

`.deps/` is read-only context. Edits there are denied by `opencode.json`, as are edits in
`build/` and `.internal/`.

## Build and inspect through the running editor

These commands wrap the editor HTTP API (port from `.internal/editor.port`), and are
preferred over ad-hoc curl:

- `/build`, `/clean-build` - compile and run, returns structured issues (HTTP 422 on failure)
- `/ref <query>` - API reference of the *installed* editor version, the most authoritative source
- `/console` - editor console output
- `/preview <resource> [width] [height]` - render a scene resource to PNG for visual checks
- `/docs <topic>`, `/examples <topic>` - live indexes from defold.com/llms/*

Never read `.internal/editor.token` into a prompt, log or report, and ask before using
`POST /eval`.

## Diagnostics

`.script`, `.gui_script`, `.render_script` and `.editor_script` are sent to
lua-language-server as Lua, with Defold 1.13.1 annotations from
`~/.local/share/defold-annotations/1.13.1` and `.deps/` as a library root (see `.luarc.json`).
Diagnostics reported after an edit are authoritative about API existence and argument types -
fix them rather than explaining them away. If an API is flagged as undefined, confirm with
`/ref` before assuming the annotations are stale.
