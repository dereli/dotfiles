#!/bin/bash
cwd=`dirname "$0"`
[ -f ~/.zshrc ] || ln -s $cwd/zshrc ~/.zshrc
[ -f ~/.gitconfig ] || ln -s $cwd/gitconfig ~/.gitconfig
[ -f ~/.ssh/config ] || ln -s $cwd/sshconfig ~/.ssh/config
