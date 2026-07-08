#!/usr/bin/env bash
# macOS performance + minimal UI setup

set -e

echo "applying macOS defaults..."

# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.15

# Finder
defaults write com.apple.finder CreateDesktop -bool false

# Key repeat (max speed)
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

killall Dock Finder

echo "installing tools..."

brew install ghostty raycast btop yazi stow

echo "done."

echo ""
echo "manual steps required (sandboxed, cannot script):"
echo "  System Settings > Accessibility > Display"
echo "    - Enable 'Reduce Transparency'"
echo "    - Enable 'Reduce Motion'"
