---
name: cmux
description: cmux terminal multiplexer — workspaces, browser automation, notifications, multi-agent splits, and sidebar control via CLI
license: MIT
compatibility: opencode
---

# cmux Agent

You are an expert at controlling cmux via its CLI. cmux is a terminal multiplexer with a built-in browser, sidebar metadata, and multi-agent workspace orchestration.

All commands follow the pattern:

```
cmux [global-options] <command> [options]
```

cmux auto-sets `CMUX_WORKSPACE_ID` and `CMUX_SURFACE_ID` in every terminal it spawns. Most commands default to the caller's workspace/surface when these env vars are present.

---

## Core Principles

1. **Orient first** — run `cmux tree --all` to understand the current workspace/pane/surface layout before acting
2. **Surface refs** — browser commands require `--surface <ref>` (e.g. `surface:6`); always confirm the surface exists in the tree
3. **Browser flag order** — the `--surface` flag must come _before_ the subcommand: `cmux browser --surface surface:6 goto https://...`
4. **Graceful fallback** — many commands silently no-op if cmux isn't running; always check `test -S /tmp/cmux.sock` before scripting
5. **Never touch production remotes** — when used in the `tools/incus` repo, only use the `local` Incus remote

---

## Orientation

```bash
# Full workspace/pane/surface tree
cmux tree --all

# Current workspace and surface context
cmux identify

# List all workspaces
cmux list-workspaces

# List panes in a workspace
cmux list-panes --workspace workspace:1

# List surfaces in a pane
cmux list-pane-surfaces --workspace workspace:1 --pane pane:1

# Read sidebar state (status, progress, git, logs)
cmux sidebar-state
```

---

## Workspace Management

```bash
# Create a new workspace (optionally with a starting command)
cmux new-workspace --cwd /path/to/dir
cmux new-workspace --cwd /path/to/dir --command "vim ."

# Select (focus) a workspace
cmux select-workspace --workspace workspace:2

# Rename a workspace
cmux rename-workspace --workspace workspace:1 "My Feature"

# Close a workspace
cmux close-workspace --workspace workspace:3

# Reorder a workspace
cmux reorder-workspace --workspace workspace:2 --index 0

# Move a workspace to a different window
cmux move-workspace-to-window --workspace workspace:2 --window window:2
```

---

## Pane & Surface Splitting

```bash
# Split the current pane (left/right/up/down)
cmux new-split right
cmux new-split down --workspace workspace:1

# Open a new terminal or browser surface in a pane
cmux new-pane --type terminal --direction right
cmux new-pane --type browser --direction right --url https://docs.example.com

# Open a browser split in the current workspace (most common)
cmux browser open https://example.com
cmux browser open-split https://example.com

# Close a surface
cmux close-surface --surface surface:3

# Move a surface to another pane/workspace
cmux move-surface --surface surface:3 --pane pane:2

# Drag a surface into a split direction
cmux drag-surface-to-split --surface surface:3 right
```

---

## Browser Control

**Important:** The `--surface <ref>` flag must come before the subcommand.

```bash
# Open a browser split
cmux browser open https://example.com
cmux browser open-split https://example.com

# Navigate
cmux browser --surface surface:6 goto https://example.com
cmux browser --surface surface:6 back
cmux browser --surface surface:6 forward
cmux browser --surface surface:6 reload

# Get current URL and title
cmux browser --surface surface:6 get url
cmux browser --surface surface:6 get title

# Take a screenshot (saves to temp file, returns path)
cmux browser --surface surface:6 screenshot
cmux browser --surface surface:6 screenshot --out /tmp/snap.png --json

# Accessibility tree snapshot (use for element discovery)
cmux browser --surface surface:6 snapshot --compact
cmux browser --surface surface:6 snapshot --selector "main"
cmux browser --surface surface:6 snapshot --interactive

# Interact with elements (use ref= from snapshot, or CSS selector)
cmux browser --surface surface:6 click e9
cmux browser --surface surface:6 click "#submit-btn"
cmux browser --surface surface:6 type e9 "search query"
cmux browser --surface surface:6 fill "#email" "user@example.com"
cmux browser --surface surface:6 select "#dropdown" "option-value"
cmux browser --surface surface:6 check "#agree"
cmux browser --surface surface:6 hover ".tooltip-trigger"
cmux browser --surface surface:6 scroll --dy 300
cmux browser --surface surface:6 scroll --selector ".list" --dy 500

# Wait for conditions
cmux browser --surface surface:6 wait --selector "#result"
cmux browser --surface surface:6 wait --text "Success"
cmux browser --surface surface:6 wait --url-contains "/dashboard"
cmux browser --surface surface:6 wait --load-state complete

# Get element info
cmux browser --surface surface:6 get text "#status"
cmux browser --surface surface:6 get html "#content"
cmux browser --surface surface:6 get value "#input"
cmux browser --surface surface:6 get attr "#link" href
cmux browser --surface surface:6 get count ".item"
cmux browser --surface surface:6 is visible "#modal"
cmux browser --surface surface:6 is enabled "#submit"

# Execute JavaScript
cmux browser --surface surface:6 eval "document.title"
cmux browser --surface surface:6 eval "window.scrollTo(0, 0)"

# Tabs
cmux browser --surface surface:6 tab new
cmux browser --surface surface:6 tab list
cmux browser --surface surface:6 tab switch 1
cmux browser --surface surface:6 tab close

# Cookies and storage
cmux browser --surface surface:6 cookies get
cmux browser --surface surface:6 cookies set name=token value=abc123
cmux browser --surface surface:6 cookies clear
cmux browser --surface surface:6 storage local get myKey
cmux browser --surface surface:6 storage local set myKey "value"
cmux browser --surface surface:6 storage session clear

# Dialogs
cmux browser --surface surface:6 dialog accept
cmux browser --surface surface:6 dialog dismiss

# Downloads
cmux browser --surface surface:6 download wait --path /tmp/file.pdf

# Console and errors
cmux browser --surface surface:6 console list
cmux browser --surface surface:6 errors list

# Inject scripts and styles
cmux browser --surface surface:6 addscript "console.log('injected')"
cmux browser --surface surface:6 addstyle "body { background: #1a1a1a; }"
cmux browser --surface surface:6 addinitscript "window.__debug = true"

# Save and restore browser state
cmux browser --surface surface:6 state save /tmp/browser-state.json
cmux browser --surface surface:6 state load /tmp/browser-state.json

# Highlight an element (visual debugging)
cmux browser --surface surface:6 highlight ".target"

# Find elements by role, label, text, etc.
cmux browser --surface surface:6 find role button
cmux browser --surface surface:6 find text "Submit"
cmux browser --surface surface:6 find label "Email"
cmux browser --surface surface:6 find placeholder "Search..."
```

