#!/bin/bash
set -e

# Call the separate setup scripts
bash ./setup-husky.sh
bash ./setup-fish.sh

echo "✅ Full global setup complete! Restart your terminal to apply changes."
