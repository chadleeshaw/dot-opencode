#!/usr/bin/env zsh
# setup.sh — install dot-opencode on a new machine
#
# Idempotent: safe to re-run. Creates symlinks and installs dependencies.
# Called by ~/src/chadleeshaw/dotfiles/bootstrap.sh, or run standalone:
#
#   ~/.agents/setup.sh

set -e

AGENTS_DIR="${AGENTS_DIR:-$HOME/.agents}"
OPENCODE_CONFIG="$HOME/.config/opencode"
LOCAL_BIN="$HOME/.local/bin"

info()    { echo "==> [dot-opencode] $*"; }
success() { echo "    ✓ $*"; }
skip()    { echo "    – $* (already done)"; }

# ── pre-flight ────────────────────────────────────────────────────────────────

info "Setting up dot-opencode from $AGENTS_DIR"

if [ ! -d "$AGENTS_DIR/.git" ]; then
  echo "dot-opencode: error: $AGENTS_DIR is not a git repo" >&2
  echo "  Clone it first:" >&2
  echo "    git clone git@gitlab.com:vivint/horizontals/platform-ops/ai/dot-opencode.git ~/.agents" >&2
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
    # Remove a real dir or stale symlink before linking
    [ -e "$dst" ] && rm -rf "$dst"
    ln -sf "$src" "$dst"
    success "$dst -> $src"
  fi
}

symlink "$AGENTS_DIR/agents"  "$OPENCODE_CONFIG/agents"
symlink "$AGENTS_DIR/commands" "$OPENCODE_CONFIG/commands"
symlink "$AGENTS_DIR/skills"  "$OPENCODE_CONFIG/skills"
symlink "$AGENTS_DIR/plugins" "$OPENCODE_CONFIG/plugins"

# ── script symlinks ───────────────────────────────────────────────────────────

info "Symlinking scripts to $LOCAL_BIN..."

for script in "$AGENTS_DIR/scripts/"*; do
  [ -f "$script" ] || continue
  local_name="$LOCAL_BIN/$(basename "$script")"
  chmod +x "$script"
  if [ -L "$local_name" ] && [ "$(readlink "$local_name")" = "$script" ]; then
    skip "$(basename "$script")"
  else
    [ -e "$local_name" ] && rm -f "$local_name"
    ln -sf "$script" "$local_name"
    success "$(basename "$script")"
  fi
done

# ── PATH check ────────────────────────────────────────────────────────────────

if ! echo "$PATH" | tr ':' '\n' | grep -qx "$LOCAL_BIN"; then
  echo ""
  echo "    WARNING: $LOCAL_BIN is not in your PATH."
  echo "    Add this to your ~/.zshrc:"
  echo ""
  echo "      export PATH=\"\$PATH:$LOCAL_BIN\""
  echo ""
fi

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
echo "  Scripts:           $LOCAL_BIN/{oc-swarm,oc-worker}"
echo ""
