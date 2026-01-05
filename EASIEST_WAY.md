# Easiest Way to Push (3 commands)

The codespace doesn't have push permissions. Here's the simplest way:

## From Your Local Machine:

```bash
# 1. Download the directory from codespace to your local machine
#    (Use VS Code's file explorer: right-click on /workspaces/Facet/agent-tooling-setup and Download)

# 2. Navigate to where you downloaded it
cd ~/Downloads/agent-tooling-setup

# 3. Run the upload script
./QUICK_UPLOAD.sh
```

That's it! The script will:
- Clone the empty repo
- Copy all files
- Commit and push

## Alternative: Manual Method (if script doesn't work)

```bash
# 1. Clone the repository
git clone https://github.com/jesposito/agent-tooling-setup.git
cd agent-tooling-setup

# 2. Copy files from the downloaded folder
cp -r /path/to/downloaded/agent-tooling-setup/* .
cp -r /path/to/downloaded/agent-tooling-setup/.github .

# 3. Commit and push
git add -A
git commit -m "Initial commit: Agent tooling setup installer"
git push origin main
```

## Or: Use GitHub's Web UI

1. Go to https://github.com/jesposito/agent-tooling-setup
2. Click "Add file" → "Upload files"
3. Drag all files from `/workspaces/Facet/agent-tooling-setup/` (except .git folder)
4. Commit directly to main

Done! 🎉
