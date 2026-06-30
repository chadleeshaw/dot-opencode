---
name: obsidian
description: Obsidian second brain - notes, dashboards, tasks, and knowledge management via CLI
license: MIT
---

# Obsidian — Chad's Vault

Delegate to the official sub-skills for all technical detail:

| Skill | Use for |
|---|---|
| `obsidian:obsidian-cli` | CLI commands — read, create, search, tasks, properties, daily notes |
| `obsidian:obsidian-markdown` | Obsidian-flavored markdown — wikilinks, callouts, embeds, frontmatter |
| `obsidian:obsidian-bases` | `.base` files — table/card views, filters, formulas |
| `obsidian:json-canvas` | `.canvas` files — visual maps, flowcharts, node graphs |
| `obsidian:defuddle` | Fetch web URLs as clean markdown (use instead of WebFetch for articles/docs) |

## Vault

- **Name:** Notes
- **Path:** `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Notes`
- **Target with:** `vault=Notes` if needed

## Orient first

Before acting, read the relevant `_ai/` context note:

```bash
obsidian read file="environment"    # tools, auth, machine
obsidian read file="infrastructure" # k8s, GCP, Vault
obsidian read file="team"           # repos, CI/CD
obsidian read file="workflows"      # how we work
```

Then orient to the vault if needed:

```bash
obsidian folders
obsidian recents
```

## Key structure

| Folder | Purpose |
|---|---|
| `_ai/` | Agent context — environment, team, infrastructure, workflows |
| `_ai/tools/` | Tool-specific notes (kafka, kubefwd, mrmeseeks, etc.) |
| `work/` | Work notes |
| `programming/` | Dev references |
| `_archive/` | Old notes |

## Frontmatter conventions

```yaml
type: note|project|meeting|reference|dashboard|ai-context
status: active|someday|done|archived
```
