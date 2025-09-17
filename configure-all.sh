#!/bin/bash
set -e

# -------------------------------
# NVM + Node.js Setup
# -------------------------------
echo "📦 Ensuring NVM is installed..."
export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi
source "$NVM_DIR/nvm.sh"

echo "📦 Installing Node.js LTS..."
nvm install --lts
nvm use --lts

# -------------------------------
# Global npm packages
# -------------------------------
echo "📦 Installing global npm packages..."
npm install -g husky @commitlint/cli @commitlint/config-conventional commitizen cz-conventional-changelog

# -------------------------------
# Commitizen Setup
# -------------------------------
echo "🛠️ Configuring Commitizen..."
echo '{ "path": "cz-conventional-changelog" }' > ~/.czrc

# -------------------------------
# Commitlint Setup
# -------------------------------
echo "🧩 Creating Commitlint configuration..."
mkdir -p ~/.config/commitlint
cat <<EOF > ~/.config/commitlint/commitlint.config.js
module.exports = {
  extends: ["@commitlint/config-conventional"],
  rules: {
    "type-enum": [
      2,
      "always",
      ["feat", "fix", "docs", "style", "refactor", "test", "chore", "perf", "build", "ci", "revert"]
    ],
    "header-max-length": [2, "always", 150]
  }
};
EOF

# -------------------------------
# Husky Global Hooks
# -------------------------------
echo "🔧 Setting up Husky global hooks..."
mkdir -p ~/.husky
git config --global core.hooksPath ~/.husky

echo "📎 Adding commit-msg hook..."
cat <<EOF > ~/.husky/commit-msg
#!/bin/sh
npx --no -- commitlint --edit "\$1" --config ~/.config/commitlint/commitlint.config.js
EOF
chmod +x ~/.husky/commit-msg

echo "🧬 Setting Git global init template (optional)..."
git config --global init.templateDir ~/.husky

# -------------------------------
# Fish shell integration (always run)
# -------------------------------
echo "🐟 Ensuring Fish shell is installed..."
if ! command -v fish >/dev/null 2>&1; then
  echo "📦 Installing Fish shell via Homebrew..."
  brew install fish
fi

echo "🐟 Configuring Fish shell..."
FISH_CONFIG=~/.config/fish/config.fish
COMMIT_BIN="npx cz"

mkdir -p ~/.config/fish

if grep -q "alias commit=" "$FISH_CONFIG" 2>/dev/null; then
  sed -i '' "s|alias commit=.*|alias commit=\"$COMMIT_BIN\"|" "$FISH_CONFIG"
else
  echo "alias commit=\"$COMMIT_BIN\"" >> "$FISH_CONFIG"
fi

fish -c "source $FISH_CONFIG"

which fish | sudo tee -a /etc/shells

chsh -s $(which fish)

echo $SHELL

# Append 'exec fish' only if it’s not already in the file
grep -qxF 'exec fish' ~/.zshrc || echo 'exec fish' >> ~/.zshrc

echo "✅ Fish shell configured. Use 'commit' to run Commitizen."

echo "✅ Setup complete! Restart your terminal to apply changes."

