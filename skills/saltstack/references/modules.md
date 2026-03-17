# Execution Modules, State Modules, Grains & Mine Reference

## Execution Modules

Execution modules run on-demand via `salt '*' module.function`. Key built-ins:

```bash
# Package management
salt '*' pkg.install nginx
salt '*' pkg.remove nginx
salt '*' pkg.list_upgrades
salt '*' pkg.version nginx

# Service management
salt '*' service.status nginx
salt '*' service.start nginx
salt '*' service.restart nginx
salt '*' service.enable nginx

# File operations
salt '*' file.file_exists /etc/nginx/nginx.conf
salt '*' file.get_managed /tmp/test salt://nginx/files/nginx.conf
salt '*' cp.get_file salt://nginx/files/nginx.conf /tmp/nginx.conf

# Commands
salt '*' cmd.run 'df -h'
salt '*' cmd.run_all 'systemctl status nginx'

# Network
salt '*' network.interfaces
salt '*' network.ip_addrs

# System
salt '*' system.reboot
salt '*' status.diskusage
salt '*' status.meminfo

# User/group
salt '*' user.info root
salt '*' group.list_groups
```

## Calling Execution Modules from States

```yaml
# Run a command
run_migration:
  cmd.run:
    - name: /opt/app/migrate.sh
    - runas: appuser
    - cwd: /opt/app
    - env:
      - DATABASE_URL: {{ pillar['app']['db_url'] }}
    - onchanges:
      - file: app_release

# Use module.run (preferred over cmd.run for Salt modules)
sync_grains_after_setup:
  module.run:
    - name: saltutil.sync_grains
    - require:
      - pkg: salt_grains_package
```

## Grains

Grains are static/semi-static facts about a minion.

```bash
# List all grains
salt 'minion' grains.items

# Get specific grain
salt 'minion' grains.get os
salt 'minion' grains.get ip4_interfaces:eth0

# Set a custom grain
salt 'minion' grains.setval role webserver
salt 'minion' grains.setval roles ['webserver', 'monitoring']

# Delete a grain
salt 'minion' grains.delval role

# Sync custom grain modules
salt '*' saltutil.sync_grains
```

### Custom Grain Modules

```python
# _grains/custom_grains.py — placed in your state tree

def app_grains():
    """
    Custom grains for application metadata.
    """
    grains = {}
    
    try:
        with open('/etc/myapp/version') as f:
            grains['app_version'] = f.read().strip()
    except FileNotFoundError:
        grains['app_version'] = 'unknown'
    
    import subprocess
    result = subprocess.run(['hostname', '-f'], capture_output=True, text=True)
    if result.returncode == 0:
        grains['fqdn_custom'] = result.stdout.strip()
    
    return grains
```

```bash
# Deploy custom grains
salt '*' saltutil.sync_grains
salt '*' grains.items | grep app_version
```

### Grains in Targeting & States

```jinja
{# In states #}
{% if grains['os_family'] == 'RedHat' %}
  {# RHEL path #}
{% endif %}

{# Nested grain access #}
{% set primary_ip = grains['ip4_interfaces'].get('eth0', [''])[0] %}

{# In top.sls #}
'role:webserver':
  - match: grain
  - nginx
```

## Mine

Mine collects and shares data from minions so other minions can query it.

### Configuration

```yaml
# minion config  (or set via pillar/state)
mine_functions:
  network.ip_addrs:
    - interface: eth0
  grains.items: []
  
  # Custom function with alias
  my_ip:
    mine_function: network.ip_addrs
    interface: eth0
    cidr: 10.0.0.0/8
```

```yaml
# Set mine functions via pillar (preferred — no minion config change)
# pillar/mine.sls
mine_functions:
  network.ip_addrs:
    - interface: eth0
  disk.usage: []
```

```yaml
# Apply mine config via state
configure_mine:
  module.run:
    - name: mine.update
```

### Accessing Mine Data

```bash
# From master CLI
salt-run mine.get '*' network.ip_addrs
salt-run mine.get 'web*' my_ip

# From a minion (in states/Jinja)
{% set web_ips = salt['mine.get']('role:webserver', 'network.ip_addrs', tgt_type='grain') %}
```

```jinja
{# Use mine data in a config template #}
upstream backend {
{% for minion, ips in salt['mine.get']('role:appserver', 'network.ip_addrs', tgt_type='grain').items() %}
  {% for ip in ips %}
    server {{ ip }}:8080;
  {% endfor %}
{% endfor %}
}
```

```bash
# Refresh mine data immediately
salt '*' mine.update

# Clear mine data for a minion
salt 'minion' mine.delete

# List available mine functions
salt-run mine.get '*' '*'
```

## Custom Execution Modules

```python
# _modules/myapp.py — placed in your state tree

"""
Custom execution module for myapp management.
"""

import subprocess

__virtualname__ = 'myapp'


def __virtual__():
    """Only load on systems with myapp installed."""
    if __salt__['file.file_exists']('/usr/bin/myapp'):
        return __virtualname__
    return False, 'myapp binary not found'


def version():
    """Return the installed myapp version."""
    result = __salt__['cmd.run_all']('/usr/bin/myapp --version')
    if result['retcode'] == 0:
        return result['stdout'].strip()
    return None


def status(service_name='default'):
    """Return status dict for a myapp service."""
    result = __salt__['cmd.run_all'](
        '/usr/bin/myapp status {}'.format(service_name)
    )
    return {
        'running': result['retcode'] == 0,
        'output': result['stdout'],
    }
```

```bash
# Deploy and use custom module
salt '*' saltutil.sync_modules
salt '*' myapp.version
salt '*' myapp.status my-service
```

## Custom State Modules

```python
# _states/myapp.py

"""
Custom state module for myapp.
"""


def running(name, **kwargs):
    """
    Ensure a myapp service is running.
    """
    ret = {'name': name, 'changes': {}, 'result': True, 'comment': ''}
    
    current = __salt__['myapp.status'](name)
    
    if current['running']:
        ret['comment'] = 'myapp service {} is already running'.format(name)
        return ret
    
    if __opts__['test']:
        ret['result'] = None
        ret['comment'] = 'myapp service {} would be started'.format(name)
        return ret
    
    result = __salt__['myapp.start'](name)
    if result:
        ret['changes'] = {'started': name}
        ret['comment'] = 'Started myapp service {}'.format(name)
    else:
        ret['result'] = False
        ret['comment'] = 'Failed to start myapp service {}'.format(name)
    
    return ret
```
