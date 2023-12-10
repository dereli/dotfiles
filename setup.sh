#!/bin/bash
cwd=`dirname $(realpath "$0")`
[ -f ~/.zshrc ] || ln -s $cwd/zshrc ~/.zshrc
[ -f ~/.gitconfig ] || ln -s $cwd/gitconfig ~/.gitconfig
[ -f ~/.ssh/config ] || ln -s $cwd/sshconfig ~/.ssh/config
mkdir -p ~/.zsh
curl https://git.kernel.org/pub/scm/git/git.git/plain/contrib/completion/git-completion.bash -o ~/.zsh/git-completion.bash
