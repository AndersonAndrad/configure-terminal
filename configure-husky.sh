#!/bin/bash
set -e

# Error handling function
handle_error() {
    echo "❌ Error occurred in configure-husky.sh at line $1"
    echo "💡 Please check the error above and try again"
    exit 1
}

trap 'handle_error $LINENO' ERR

echo "🚀 Starting Husky global configuration..."

# -------------------------------
# NVM + Node.js Setup
# -------------------------------
echo "📦 Checking NVM installation..."
export NVM_DIR="$HOME/.nvm"

if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    echo "📥 Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install NVM"
        exit 1
    fi
else
    echo "✅ NVM is already installed"
fi

echo "📥 Loading NVM..."
source "$NVM_DIR/nvm.sh"

echo "📦 Installing Node.js LTS..."
nvm install --lts
nvm use --lts

# Verify Node.js installation
if ! command -v node >/dev/null 2>&1; then
    echo "❌ Node.js installation failed"
    exit 1
fi
echo "✅ Node.js $(node --version) installed successfully"

# -------------------------------
# Global npm packages
# -------------------------------
echo "📦 Installing global npm packages..."
echo "📥 Installing: husky, commitlint, commitizen..."

# Install packages one by one to ensure they're properly installed
echo "📥 Installing husky..."
npm install -g husky

echo "📥 Installing commitlint..."
npm install -g @commitlint/cli @commitlint/config-conventional

echo "📥 Installing commitizen..."
npm install -g commitizen cz-conventional-changelog

# Verify installations
echo "🔍 Verifying installations..."
if ! command -v commitlint >/dev/null 2>&1; then
    echo "❌ Commitlint not found after installation"
    echo "🔄 Trying to fix PATH..."
    export PATH="$PATH:$(npm config get prefix)/bin"
fi

if ! command -v commitizen >/dev/null 2>&1; then
    echo "❌ Commitizen not found after installation"
    echo "🔄 Trying to fix PATH..."
    export PATH="$PATH:$(npm config get prefix)/bin"
fi

echo "✅ Global npm packages installation completed"

# -------------------------------
# Commitizen Setup
# -------------------------------
echo "🛠️ Configuring Commitizen..."
echo '{ "path": "cz-conventional-changelog" }' > ~/.czrc

if [ ! -f ~/.czrc ]; then
    echo "❌ Failed to create Commitizen configuration"
    exit 1
fi
echo "✅ Commitizen configuration created"

# -------------------------------
# Commitlint Setup
# -------------------------------
echo "🧩 Creating Commitlint configuration..."
mkdir -p ~/.config/commitlint

# Create a simple config that doesn't require external modules
cat <<EOF > ~/.config/commitlint/commitlint.config.js
module.exports = {
  rules: {
    "type-enum": [
      2,
      "always",
      ["feat", "fix", "docs", "style", "refactor", "test", "chore", "perf", "build", "ci", "revert"]
    ],
    "type-case": [2, "always", "lower-case"],
    "type-empty": [2, "never"],
    "subject-case": [2, "never"],
    "subject-empty": [2, "never"],
    "subject-full-stop": [2, "never", "."],
    "header-max-length": [2, "always", 150],
    "body-max-line-length": [2, "always", 100],
    "footer-max-line-length": [2, "always", 100]
  }
};
EOF

# Also create a JSON config as fallback
cat <<EOF > ~/.config/commitlint/commitlint.config.json
{
  "rules": {
    "type-enum": [2, "always", ["feat", "fix", "docs", "style", "refactor", "test", "chore", "perf", "build", "ci", "revert"]],
    "type-case": [2, "always", "lower-case"],
    "type-empty": [2, "never"],
    "subject-case": [2, "never"],
    "subject-empty": [2, "never"],
    "subject-full-stop": [2, "never", "."],
    "header-max-length": [2, "always", 150],
    "body-max-line-length": [2, "always", 100],
    "footer-max-line-length": [2, "always", 100]
  }
}
EOF

if [ ! -f ~/.config/commitlint/commitlint.config.js ]; then
    echo "❌ Failed to create Commitlint configuration"
    exit 1
fi
echo "✅ Commitlint configuration created"

# -------------------------------
# Husky Global Hooks
# -------------------------------
echo "🔧 Setting up Husky global hooks..."
mkdir -p ~/.husky

echo "🔧 Configuring Git to use global hooks..."
git config --global core.hooksPath ~/.husky

echo "📎 Creating commit-msg hook..."
cat <<'EOF' > ~/.husky/commit-msg
#!/bin/sh
# Global Husky commit-msg hook for commitlint validation
# Works with both npm and yarn projects

# Fix PATH to include npm global bin directory
export PATH="$PATH:$(npm config get prefix)/bin"

# Find Node.js binary
NODE_BIN=$(which node 2>/dev/null)
if [ -z "$NODE_BIN" ]; then
    echo "❌ Node.js not found in PATH"
    exit 1
fi

# Find commitlint binary with multiple fallback methods
COMMITLINT_BIN=""

# Method 1: Direct path
if command -v commitlint >/dev/null 2>&1; then
    COMMITLINT_BIN=$(which commitlint)
