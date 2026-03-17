# GitFS & Fileserver Backends Reference

## Master Configuration

```yaml
# /etc/salt/master

# Enable GitFS backend (order matters — first match wins)
fileserver_backend:
  - gitfs        # Check git repos first
  - roots        # Fall back to local /srv/salt

# GitFS remotes
gitfs_remotes:
  - https://github.com/myorg/salt-states.git
  - https://github.com/myorg/salt-formulas.git:
    - name: formulas
    - mountpoint: salt://formulas    # available as salt://formulas/...
    - root: formulas                  # only serve from this subdir in repo
  - git@github.com:myorg/private-states.git:
    - name: private
    - saltenv:
      - base:
        - ref: main
      - staging:
        - ref: staging
      - prod:
        - ref: production

# GitFS global defaults
gitfs_provider: pygit2              # or gitpython
gitfs_base: main                    # default branch → base env
gitfs_update_interval: 60           # seconds between fetches
gitfs_ssl_verify: True
```

## Branch → saltenv Mapping

By default, each git branch maps to a saltenv of the same name. `main` (or `master`) maps to `base`.

| Branch | saltenv |
|--------|---------|
| `main` | `base` |
| `staging` | `staging` |
| `production` | `production` |
| `feature/xyz` | `feature_xyz` (slashes → underscores) |

Override with explicit `saltenv` mapping in the remote config (see above).

## Per-Remote Configuration

```yaml
gitfs_remotes:
  - https://github.com/myorg/salt.git:
    - name: main-states           # unique name for this remote
    - saltenv:
      - base:
        - ref: main               # branch/tag/commit for base env
    - root: states                # serve only from states/ subdir
    - mountpoint: salt://         # where it appears in salt://
    - update_interval: 30
    - ssl_verify: True
    - pubkey: /etc/salt/ssh/id_rsa.pub
    - privkey: /etc/salt/ssh/id_rsa
    - passphrase: ''
```

## Pillar GitFS (git_pillar)

```yaml
# master config
ext_pillar:
  - git:
    - main https://github.com/myorg/salt-pillar.git:
      - name: pillar-main
      - root: pillar
    - staging https://github.com/myorg/salt-pillar.git:
      - name: pillar-staging
      - saltenv: staging

git_pillar_provider: pygit2
git_pillar_update_interval: 60
git_pillar_ssl_verify: True
```

## Fileserver Backend Priority

```yaml
fileserver_backend:
  - roots     # local /srv/salt (highest priority)
  - gitfs     # git repos
  - s3        # S3 bucket (requires boto)
```

Files are served from the **first backend** that has a match. To override a GitFS file locally, put it in `roots` and list `roots` first.

## saltenv Usage

```bash
# Apply states from a specific environment
salt '*' state.apply mystate saltenv=staging

# Show files in an environment
salt '*' cp.list_master saltenv=staging

# target top.sls per env
salt -C 'G@saltenv:staging' state.apply saltenv=staging
```

```yaml
# Minion config — pin a minion to an environment
saltenv: staging

# Or set dynamically via grain
# Then target: salt -C 'G@saltenv:staging' state.highstate saltenv=staging
```

## Debugging GitFS

```bash
# Force immediate update from all remotes
salt-run fileserver.update

# List all environments GitFS sees
salt-run fileserver.envs backend=gitfs

# List files in an env
salt-run fileserver.file_list saltenv=staging backend=gitfs

# Check which backend is serving a file
salt-run fileserver.file_list saltenv=base | grep nginx

# Show GitFS remote status
salt-run gitfs.remotes

# Clear GitFS cache (when a remote won't update)
salt-run fileserver.clear_cache backend=gitfs
service salt-master restart
```

## Common Problems

**Files not updating after a git push**
- GitFS fetches on `update_interval` (default 60s). Force with `salt-run fileserver.update`.
- Check master logs: `tail -f /var/log/salt/master | grep gitfs`
- Verify SSH keys have read access: `git -c core.sshCommand="ssh -i /path/to/key" ls-remote <url>`

**Wrong branch being served**
- `gitfs_base` controls what `base` points to (default: `main`).
- Old masters may default to `master` branch. Set `gitfs_base: main` explicitly.

**Mountpoint conflicts**
- Two remotes serving the same path → undefined which wins.
- Use `mountpoint` and `root` to namespace remotes cleanly.

**pygit2 vs gitpython**
- `pygit2` is preferred (faster, better SSH key support).
- Install: `pip install pygit2` or `apt install python3-pygit2`
- Verify: `salt-run gitfs.remotes` — if it errors, check provider.
