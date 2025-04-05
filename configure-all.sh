#!/bin/bash

set -e

echo "📦 Ensuring NVM is installed..."
export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi
source "$NVM_DIR/nvm.sh"

echo "📦 Installing Node.js LTS..."
nvm install --lts
nvm use --lts

echo "📦 Installing global npm packages..."
npm install -g husky @commitlint/cli @commitlint/config-conventional commitizen cz-conventional-changelog

echo "🛠️ Configuring Commitizen..."
echo '{ "path": "cz-conventional-changelog" }' > ~/.czrc

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

echo "🐟 Configuring Fish shell..."

# Define temporary alias for current session (only applies if inside fish shell)
echo 'alias commit "npx cz"' | fish

# Append persistent alias to config.fish
echo 'alias commit="npx cz"' >> ~/.config/fish/config.fish

# Define as a function and save it
fish -c 'function commit; npx cz \$argv; end; funcsave commit'

# Use Fish 3.0+ --save method to define and persist alias
fish -c 'alias --save commit="npx cz"'


echo "✅ Done. Restart your terminal or run: source ~/.config/fish/functions/commit.fish"

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
