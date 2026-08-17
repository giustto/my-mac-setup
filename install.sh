#!/usr/bin/env bash

set -Eeuo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This setup supports macOS only." >&2
  exit 1
fi

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.my-mac-setup-backups/$(date +%Y%m%d-%H%M%S)"
CREATED_BACKUP=0
REPLACED_EXISTING=0
BACKUP_EXISTING_CONFIGS="${BACKUP_EXISTING_CONFIGS:-}"
REDUCE_ANIMATIONS="${REDUCE_ANIMATIONS:-}"

log() {
  printf '\n==> %s\n' "$1"
}

backup_and_copy() {
  local source="$1"
  local target="$2"
  local relative_target

  mkdir -p "$(dirname "$target")"

  if [[ -f "$target" && ! -L "$target" ]] && cmp -s "$source" "$target"; then
    printf 'Already installed: %s\n' "$target"
    return
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    if [[ -d "$target" && ! -L "$target" ]]; then
      printf 'Refusing to replace a directory: %s\n' "$target" >&2
      exit 1
    fi

    REPLACED_EXISTING=1
    if [[ "$BACKUP_EXISTING_CONFIGS" == "yes" ]]; then
      relative_target="${target#"$HOME"/}"
      mkdir -p "$BACKUP_DIR/$(dirname "$relative_target")"
      mv "$target" "$BACKUP_DIR/$relative_target"
      CREATED_BACKUP=1
      printf 'Backed up: %s\n' "$target"
    else
      rm -f -- "$target"
      printf 'Replaced without backup: %s\n' "$target"
    fi
  fi

  cp -p "$source" "$target"
  printf 'Installed: %s\n' "$target"
}

log "Checking Xcode Command Line Tools"
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
  echo "Finish the installation, then run this script again."
  exit 0
fi

log "Checking Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

log "Installing packages from Brewfile"
# koekeishiya/formulae (yabai, skhd) is a third-party tap. Recent Homebrew
# refuses to load formulae from a tap that hasn't been explicitly trusted, so
# trust the one tap this Brewfile actually declares before bundling.
if command -v brew >/dev/null 2>&1 && brew trust --help >/dev/null 2>&1; then
  brew trust --taps koekeishiya/formulae
fi
brew bundle --file "$REPO_DIR/Brewfile"

if [[ -z "$BACKUP_EXISTING_CONFIGS" ]]; then
  if [[ -t 0 ]]; then
    while true; do
      read -r -p "Back up existing configuration files before replacing them? [Y/n] " answer
      case "${answer:-y}" in
        [Yy]|[Yy][Ee][Ss]) BACKUP_EXISTING_CONFIGS="yes"; break ;;
        [Nn]|[Nn][Oo]) BACKUP_EXISTING_CONFIGS="no"; break ;;
        *) echo "Please answer yes or no." ;;
      esac
    done
  else
    BACKUP_EXISTING_CONFIGS="yes"
    echo "No interactive terminal detected; existing files will be backed up."
  fi
fi

case "$BACKUP_EXISTING_CONFIGS" in
  yes|no) ;;
  *) echo "BACKUP_EXISTING_CONFIGS must be 'yes' or 'no'." >&2; exit 2 ;;
esac

log "Installing configuration files"
backup_and_copy "$REPO_DIR/config/yabai/yabairc" "$HOME/.config/yabai/yabairc"
backup_and_copy "$REPO_DIR/config/skhd/skhdrc" "$HOME/.config/skhd/skhdrc"
backup_and_copy "$REPO_DIR/config/zsh/.zshrc" "$HOME/.config/zsh/.zshrc"
backup_and_copy "$REPO_DIR/config/zsh/.p10k.zsh" "$HOME/.config/zsh/.p10k.zsh"
backup_and_copy "$REPO_DIR/config/zsh/.zshenv" "$HOME/.zshenv"
backup_and_copy "$REPO_DIR/config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
backup_and_copy "$REPO_DIR/config/yazi/init.lua" "$HOME/.config/yazi/init.lua"
backup_and_copy "$REPO_DIR/config/yazi/package.toml" "$HOME/.config/yazi/package.toml"
backup_and_copy "$REPO_DIR/config/ghostty/config.ghostty" "$HOME/.config/ghostty/config.ghostty"
backup_and_copy "$REPO_DIR/config/ghostty/themes/neon-dark" "$HOME/.config/ghostty/themes/neon-dark"
backup_and_copy "$REPO_DIR/config/ghostty/themes/neon-light" "$HOME/.config/ghostty/themes/neon-light"
backup_and_copy "$REPO_DIR/config/lazygit/config.yml" "$HOME/Library/Application Support/lazygit/config.yml"

