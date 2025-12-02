#!/usr/bin/env bash
script_dir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

mkdir -p ~/.ssh ~/.config/ ~/.zsh/completions
[ -e ~/.zshenv ] || echo "ZDOTDIR=~/.zsh" > ~/.zshenv
[ -e ~/.zsh/.zshrc ] || ln -s $script_dir/zshrc ~/.zsh/.zshrc
[ -e ~/.gitconfig ] || ln -s $script_dir/gitconfig ~/.gitconfig
[ -e ~/.ssh/config ] || ln -s $script_dir/sshconfig ~/.ssh/config
[ -e ~/.config/node.pem ] || touch ~/.config/node.pem
[ -e ~/.zsh/_docker ] || curl -s https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker -o ~/.zsh/completions/_docker

chmod 600 ~/.ssh/config
chmod 600 ~/.config/node.pem

codium_config_dir=~/.config/codium/user-data/User

mkdir -p $codium_config_dir
[ -e "$codium_config_dir/settings.json" ] || ln -s $script_dir/codium/settings.json "$codium_config_dir/settings.json"
[ -e "$codium_config_dir/keybindings.json" ] || ln -s $script_dir/codium/keybindings.json "$codium_config_dir/keybindings.json"
