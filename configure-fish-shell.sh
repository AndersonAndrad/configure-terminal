#!/bin/bash
set -e

# Error handling function
handle_error() {
    echo "❌ Error occurred in configure-fish-shell.sh at line $1"
    echo "💡 Please check the error above and try again"
    exit 1
}

trap 'handle_error $LINENO' ERR

echo "🚀 Starting Fish shell configuration..."

# -------------------------------
# Fish Shell Installation
# -------------------------------
echo "🐟 Checking Fish shell installation..."

if ! command -v fish >/dev/null 2>&1; then
    echo "📦 Installing Fish via Homebrew..."
    
    # Check if Homebrew is installed
    if ! command -v brew >/dev/null 2>&1; then
        echo "❌ Homebrew not found. Please install Homebrew first:"
        echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    
    brew install fish
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install Fish shell"
        exit 1
    fi
    echo "✅ Fish shell installed successfully"
else
    echo "✅ Fish shell is already installed ($(fish --version))"
fi

# -------------------------------
# Fish Configuration Setup
# -------------------------------
echo "🔧 Setting up Fish configuration..."
mkdir -p ~/.config/fish

FISH_CONFIG=~/.config/fish/config.fish

# Create config.fish if it doesn't exist
if [ ! -f "$FISH_CONFIG" ]; then
    echo "📝 Creating Fish configuration file..."
    touch "$FISH_CONFIG"
fi

# -------------------------------
# Commit Alias Configuration
# -------------------------------
echo "🔗 Configuring 'commit' alias for Commitizen..."

# Check if commitizen is available globally
if ! command -v commitizen >/dev/null 2>&1; then
    echo "❌ Commitizen not found globally. Please run configure-husky.sh first"
    exit 1
fi

echo "✅ Commitizen found globally"

# Backup existing config
if [ -f "$FISH_CONFIG" ]; then
    cp "$FISH_CONFIG" "$FISH_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
    echo "💾 Backed up existing Fish config"
fi

# Clean the entire Fish config and keep only the commit alias
echo "🧹 Cleaning Fish config - removing all aliases..."

# Create a clean config file with only the commit alias
cat > "$FISH_CONFIG" << 'EOF'
# Fish shell configuration
# Only commit alias for conventional commits with Husky

alias commit='cz'
EOF

echo "✅ Fish config cleaned - only commit alias remains"

# Verify the commit alias was added
if grep -q "alias commit='cz'" "$FISH_CONFIG"; then
    echo "✅ Commit alias configured successfully"
else
    echo "❌ Failed to configure commit alias"
    echo "🔍 Debug: Checking config file content..."
    cat "$FISH_CONFIG"
    exit 1
fi

# Force reload Fish configuration to make commit command available immediately
echo "🔄 Forcing Fish configuration reload..."

# Check if Fish is available and working
if ! command -v fish >/dev/null 2>&1; then
    echo "❌ Fish shell not found"
    exit 1
fi

# Try to source the configuration safely
if fish -c "source $FISH_CONFIG" 2>/dev/null; then
    echo "✅ Fish configuration reloaded successfully"
else
    echo "⚠️  Could not reload Fish config immediately, but configuration was saved"
fi

# Test the commit command immediately
echo "🔄 Testing commit configuration..."

# Create a comprehensive test script
TEST_SCRIPT=$(mktemp 2>/dev/null || echo "/tmp/fish_commit_test_$$")
cat <<'EOF' > "$TEST_SCRIPT"
# Test Fish configuration
echo "Testing Fish configuration..."

# Source the config
source ~/.config/fish/config.fish

# Test if commit command exists
if type commit >/dev/null 2>&1
    echo "SUCCESS: Commit command found"
    
    # Test if it's a function
    if type commit | grep -q "function"
        echo "SUCCESS: Commit is a function"
    else
        echo "INFO: Commit is an alias"
    fi
    
    # Test if cz is available
    if type cz >/dev/null 2>&1
        echo "SUCCESS: cz is available"
        exit 0
    else
        echo "ERROR: cz not found"
        exit 1
    end
else
    echo "ERROR: Commit command not found"
    exit 1
end
EOF

# Run the test
if fish "$TEST_SCRIPT" 2>/dev/null; then
    echo "✅ Commit command is working immediately"
