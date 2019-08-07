export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export ZSH=~/.oh-my-zsh
export NODE_EXTRA_CA_CERTS=~/.config/node.pem

setopt hist_ignore_dups
setopt hist_ignore_space

HYPHEN_INSENSITIVE=true
COMPLETION_WAITING_DOTS=true
ZSH_COMPDUMP="$ZSH/.cache/.zcompdump-$ZSH_VERSION"
plugins=(aws colorize docker git mvn node npm)

source $ZSH/oh-my-zsh.sh

# ALIAS #
alias c="codium"
alias d="docker"
alias k9="kill -9"
alias py="python"
alias ls="ls -GF"
alias l="ls -lhaGF"

psv() { ps x | grep $1 | grep -v 'VS\|vscode' }
serve() { python -m SimpleHTTPServer ${1:-8000} }

case $(uname) in
Darwin)
  alias nw="networksetup -switchtolocation '${1:-Automatic}' 1> /dev/null"
  alias gx="gitx"
  ;;
Linux)
  #
  ;;
esac

PROMPT='%{$fg[green]%}%~%{$reset_color%}$(git_prompt_info) \$ '
RPROMPT='$(last_exit_code)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[cyan]%} ["
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}!%{$fg[cyan]%}]"
ZSH_THEME_GIT_PROMPT_CLEAN="]"

function last_exit_code() {
  local LAST_EXIT_CODE=$?
  if [[ $LAST_EXIT_CODE -ne 0 ]]; then
    local EXIT_CODE_PROMPT=' '
    EXIT_CODE_PROMPT+="%{$fg[red]%}[ %{$reset_color%}"
    EXIT_CODE_PROMPT+="%{$fg_bold[red]%}$LAST_EXIT_CODE%{$reset_color%}"
    EXIT_CODE_PROMPT+="%{$fg[red]%} ]%{$reset_color%}"
    echo "$EXIT_CODE_PROMPT"
  fi
}
