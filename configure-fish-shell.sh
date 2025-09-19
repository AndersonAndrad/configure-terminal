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

# Ensure config folder exists
mkdir -p ~/.config/fish

# Universal commit alias for Yarn/NPM
FISH_CONFIG=~/.config/fish/config.fish
NODE_BIN=$(which node)
COMMIT_BIN=$(which commitizen)

# Add or update alias
if grep -q "alias commit=" "$FISH_CONFIG"; then
  sed -i '' "s|alias commit=.*|alias commit=\"$NODE_BIN $COMMIT_BIN\"|" "$FISH_CONFIG"
else
  echo "alias commit=\"$NODE_BIN $COMMIT_BIN\"" >> "$FISH_CONFIG"
fi

# Reload fish config
fish -c "source $FISH_CONFIG"

# Optionally add exec fish to zsh startup
grep -qxF 'exec fish' ~/.zshrc || echo 'exec fish' >> ~/.zshrc

echo "✅ Fish shell configured. Use 'commit' to run Commitizen globally."