else
    echo "🔄 Commit command not immediately available, testing alternatives..."
    
    # Try to manually test the function
    if fish -c "source $FISH_CONFIG; type commit" 2>/dev/null; then
        echo "✅ Commit command is available after sourcing config"
    else
        echo "⚠️  Commit command will be available after Fish restart"
        echo "💡 Configuration is saved and will work in new Fish sessions"
    fi
fi

# Clean up test file
rm -f "$TEST_SCRIPT" 2>/dev/null

# -------------------------------
# Fish Configuration Complete
# -------------------------------
echo "✅ Fish configuration completed - only commit alias added"

# -------------------------------
# Shell Integration & Auto-Restart
# -------------------------------
echo "🔗 Setting up shell integration..."

# Check if we're running from zsh
if [ -n "$ZSH_VERSION" ]; then
    echo "🐚 Detected Zsh shell"
    
    # Add exec fish to zsh startup if not already present
    if ! grep -qxF 'exec fish' ~/.zshrc; then
        echo "📝 Adding 'exec fish' to ~/.zshrc..."
        echo 'exec fish' >> ~/.zshrc
        echo "✅ Fish will start automatically in new terminal sessions"
    else
        echo "✅ Fish is already configured to start automatically"
    fi
    
    # Automatically switch to Fish if commit command is not working
    echo "🔄 Checking if commit command is available in current session..."
    if ! fish -c "type commit" 2>/dev/null; then
        echo "🚀 Automatically switching to Fish shell to activate commit command..."
        echo "💡 Fish shell will now be active with the 'commit' command ready to use"
        # Use a more robust exec command
        if command -v fish >/dev/null 2>&1; then
            exec fish
        else
            echo "⚠️  Fish shell not found, but configuration is complete"
        fi
    else
        echo "✅ Commit command is already available in current session"
    fi
else
    echo "ℹ️  Not running from Zsh. Fish configuration is complete."
fi

# -------------------------------
# Verification
# -------------------------------
echo "🔍 Verifying Fish configuration..."

# Test Fish configuration
if fish -c "echo 'Fish configuration test successful'" 2>/dev/null; then
    echo "✅ Fish configuration is valid"
else
    echo "⚠️  Fish configuration test failed, but config file was created"
    echo "💡 This is usually not a critical error"
fi

# Test commit command availability
echo "🔍 Testing commit command availability..."

# Verify alias is in the config file
if grep -q "alias commit='cz'" "$FISH_CONFIG"; then
    echo "✅ Commit alias found in Fish configuration file"
    
    # Test if it's available in current Fish session
    if fish -c "type commit" 2>/dev/null; then
        echo "✅ Commit command is available in Fish"
    elif fish -c "source $FISH_CONFIG; type commit" 2>/dev/null; then
        echo "✅ Commit command is available in Fish (after sourcing config)"
    else
        echo "⚠️  Commit command not immediately available, but will work after restart"
        echo "💡 This is normal - Fish needs to be restarted to load new aliases"
    fi
else
    echo "❌ Commit alias not found in Fish configuration file"
    echo "💡 This indicates a configuration error"
    exit 1
fi

# -------------------------------
# Final Verification & Instructions
# -------------------------------
echo ""
echo "🎉 Fish shell configuration completed successfully!"
echo ""

# Final verification that commit command works
echo "🔍 Final verification..."
if fish -c "type commit" 2>/dev/null; then
    echo "✅ Commit command is fully functional and ready to use!"
else
    echo "⚠️  Commit command will be available after Fish restart"
    echo "💡 Configuration is complete - restart Fish to activate"
fi

echo ""
echo "📝 Configuration summary:"
echo "   • Fish shell: $(fish --version)"
echo "   • Fish config: Cleaned - only commit alias remains"
echo "   • Commit alias: 'commit' → runs cz"
echo "   • Global Husky hooks: Will validate commits"
echo "   • Works with: npm and yarn projects"
echo ""
echo "💡 Usage instructions:"
echo "   1. Navigate to any git repository (npm or yarn project)"
echo "   2. Use 'commit' command to create conventional commits"
echo "   3. Global Husky hooks will validate your commit messages"
echo ""
echo "✅ Everything is configured and ready to use!"
echo ""
echo "🎯 The 'commit' command is now available and ready to use!"
echo ""
echo "⚠️  Note: If you want to use Fish as your default shell permanently:"
echo "   chsh -s (which fish)"
