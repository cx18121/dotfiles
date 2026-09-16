# Personal development environment

This repository is the entry point for setting up every machine I use. Mise installs the tools, repositories, shell integration, and dotfiles selected by the `macos` or `linux` environment. App repositories own their own internal setup and expose bootstrap and check tasks that this project calls.

## Set up a machine

Install the mise version required by this repository:

```bash
MISE_VERSION=v2026.9.9 curl -fsSL https://mise.run | sh
```

Then bootstrap a Mac:

```bash
~/.local/bin/mise bootstrap \
  --from https://github.com/cx18121/dotfiles.git \
  --from-dir "$HOME/dotfiles" \
  -E macos \
  --locked \
  --yes
```

Use `-E linux` for an Ubuntu or other supported Linux development host.

For an existing checkout:

```bash
mise -C ~/dotfiles -E macos bootstrap --locked
```

Preview or inspect the selected environment without changing it:

```bash
mise -C ~/dotfiles -E macos bootstrap --dry-run
mise -C ~/dotfiles -E macos bootstrap status
mise -C ~/dotfiles -E macos run check -- macos
```

## What it owns

`mise.toml` contains repositories, dotfiles, and the final bootstrap task. `managed/mise-tools.toml` is linked into mise's global configuration so the exact tools are available from every directory. `mise.macos.toml` and `mise.linux.toml` contain only platform-specific composition.

- Mise owns versioned development tools on both platforms.
- Mise's native dotfile manager links configuration into the home directory.
- Homebrew owns macOS applications and native libraries through `brew/Brewfile`.
- `pi-personal` owns Pi extensions and generated platform settings.
- `herdr-personal` owns Herdr configuration, personal commands, and pinned plugins.
- `agent-skills` owns shared reusable skills.
- `personal-cloud` owns AWS infrastructure and host-specific safety controls.

Credentials, authentication sessions, caches, terminal sessions, run history, and personal data are deliberately excluded.

## Pi local overlay

Portable Pi settings live in `pi-personal`. A machine can add packages or override preferences without committing machine-specific paths by creating:

```text
~/.config/pi/settings.local.json
```

See `pi-personal/config/settings.local.example.json` for the supported shape.

## Updating

Update repositories and reapply the selected environment:

```bash
mise -C ~/dotfiles -E macos bootstrap --update --locked
```

Change exact tool versions in `managed/mise-tools.toml`, then refresh `managed/mise.lock` with `mise lock --global` for the supported platforms.

## Stored for reference only

`superset` and `vscode` remain historical settings. They are not applied by the bootstrap.
