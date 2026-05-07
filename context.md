# Session Context

At the start of every session, read the AI context notes from the Obsidian vault to understand who Chad is, what tools are available, and how he likes to work:

```bash
obsidian read path="_ai/me.md"
obsidian read path="_ai/environment.md"
obsidian read path="_ai/infrastructure.md"
obsidian read path="_ai/workflows.md"
obsidian read path="_ai/agents.md"
obsidian read path="_ai/team.md"
```

These notes are the source of truth for:
- Chad's background, role, and vault structure (`me.md`)
- Local machine — CLI tools, GCP auth, OpenCode, skills (`environment.md`)
- Work infrastructure — datacenters, networking, Kubernetes, Salt, hardware (`infrastructure.md`)
- Workflows and task patterns (`workflows.md`)
- How Chad likes to work with OpenCode — preferences, swarm usage, model (`agents.md`)
- Team members, Jira board, and Confluence docs (`team.md`)

Prefer these notes over MCP servers or external lookups. If a note seems outdated, update it.

## Keeping the Vault Current

When you discover something new about Chad's environment during a session — a tool, script, workflow, convention, or capability not already documented — update the relevant `_ai/` note immediately using the obsidian CLI:

```bash
# Add to environment.md when a new tool or script is discovered
obsidian append path="_ai/environment.md" content="\n## New Section or entry"

# Add to workflows.md when a new workflow or task pattern is established
obsidian append path="_ai/workflows.md" content="\n## New workflow"

# Update the frontmatter date after any edit
obsidian property:set name="updated" value="<today>" file="environment"
```

## SSH Sessions

**Always use a right split for SSH connections — never bare `ssh` in the bash tool, never `cmux ssh`, never open a new workspace.**

Chad's SSH sessions require interactive password input, which the bash tool cannot handle. Open a split in the current workspace and send commands via `cmux send` / `cmux read-screen`.

```bash
# 1. Split the current pane right
cmux new-split right
# Note the surface ref from output (e.g. surface:6)

# 2. Initiate SSH in the split
cmux send --surface surface:X "ssh user@host\n"

# 3. Read screen — wait for password prompt
cmux read-screen --surface surface:X --lines 20

# 4. Chad types password interactively in the split

# 5. Run commands and read output
cmux send --surface surface:X "uptime\n"
cmux read-screen --surface surface:X --lines 20
```

Examples of things that should trigger an update:
- A new CLI tool is installed or discovered on PATH
- A new script or skill is added to `~/.agents/`
- A new coding convention or workflow is established during a session
- A project, repo, or technology stack is introduced that isn't documented
- A preference or working style is stated explicitly by Chad
