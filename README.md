# Harsha's Claude Statusline

Minimal, color-first, 2-line statusline for [Claude Code](https://docs.claude.com/en/docs/claude-code). No emojis, uppercase labels, dense info.

```
/Users/you/project (repo/branch) │ Claude Opus 4.6 │ MCP brain-fs,github │ SKILL webapp-testing │ EFFORT high │ EXTRA off │ CHROME on
CTX ████░░░░░░ 42% │ IN 170 │ OUT 27.0K │ CACHE 2.8M │ TOT 2.8M │ 5H 23% │ 7D 67%
```

## What it shows

**Line 1** — session context
| Field | Meaning |
|---|---|
| `cwd` | Current directory (`~` shortened) |
| `repo/branch` | Git repo name + current branch (or short SHA if detached) |
| Model | `Claude Opus 4.6`, `Claude Sonnet 4.6`, etc. |
| `MCP <names>` | Comma-separated MCP server names from `~/.claude.json` |
| `SKILL <name>` | Most recently invoked skill (parsed from transcript tail) |
| `EFFORT <level>` | Reasoning effort: `max` red · `high` yellow · `medium` green · `low` dim |
| `EXTRA on/off` | Extra-usage status from `~/.claude.json` |
| `CHROME on/off` | Whether session was started with `claude --chrome` (detected by walking parent processes) |

**Line 2** — numbers
| Field | Meaning |
|---|---|
| `CTX ████░░ 42%` | Context window used (10-block bar, green → yellow → red) |
| `IN / OUT / CACHE / TOT` | Cumulative tokens for this transcript (auto K/M format) |
| `5H <pct>` | 5-hour rate limit used |
| `7D <pct>` | 7-day rate limit used |

## Install

### One-liner

```bash
curl -fsSL https://raw.githubusercontent.com/HAR5HA-7663/harshas-claude-statusline/main/install.sh | bash
```

### Manual

```bash
# 1. Save the script
mkdir -p ~/.claude
curl -fsSL https://raw.githubusercontent.com/HAR5HA-7663/harshas-claude-statusline/main/statusline.sh \
  -o ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh

# 2. Wire it into Claude Code settings.json
#    ~/.claude/settings.json should contain:
#    {
#      "statusLine": {
#        "type": "command",
#        "command": "bash ~/.claude/statusline.sh"
#      }
#    }
```

## Requirements

- **`jq`** — JSON parsing. `brew install jq` / `apt install jq`
- **`bash` 4+** — macOS ships 3.2. `brew install bash` puts 5.x in `/opt/homebrew/bin/bash`
- **`git`** — for repo/branch detection (optional, segment hides if absent)
- **Claude Code** ≥ any recent version (uses standard statusline JSON input)

## Customize

All logic is in one `statusline.sh` (~150 lines). Sections are clearly labeled with `# ── <name> ──` headers:

- Hide a segment → delete its `line1="${line1}...` / `line2="${line2}...` append
- Change colors → edit the ANSI block at the top (`CYAN`, `GREEN`, etc.)
- Change thresholds → edit `CTX` / rate-color if-conditions
- Add a new segment → copy an existing one, change the source field

## How data flows

Claude Code pipes a JSON blob to your statusline command on every render. This script reads:

- `.model.display_name`
- `.workspace.current_dir`
- `.context_window.used_percentage`
- `.rate_limits.five_hour.used_percentage`, `.seven_day.used_percentage`
- `.reasoning_effort`
- `.transcript_path` (parsed for skill invocations + token totals)

Plus out-of-band sources:

- `~/.claude.json` — MCP server list, extra-usage flag
- `~/.claude/settings.json` — effort level fallback
- Parent process tree (`ps`) — `--chrome` flag detection

## Claude-friendly notes

If you're asking Claude Code to modify this file, the canonical segment pattern is:

```bash
# ── <segment_name> ─────────────────────────────────
<segment>_str=""
if [ -n "$<source_var>" ]; then
  <segment>_str=" ${SEP} ${D}LABEL${R} ${COLOR}<value>${R}"
fi
```

Then append to `line1` or `line2`:
```bash
line1="${line1}${<segment>_str}"
```

Labels are always uppercase. Separator between segments is always `${SEP}` (`│`). Value colors follow this convention:
- Identity / names → `GREEN`
- Model → `BOLD CYAN`
- Warning / off → `RED`
- Elevated / on → `YELLOW` or `GREEN`
- Dim / passive → `DIM`

## License

MIT. Take it, fork it, bend it to your taste.
