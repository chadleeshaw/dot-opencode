---
name: incus
description: Incus container and VM management via CLI. Use this skill for any incus commands — launching, listing, execing into, managing snapshots, profiles, storage, networks, or working with remotes.
license: MIT
compatibility: opencode
---

# Incus Skill

You are an expert at managing Incus instances via the CLI. Incus manages both system containers (LXC) and virtual machines.

All commands follow the pattern:

```
incus [command] [<remote>:]<instance> [options]
```

When no remote is specified, the current default remote is used. Prefix with `<remote>:` to target a specific server.

---

## Core Principles

1. **Orient first** — run `incus list <remote>:` to understand what's running before acting
2. **Always specify the remote** — never assume the default remote is correct; be explicit
3. **Containers vs VMs** — containers are faster to launch; VMs provide full kernel isolation. Check `TYPE` column in `incus list`
4. **Exec vs console** — use `exec` for scripted commands; use `console` for interactive shell access
5. **Snapshots before destructive ops** — snapshot before `rebuild`, `delete`, or major config changes

---

## Remotes

```bash
# List configured remotes
incus remote list

# Show current default remote
incus remote get-default

# Switch default remote
incus remote switch <remote>

# Add a new remote
incus remote add <name> https://<host>:8443
```

---

## Listing & Inspection

```bash
# List all instances on a remote
incus list <remote>:

# List with filter
incus list <remote>: name=vault
incus list <remote>: status=running

# Show detailed info about an instance
incus info <remote>:<instance>

# Show server/remote info
incus info <remote>:

# Live resource usage
incus top <remote>:
```

---

## Launching Instances

```bash
# Launch a container from an image
incus launch images:ubuntu/24.04 <remote>:<name>

# Launch a VM
incus launch images:ubuntu/24.04 <remote>:<name> --vm

# Launch with a profile
incus launch images:ubuntu/24.04 <remote>:<name> --profile <profile>

# Launch with config overrides
incus launch images:ubuntu/24.04 <remote>:<name> \
  --config limits.cpu=2 \
  --config limits.memory=4GB

# Create without starting
incus create images:ubuntu/24.04 <remote>:<name>
```

---

## Start / Stop / Restart / Delete

```bash
incus start   <remote>:<instance>
incus stop    <remote>:<instance>
incus stop    <remote>:<instance> --force    # immediate kill
incus restart <remote>:<instance>
incus pause   <remote>:<instance>
incus resume  <remote>:<instance>
incus delete  <remote>:<instance>
incus delete  <remote>:<instance> --force    # delete even if running
```

---

## Executing Commands

```bash
# Run a command in an instance
incus exec <remote>:<instance> -- <command>

# Interactive shell
incus exec <remote>:<instance> -- bash

# Run as a specific user
incus exec <remote>:<instance> --user 1000 -- bash

# Set environment variables
incus exec <remote>:<instance> --env MY_VAR=value -- bash

# Attach to the instance console (VM serial console or container TTY)
incus console <remote>:<instance>
incus console <remote>:<instance> --type vga   # graphical console for VMs
```

---

## File Management

```bash
# Push a file into an instance
incus file push <local-path> <remote>:<instance>/<path>

# Pull a file from an instance
incus file pull <remote>:<instance>/<path> <local-path>

# Edit a file in place
incus file edit <remote>:<instance>/<path>

# List directory contents
incus file list <remote>:<instance>/<path>

# Create a directory
incus file mkdir <remote>:<instance>/<path>

# Delete a file
incus file delete <remote>:<instance>/<path>
```

---

## Configuration

```bash
# Show instance config
incus config show <remote>:<instance>

# Set a config key
incus config set <remote>:<instance> limits.cpu 4
incus config set <remote>:<instance> limits.memory 8GB

# Unset a config key
incus config unset <remote>:<instance> limits.cpu

# Edit full config in $EDITOR
incus config edit <remote>:<instance>

# Add a device (e.g. disk, NIC)
incus config device add <remote>:<instance> <device-name> disk \
  source=/host/path path=/container/path

# Remove a device
incus config device remove <remote>:<instance> <device-name>
```

