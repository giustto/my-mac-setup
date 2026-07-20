#!/usr/bin/env bash

set -Eeuo pipefail

echo "Applying reduced macOS animation settings..."

defaults write NSGlobalDomain NSScrollViewRubberbanding -bool false
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write NSGlobalDomain NSScrollAnimationEnabled -bool false
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
defaults write NSGlobalDomain QLPanelAnimationDuration -float 0
defaults write NSGlobalDomain NSDocumentRevisionsWindowTransformAnimation -bool false
defaults write NSGlobalDomain NSToolbarFullScreenAnimationDuration -float 0
defaults write NSGlobalDomain NSBrowserColumnAnimationSpeedMultiplier -float 0

defaults write com.apple.dock autohide-time-modifier -float 0
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock springboard-show-duration -float 0
defaults write com.apple.dock springboard-hide-duration -float 0
defaults write com.apple.dock springboard-page-duration -float 0

defaults write com.apple.finder DisableAllAnimations -bool true
defaults write com.apple.Mail DisableSendAnimations -bool true
defaults write com.apple.Mail DisableReplyAnimations -bool true

killall Dock >/dev/null 2>&1 || true
killall Finder >/dev/null 2>&1 || true

echo "Reduced animation settings applied. Restart open applications or log out for all changes to take effect."