fi

# Method 2: Try npx with proper flags
if [ -z "$COMMITLINT_BIN" ]; then
    if command -v npx >/dev/null 2>&1; then
        # Test if commitlint is available via npx without installing
        if npx --no-install commitlint --version >/dev/null 2>&1; then
            COMMITLINT_BIN="npx --no-install commitlint"
        elif npx --yes commitlint --version >/dev/null 2>&1; then
            COMMITLINT_BIN="npx --yes commitlint"
        fi
    fi
fi

# Method 3: Try yarn
if [ -z "$COMMITLINT_BIN" ]; then
    if command -v yarn >/dev/null 2>&1; then
        COMMITLINT_BIN="yarn commitlint"
    fi
fi

# Method 4: Try npm
if [ -z "$COMMITLINT_BIN" ]; then
    if command -v npm >/dev/null 2>&1; then
        COMMITLINT_BIN="npm exec commitlint"
    fi
fi

if [ -z "$COMMITLINT_BIN" ]; then
    echo "❌ Commitlint not found. Please run configure-husky.sh first"
    echo "💡 Tried: commitlint, npx, yarn, npm"
    exit 1
fi

# Get commit message file
MSG_FILE="${1:-.git/COMMIT_EDITMSG}"

# Check if config file exists and try different formats
CONFIG_FILE=""
if [ -f "$HOME/.config/commitlint/commitlint.config.js" ]; then
    CONFIG_FILE="$HOME/.config/commitlint/commitlint.config.js"
elif [ -f "$HOME/.config/commitlint/commitlint.config.json" ]; then
    CONFIG_FILE="$HOME/.config/commitlint/commitlint.config.json"
fi

if [ -z "$CONFIG_FILE" ]; then
    echo "⚠️  Commitlint config not found, using basic validation"
    # Basic validation without config
    if echo "$(cat "$MSG_FILE")" | grep -E "^(feat|fix|docs|style|refactor|test|chore|perf|build|ci|revert)(\(.+\))?: .+" >/dev/null; then
        echo "✅ Commit message format is valid"
        exit 0
    else
        echo "❌ Commit message format is invalid"
        echo "💡 Expected format: type(scope): description"
        echo "💡 Valid types: feat, fix, docs, style, refactor, test, chore, perf, build, ci, revert"
        exit 1
    fi
fi

# Validate commit message with config
echo "🔍 Validating commit message with: $COMMITLINT_BIN"
echo "🔍 Using config: $CONFIG_FILE"
$COMMITLINT_BIN --edit "$MSG_FILE" --config "$CONFIG_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Commit message validation passed"
else
    echo "❌ Commit message validation failed"
    exit 1
fi
EOF

chmod +x ~/.husky/commit-msg

if [ ! -x ~/.husky/commit-msg ]; then
    echo "❌ Failed to create executable commit-msg hook"
    exit 1
fi
echo "✅ Commit-msg hook created and made executable"

# -------------------------------
# Global Git Configuration
# -------------------------------
echo "🧬 Setting Git global init template..."
git config --global init.templateDir ~/.husky

echo "🔧 Setting Git global configuration..."
git config --global core.autocrlf input
git config --global core.safecrlf true

echo "✅ Git global configuration updated"

# -------------------------------
# Verification
# -------------------------------
echo "🔍 Verifying installation..."

# Test commitlint configuration with multiple methods
echo "🔍 Testing commitlint availability..."

commitlint_available=false

# Test direct command
if command -v commitlint >/dev/null 2>&1; then
    echo "✅ Commitlint is available globally"
    commitlint_available=true
elif command -v npx >/dev/null 2>&1 && (npx --no-install commitlint --version >/dev/null 2>&1 || npx --yes commitlint --version >/dev/null 2>&1); then
    echo "✅ Commitlint is available via npx"
    commitlint_available=true
elif command -v yarn >/dev/null 2>&1 && yarn commitlint --version >/dev/null 2>&1; then
    echo "✅ Commitlint is available via yarn"
    commitlint_available=true
elif command -v npm >/dev/null 2>&1 && npm exec commitlint --version >/dev/null 2>&1; then
    echo "✅ Commitlint is available via npm"
    commitlint_available=true
fi

if [ "$commitlint_available" = false ]; then
    echo "❌ Commitlint not found with any method"
    echo "💡 This might cause issues with commit validation"
    echo "⚠️  Continuing anyway - the hook will try multiple methods"
fi

# Test commitizen configuration
if command -v commitizen >/dev/null 2>&1; then
    echo "✅ Commitizen is available globally"
else
    echo "❌ Commitizen not found in PATH"
    exit 1
fi

echo ""
echo "🎉 Husky global configuration completed successfully!"
echo "📝 You can now use 'commit' alias in your shell to run Commitizen"
echo "🔧 Global commit-msg hook will validate all commits using commitlint"
echo "📦 Works with both npm and yarn projects"
echo ""
echo "💡 Next steps:"
echo "   1. Run configure-fish-shell.sh to set up the 'commit' alias"
echo "   2. Restart your terminal"
echo "   3. Use 'commit' command in any git repository"
