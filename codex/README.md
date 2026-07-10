# Codex config

Tracked Codex CLI configuration, deployed with GNU Stow:

`~/.codex/config.toml -> ../dotfiles/codex/.codex/config.toml`

The native status line shows:

`project dir | PR | branch changes | model/reasoning | context used | permissions | task progress`

Codex currently supports built-in status-line fields only, so this cannot
replicate Claude Code's command-rendered progress bar, width-aware path trimming,
or working-tree status. The footer uses `project-name` instead of `current-dir`
so Superset worktrees do not show the UUID-heavy worktree prefix.
