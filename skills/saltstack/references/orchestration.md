# Orchestration, Runners, Reactors & Beacons Reference

## Orchestration States

Orchestration runs on the master via `salt-run state.orchestrate` and coordinates actions across many minions with explicit ordering.

```yaml
# orch/deploy.sls

# Step 1: Run DB migrations on database minion
run_migrations:
  salt.state:
    - tgt: 'role:database'
    - tgt_type: grain
    - sls:
      - myapp.migrate
    - pillar:
        myapp:
          version: {{ pillar.get('deploy:version') }}

# Step 2: Deploy to app servers (only after migrations succeed)
deploy_app:
  salt.state:
    - tgt: 'role:appserver'
    - tgt_type: grain
    - sls:
      - myapp.deploy
    - batch: '25%'            # rolling deploy — 25% at a time
    - pillar:
        myapp:
          version: {{ pillar.get('deploy:version') }}
    - require:
      - salt: run_migrations

# Step 3: Reload load balancer
reload_lb:
  salt.function:
    - name: service.reload
    - tgt: 'role:loadbalancer'
    - tgt_type: grain
    - arg:
      - nginx
    - require:
      - salt: deploy_app

# Step 4: Run a runner
notify_deploy:
  salt.runner:
    - name: slack.post_message
    - channel: '#deploys'
    - message: 'Deploy complete: {{ pillar.get("deploy:version") }}'
    - require:
      - salt: reload_lb
```

```bash
# Run orchestration
salt-run state.orchestrate orch.deploy pillar='{"deploy": {"version": "1.2.3"}}'

# Dry run
salt-run state.orchestrate orch.deploy test=True

# With timeout
salt-run state.orchestrate orch.deploy timeout=300
```

## salt.function vs salt.state vs salt.runner

| Directive | What it does |
|---|---|
| `salt.state` | Apply SLS states to target minions |
| `salt.function` | Run an execution module function on minions |
| `salt.runner` | Run a runner function on the master |
| `salt.wheel` | Run a wheel module on the master |
| `salt.wait_for_event` | Block until an event fires on the event bus |

## Custom Runners

```python
# _runners/deploy.py — runs on the master

"""
Custom runner for deployment operations.
"""

import salt.client


def rollback(service, version, tgt='*'):
    """
    Roll back a service to a previous version.
    
    CLI Example:
        salt-run deploy.rollback myapp 1.1.0 'role:appserver'
    """
    client = salt.client.LocalClient()
    
    result = client.cmd(
        tgt,
        'state.apply',
        ['myapp.deploy'],
        kwarg={'pillar': {'myapp': {'version': version}}},
        tgt_type='grain' if ':' in tgt else 'glob',
        timeout=120,
    )
    
    failed = [m for m, r in result.items() if not r]
    if failed:
        return {'success': False, 'failed_minions': failed}
    
    return {'success': True, 'rolled_back_to': version}
```

```bash
# Use the custom runner
salt '*' saltutil.sync_runners
salt-run deploy.rollback myapp 1.1.0 'role:appserver'
```

## Reactor System

Reactors listen on the event bus and trigger actions in response to events.

```yaml
# master config
reactor:
  # React to minion start
  - 'salt/minion/*/start':
    - /srv/salt/reactor/minion_start.sls

  # React to custom events
  - 'myapp/deploy/request':
    - /srv/salt/reactor/handle_deploy.sls

  # React to grain changes
  - 'salt/minion/*/data':
    - /srv/salt/reactor/grain_sync.sls
```

```jinja
{# reactor/minion_start.sls #}
{# data is the event data dict #}

sync_new_minion:
  local.state.apply:
    - tgt: {{ data['id'] }}
    - arg:
      - common
    - kwarg:
        pillar:
          bootstrap: True

highstate_new_minion:
  local.state.highstate:
    - tgt: {{ data['id'] }}
    - require:
      - local: sync_new_minion
```

```jinja
{# reactor/handle_deploy.sls — reacting to a custom event #}

{% if data.get('env') == 'prod' %}
run_prod_deploy:
  runner.state.orchestrate:
    - args:
      - mods: orch.deploy
      - pillar:
          deploy:
            version: {{ data['version'] }}
            env: prod
{% endif %}
```

### Firing Custom Events

```bash
# From master CLI
salt-run event.fire '{"version": "1.2.3", "env": "prod"}' 'myapp/deploy/request'

# From a minion (execution module)
salt '*' event.fire_master '{"status": "ready"}' 'myapp/ready'
```

```python
# From Python (master-side)
import salt.utils.event

event = salt.utils.event.get_event('master', sock_dir='/var/run/salt/master')
event.fire_event({'version': '1.2.3', 'env': 'prod'}, 'myapp/deploy/request')
```

## Beacons

Beacons run on minions and watch for system events, firing events to the master.

```yaml
# minion config or pillar/state
beacons:
  # Watch a file for changes
  inotify:
    - files:
        /etc/myapp/config.yaml:
          mask:
            - modify
            - delete
    - interval: 10

  # Monitor disk usage
  diskusage:
    - /: 90%
    - /var: 85%
    - interval: 60

  # Watch for process crashes
  service:
    - services:
        nginx:
          running: True
    - interval: 30

  # Monitor load average
  load:
    - averages:
        1m:
          - 0.0
          - 2.0
        5m:
          - 0.0
          - 1.5
    - interval: 60

  # Network connectivity
  network_settings:
    - interfaces:
        eth0:
          ip_settings:
            changed: True
    - interval: 30
```

```yaml
# React to beacon events in reactor
reactor:
  - 'salt/beacon/*/diskusage/*':
    - /srv/salt/reactor/disk_alert.sls
  - 'salt/beacon/*/service/nginx':
    - /srv/salt/reactor/restart_nginx.sls
```

```bash
# Enable/disable beacons at runtime
salt 'minion' beacons.add inotify '[{files: {/etc/myapp: {mask: [modify]}}}]'
salt 'minion' beacons.list
salt 'minion' beacons.disable inotify
salt 'minion' beacons.reset
```

## Event Bus Monitoring

```bash
# Watch all events (essential for debugging reactors/beacons)
salt-run state.event pretty=True

# Filter by tag prefix
salt-run state.event tagmatch='salt/minion/*/start' pretty=True
salt-run state.event tagmatch='myapp/*' pretty=True

# From Python
salt-run state.event count=10  # capture 10 events and exit
```
