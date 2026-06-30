# dot-agents

AI configuration for Claude Code — agents, commands, and skills.

Cloned to `~/.agents` and symlinked into `~/.claude` by `setup.sh`.

## Structure

```
~/.agents/
├── agents/       # Custom agent definitions
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

Agents in `agents/` use Claude Code frontmatter (`name`, `description`, `model`, `tools`).

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

Slash commands in `commands/` are invoked manually with `/name`.

| Command | Purpose |
|---|---|
| `/context` | Load AI context notes from Obsidian (_ai/me, environment, infrastructure, workflows, team) |
| `/review` | Review staged and unstaged changes against applicable coding skills and best practices |
| `/shipit` | Stage, commit, and push changes with an auto-generated message |
| `/simplify` | Refactor selected code for clarity and simplicity |
| `/test` | Run linting and tests, auto-fix where possible |
| `/zoom-out` | Step back for a higher-level perspective on the current code |

## Skills

Skills in `skills/` are auto-triggered when a task matches their domain.

| Skill | Loaded for |
|---|---|
| `caveman` | Ultra-compressed communication mode |
| `css` | CSS best practices |
| `golang` | Go best practices |
| `html` | HTML best practices |
| `incus` | Incus container and VM management via CLI |
| `javascript` | JS/TS best practices |
| `kubernetes` | kubectl, pods, deployments, ArgoCD, helmfile, and Kafka on k8s |
| `obsidian` | Obsidian notes and knowledge management |
| `python` | Python best practices |
| `saltstack` | SaltStack states, formulas, pillar, and configuration management |
| `terraform` | Terraform HCL, modules, and infrastructure as code |
| `zoom-out` | Higher-level perspective on current code or problem |
