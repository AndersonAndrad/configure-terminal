#!/bin/bash
set -e

echo "🐟 Installing Fish shell..."

# Install Fish via Homebrew (macOS)
if ! command -v fish >/dev/null 2>&1; then
  echo "📦 Installing Fish via Homebrew..."
  brew install fish
else
  echo "✅ Fish is already installed."
fi

# Ensure ~/.config/fish exists
mkdir -p ~/.config/fish

# Add 'commit' alias for Fish (example)
grep -qxF 'alias commit="npx cz"' ~/.config/fish/config.fish || \
  echo 'alias commit="npx cz"' >> ~/.config/fish/config.fish

# Optionally add exec fish to zsh startup so new terminals start in Fish
grep -qxF 'exec fish' ~/.zshrc || echo 'exec fish' >> ~/.zshrc

echo "✅ Fish shell installed and configured!"
echo "📌 Restart your terminal to start using Fish by default."
