# dot-agents

AI configuration for Claude Code and OpenCode — agents, commands, skills, and plugins.

Cloned to `~/.agents` and symlinked into `~/.claude` and `~/.config/opencode` by `setup.sh`.

## Structure

```
~/.agents/
├── agents/       # Custom agent definitions (Claude Code + OpenCode)
├── commands/     # Slash commands (/shipit, /test, ...)
├── skills/       # Language/domain skills loaded on demand
└── setup.sh      # Idempotent install script
```

## Setup

```sh
git clone git@github.com:chadleeshaw/dot-opencode.git ~/.agents
~/.agents/setup.sh
```

`setup.sh` symlinks everything into place. Safe to re-run.

## Agents

Agents in `agents/` use Claude Code frontmatter (`name`, `description`, `model`, `tools`) with `mode: subagent` added for OpenCode compatibility. Claude Code is the primary target.

| Agent | Purpose |
|---|---|
| `architect` | Analyze and improve workflows, processes, and system design |
| `bug-finder` | Identify logic errors and potential issues |
| `code-review` | Code review focused on readability and security |
| `documentation` | Write clear, concise README and docs files |
| `domain-modeling` | Build and sharpen a project's domain model |
| `grill-me` | Delegate to `/grilling` for stress-testing a plan |
| `grill-with-docs` | Stress-test a plan and write ADRs as you go |
| `grilling` | Interview the user relentlessly about a plan or design |
| `optimizer` | Analyze runtime performance and identify bottlenecks |
| `refactor` | Improve readability and maintainability |
| `test-coverage` | Audit tests for coverage gaps and quality issues |
| `test-writer` | Write readable, maintainable tests for existing code |

## Commands

Slash commands in `commands/` work in both Claude Code and OpenCode.

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

