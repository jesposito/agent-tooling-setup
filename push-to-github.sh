#!/usr/bin/env bash
set -e

echo "=============================================="
echo "  Pushing agent-tooling-setup to GitHub"
echo "=============================================="
echo ""

# Check if remote exists
if ! git remote get-url origin &> /dev/null; then
    echo "Adding remote origin..."
    git remote add origin https://github.com/jesposito/agent-tooling-setup.git
fi

echo "Repository will be pushed to:"
echo "  https://github.com/jesposito/agent-tooling-setup"
echo ""

# Check if repo exists
echo "Checking if repository exists on GitHub..."
if gh repo view jesposito/agent-tooling-setup &> /dev/null; then
    echo "✓ Repository exists!"
else
    echo ""
    echo "⚠️  Repository does not exist yet."
    echo ""
    echo "Please create it manually:"
    echo "  1. Go to: https://github.com/new"
    echo "  2. Repository name: agent-tooling-setup"
    echo "  3. Description: One-command setup for AI agent development (Empirica + Beads + Perles)"
    echo "  4. Make it: Public"
    echo "  5. DO NOT initialize with README, .gitignore, or license"
    echo "  6. Click 'Create repository'"
    echo ""
    read -p "Press Enter after creating the repository..."
    echo ""
fi

# Push to GitHub
echo "Pushing to GitHub..."
git push -u origin main

echo ""
echo "=============================================="
echo "  ✓ Successfully pushed to GitHub!"
echo "=============================================="
echo ""
echo "Repository URL: https://github.com/jesposito/agent-tooling-setup"
echo ""
echo "Users can now install with:"
echo "  curl -fsSL https://raw.githubusercontent.com/jesposito/agent-tooling-setup/main/install.sh | bash"
echo ""
