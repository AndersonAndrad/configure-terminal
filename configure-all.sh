#!/bin/bash
set -e

# Error handling function
handle_error() {
    echo "❌ Error occurred in configure-all.sh at line $1"
    echo "💡 Please check the error above and try again"
    exit 1
}

trap 'handle_error $LINENO' ERR

echo "🚀 Starting complete terminal configuration..."
echo "📋 This will configure:"
echo "   • Global Husky hooks for commit validation"
echo "   • Commitizen for conventional commits"
echo "   • Fish shell with 'commit' alias"
echo "   • Enhanced development environment"
echo ""

# Call the separate setup scripts
echo "🔧 Step 1/2: Configuring Husky and Commitlint..."
bash ./configure-husky.sh

echo ""
echo "🔧 Step 2/2: Configuring Fish shell..."
bash ./configure-fish-shell.sh

echo ""
echo "🎉 Complete configuration finished successfully!"
echo ""
echo "📝 What was configured:"
echo "   ✅ Global Husky hooks (validates all commits)"
echo "   ✅ Commitizen (conventional commit tool)"
echo "   ✅ Commitlint (commit message validation)"
echo "   ✅ Fish shell with 'commit' alias"
echo "   ✅ Enhanced Fish prompt with git info"
echo "   ✅ Development-friendly aliases"
echo ""
echo "💡 Next steps:"
echo "   1. Navigate to any git repository (npm or yarn project)"
echo "   2. Use 'commit' command to create conventional commits"
echo "   3. All commits will be automatically validated by Husky"
echo ""
echo "🔧 Usage examples:"
echo "   • commit          # Interactive conventional commit"
echo "   • gs              # git status"
echo "   • ga .            # git add ."
echo "   • gp              # git push"
echo ""
echo "✅ Everything is configured and ready to use immediately!"
echo "🎯 No manual commands needed - the 'commit' command is now active!"
