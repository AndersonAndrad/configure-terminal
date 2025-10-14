#!/bin/bash
set -e
trap 'echo "❌ Error in configure-husky.sh at line $LINENO"; exit 1' ERR

echo "🪝 Configuring Husky + Commitlint + Commitizen..."

export NVM_DIR="$HOME/.nvm"
source "$(brew --prefix nvm)/nvm.sh"
nvm use --lts >/dev/null

npm install -g husky @commitlint/cli @commitlint/config-conventional commitizen cz-conventional-changelog >/dev/null

echo '{ "path": "cz-conventional-changelog" }' > ~/.czrc

mkdir -p ~/.config/commitlint
cat <<'EOF' > ~/.config/commitlint/commitlint.config.js
module.exports = {
  rules: {
    "type-enum": [2,"always",["feat","fix","docs","style","refactor","test","chore","perf","build","ci","revert"]],
    "header-max-length": [0],
    "subject-empty": [0],
    "subject-case": [0],
    "scope-empty": [0]
  }
};
EOF

mkdir -p ~/.husky
git config --global core.hooksPath ~/.husky

# Hook triggers commitlint only for Commitizen commits
cat <<'EOF' > ~/.husky/commit-msg
#!/bin/bash
MSG_FILE="$1"
COMMIT_MSG=$(cat "$MSG_FILE")

# Run commitlint only when Commitizen alias is used
if echo "$COMMIT_MSG" | grep -q "^# CZ"; then
  if command -v commitlint >/dev/null 2>&1; then
    commitlint --config "$HOME/.config/commitlint/commitlint.config.js" --edit "$MSG_FILE"
    exit $?
  fi
fi
exit 0
EOF

chmod +x ~/.husky/commit-msg
echo "✅ Husky and Commitlint configured globally"
