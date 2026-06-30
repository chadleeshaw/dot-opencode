#!/usr/bin/env zsh
# setup.sh — install dot-opencode / dot-claude on a new machine
#
# Idempotent: safe to re-run. Creates symlinks and installs dependencies.
# Called by ~/src/chadleeshaw/dotfiles/bootstrap.sh, or run standalone:
#
#   ~/.agents/setup.sh

set -e

AGENTS_DIR="${AGENTS_DIR:-$HOME/.agents}"
OPENCODE_CONFIG="$HOME/.config/opencode"
CLAUDE_CONFIG="$HOME/.claude"
LOCAL_BIN="$HOME/.local/bin"

info()    { echo "==> [dot-opencode] $*"; }
success() { echo "    ✓ $*"; }
skip()    { echo "    – $* (already done)"; }

# ── pre-flight ────────────────────────────────────────────────────────────────

info "Setting up dot-opencode from $AGENTS_DIR"

if [ ! -d "$AGENTS_DIR/.git" ]; then
  echo "dot-opencode: error: $AGENTS_DIR is not a git repo" >&2
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
mkdir -p "$LOCAL_BIN"

# ── opencode config symlinks ──────────────────────────────────────────────────

info "Symlinking opencode config directories..."

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

symlink "$AGENTS_DIR/agents"  "$OPENCODE_CONFIG/agents"
symlink "$AGENTS_DIR/commands" "$OPENCODE_CONFIG/commands"
symlink "$AGENTS_DIR/skills"  "$OPENCODE_CONFIG/skills"
symlink "$AGENTS_DIR/plugins" "$OPENCODE_CONFIG/plugins"

# ── PATH check ────────────────────────────────────────────────────────────────

if ! echo "$PATH" | tr ':' '\n' | grep -qx "$LOCAL_BIN"; then
  echo ""
  echo "    WARNING: $LOCAL_BIN is not in your PATH."
  echo "    Add this to your ~/.zshrc:"
  echo ""
  echo "      export PATH=\"\$PATH:$LOCAL_BIN\""
  echo ""
fi

# ── claude config symlinks ───────────────────────────────────────────────────

info "Symlinking claude config directories..."

mkdir -p "$CLAUDE_CONFIG"

symlink "$AGENTS_DIR/agents"      "$CLAUDE_CONFIG/agents"
symlink "$AGENTS_DIR/commands"      "$CLAUDE_CONFIG/commands"
symlink "$AGENTS_DIR/skills"        "$CLAUDE_CONFIG/skills"


# ── cmux CLI symlink ──────────────────────────────────────────────────────────

CMUX_APP="/Applications/cmux.app/Contents/Resources/bin/cmux"
if [ -f "$CMUX_APP" ] && ! command -v cmux &>/dev/null; then
  info "Symlinking cmux CLI..."
  sudo ln -sf "$CMUX_APP" /usr/local/bin/cmux && success "cmux -> /usr/local/bin/cmux" || \
    echo "    WARNING: could not symlink cmux — run manually: sudo ln -sf $CMUX_APP /usr/local/bin/cmux"
elif command -v cmux &>/dev/null; then
  skip "cmux already on PATH ($(command -v cmux))"
fi

# ── done ─────────────────────────────────────────────────────────────────────

echo ""
info "Done."
echo ""
echo "  OpenCode agents:   $OPENCODE_CONFIG/agents    -> $AGENTS_DIR/agents"
echo "  OpenCode commands: $OPENCODE_CONFIG/commands  -> $AGENTS_DIR/commands"
echo "  OpenCode skills:   $OPENCODE_CONFIG/skills    -> $AGENTS_DIR/skills"
echo "  OpenCode plugins:  $OPENCODE_CONFIG/plugins   -> $AGENTS_DIR/plugins"
echo "  Claude agents:     $CLAUDE_CONFIG/agents      -> $AGENTS_DIR/claude-agents"
echo "  Claude commands:   $CLAUDE_CONFIG/commands    -> $AGENTS_DIR/commands"
echo "  Claude skills:     $CLAUDE_CONFIG/skills      -> $AGENTS_DIR/skills"
echo "  Scripts:           $(ls "$LOCAL_BIN" | tr '\n' ' ' | sed 's/ $//')"
echo ""
