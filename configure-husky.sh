#!/bin/bash
set -e

# -------------------------------
# NVM + Node.js Setup
# -------------------------------
echo "📦 Ensuring NVM is installed..."
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] || curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
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
cat <<'EOF' > ~/.husky/commit-msg
#!/bin/sh
# Ensure Node and commitlint are resolved globally
NODE_BIN=$(which node)
COMMITLINT_BIN=$(which commitlint)

# fallback if not found
[ -z "$COMMITLINT_BIN" ] && COMMITLINT_BIN="npx --no -- commitlint"

MSG_FILE="${1:-.git/COMMIT_EDITMSG}"

$NODE_BIN $COMMITLINT_BIN --edit "$MSG_FILE" --config ~/.config/commitlint/commitlint.config.js
EOF

chmod +x ~/.husky/commit-msg

echo "🧬 Setting Git global init template (optional)..."
git config --global init.templateDir ~/.husky

echo "✅ Husky and Commitlint configured globally."
