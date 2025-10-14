#!/bin/bash
set -e
trap 'echo "❌ Error at line $LINENO"; exit 1' ERR

echo "🚀 Starting full environment setup..."

echo "🔧 Step 1/3: NVM setup (Homebrew)"
bash ./configure-nvm.sh

echo "🐟 Step 2/3: Fish shell setup"
bash ./configure-fish-shell.sh

echo "🪝 Step 3/3: Husky + Commitizen + Commitlint"
bash ./configure-husky.sh

echo ""
echo "🎉 All configuration complete!"
echo "💡 Use:"
echo "   • commit     → opens Commitizen and runs commitlint automatically"
echo "   • git commit → normal git commit (commitlint skipped)"
