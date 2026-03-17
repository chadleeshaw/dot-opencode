# Formula Structure & map.jinja Reference

## Standard Formula Layout

```
formula-name/
├── FORMULA                    # metadata (name, version, description)
├── README.rst
├── formula-name/
│   ├── init.sls               # main entry point
│   ├── install.sls            # package installation
│   ├── config.sls             # configuration management
│   ├── service.sls            # service management
│   ├── map.jinja              # OS/grain abstraction layer
│   ├── defaults.yaml          # default values (with map.jinja v2)
│   └── files/
│       ├── default/
│       │   └── config.conf.jinja
│       └── RedHat/
│           └── config.conf.jinja
├── pillar.example
└── test/
    └── salt/
        └── minion
```

## map.jinja — Classic Pattern

Used to abstract OS-specific differences. Always import at the top of states that need it.

```jinja
{# formula-name/map.jinja #}
{% set os_map = salt['grains.filter_by']({
    'Debian': {
        'pkg': 'nginx',
        'service': 'nginx',
        'conf_dir': '/etc/nginx',
        'log_dir': '/var/log/nginx',
        'user': 'www-data',
    },
    'RedHat': {
        'pkg': 'nginx',
        'service': 'nginx',
        'conf_dir': '/etc/nginx',
        'log_dir': '/var/log/nginx',
        'user': 'nginx',
    },
    'Arch': {
        'pkg': 'nginx',
        'service': 'nginx',
        'conf_dir': '/etc/nginx',
        'log_dir': '/var/log/nginx',
        'user': 'http',
    },
}, grain='os_family', default='Debian') %}

{# Merge with pillar overrides — pillar always wins #}
{% do os_map.update(pillar.get('nginx', {})) %}
```

```jinja
{# Using map.jinja in a state file #}
{% from "nginx/map.jinja" import os_map as nginx with context %}

nginx_pkg:
  pkg.installed:
    - name: {{ nginx.pkg }}

nginx_service:
  service.running:
    - name: {{ nginx.service }}
    - enable: True
```

## map.jinja — Modern Pattern (v2, recommended for new formulas)

Uses `defaults.yaml` + `parameters/` directory for cleaner separation.

```yaml
# nginx/defaults.yaml
nginx:
  pkg: nginx
  service: nginx
  conf_dir: /etc/nginx
  user: nginx
```

```jinja
{# nginx/map.jinja (v2) #}
{% import_yaml tpldir + "/defaults.yaml" as defaults %}

{% set nginx = salt['grains.filter_by']({
    'Debian': {'user': 'www-data'},
    'RedHat': {'user': 'nginx'},
}, grain='os_family', merge=defaults.get('nginx', {})) %}

{% do nginx.update(pillar.get('nginx', {})) %}
```

## init.sls Pattern

Keep `init.sls` as an orchestrator — include sub-states, don't put logic here.

```yaml
# nginx/init.sls
include:
  - nginx.install
  - nginx.config
  - nginx.service
```

```yaml
# nginx/install.sls
{% from "nginx/map.jinja" import nginx with context %}

nginx_install:
  pkg.installed:
    - name: {{ nginx.pkg }}
    - version: {{ nginx.get('version', 'latest') }}
```

```yaml
# nginx/config.sls
{% from "nginx/map.jinja" import nginx with context %}

nginx_config_dir:
  file.directory:
    - name: {{ nginx.conf_dir }}
    - user: root
    - group: root
    - mode: '0755'

nginx_main_config:
  file.managed:
    - name: {{ nginx.conf_dir }}/nginx.conf
    - source:
      - salt://nginx/files/{{ grains['os_family'] }}/nginx.conf.jinja
      - salt://nginx/files/default/nginx.conf.jinja
    - template: jinja
    - context:
        nginx: {{ nginx | json }}
    - require:
      - file: nginx_config_dir
    - watch_in:
      - service: nginx_service
```

```yaml
# nginx/service.sls
{% from "nginx/map.jinja" import nginx with context %}

nginx_service:
  service.running:
    - name: {{ nginx.service }}
    - enable: True
    - require:
      - pkg: nginx_install
```

## Template Files

```jinja
{# nginx/files/default/nginx.conf.jinja #}
{# Context: nginx dict from map.jinja #}
user {{ nginx.user }};
worker_processes {{ nginx.get('worker_processes', 'auto') }};
pid /run/nginx.pid;

events {
    worker_connections {{ nginx.get('worker_connections', 1024) }};
}

http {
    keepalive_timeout {{ nginx.get('keepalive_timeout', 65) }};

    {% for vhost in nginx.get('vhosts', []) %}
    include {{ nginx.conf_dir }}/sites-enabled/{{ vhost.name }}.conf;
    {% endfor %}
}
```

## Source Fallback Pattern

Salt tries sources in order — use this for OS-specific files with a generic fallback:

```yaml
my_config:
  file.managed:
    - name: /etc/myapp/config
    - source:
      - salt://myformula/files/{{ grains['os'] }}/config.jinja
      - salt://myformula/files/{{ grains['os_family'] }}/config.jinja
      - salt://myformula/files/default/config.jinja
    - template: jinja
```

## FORMULA Metadata File

```yaml
name: nginx
os:
  Debian: bullseye, bookworm
  Ubuntu: focal, jammy
  CentOS: 7, 8
  Rocky: 8, 9
  RedHat: 7, 8, 9
os_family:
  Debian: null
  RedHat: null
version: 2.0.1
minimum_version: 3004
description: >
  Formula to configure the nginx web server.
```
