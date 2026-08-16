# PATH
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="$HOME/.local/bin/zed-editor"
export VISUAL="$EDITOR"
export PATH="/opt/homebrew/bin:$PATH"
export PNPM_HOME="/Users/charliexue/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# fnm (Node version manager)
eval "$(fnm env --use-on-cd)"

# opam (OCaml)
[[ ! -r '/Users/charliexue/.opam/opam-init/init.zsh' ]] || source '/Users/charliexue/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null

# Aliases
alias claude='unset ANTHROPIC_BASE_URL ANTHROPIC_AUTH_TOKEN ANTHROPIC_MODEL \
  ANTHROPIC_SMALL_FAST_MODEL ANTHROPIC_DEFAULT_SONNET_MODEL \
  ANTHROPIC_DEFAULT_OPUS_MODEL ANTHROPIC_DEFAULT_HAIKU_MODEL \
  API_TIMEOUT_MS CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC && \
  /Users/charliexue/.local/bin/claude --dangerously-skip-permissions'
alias python='python3'
alias pip='pip3'
alias ls="lsd"
alias codex="codex --yolo"

# Completions
fpath=(/opt/homebrew/share/zsh-completions $fpath)
autoload -Uz compinit
compinit

# Tools
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# Plugins (must be last)
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/opt/homebrew/lib/ruby/gems/4.0.0/bin:$PATH"
export PATH="$PATH:$(go env GOPATH)/bin"

export PATH="/Users/charliexue/.local/share/fnm/node-versions/v24.14.1/installation/bin:$PATH"

# bun completions
[ -s "/Users/charliexue/.bun/_bun" ] && source "/Users/charliexue/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="/Users/charliexue/.local/share/fnm/node-versions/v24.14.1/installation/bin:$PATH"

export PATH=/opt/homebrew/share/google-cloud-sdk/bin:"$PATH"