---

## Snapshots

```bash
# Create a snapshot
incus snapshot create <remote>:<instance> <snapshot-name>

# List snapshots
incus snapshot list <remote>:<instance>

# Restore a snapshot
incus snapshot restore <remote>:<instance> <snapshot-name>

# Delete a snapshot
incus snapshot delete <remote>:<instance> <snapshot-name>
```

---

## Profiles

```bash
# List profiles
incus profile list <remote>:

# Show a profile
incus profile show <remote>:<profile>

# Apply a profile to an instance
incus profile add <remote>:<instance> <profile>

# Remove a profile from an instance
incus profile remove <remote>:<instance> <profile>

# Edit a profile
incus profile edit <remote>:<profile>
```

---

## Images

```bash
# List available images on a remote image server
incus image list images:
incus image list images: ubuntu

# List locally cached images
incus image list <remote>:

# Copy an image to a remote
incus image copy images:ubuntu/24.04 <remote>: --alias ubuntu-24.04

# Delete a cached image
incus image delete <remote>:<fingerprint-or-alias>

# Publish an instance as an image
incus publish <remote>:<instance> <remote>: --alias <name>
```

---

## Storage

```bash
# List storage pools
incus storage list <remote>:

# Show pool details
incus storage show <remote>:<pool>

# List volumes in a pool
incus storage volume list <remote>:<pool>

# Create a custom volume
incus storage volume create <remote>:<pool> <volume-name>

# Attach a volume to an instance
incus storage volume attach <remote>:<pool> <volume-name> <instance> <path>
```

---

## Networks

```bash
# List networks
incus network list <remote>:

# Show network details
incus network show <remote>:<network>

# Attach an instance to a network
incus network attach <remote>:<network> <instance> <device-name>

# Detach
incus network detach <remote>:<network> <instance> <device-name>
```

---

## Copying & Moving

```bash
# Copy an instance (within or between remotes)
incus copy <src-remote>:<instance> <dst-remote>:<new-name>

# Move an instance
incus move <src-remote>:<instance> <dst-remote>:<new-name>

# Copy a snapshot to a new instance
incus copy <remote>:<instance>/<snapshot> <remote>:<new-name>
```

---

## Cluster Management

```bash
# List cluster members
incus cluster list <remote>:

# Show cluster member info
incus cluster show <remote>:<member>

# Evacuate a member (migrate instances away before maintenance)
incus cluster evacuate <remote>:<member>

# Restore after maintenance
incus cluster restore <remote>:<member>
```

---

## Common Workflows

### Inspect what's running on a remote

```bash
incus list <remote>: --columns nstIPA4
# n=name, s=state, t=type, I=ipv4, P=profiles, A=arch, 4=ipv4
```

### Get a shell in a running instance

```bash
incus exec <remote>:<instance> -- bash
```

### Snapshot before making changes

```bash
incus snapshot create <remote>:<instance> pre-change
# ... make changes ...
# Roll back if needed:
incus snapshot restore <remote>:<instance> pre-change
```

### Push a config file and restart a service

```bash
incus file push ./my.conf <remote>:<instance>/etc/service/my.conf
incus exec <remote>:<instance> -- systemctl restart my-service
```

### Launch a throwaway Ubuntu container for testing

```bash
incus launch images:ubuntu/24.04 <remote>:test-$(date +%s)
incus exec <remote>:test-* -- bash
incus delete <remote>:test-* --force
```

### Copy an instance between remotes

```bash
incus copy <src>:<instance> <dst>:<instance> --instance-only
```

---

## Output Formatting

```bash
# JSON output (useful for scripting)
incus list <remote>: --format json | jq '.[].name'

# CSV output
incus list <remote>: --format csv

# Columns shorthand
incus list <remote>: --columns "nsaIP4"
```
