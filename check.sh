#!/usr/bin/env bash

set -u

failures=0

check_command() {
  if command -v "$1" >/dev/null 2>&1; then
    printf 'OK      %-18s %s\n' "$1" "$(command -v "$1")"
  else
    printf 'MISSING %s\n' "$1"
    failures=$((failures + 1))
  fi
}

check_path() {
  if [[ -e "$1" || -L "$1" ]]; then
    printf 'OK      %s\n' "$1"
  else
    printf 'MISSING %s\n' "$1"
    failures=$((failures + 1))
  fi
}

printf 'Commands\n'
for command_name in brew yabai skhd jq fzf zoxide lazygit tmux yazi; do
  check_command "$command_name"
done

printf '\nConfiguration\n'
check_path "$HOME/.zshenv"
check_path "$HOME/.config/zsh/.zshrc"
check_path "$HOME/.config/zsh/.p10k.zsh"
check_path "$HOME/.config/tmux/tmux.conf"
check_path "$HOME/.config/yazi/init.lua"
check_path "$HOME/.config/yazi/package.toml"
check_path "$HOME/.config/yazi/plugins/no-status.yazi/main.lua"
check_path "$HOME/Library/Application Support/lazygit/config.yml"
check_path "$HOME/.yabairc"
check_path "$HOME/.skhdrc"
check_path "$HOME/.local/bin/visible-frame"
check_path "$HOME/.local/bin/cursor-warp"

printf '\nServices\n'
for service in com.asmvik.yabai com.koekeishiya.skhd; do
  if launchctl print "gui/$(id -u)/$service" >/dev/null 2>&1; then
    printf 'OK      %s\n' "$service"
  else
    printf 'STOPPED %s\n' "$service"
    failures=$((failures + 1))
  fi
done

if (( failures > 0 )); then
  printf '\n%d check(s) failed. See README.md for troubleshooting.\n' "$failures"
  exit 1
fi

printf '\nAll checks passed.\n'
