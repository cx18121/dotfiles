# dotfiles

Configuration for every machine I use, in one place.

## Set up a machine

```bash
git clone git@github.com:cx18121/dotfiles.git ~/dotfiles
~/dotfiles/install.sh --profile macos
```

Use `--profile linux` on a headless host. `./install.sh --list` shows what exists.

The script installs mise if it is missing, pins that profile's tools, runs the
Brewfile when the profile names one, and links that profile's packages with
stow. It is safe to rerun. On a machine that already matches its profile it
changes nothing.

Useful flags: `--dry-run`, `--no-tools`, `--no-packages`, `--no-brew`.

## How it is organised

Every directory is a stow package whose contents mirror `$HOME`, so
`git/.gitignore_global` links to `~/.gitignore_global`.

`profiles.toml` decides what a machine gets. A profile names its tools and its
packages, and can inherit a shared tool set. Machines differ by selecting
different packages, never by keeping a second copy of the same file. When a
config genuinely differs between platforms it becomes a separate package, which
is why `herdr` and `herdr-linux` both exist.

Nothing is auto-detected. A machine gets exactly the profile you name, so a new
one cannot silently inherit the wrong set.

## Who owns what

Homebrew keeps what mise cannot express: casks, VS Code extensions, and native
libraries such as `sdl2`, `grpc`, `protobuf`, `ffmpeg`, and `mactex`.

mise keeps language runtimes and CLI tools. Anything pinned in a tool set must
not also come from another installer on that machine, or PATH order decides
which copy runs and the two drift apart.

The `macos` profile deliberately opts out of the shared tool set. On that
machine node comes from fnm, rust from rustup, bun from its own installer, and
the rest from Homebrew. Adopting the set there is a deliberate migration, not
something a config run should do behind your back.

## Known gaps

- `zsh` is tracked but not in any profile. The live `~/.zshrc` is a real file
  that has drifted from the copy here. Reconcile them before linking it.
- `superset` and `vscode` are stored for reference only. Their paths are not
  stow shaped, so linking them would create `~/themes/` and `~/settings.json`.
