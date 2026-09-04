#!/usr/bin/env bash
set -euo pipefail

# Configure a machine from this repository.
#
#   git clone git@github.com:cx18121/dotfiles.git ~/dotfiles
#   ~/dotfiles/install.sh --profile macos
#
# Profiles live in profiles.toml. Nothing is detected or guessed: a machine
# gets exactly the profile you name, so a new one cannot silently inherit the
# wrong set.

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
profiles="$root/profiles.toml"

profile=""
do_tools=1
do_packages=1
do_brew=1
dry_run=0

usage() {
  cat <<'USAGE'
Usage: install.sh --profile <name> [options]

Options:
  --profile <name>   Profile from profiles.toml. Required.
  --list             List available profiles and exit.
  --no-tools         Skip mise tool pinning.
  --no-packages      Skip stow linking.
  --no-brew          Skip the Brewfile even when the profile names one.
  --dry-run          Show what would change without changing it.
  -h, --help         Show this message.
USAGE
}

read_profiles() {
  python3 - "$profiles" "$@" <<'PY'
import sys
import tomllib
from pathlib import Path

config = tomllib.loads(Path(sys.argv[1]).read_text())
profiles = config.get("profiles", {})
tool_sets = config.get("tool_sets", {})
mode = sys.argv[2]

if mode == "list":
    for name, body in profiles.items():
        print(f"{name}\t{body.get('description', '')}")
    raise SystemExit(0)

name = sys.argv[3]
if name not in profiles:
    known = ", ".join(sorted(profiles)) or "none"
    raise SystemExit(f"Unknown profile '{name}'. Known profiles: {known}")

body = profiles[name]
if mode == "tools":
    resolved = []
    for set_name in body.get("tool_sets", []):
        if set_name not in tool_sets:
            known = ", ".join(sorted(tool_sets)) or "none"
            raise SystemExit(
                f"Profile '{name}' wants unknown tool set '{set_name}'. Known: {known}"
            )
        resolved += tool_sets[set_name].get("tools", [])
    resolved += body.get("tools", [])

    seen = []
    for tool in resolved:
        if tool not in seen:
            seen.append(tool)
    print("\n".join(seen))
elif mode == "packages":
    print("\n".join(body.get("packages", [])))
elif mode == "brewfile":
    print(body.get("brewfile", ""))
PY
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) profile="${2:-}"; shift 2 ;;
    --list) read_profiles list; exit 0 ;;
    --no-tools) do_tools=0; shift ;;
    --no-packages) do_packages=0; shift ;;
    --no-brew) do_brew=0; shift ;;
    --dry-run) dry_run=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ -z "$profile" ]]; then
  printf 'A profile is required.\n\n' >&2
  usage >&2
  exit 2
fi

# Capture first so an unknown profile aborts here. Reading through process
# substitution instead would let the loop finish with an empty array and
# report success. Arrays are filled without mapfile, which macOS bash 3.2
# lacks and a fresh Mac has to run.
tools_raw=$(read_profiles tools "$profile")
packages_raw=$(read_profiles packages "$profile")
brewfile=$(read_profiles brewfile "$profile")

tools=()
while IFS= read -r line; do
  [[ -n "$line" ]] && tools+=("$line")
done <<< "$tools_raw"

packages=()
while IFS= read -r line; do
  [[ -n "$line" ]] && packages+=("$line")
done <<< "$packages_raw"

printf 'Profile %s: %d tools, %d packages.\n' \
  "$profile" "${#tools[@]}" "${#packages[@]}"

if (( do_tools )) && (( ${#tools[@]} )); then
  if ! command -v mise >/dev/null 2>&1 && [[ ! -x "$HOME/.local/bin/mise" ]]; then
    if (( dry_run )); then
      printf 'would install mise\n'
    else
      printf 'Installing mise...\n'
      curl -fsSL https://mise.run | sh
    fi
  fi

  mise_bin=$(command -v mise || printf '%s' "$HOME/.local/bin/mise")
  if (( dry_run )); then
    printf 'would pin: %s\n' "${tools[*]}"
  elif [[ -x "$mise_bin" ]]; then
    "$mise_bin" use -g "${tools[@]}"
  fi
fi

if (( do_brew )) && [[ -n "$brewfile" ]] && command -v brew >/dev/null 2>&1; then
  if (( dry_run )); then
    printf 'would run: brew bundle --file %s\n' "$root/$brewfile"
  else
    brew bundle --file "$root/$brewfile"
  fi
fi

if (( do_packages )) && (( ${#packages[@]} )); then
  if ! command -v stow >/dev/null 2>&1; then
    printf 'GNU Stow is required to link packages.\n' >&2
    exit 1
  fi

  stow_args=(--dir "$root" --target "$HOME")
  (( dry_run )) && stow_args+=(--simulate --verbose)

  failed=()
  for package in "${packages[@]}"; do
    if [[ ! -d "$root/$package" ]]; then
      printf 'Missing package directory: %s\n' "$package" >&2
      failed+=("$package")
      continue
    fi
    # Keep going so one conflict cannot leave a new machine half configured.
    if ! stow "${stow_args[@]}" "$package"; then
      failed+=("$package")
    fi
  done

  if (( ${#failed[@]} )); then
    printf '\nThese packages did not link: %s\n' "${failed[*]}" >&2
    printf 'A conflict usually means a real file exists where a link belongs.\n' >&2
    printf 'Inspect it, remove it if the repository copy is correct, then rerun.\n' >&2
    exit 1
  fi
fi

printf 'Profile %s applied.\n' "$profile"
