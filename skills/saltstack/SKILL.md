---
name: saltstack
description: >
  Expert SaltStack assistance for writing, debugging, and architecting Salt configurations.
  Use this skill whenever the user asks about SaltStack, Salt states, Salt formulas, pillar
  data, Jinja templating in Salt, the Salt master/minion setup, execution modules, grains,
  mine functions, orchestration, GitFS, or any salt-* CLI commands. Also trigger for questions
  about converting shell scripts or Ansible playbooks to Salt states, troubleshooting
  `state.apply` failures, designing pillar hierarchies, or writing Salt runners and reactors.
  If the user mentions `.sls` files, `top.sls`, `map.jinja`, `salt-call`, `salt-run`,
  `saltenv`, or anything that smells like Salt configuration management — use this skill.
---

# SaltStack Skill

You are an expert SaltStack practitioner. Help the user write, debug, and architect Salt
configurations. Always produce idiomatic, production-quality Salt code with clear explanations.

## Quick Reference: When to Load Reference Files

| Topic | Load |
|---|---|
| State authoring, requisites, Jinja | Inline below — no extra file needed |
| Pillar design, top.sls targeting | `references/pillars.md` |
| Formula structure, map.jinja | `references/formulas.md` |
| GitFS, fileserver backends | `references/gitfs.md` |
| Execution/state modules, grains, mine | `references/modules.md` |
| Orchestration, runners, reactors, beacons | `references/orchestration.md` |
| Troubleshooting, debugging, test=True | `references/troubleshooting.md` |

Read the relevant reference file before answering complex questions in those areas.
For simple state-writing tasks the inline content below is sufficient.

---

## Core Concepts (Inline)

### State File Structure

```yaml
# states/nginx/init.sls
nginx_package:
  pkg.installed:
    - name: nginx

nginx_service:
  service.running:
    - name: nginx
    - enable: True
    - require:
      - pkg: nginx_package
    - watch:
      - file: nginx_config

nginx_config:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://nginx/files/nginx.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
```

### Requisites Cheat Sheet

| Requisite | Direction | Behavior |
|---|---|---|
| `require` | before | Don't run me until X succeeds |
| `watch` | before | Run me if X changes (triggers mod_watch) |
| `require_in` | after | Make X require me |
| `watch_in` | after | Make X watch me |
| `onchanges` | before | Only run me if X changed |
| `onfail` | before | Only run me if X failed |
| `use` | — | Inherit another state's args |
| `prereq` | after | Run me before X if X would change |

### Jinja in States

```jinja
{# Load grains and pillar #}
{% set os = grains['os'] %}
{% set pkg_name = pillar.get('nginx:package', 'nginx') %}

{# Conditional logic #}
{% if grains['os_family'] == 'RedHat' %}
  {# RHEL-specific config #}
{% elif grains['os_family'] == 'Debian' %}
  {# Debian-specific config #}
{% endif %}

{# Loop over pillar list #}
{% for user in pillar.get('users', []) %}
user_{{ user.name }}:
  user.present:
    - name: {{ user.name }}
    - shell: {{ user.get('shell', '/bin/bash') }}
{% endfor %}

{# Safe default with nested key #}
{% set timeout = salt['pillar.get']('app:timeout', 30) %}
```

### top.sls Basics

```yaml
# top.sls
base:
  '*':
    - common

  'role:webserver':
    - match: grain
    - nginx
    - php

  'os_family:RedHat':
    - match: grain
    - rhel_base

  'G@role:database and G@env:prod':
    - match: compound
    - postgres
    - postgres.backup

  'db*':
    - postgres
```

### Common Targeting Methods

| Flag | Description | Example |
|---|---|---|
| (none) | Glob on minion ID | `salt 'web*' ...` |
| `-G` | Grain | `salt -G 'role:web' ...` |
| `-I` | Pillar | `salt -I 'app:name:myapp' ...` |
| `-L` | List | `salt -L 'web1,web2' ...` |
| `-C` | Compound | `salt -C 'G@role:web and not web3' ...` |
| `-N` | Nodegroup | `salt -N webservers ...` |
| `-E` | PCRE regex | `salt -E 'web[0-9]+' ...` |

---

## Output Style Guidelines

- **Always show complete, runnable `.sls` files** — no pseudocode.
- **Include ID declarations** that are descriptive and unique within the state.
- **Use `pillar.get` with defaults** rather than bare `pillar['key']` to avoid KeyErrors.
- **Explain requisites** when the relationship isn't obvious.
- **Prefer `file.managed` with Jinja templates** over inline `contents:` for anything non-trivial.
- **Always include `test=True` advice** when suggesting state changes that affect running services.
- When writing formulas, always read `references/formulas.md` first.
- When designing pillar structure, always read `references/pillars.md` first.

---

## Common CLI Commands

```bash
# Apply states
salt '*' state.apply
salt 'minion-id' state.apply nginx
salt 'minion-id' state.apply nginx test=True

# Single state function
salt '*' state.single service.running name=nginx

# Run execution module
salt '*' cmd.run 'systemctl status nginx'
salt '*' pkg.list_upgrades
salt '*' grains.items

# Sync custom modules/grains/states to minions
salt '*' saltutil.sync_all

# Refresh pillar
salt '*' saltutil.refresh_pillar

# Orchestration
salt-run state.orchestrate orch.deploy

# Event bus (debug)
salt-run state.event pretty=True

# Test pillar render
salt 'minion-id' pillar.items
salt 'minion-id' pillar.get app:config

# Test Jinja rendering
salt 'minion-id' slsutil.renderer states/mystate.sls
```

---

## Gotchas & Best Practices

1. **State ID uniqueness** — IDs must be unique across all included states in a run. Prefix with module name to avoid collisions (`nginx_config`, not just `config`).

2. **`require` vs `watch`** — `watch` implies `require`. Don't list both. Use `watch` only when you need `mod_watch` behavior (e.g., `service.running` restarting on config change).

3. **Pillar KeyError** — `pillar['key']` raises an error if missing. Always use `pillar.get('key', default)` or `salt['pillar.get']('nested:key', default)`.

4. **`__opts__['test']`** — Check this in custom modules to respect `test=True` runs.

5. **Jinja whitespace** — Use `{%- -%}` to strip whitespace around blocks and avoid blank lines in rendered YAML.

6. **`include:` order** — `include:` does not guarantee order; use requisites to enforce sequencing.

7. **`file.managed` atomicity** — Files are written to a temp path and moved atomically. Avoid writing to files that other processes hold open.

8. **Grains caching** — Grains are cached on the master. Force refresh with `salt '*' saltutil.sync_grains` or `salt '*' grains.items`.

9. **Pillar rendering errors** — A broken pillar renders as `{}` for that minion silently. Always check `salt 'minion' pillar.items` after changes.

10. **`state.apply` vs `state.highstate`** — They're equivalent. `state.apply` with no args = highstate; with args = apply named SLS.
