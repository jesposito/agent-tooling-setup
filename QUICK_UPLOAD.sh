#!/usr/bin/env bash
# Quick upload script - Run this from your LOCAL machine (not codespace)

echo "Agent Tooling Setup - Quick Upload"
echo "====================================="
echo ""
echo "This script will push the files to GitHub from your local machine."
echo ""
echo "Prerequisites:"
echo "  - Git installed"
echo "  - GitHub credentials configured (git config user.name/email)"
echo "  - Push access to jesposito/agent-tooling-setup"
echo ""
read -p "Press Enter to continue..."

# Clone the repo
echo ""
echo "Cloning repository..."
git clone https://github.com/jesposito/agent-tooling-setup.git /tmp/agent-tooling-upload
cd /tmp/agent-tooling-upload

# Copy files from current directory
echo "Copying files..."
cp -r "$(dirname "$0")"/* . 2>/dev/null || true
cp -r "$(dirname "$0")/.github" . 2>/dev/null || true

# Remove this script and git directory
rm -rf .git
git init
rm -f QUICK_UPLOAD.sh

# Commit
echo "Committing..."
git add -A
git commit -m "Initial commit: Agent tooling setup installer

- Empirica + Beads + Perles integration
- Cross-platform installer script
- Uninstaller with safety checks
- GitHub Actions CI testing
- Comprehensive documentation"

# Add remote and push
echo "Pushing to GitHub..."
git remote add origin https://github.com/jesposito/agent-tooling-setup.git
git branch -M main
git push -u origin main

echo ""
echo "✓ Successfully pushed to GitHub!"
echo ""
echo "Repository: https://github.com/jesposito/agent-tooling-setup"
echo ""
