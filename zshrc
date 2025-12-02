# Zsh configuration file
# Set locale to ensure consistent language and encoding
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LANG="en_US.UTF-8"

# Terminal and color settings for better compatibility and appearance
export TERM=screen-256color
export CLICOLOR=1  # Enable colorized output for supported commands
export LSCOLORS=Gxfxcxdxbxegedabagacad  # Custom color scheme for 'ls' output

# Use custom CA certificates for Node.js if present
# export NODE_EXTRA_CA_CERTS=~/.config/node.pem

# Zsh options for usability and history behavior
setopt autocd                # Change directory by typing its name
setopt complete_in_word      # Complete words in the middle
setopt hist_expire_dups_first # Expire duplicate entries first when trimming history
setopt hist_ignore_dups      # Ignore duplicate commands in history
setopt hist_ignore_space     # Ignore commands that start with a space in history
setopt menu_complete         # Use menu completion
setopt no_beep               # Disable beep on errors
setopt prompt_subst          # Enable prompt substitution
setopt pushd_ignore_dups     # Don't store duplicate directories in the stack

# Add custom functions directory to fpath for autoloading
fpath+=~/.zsh/completions

# Use system path helper on macOS to set PATH
if [ -x /usr/libexec/path_helper ]; then
    eval `/usr/libexec/path_helper -s`
fi

# Configure completion behavior
zstyle ':completion:*' ignore-parents parent pwd
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select=2
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle :compinstall filename '~/.zshrc'

zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# Load completion, color, and custom search widgets
autoload -Uz compinit && compinit
autoload -U colors && colors
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search

# Bind custom search widgets to up/down arrow keys
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey "^[b" backward-word
bindkey "^[f" forward-word

# Enable AWS CLI completion if available
[ -f /usr/local/bin/aws_completer ] && complete -C '/usr/local/bin/aws_completer' aws

# Zsh plugin and completion settings
HYPHEN_INSENSITIVE=true         # Ignore hyphens when completing
COMPLETION_WAITING_DOTS=true    # Show dots while waiting for completion
ZSH_COMPDUMP="$ZSH/.cache/.zcompdump-$ZSH_VERSION"  # Cache file for completions

# History configuration
HISTFILE="$ZDOTDIR/.history"
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory           # Append to history file, don't overwrite
setopt share_history          # Share history between all sessions
setopt inc_append_history     # Append commands to history immediately

# Common aliases for convenience
alias -g ...=../..
alias -g ....=../../..
alias c="code"
alias d="docker"
alias g="git"
alias gr="cd \`git rev-parse --show-toplevel\`"  # Go to git repo root
alias k9="kill -9"
alias n="npm"
alias py="python"
alias l="ls -l"
alias ll="ls -la"

serve() { python3 -m http.server ${1:-8000} }
chpwd() { ls -la }

# OS-specific aliases for 'ls'
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

case ":${PATH}:" in
    *:"$HOME/.local/bin":*)
        ;;
    *)
        # Prepend path in case a system-installed binary needs to be overridden
        export PATH="$HOME/.local/bin:$PATH"
        ;;
esac

# Show last command's exit code in the prompt if non-zero
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

# Source private settings if present
[ -f ~/.zshrc-private ] && . ~/.zshrc-private

# Show current git branch or tag in prompt
function git_current_branch() {
  local ref
  ref=$(git symbolic-ref --short HEAD 2> /dev/null) \
  || ref=$(git describe --tags --exact-match HEAD 2> /dev/null) \
  || ref=$(git rev-parse --short HEAD 2> /dev/null) \
  || return 0
  echo "${ref:gs/%/%%}"
}

# Show '!' if git repo is dirty
function parse_git_dirty() {
  local STATUS
  STATUS=$(git status --porcelain 2> /dev/null | tail -n 1)
  if [[ -n $STATUS ]]; then
    echo "!"
  fi
}

# Compose git prompt segment
function git_prompt() {
  STATUS=$(git_current_branch)
  if [[ -n $STATUS ]]; then
    echo " %{$fg[blue]%}[$(git_current_branch)$(parse_git_dirty)]%{$reset_color%}"
  fi
}

# Show hostname if VISIBLE_HOSTNAME is defined
function visible_hostname() {
  if [[ -n $VISIBLE_HOSTNAME ]]; then
    echo "%{$fg_bold[green]%}$VISIBLE_HOSTNAME%{$reset_color%} "
  fi
}

# Warn if using npm in a yarn-managed project (custom wrapper)
function npm() {
  YARN_LOCK_PATH="$(command npm root)/../yarn.lock"
  if [ -e "$YARN_LOCK_PATH" ]; then
      echo -e "Use \033[0;33myarn\033[0m in a package with \033[0;33myarn.lock\033[0m"
      return 1
  else
      command npm "$@"
  fi
}

# Set prompt and right prompt
PROMPT='$(visible_hostname)%{$fg[yellow]%}%~%{$reset_color%}$(git_prompt) $ '
RPROMPT='$(last_exit_code)'
