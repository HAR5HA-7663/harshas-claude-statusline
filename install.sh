#!/usr/bin/env bash
# Installer for Harsha's Claude Statusline
set -e

REPO_RAW="https://raw.githubusercontent.com/HAR5HA-7663/harshas-claude-statusline/main"
DEST="$HOME/.claude/statusline.sh"
SETTINGS="$HOME/.claude/settings.json"

echo "▸ Installing to $DEST"
mkdir -p "$HOME/.claude"
curl -fsSL "$REPO_RAW/statusline.sh" -o "$DEST"
chmod +x "$DEST"

# Dependency check
missing=()
command -v jq  >/dev/null 2>&1 || missing+=("jq")
command -v git >/dev/null 2>&1 || missing+=("git (optional, for repo/branch segment)")
if [ ${#missing[@]} -gt 0 ]; then
  echo "⚠ Missing: ${missing[*]}"
  echo "  macOS: brew install ${missing[*]}"
  echo "  Debian/Ubuntu: sudo apt install ${missing[*]}"
fi

# Bash 4+ check
bash_major=$(bash -c 'echo ${BASH_VERSINFO[0]}')
if [ "$bash_major" -lt 4 ]; then
  echo "⚠ bash $bash_major detected. Install bash 4+ for full features:"
  echo "  brew install bash"
fi

# Patch settings.json
if [ -f "$SETTINGS" ]; then
  cp "$SETTINGS" "${SETTINGS}.backup.$(date +%Y%m%d_%H%M%S)"
  jq '.statusLine = {"type":"command","command":"bash ~/.claude/statusline.sh"}' "$SETTINGS" \
    > "${SETTINGS}.tmp" && mv "${SETTINGS}.tmp" "$SETTINGS"
else
  cat > "$SETTINGS" <<EOF
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline.sh"
  }
}
EOF
fi

echo "✓ Installed. Restart Claude Code to see the new statusline."
