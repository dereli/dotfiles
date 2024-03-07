#!/usr/bin/env bash
cwd=`dirname $(realpath "$0")`
mkdir -p ~/.ssh ~/.zsh ~/.config
[ -f ~/.zshenv ] || echo "ZDOTDIR=~/.zsh" > ~/.zshenv
[ -f ~/.zsh/.zshrc ] || ln -s $cwd/zshrc ~/.zsh/.zshrc
[ -f ~/.gitconfig ] || ln -s $cwd/gitconfig ~/.gitconfig
[ -f ~/.ssh/config ] || ln -s $cwd/sshconfig ~/.ssh/config
[ -f ~/.config/node.pem ] || touch ~/.config/node.pem
curl -s https://git.kernel.org/pub/scm/git/git.git/plain/contrib/completion/git-completion.bash -o ~/.zsh/git-completion.bash