log "Installing Yazi plugins"
if ! ya pkg install; then
  echo "ya pkg install failed, likely because a previously deployed plugin" >&2
  echo "was locally modified. Retrying with --discard to reset it." >&2
  if ! ya pkg install --discard; then
    echo "ya pkg install still failed; continuing without Yazi plugins." >&2
    echo "Run 'ya pkg install --discard' by hand once yazi is working." >&2
  fi
fi

# tmux reads ~/.tmux.conf before it ever looks at the XDG path, and yabai's
# and skhd's Homebrew LaunchAgents may still look only at the legacy paths in
# the home directory. Keep both locations in sync so a config left over from
# an older, non-XDG setup can never silently shadow the one we just installed.
backup_and_copy "$REPO_DIR/config/tmux/tmux.conf" "$HOME/.tmux.conf"
backup_and_copy "$REPO_DIR/config/yabai/yabairc" "$HOME/.yabairc"
backup_and_copy "$REPO_DIR/config/skhd/skhdrc" "$HOME/.skhdrc"

log "Compiling helper tools"
mkdir -p "$HOME/.local/bin"
xcrun clang "$REPO_DIR/helpers/cursor-warp.c" \
  -framework ApplicationServices \
  -o "$HOME/.local/bin/cursor-warp"
xcrun clang "$REPO_DIR/helpers/visible-frame.m" \
  -framework Cocoa \
  -o "$HOME/.local/bin/visible-frame"

ln -sf "$(command -v yabai)" "$HOME/.local/bin/yabai"
ln -sf "$(command -v jq)" "$HOME/.local/bin/jq"
mkdir -p "$HOME/.local/state/zsh"
touch "$HOME/.hushlogin"

log "Starting services"
yabai --start-service || yabai --restart-service
skhd --start-service || skhd --restart-service

if [[ -z "$REDUCE_ANIMATIONS" ]]; then
  if [[ -t 0 ]]; then
    while true; do
      read -r -p "Apply reduced macOS animation settings? [y/N] " answer
      case "${answer:-n}" in
        [Yy]|[Yy][Ee][Ss]) REDUCE_ANIMATIONS="yes"; break ;;
        [Nn]|[Nn][Oo]) REDUCE_ANIMATIONS="no"; break ;;
        *) echo "Please answer yes or no." ;;
      esac
    done
  else
    REDUCE_ANIMATIONS="no"
    echo "No interactive terminal detected; macOS animation settings are unchanged."
  fi
fi

case "$REDUCE_ANIMATIONS" in
  yes) "$REPO_DIR/macos/reduce-animations.sh" ;;
  no) echo "macOS animation settings were left unchanged." ;;
  *) echo "REDUCE_ANIMATIONS must be 'yes' or 'no'." >&2; exit 2 ;;
esac

if (( CREATED_BACKUP )); then
  printf '\nExisting files were backed up to:\n%s\n' "$BACKUP_DIR"
elif (( REPLACED_EXISTING )); then
  printf '\nExisting configuration files were replaced without a backup.\n'
else
  printf '\nNo existing configuration files needed to be replaced.\n'
fi

cat <<'EOF'

Installation complete.

Manual steps still required:
1. Open System Settings > Privacy & Security > Accessibility.
2. Allow yabai and skhd (toggle them off and on if they were already listed).
3. Open a new terminal or run `exec zsh`.

Test with: yabai -m query --displays
EOF
