#!/bin/bash

# Setup GitHub repository for gummy-agent

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_NAME="gummy-agent"
ORG="WillyV3"

echo ""
echo "Setting up GitHub repository: ${ORG}/${REPO_NAME}"
echo ""

# Create repository
echo -e "${BLUE}→${NC} Creating GitHub repository..."
gh repo create "${ORG}/${REPO_NAME}" \
  --public \
  --description "Fast multi-agent orchestration using Claude Haiku with real-time TUI monitoring" \
  --clone=false

echo -e "${GREEN}✓${NC} Repository created"

# Initialize git if not already
if [ ! -d .git ]; then
    echo -e "${BLUE}→${NC} Initializing git..."
    git init
    git branch -M main
fi

# Add remote
echo -e "${BLUE}→${NC} Adding remote..."
git remote add origin "git@github.com:${ORG}/${REPO_NAME}.git" 2>/dev/null || \
git remote set-url origin "git@github.com:${ORG}/${REPO_NAME}.git"

# Create .gitignore
echo -e "${BLUE}→${NC} Creating .gitignore..."
cat > .gitignore << 'EOF'
# Binaries
gummy-watch

# Go
*.test
*.prof
vendor/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log
EOF

# Initial commit
echo -e "${BLUE}→${NC} Creating initial commit..."
git add -A
git commit -m "Initial commit: gummy-agent v0.1.0

Fast multi-agent orchestration system using Claude Haiku 4.5

Features:
- Plan mode for complex tasks
- Execute mode for approved plans
- Task mode for simple operations
- Real-time TUI monitoring with markdown rendering
- Clipboard integration"

# Push to GitHub
echo -e "${BLUE}→${NC} Pushing to GitHub..."
git push -u origin main

echo ""
echo -e "${GREEN}✓${NC} Setup complete!"
echo ""
echo "Repository: https://github.com/${ORG}/${REPO_NAME}"
echo ""
echo "Next steps:"
echo "  1. Review the repository"
echo "  2. Run: ./release.sh patch"
echo ""
