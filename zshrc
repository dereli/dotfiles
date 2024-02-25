# TODO Document all choices

export LC_ALL="en_US.UTF-8"
export LC_CTYPE=en_US.UTF-8
export LANG="en_US.UTF-8"

export TERM=screen-256color
export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad

export NODE_EXTRA_CA_CERTS=~/.config/node.pem

setopt autocd
setopt complete_in_word
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt menu_complete
setopt no_beep
setopt prompt_subst
setopt pushd_ignore_dups

fpath=(~/.zsh $fpath)
if [ -x /usr/libexec/path_helper ]; then
    PATH=''
    eval `/usr/libexec/path_helper -s`
fi

autoload bashcompinit && bashcompinit
zstyle ':completion:*' ignore-parents parent pwd
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select=2
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
zstyle :compinstall filename '~/.zshrc'

autoload -Uz compinit && compinit
autoload -U colors && colors
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey "^[b" backward-word
bindkey "^[f" forward-word

[ -f /usr/local/bin/aws_completer ] && complete -C '/usr/local/bin/aws_completer' aws

HYPHEN_INSENSITIVE=true
COMPLETION_WAITING_DOTS=true
ZSH_COMPDUMP="$ZSH/.cache/.zcompdump-$ZSH_VERSION"

alias -g ...=../..
alias -g ....=../../..
alias c="code"
alias cat="cat -n"
alias d="docker"
alias g="git"
alias gr="cd \`git rev-parse --show-toplevel\`"
alias k9="kill -9"
alias n="npm"
alias py="python"
psv() { ps ax | grep $1 | grep -v 'VS\|vscode' }
serve() { python3 -m http.server ${1:-8000} }

case $(uname) in
Darwin)
  alias ls="ls -GF"
  alias l="ls -lhaGF"
  ;;
Linux)
  #
  alias ls="ls -F --color"
  alias l="ls -lhaF --color"
  ;;
esac


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

[ -f ~/.zshrc-private ] && . ~/.zshrc-private

function git_current_branch() {
  local ref
  ref=$(git symbolic-ref --short HEAD 2> /dev/null) \
  || ref=$(git describe --tags --exact-match HEAD 2> /dev/null) \
  || ref=$(git rev-parse --short HEAD 2> /dev/null) \
  || return 0
  echo "${ref:gs/%/%%}"
}

function parse_git_dirty() {
  local STATUS
  STATUS=$(git status --porcelain 2> /dev/null | tail -n 1)
  if [[ -n $STATUS ]]; then
    echo "!"
  fi
}

function git_prompt() {
  STATUS=$(git_current_branch)
  if [[ -n $STATUS ]]; then
    echo " %{$fg[blue]%}[$(git_current_branch)$(parse_git_dirty)]%{$reset_color%}"
  fi
}

function npm() {
  PACKAGE="$(command npm root)/../yarn.lock"
  if [ -e "$PACKAGE" ]; then
      echo -e "Use \033[0;33myarn\033[0m in a package with \033[0;33myarn.lock\033[0m"
      return 1
  else
      command npm "$@"
  fi
}

PROMPT='%{$fg[yellow]%}%~%{$reset_color%}$(git_prompt) $ '
RPROMPT='$(last_exit_code)'
