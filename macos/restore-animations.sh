#!/usr/bin/env bash

set -u

echo "Removing custom macOS animation settings..."

delete_default() {
  defaults delete "$1" "$2" >/dev/null 2>&1 || true
}

delete_default NSGlobalDomain NSScrollViewRubberbanding
delete_default NSGlobalDomain NSAutomaticWindowAnimationsEnabled
delete_default NSGlobalDomain NSScrollAnimationEnabled
delete_default NSGlobalDomain NSWindowResizeTime
delete_default NSGlobalDomain QLPanelAnimationDuration
delete_default NSGlobalDomain NSDocumentRevisionsWindowTransformAnimation
delete_default NSGlobalDomain NSToolbarFullScreenAnimationDuration
delete_default NSGlobalDomain NSBrowserColumnAnimationSpeedMultiplier

delete_default com.apple.dock autohide-time-modifier
delete_default com.apple.dock autohide-delay
delete_default com.apple.dock expose-animation-duration
delete_default com.apple.dock springboard-show-duration
delete_default com.apple.dock springboard-hide-duration
delete_default com.apple.dock springboard-page-duration

delete_default com.apple.finder DisableAllAnimations
delete_default com.apple.Mail DisableSendAnimations
delete_default com.apple.Mail DisableReplyAnimations

killall Dock >/dev/null 2>&1 || true
killall Finder >/dev/null 2>&1 || true

echo "Custom animation settings removed. Restart open applications or log out for all changes to take effect."
