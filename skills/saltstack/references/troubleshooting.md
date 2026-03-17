# Troubleshooting & Debugging Reference

## Diagnostic Command Sequence

When a state fails or behaves unexpectedly, work through these in order:

```bash
# 1. Check connectivity
salt 'minion-id' test.ping

# 2. Dry run with verbose output
salt 'minion-id' state.apply mystate test=True

# 3. Apply single state with full output
salt 'minion-id' state.apply mystate -l debug 2>&1 | tee /tmp/salt-debug.log

# 4. Check pillar data (is it rendering correctly?)
salt 'minion-id' pillar.items

# 5. Check grains
salt 'minion-id' grains.items

# 6. Verify file is being served correctly
salt 'minion-id' cp.get_url salt://myformula/files/config.jinja /tmp/test-render

# 7. Render a Jinja template manually
salt 'minion-id' slsutil.renderer myformula/init.sls

# 8. Watch the event bus while running
# (In another terminal): salt-run state.event pretty=True tagmatch='salt/*'
salt 'minion-id' state.apply mystate
```

## Reading state.apply Output

```
# SUCCESS
pkg_|-nginx_install_|-nginx_|-installed:
  Result: True
  Comment: The following packages were installed/updated: nginx
  Changes:
    nginx: {new: 1.18.0, old: ''}

# FAILURE — read Comment carefully
file_|-nginx_config_|-/etc/nginx/nginx.conf_|-managed:
  Result: False
  Comment: Source file 'salt://nginx/files/nginx.conf.jinja' not found
  Changes: {}

# NO CHANGE (correct behavior)
service_|-nginx_service_|-nginx_|-running:
  Result: True
  Comment: The service nginx is already running
  Changes: {}

# SKIPPED due to failed requisite
service_|-nginx_service_|-nginx_|-running:
  Result: False
  Comment: One or more requisite failed: nginx.config.nginx_config
  Changes: {}
```

## Log Files & Levels

```bash
# Master log
tail -f /var/log/salt/master

# Minion log
tail -f /var/log/salt/minion

# Run with debug logging (very verbose)
salt 'minion' state.apply mystate -l debug

# On the minion directly (bypasses master)
salt-call state.apply mystate -l debug --local

# Log levels: quiet, critical, error, warning, info (default), debug, trace, garbage
```

## Jinja Template Debugging

```bash
# Render a state file to see what Jinja produces
salt 'minion' slsutil.renderer mystate/init.sls

# Check what a Jinja expression evaluates to
salt 'minion' grains.get os_family
salt 'minion' pillar.get myapp:config

# Use salt-call to test locally on the minion
ssh minion-id
salt-call slsutil.renderer salt://myformula/init.sls -l debug
```

```jinja
{# Add debug output to a template — shows in state output #}
{# Remove before production! #}
{{ "DEBUG: os_family=" + grains['os_family'] | yaml_encode }}
```

## Common Errors & Fixes

### `Source file not found`
```
Comment: Source file 'salt://nginx/files/nginx.conf.jinja' not found
```
- The file path is relative to `file_roots` / GitFS root
- Verify: `salt-run fileserver.file_list saltenv=base | grep nginx.conf`
- Check `fileserver_backend` order in master config
- Force GitFS update: `salt-run fileserver.update`

### `Rendering SLS failed`
```
Comment: Rendering SLS 'mystate/init.sls' failed: ...Jinja variable 'dict object' has no attribute 'X'
```
- A pillar key is missing. Use `pillar.get('key', default)` instead of `pillar['key']`
- Check with: `salt 'minion' pillar.items`
- Pillar may have failed to render — look for `{}` or missing keys

### `Requisite failed`
```
Comment: One or more requisite failed: mystate.install.pkg_name
```
- The dependency state failed — look earlier in the output for the actual error
- Check state ID spelling — IDs are case-sensitive
- `require` uses the full state ID: `{module}: {id}` or `{module}: {name}`

### Minion not responding
```
minion-id: No response from minion
```
- `ping` the minion: `salt 'minion-id' test.ping`
- Check minion service: `systemctl status salt-minion`
- Check master/minion clock skew: `salt 'minion-id' status.time`
- Check key is accepted: `salt-key -L`
- Check firewall: ports 4505 and 4506 must be open to master

### State runs but nothing changes
- Did the state file actually get updated? Check GitFS: `salt-run fileserver.update`
- Is `test=True` still set somewhere in the call?
- State ID collision — two states with the same ID; second one silently wins

### Pillar returns `{}`
- Pillar failed to render — check master log for errors
- `jinja2.exceptions.UndefinedError` in pillar SLS
- A pillar `include:` points to a non-existent file
- Check: `salt 'minion' pillar.items 2>&1 | head -50`

## salt-call — Run Directly on a Minion

```bash
# Run on the minion itself without going through master
# Useful for: testing before pushing, debugging locally, bootstrap scripts

ssh minion-id

# Apply a state using local file_roots
salt-call state.apply mystate --local

# Apply against master
salt-call state.apply mystate

# Debug mode
salt-call state.apply mystate -l debug

# Grains
salt-call grains.items

# Pillar
salt-call pillar.items

# Test a single state function
salt-call state.single pkg.installed name=nginx test=True
```

## Key Management

```bash
# List all keys
salt-key -L

# Accept a specific key
salt-key -a minion-id

# Accept all pending keys (careful in production!)
salt-key -A

# Delete a key (decommission minion)
salt-key -d minion-id

# Fingerprint — verify before accepting
salt-key -f minion-id          # from master
salt-call key.finger --local   # from minion
```

## Performance & Scale Debugging

```bash
# How long did a state run take?
salt 'minion' state.apply --out=json 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
for minion, states in data.items():
    for sid, result in states.items():
        if result.get('duration', 0) > 1000:
            print(f'{result[\"duration\"]:>8.0f}ms  {sid}')
" | sort -rn | head -20

# Batch large jobs to avoid overloading master
salt '*' state.apply mybigstate --batch=10 --batch-wait=5

# Async job — don't wait for result
salt --async '*' state.apply
salt-run jobs.lookup_jid <jid>   # check later
salt-run jobs.active              # see running jobs
```
