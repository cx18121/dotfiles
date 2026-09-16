# Tool shims must stay ahead of older standalone and Homebrew copies.
export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:/opt/homebrew/bin:$PATH"
eval "$(mise activate zsh)"

export EDITOR="$HOME/.local/bin/zed-editor"
export VISUAL="$EDITOR"

# opam (OCaml)
[[ ! -r "$HOME/.opam/opam-init/init.zsh" ]] || source "$HOME/.opam/opam-init/init.zsh" > /dev/null 2> /dev/null

# Aliases
alias claude='unset ANTHROPIC_BASE_URL ANTHROPIC_AUTH_TOKEN ANTHROPIC_MODEL \
  ANTHROPIC_SMALL_FAST_MODEL ANTHROPIC_DEFAULT_SONNET_MODEL \
  ANTHROPIC_DEFAULT_OPUS_MODEL ANTHROPIC_DEFAULT_HAIKU_MODEL \
  API_TIMEOUT_MS CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC && \
  "$HOME/.local/bin/claude" --dangerously-skip-permissions'
alias python='python3'
alias pip='pip3'
alias ls='lsd'
alias codex='codex --yolo'
alias rv='docker run -i --init --rm -v "$PWD:/root" ghcr.io/sampsyo/cs3410-infra'

# Completions
fpath=(/opt/homebrew/share/zsh-completions $fpath)
autoload -Uz compinit
compinit

# Tools
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
export PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/lib/ruby/gems/4.0.0/bin:/usr/local/bin:$PATH"
export PATH="$PATH:$(go env GOPATH)/bin"
export PATH="/opt/homebrew/share/google-cloud-sdk/bin:$PATH"

# Plugins
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# CRE
export CRE_INSTALL="$HOME/.cre"
export PATH="$CRE_INSTALL/bin:$PATH"

setup-cs3410() {
  mkdir -p .devcontainer .vscode &&
    curl -fsSL https://raw.githubusercontent.com/cs3410/cs3410-infra/main/.devcontainer/devcontainer.json \
      -o .devcontainer/devcontainer.json &&
    curl -fsSL https://raw.githubusercontent.com/cs3410/cs3410-infra/main/.vscode/c_cpp_properties.json \
      -o .vscode/c_cpp_properties.json
}
