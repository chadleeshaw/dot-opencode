# dot-opencode

OpenCode AI configuration — agents, commands, skills, plugins, and scripts.

Cloned to `~/.agents` and symlinked into `~/.config/opencode` by `setup.sh`.

## Structure

```
~/.agents/
├── agents/       # Custom agent definitions
├── commands/     # Slash commands (/shipit, /test, ...)
├── skills/       # Language/domain skills loaded on demand
├── plugins/      # OpenCode JS plugins
└── setup.sh      # Idempotent install script
```

## Setup

```sh
git clone git@github.com:chadleeshaw/dot-opencode.git ~/.agents
~/.agents/setup.sh
```

`setup.sh` symlinks everything into place and adds scripts to `~/.local/bin`. Safe to re-run.

## Agents

Custom agents in `agents/` extend OpenCode's built-in agent types.

| Agent | Purpose |
|---|---|
| `architect` | Analyze and improve workflows, processes, and system design |
| `bug-finder` | Identify logic errors and potential issues |
| `code-review` | Code review focused on readability and security |
| `documentation` | Write clear, concise README and docs files |
| `optimizer` | Analyze runtime performance and identify bottlenecks |
| `refactor` | Improve readability and maintainability |
| `test-coverage` | Audit tests for coverage gaps and quality issues |
| `test-writer` | Write readable, maintainable tests for existing code |
| `grill-me` | Interview the user relentlessly about a plan or design until reaching shared understanding |

## Commands

Slash commands in `commands/` are available inside any OpenCode session.

| Command | Purpose |
|---|---|
| `/context` | Load AI context notes from Obsidian (_ai/me, environment, conventions) |
| `/review` | Review staged and unstaged changes against applicable coding skills and best practices |
| `/shipit` | Stage, commit, and push changes with an auto-generated message |
| `/simplify` | Refactor selected code for clarity and simplicity |
| `/test` | Run tests and fix failures |

## Skills

Skills in `skills/` are loaded on demand when a task matches their domain.

| Skill | Loaded for |
|---|---|
| `cmux` | cmux terminal multiplexer — workspaces, browser automation, notifications |
| `golang` | Go best practices |
| `incus` | Incus container and VM management via CLI |
| `javascript` | JS/TS best practices |
| `python` | Python best practices |
| `css` | CSS best practices |
| `html` | HTML best practices |
| `kubernetes` | kubectl, pods, deployments, ArgoCD, helmfile, and Kafka on k8s |
| `obsidian` | Obsidian notes and knowledge management |
| `saltstack` | SaltStack states, formulas, pillar, and configuration management |
| `terraform` | Terraform HCL, modules, and infrastructure as code |

## Plugins

| Plugin | Purpose |
|---|---|
| `cmux-feed.js` | Bridges OpenCode plugin events to the cmux socket feed |
| `cmux-notify.js` | Sends a cmux notification ring when OpenCode goes idle or errors |
| `cmux-session.js` | Bridges OpenCode session lifecycle events into cmux's restorable session store |
