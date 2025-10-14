#!/bin/bash
set -e
trap 'echo "❌ Error in configure-fish-shell.sh at line $LINENO"; exit 1' ERR

echo "🐟 Configuring Fish shell..."

export NVM_DIR="$HOME/.nvm"
source "$(brew --prefix nvm)/nvm.sh"
nvm install --lts >/dev/null
nvm use --lts >/dev/null

NODE_BIN_PATH="$(dirname "$(command -v node)")"
NPM_GLOBAL_BIN="$(npm bin -g 2>/dev/null || echo "$NODE_BIN_PATH")"

mkdir -p ~/.config/fish
FISH_CONFIG=~/.config/fish/config.fish
if [ -f "$FISH_CONFIG" ]; then
  cp "$FISH_CONFIG" "$FISH_CONFIG.backup.$(date +%s)"
fi

cat <<EOF > "$FISH_CONFIG"
# Auto-generated Fish config
set -Ux PATH "$NODE_BIN_PATH" "$NPM_GLOBAL_BIN" \$PATH
alias commit='cz && echo "# CZ run" >> .git/COMMIT_EDITMSG'
EOF

if ! grep -q "$(which fish)" /etc/shells; then
  echo "$(which fish)" | sudo tee -a /etc/shells >/dev/null
fi
chsh -s "$(which fish)"

echo "✅ Fish configured and set as default shell"
