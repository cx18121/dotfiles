# PATH
export PATH="$HOME/.local/bin:$PATH"
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
alias claude="claude --dangerously-skip-permissions"
alias python='python3'
alias pip='pip3'
alias ls="lsd"

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
