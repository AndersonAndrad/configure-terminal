#!/bin/bash

# Ensure Node & npm are available (via nvm)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Exit on any error
set -e

echo "📦 Installing global npm packages..."
npm install -g husky @commitlint/cli @commitlint/config-conventional commitizen cz-conventional-changelog

echo "🛠️ Configuring commitizen..."
echo '{ "path": "cz-conventional-changelog" }' > ~/.czrc

echo "🧩 Creating commitlint configuration..."
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

echo "🚀 Adding 'commit' alias to Fish shell..."
FISH_CONFIG=~/.config/fish/config.fish
COMMIT_BIN="$(npm bin -g)/commitizen"

# Add or update the alias
if grep -q "alias commit=" "$FISH_CONFIG"; then
  sed -i '' "s|alias commit=.*|alias commit=\"$COMMIT_BIN\"|" "$FISH_CONFIG"
else
  echo "alias commit=\"$COMMIT_BIN\"" >> "$FISH_CONFIG"
fi

# Reload fish config
fish -c "source $FISH_CONFIG"

echo "✅ Setup complete! Use 'commit' to start conventional commits."