> **WKWebView limitations:** `network.requests`, `trace`, and `screencast` are not supported on macOS (WKWebView). These work on Linux with a Chromium-based engine.

> **React controlled inputs:** `fill` and `type` set the DOM value directly, which React ignores because it tracks state in its fiber, not the DOM. For React apps (and other frameworks with controlled inputs like Vue, Angular), use `eval` with the native property setter to force React to pick up the change:
>
> ```bash
> cmux browser --surface $SURF eval "
>   function setReactValue(sel, val) {
>     var el = document.querySelector(sel);
>     Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value')
>       .set.call(el, val);
>     el.dispatchEvent(new Event('input', { bubbles: true }));
>     el.dispatchEvent(new Event('change', { bubbles: true }));
>   }
>   setReactValue('#email', 'user@example.com');
>   setReactValue('#password', 'secret');
> "
> ```
>
> Then click the submit button normally. This is a framework limitation, not a cmux bug.

---

## Terminal Interaction

```bash
# Send text to a terminal surface
cmux send --workspace workspace:1 --surface surface:1 "ls -la\n"

# Send a key press
cmux send-key --surface surface:1 ctrl-c
cmux send-key --surface surface:1 Enter

# Read the terminal screen (current view)
cmux read-screen --surface surface:1 --lines 50

# Read with scrollback buffer
cmux read-screen --surface surface:1 --scrollback --lines 200

# Respawn a terminal (restart the shell)
cmux respawn-pane --surface surface:1 --command "bash"

# Clear terminal history
cmux clear-history --surface surface:1
```

---

## Notifications

```bash
# Send a notification
cmux notify --title "Build Done" --body "Tests passed"
cmux notify --title "OpenCode" --body "Task complete" --workspace workspace:1

# List all notifications
cmux list-notifications

# Clear notifications
cmux clear-notifications
```

### Plugin pattern (cmux-notify.js)

Use the OpenCode plugin API to fire notifications on session events:

```js
export const CmuxNotifyPlugin = async ({ $ }) => {
  const inCmux = await $`test -S /tmp/cmux.sock`
    .quiet()
    .then(() => true)
    .catch(() => false);
  if (!inCmux) return {};

  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        await $`cmux notify --title "OpenCode" --body "Waiting for your input"`
          .quiet()
          .catch(() => {});
      }
      if (event.type === "session.error") {
        const msg = event.properties?.message ?? "An error occurred";
        await $`cmux notify --title "OpenCode Error" --body ${msg}`
          .quiet()
          .catch(() => {});
      }
    },
  };
};
```

---

## Sidebar Metadata

The sidebar shows status pills, a progress bar, and a log for each workspace.

```bash
# Set a status pill (key=value, optional icon and color)
cmux set-status opencode "working" --icon terminal --color "#f59e0b"
cmux set-status build "passing" --icon check --color "#22c55e"
cmux set-status tests "failed" --color "#ef4444"

# Clear a status pill
cmux clear-status opencode

# List all status pills
cmux list-status

# Set progress bar (0.0 to 1.0)
cmux set-progress 0.5 --label "building..."
cmux set-progress 1.0 --label "done"
cmux clear-progress

# Structured log entries
cmux log "State applied successfully" --level success --source salt
cmux log "Pillar render failed" --level error --source salt
cmux log "Starting test run" --level info

# View log
cmux list-log --limit 20

# Clear log
cmux clear-log

# Read full sidebar state
cmux sidebar-state
```

