# Setup Instructions for GitHub Repository

This repository is ready to be pushed to GitHub. Follow these steps:

## Step 1: Create GitHub Repository

Go to GitHub and create a new repository:

1. Visit https://github.com/new
2. Repository name: `agent-tooling-setup` (or your preferred name)
3. Description: "One-command setup for AI agent development (Empirica + Beads + Perles)"
4. Choose: **Public** (recommended for easy sharing)
5. **DO NOT** initialize with README, .gitignore, or license (we already have these)
6. Click "Create repository"

## Step 2: Push This Repository

Copy the commands from the GitHub "push an existing repository" section, or use these:

```bash
# Navigate to the repository
cd /tmp/agent-tooling-setup

# Add your GitHub remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/agent-tooling-setup.git

# Or using SSH:
# git remote add origin git@github.com:YOUR_USERNAME/agent-tooling-setup.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 3: Update README with Your Username

After pushing, update the README with your actual GitHub username:

```bash
# Edit README.md and replace YOUR_GITHUB_USERNAME with your actual username
# Then commit and push:
git add README.md
git commit -m "Update installation URLs with actual username"
git push
```

Or do it in one command:

```bash
# Replace YOUR_ACTUAL_USERNAME below
sed -i 's/YOUR_GITHUB_USERNAME/YOUR_ACTUAL_USERNAME/g' README.md
git add README.md
git commit -m "Update installation URLs"
git push
```

## Step 4: Enable GitHub Actions (Optional)

The repository includes automated testing via GitHub Actions. To enable:

1. Go to your repository on GitHub
2. Click "Actions" tab
3. Click "I understand my workflows, go ahead and enable them"

Tests will run automatically on every push and pull request.

## Step 5: Create a Release (Optional)

To make it easy for users to download:

1. Go to your repository on GitHub
2. Click "Releases" → "Create a new release"
3. Tag version: `v1.0.0`
4. Release title: "Initial Release"
5. Description: Paste the feature list from README
6. Click "Publish release"

## Usage After Setup

Once pushed to GitHub, users can install with:

### Recommended (Review First)

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/agent-tooling-setup/main/install.sh -o install.sh
chmod +x install.sh
./install.sh
```

### One-Liner (For Trusted Repos)

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/agent-tooling-setup/main/install.sh | bash
```

### Git Clone

```bash
git clone https://github.com/YOUR_USERNAME/agent-tooling-setup.git
cd agent-tooling-setup
./install.sh
```

## Sharing

Share your repository:

- Link: `https://github.com/YOUR_USERNAME/agent-tooling-setup`
- Clone: `git clone https://github.com/YOUR_USERNAME/agent-tooling-setup.git`
- Install: See "Usage After Setup" above

## Maintaining

To make updates:

```bash
cd /tmp/agent-tooling-setup

# Make changes...
git add .
git commit -m "Description of changes"
git push

# Update version and tag for releases
# Edit version in install.sh, then:
git tag v1.0.1
git push --tags
```

## Repository Structure

```
agent-tooling-setup/
├── .github/
│   └── workflows/
│       └── test.yml           # CI testing
├── install.sh                 # Main installer
├── uninstall.sh              # Uninstaller
├── README.md                 # User documentation
├── LICENSE                   # MIT license
├── Makefile                  # Build/test tasks
└── SETUP.md                  # This file
```

## Next Steps

1. Push to GitHub (see Step 2)
2. Update README with your username (see Step 3)
3. Test the installation from GitHub
4. Share with others!

## Questions?

- Review README.md for user documentation
- Review install.sh for technical details
- Test with: `make test`
