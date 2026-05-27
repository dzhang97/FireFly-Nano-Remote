#!/bin/bash

# --- Configuration ---
# You can change these variables or let the script prompt you
DEFAULT_NAME="Your Name"
DEFAULT_EMAIL="your-email@example.com"

echo "--- Git Repository Configuration Setup ---"

# 1. Setup Username
read -p "Enter Git Username [$DEFAULT_NAME]: " USER_NAME
USER_NAME=${USER_NAME:-$DEFAULT_NAME}
git config user.name "$USER_NAME"
echo "✅ Username set to: $USER_NAME"

# 2. Setup Email
read -p "Enter Git Email [$DEFAULT_EMAIL]: " USER_EMAIL
USER_EMAIL=${USER_EMAIL:-$DEFAULT_EMAIL}
git config user.email "$USER_EMAIL"
echo "✅ Email set to: $USER_EMAIL"

# 3. Setup Credential Helper
echo ""
echo "Which credential helper would you like to use?"
echo "1) Store (saves to disk - plaintext)"
echo "2) Cache (saves in memory temporarily)"
echo "3) OS Keychain (macOS/Windows)"
echo "4) None/Skip"
read -p "Selection [1-4]: " HELPER_CHOICE

case $HELPER_CHOICE in
    1)
        git config credential.helper store
        echo "✅ Credential helper set to 'store'."
        ;;
    2)
        git config credential.helper cache
        echo "✅ Credential helper set to 'cache'."
        ;;
    3)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            git config credential.helper osxkeychain
            echo "✅ Credential helper set to 'osxkeychain'."
        elif [[ "$OSTYPE" == "msys" ]]; then
            git config credential.helper wincred
            echo "✅ Credential helper set to 'wincred'."
        else
            echo "❌ OS Keychain not supported on this platform."
        fi
        ;;
    *)
        echo "⏩ Skipping credential helper setup."
        ;;
esac

echo ""
echo "--- Current Local Configuration ---"
git config --list | grep -E "user.name|user.email|credential.helper"
echo ""
echo "Done! Remember: If using HTTPS, use a Personal Access Token (PAT) instead of your GitHub password."