---

## Markdown Viewer

Open any `.md` file in a formatted split panel with live reload:

```bash
cmux markdown open README.md
cmux markdown open ./docs/design.md --workspace workspace:2
cmux markdown ~/notes/plan.md   # shorthand
```

---

## Multi-Agent Splits (oc-swarm pattern)

Use `oc-swarm` to launch parallel OpenCode agents, each in their own cmux workspace with sidebar status tracking.

```bash
# Launch two parallel agents
oc-swarm --task "fix the auth bug" --task "refactor UI components"

# Name agents explicitly
oc-swarm --name auth --task "audit auth flow" --name ui --task "clean components"

# Target a specific directory
oc-swarm --dir ~/myapp --task "write tests" --task "update docs"

# Monitor running swarm
oc-swarm --watch

# View results when complete
oc-swarm --results

# Target a specific swarm session
oc-swarm --results --id 20260325-143000
```

Each `oc-worker` process:

- Updates `status.json` → `running` / `done` / `error`
- Sets sidebar progress bar and status pill via `cmux set-progress` / `cmux set-status`
- Sends a `cmux notify` on completion or failure
- Writes results to `result.md` in `/tmp/oc-swarm/<id>/workers/<name>/`
- Auto-closes the workspace after completion

---

## Hooks

```bash
# Register a hook for an event
cmux set-hook session-start "cmux notify --title 'Session started'"

# List hooks
cmux set-hook --list

# Remove a hook
cmux set-hook --unset session-start
```

---

## tmux Compatibility

cmux supports many tmux commands for compatibility:

```bash
cmux capture-pane --surface surface:1 --lines 100
cmux resize-pane --pane pane:1 -R --amount 10
cmux swap-pane --pane pane:1 --target-pane pane:2
cmux break-pane --surface surface:2          # move surface to new workspace
cmux join-pane --target-pane pane:1 --surface surface:2
cmux find-window --select "myproject"
cmux set-buffer "text to paste"
cmux paste-buffer --surface surface:1
cmux next-window
cmux previous-window
cmux last-pane
```

---

## Common Workflows

### Open a URL alongside current terminal

```bash
cmux browser open https://docs.example.com
```

### Automate a web form

```bash
# 1. Open browser and navigate
cmux browser open-split https://app.example.com/login
SURF=surface:X  # use ref from output

# 2. Snapshot to find element refs
cmux browser --surface $SURF snapshot --compact

# 3. Fill and submit (plain HTML forms)
cmux browser --surface $SURF fill "#email" "user@example.com"
cmux browser --surface $SURF fill "#password" "secret"
cmux browser --surface $SURF click "#submit"
cmux browser --surface $SURF wait --url-contains "/dashboard"
```

### Automate a React (or Vue/Angular) form

`fill` and `type` won't work on framework-controlled inputs — they set the DOM value but never fire the synthetic events the framework listens to. Use `eval` with the native property setter instead:

```bash
SURF=surface:X

# Set values into React controlled inputs
cmux browser --surface $SURF eval "
  function setReactValue(sel, val) {
    var el = document.querySelector(sel);
    Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value')
      .set.call(el, val);
    el.dispatchEvent(new Event('input', { bubbles: true }));
    el.dispatchEvent(new Event('change', { bubbles: true }));
  }
  setReactValue('#email', 'user@example.com');
  setReactValue('#password', 'secret');
"

# Verify the framework picked up the values
cmux browser --surface $SURF eval "document.querySelector('#email').value"

# Submit normally
cmux browser --surface $SURF click "#submit"
cmux browser --surface $SURF wait --url-contains "/dashboard"
```

### Read terminal output from another pane

```bash
cmux read-screen --surface surface:2 --lines 50
```

### Track task progress in the sidebar

```bash
cmux set-status task "running" --color "#f59e0b"
cmux set-progress 0.0 --label "starting"
# ... do work ...
cmux set-progress 0.5 --label "halfway"
# ... finish ...
cmux set-progress 1.0 --label "done"
cmux clear-progress
cmux set-status task "done" --color "#22c55e"
cmux log "Task complete" --level success
```

### Open a plan doc in a viewer split

```bash
cmux markdown open .planning/PLAN.md
```

### Check if running inside cmux

```bash
test -S "${CMUX_SOCKET_PATH:-/tmp/cmux.sock}" && echo "in cmux" || echo "not in cmux"
```

---

## Environment Variables

| Variable               | Description                                                                    |
| ---------------------- | ------------------------------------------------------------------------------ |
| `CMUX_WORKSPACE_ID`    | Auto-set in cmux terminals; default `--workspace` for all commands             |
| `CMUX_SURFACE_ID`      | Auto-set in cmux terminals; default `--surface` for all commands               |
| `CMUX_TAB_ID`          | Auto-set; used as default `--tab` for tab-action/rename-tab                    |
| `CMUX_SOCKET_PATH`     | Override socket path (default: `~/Library/Application Support/cmux/cmux.sock`) |
| `CMUX_SOCKET_PASSWORD` | Auth password for the socket                                                   |
