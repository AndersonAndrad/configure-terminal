#!/bin/bash
set -e
trap 'echo "❌ Error in configure-nvm.sh at line $LINENO"; exit 1' ERR

echo "📦 Installing NVM via Homebrew..."
brew install nvm
mkdir -p ~/.nvm ~/.config/fish/functions

# Fish helper
cat <<'EOF' > ~/.config/fish/functions/nvm.fish
function nvm
    bass source (brew --prefix nvm)/nvm.sh ';' nvm $argv
end
EOF

# Environment init
mkdir -p ~/.config/fish/conf.d
cat <<'EOF' > ~/.config/fish/conf.d/nvm_init.fish
set -x NVM_DIR $HOME/.nvm
EOF

echo "✅ NVM installed and Fish integration ready"
