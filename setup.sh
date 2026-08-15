#!/usr/bin/env zsh
# setup.sh — install agent config for OpenCode, Claude Code, Pi, and Grok CLI
#
# Idempotent: safe to re-run. Creates symlinks and installs dependencies.
# Called by ~/src/chadleeshaw/dotfiles/bootstrap.sh, or run standalone:
#
#   ~/.agents/setup.sh

set -e

AGENTS_DIR="${AGENTS_DIR:-$HOME/.agents}"
OPENCODE_CONFIG="$HOME/.config/opencode"
CLAUDE_CONFIG="$HOME/.claude"
PI_CONFIG="$HOME/.pi/agent"
GROK_CONFIG="$HOME/.grok"
LOCAL_BIN="$HOME/.local/bin"

info()    { echo "==> [dot-agents] $*"; }
success() { echo "    ✓ $*"; }
skip()    { echo "    – $* (already done)"; }

# ── pre-flight ────────────────────────────────────────────────────────────────

info "Setting up dot-agents from $AGENTS_DIR"

if [ ! -d "$AGENTS_DIR/.git" ]; then
  echo "dot-agents: error: $AGENTS_DIR is not a git repo" >&2
  echo "  Clone it first:" >&2
  echo "    git clone git@github.com:chadleeshaw/dot-opencode.git ~/.agents" >&2
  exit 1
fi

# Pull latest if we're in a clean state
if git -C "$AGENTS_DIR" diff --quiet && git -C "$AGENTS_DIR" diff --cached --quiet; then
  info "Pulling latest from origin..."
  git -C "$AGENTS_DIR" pull --quiet --ff-only 2>/dev/null || true
fi

# ── directories ───────────────────────────────────────────────────────────────

mkdir -p "$OPENCODE_CONFIG"
mkdir -p "$CLAUDE_CONFIG"
mkdir -p "$PI_CONFIG"
mkdir -p "$GROK_CONFIG"
mkdir -p "$LOCAL_BIN"

# ── symlink helper ────────────────────────────────────────────────────────────

symlink() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    skip "$dst"
  else
    # Remove real dir or symlink (ln -sf won't replace a symlink-to-dir)
    [ -L "$dst" ] && rm "$dst"
    [ -e "$dst" ] && rm -rf "$dst"
    ln -s "$src" "$dst"
    success "$dst -> $src"
  fi
}

# ── opencode config symlinks ──────────────────────────────────────────────────

info "Symlinking opencode config directories..."

symlink "$AGENTS_DIR/agents"   "$OPENCODE_CONFIG/agents"
symlink "$AGENTS_DIR/commands" "$OPENCODE_CONFIG/commands"
symlink "$AGENTS_DIR/skills"   "$OPENCODE_CONFIG/skills"

# ── claude config symlinks ───────────────────────────────────────────────────

info "Symlinking claude config directories..."

symlink "$AGENTS_DIR/agents"   "$CLAUDE_CONFIG/agents"
symlink "$AGENTS_DIR/commands" "$CLAUDE_CONFIG/commands"
symlink "$AGENTS_DIR/skills"   "$CLAUDE_CONFIG/skills"

# ── pi config symlinks ───────────────────────────────────────────────────────

info "Symlinking pi config directories..."

symlink "$AGENTS_DIR/agents"   "$PI_CONFIG/agents"
symlink "$AGENTS_DIR/commands" "$PI_CONFIG/prompts"
symlink "$AGENTS_DIR/skills"   "$PI_CONFIG/skills"

# ── grok config symlinks ─────────────────────────────────────────────────────

info "Symlinking grok config directories..."

symlink "$AGENTS_DIR/commands" "$GROK_CONFIG/commands"

# ── PATH check ────────────────────────────────────────────────────────────────

if ! echo "$PATH" | tr ':' '\n' | grep -qx "$LOCAL_BIN"; then
  echo ""
  echo "    WARNING: $LOCAL_BIN is not in your PATH."
  echo "    Add this to your ~/.zshrc:"
  echo ""
  echo "      export PATH=\"\$PATH:$LOCAL_BIN\""
  echo ""
fi

# ── done ─────────────────────────────────────────────────────────────────────

echo ""
info "Done."
echo ""
echo "  Claude agents:     $CLAUDE_CONFIG/agents      -> $AGENTS_DIR/agents"
echo "  Claude commands:   $CLAUDE_CONFIG/commands    -> $AGENTS_DIR/commands"
echo "  Claude skills:     $CLAUDE_CONFIG/skills      -> $AGENTS_DIR/skills"
echo "  OpenCode agents:   $OPENCODE_CONFIG/agents    -> $AGENTS_DIR/agents"
echo "  OpenCode commands: $OPENCODE_CONFIG/commands  -> $AGENTS_DIR/commands"
echo "  OpenCode skills:   $OPENCODE_CONFIG/skills    -> $AGENTS_DIR/skills"
echo "  Pi agents:         $PI_CONFIG/agents          -> $AGENTS_DIR/agents"
echo "  Pi prompts:        $PI_CONFIG/prompts         -> $AGENTS_DIR/commands"
echo "  Pi skills:         $PI_CONFIG/skills          -> $AGENTS_DIR/skills"
echo "  Grok commands:     $GROK_CONFIG/commands      -> $AGENTS_DIR/commands"
echo ""
