# Pillar Architecture Reference

## Directory Structure

```
pillar/
├── top.sls
├── common/
│   └── init.sls
├── roles/
│   ├── webserver.sls
│   ├── database.sls
│   └── monitoring.sls
├── apps/
│   ├── nginx/
│   │   └── init.sls
│   └── postgres/
│       └── init.sls
└── secrets/
    └── credentials.sls   # gitignored or managed via ext_pillar
```

## top.sls Patterns

```yaml
base:
  # Everyone gets common pillar
  '*':
    - common

  # Role-based pillar via grain
  'role:webserver':
    - match: grain
    - roles.webserver
    - apps.nginx

  # Environment-specific
  'env:prod':
    - match: grain
    - environments.prod

  # Compound: role + env
  'G@role:database and G@env:staging':
    - match: compound
    - roles.database
    - environments.staging
```

## Pillar File Structure

```yaml
# pillar/apps/nginx/init.sls
nginx:
  package: nginx
  version: latest
  service: nginx

  config:
    worker_processes: auto
    worker_connections: 1024
    keepalive_timeout: 65

  vhosts:
    - name: example.com
      port: 80
      root: /var/www/example.com
      ssl: False

    - name: secure.example.com
      port: 443
      root: /var/www/secure
      ssl: True
      cert: /etc/ssl/certs/example.pem
      key: /etc/ssl/private/example.key
```

## Merging Behavior

Salt merges pillar data with `pillar_source_merging_strategy` (default: `smart`).

```yaml
# master config
pillar_source_merging_strategy: smart   # recursive merge (default)
# Options: smart | aggregate | recurse | overwrite
```

**`recurse`** — deep merge dicts, later sources override scalar values:
```yaml
# Source 1:           # Source 2:           # Result:
nginx:                nginx:                nginx:
  port: 80              ssl: True             port: 80
  timeout: 30           timeout: 60           ssl: True
                                              timeout: 60   # overridden
```

**`aggregate`** — uses `yamlex` tags for explicit merge control (advanced).

**`overwrite`** — later sources completely replace earlier ones at the top level.

## ext_pillar — External Pillar Sources

```yaml
# master config
ext_pillar:
  # From a command output
  - cmd_yaml: /srv/pillar/scripts/generate_secrets.sh

  # From Vault
  - vault: path=secret/data/{{ minion_id }}

  # From a database
  - mysql:
      query: "SELECT `key`, `value` FROM pillar WHERE minion='%s'"
      host: localhost
      db: salt
      user: salt
      pass: secret
```

## Pillar Encryption (GPG)

```yaml
# pillar/secrets/db.sls
database:
  password: |
    -----BEGIN PGP MESSAGE-----
    [encrypted block]
    -----END PGP MESSAGE-----
```

```yaml
# master config
decrypt_pillar:
  - 'database:password': gpg

gpg_keydir: /etc/salt/gpgkeys
```

## Accessing Pillar in States

```jinja
{# Safe nested access with default #}
{% set db_host = salt['pillar.get']('database:host', 'localhost') %}
{% set db_port = salt['pillar.get']('database:port', 5432) %}

{# In state file #}
db_config:
  file.managed:
    - name: /etc/myapp/db.conf
    - contents: |
        host={{ salt['pillar.get']('database:host', 'localhost') }}
        port={{ salt['pillar.get']('database:port', 5432) }}
        name={{ pillar['database']['name'] }}
```

## Pillar Debugging

```bash
# Show all pillar for a minion
salt 'minion-id' pillar.items

# Show specific key
salt 'minion-id' pillar.get database:password

# Check what SLS files are contributing
salt 'minion-id' pillar.show_top

# Force refresh after changes
salt '*' saltutil.refresh_pillar

# Diagnose render errors (check for {})
salt 'minion-id' pillar.items 2>&1 | grep -E "ERROR|empty"
```

## Common Mistakes

- **Returning `{}`**: Pillar rendering failed silently — check `pillar.items` for errors, check Jinja syntax
- **Mutable defaults in Jinja**: `{% set config = pillar.get('app', {}) %}` — the `{}` is safe, but mutating it affects all renders in session; always use `pillar.get()` directly
- **Forgetting to refresh**: After editing pillar files, run `saltutil.refresh_pillar` before `state.apply`
- **Top file not matching**: Test with `pillar.show_top` to verify what's being included for each minion
