# Claude Code config

## CLAUDE.md

Global rules for all projects, symlinked to `~/.claude/CLAUDE.md`.

## statusline-command.sh

Custom Claude Code status line. Mirrors Starship styling and shows:

`cwd · git branch (status) · model · context bar+% · session lines (+/−)`

- **cwd** — blue, truncated to last 3 dirs when deep
- **git** — bold cyan branch; status cyan, **yellow when uncommitted**; hidden when clean+synced
- **model** — purple, parenthetical dimmed
- **context** — continuous bar + %, green ≤50 / yellow 51–80 / red >80
- **lines** — `+added` green / `−removed` red (from `cost.total_lines_*`), session-scoped

Deployed via the same symlink pattern as the other tools:
`~/.claude/statusline-command.sh → ../dotfiles/claude/.claude/statusline-command.sh`

### Hook-up (not tracked here — `~/.claude/settings.json` is machine-specific)

Add to `~/.claude/settings.json`:

```json
"statusLine": { "type": "command", "command": "sh /Users/<you>/.claude/statusline-command.sh" }
```
