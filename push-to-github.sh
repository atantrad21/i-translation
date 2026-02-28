#!/bin/bash

# 🚀 I-Translation Backend - GitHub Push Script
# This script helps you push your backend code to GitHub

echo "=========================================="
echo "🚀 I-Translation Backend - GitHub Push"
echo "=========================================="
echo ""

# Navigate to backend directory
cd /home/sandbox/medical-app-working

echo "📂 Current directory: $(pwd)"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Error: Git is not installed!"
    echo "Please install Git first: https://git-scm.com/downloads"
    exit 1
fi

echo "✅ Git is installed"
echo ""

# Ask for GitHub username
echo "📝 Please enter your GitHub username:"
read -p "Username: " github_username

if [ -z "$github_username" ]; then
    echo "❌ Error: GitHub username cannot be empty!"
    exit 1
fi

echo ""
echo "📝 Please enter your repository name (default: i-translation-backend):"
read -p "Repository name: " repo_name

if [ -z "$repo_name" ]; then
    repo_name="i-translation-backend"
fi

echo ""
echo "🔧 Configuration:"
echo "   GitHub Username: $github_username"
echo "   Repository: $repo_name"
echo "   URL: https://github.com/$github_username/$repo_name"
echo ""

read -p "Is this correct? (y/n): " confirm

if [ "$confirm" != "y" ]; then
    echo "❌ Cancelled by user"
    exit 1
fi

echo ""
echo "=========================================="
echo "Step 1: Initialize Git Repository"
echo "=========================================="

# Check if .git exists
if [ -d ".git" ]; then
    echo "⚠️  Git repository already exists"
    read -p "Do you want to reinitialize? (y/n): " reinit
    if [ "$reinit" == "y" ]; then
        rm -rf .git
        git init
        echo "✅ Git repository reinitialized"
    else
        echo "✅ Using existing Git repository"
    fi
else
    git init
    echo "✅ Git repository initialized"
fi

echo ""
echo "=========================================="
echo "Step 2: Create .gitignore"
echo "=========================================="

cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Flask
instance/
.webassets-cache

# Environment variables
.env
.env.local

# Logs
*.log
logs/
*.log.*

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Temporary files
tmp/
temp/
uploads/
*.tmp

# Analytics data
analytics_data.json
EOF

echo "✅ .gitignore created"

echo ""
echo "=========================================="
echo "Step 3: Add Files to Git"
echo "=========================================="

git add .
echo "✅ Files added to Git"

echo ""
echo "📋 Files to be committed:"
git status --short

echo ""
echo "=========================================="
echo "Step 4: Create Commit"
echo "=========================================="

git commit -m "Initial commit: I-Translation backend with 10GB support"

if [ $? -eq 0 ]; then
    echo "✅ Commit created successfully"
else
    echo "⚠️  Commit failed or no changes to commit"
fi

echo ""
echo "=========================================="
echo "Step 5: Add Remote Repository"
echo "=========================================="

# Check if remote already exists
if git remote | grep -q "origin"; then
    echo "⚠️  Remote 'origin' already exists"
    echo "Current remote URL:"
    git remote get-url origin
    echo ""
    read -p "Do you want to update it? (y/n): " update_remote
    if [ "$update_remote" == "y" ]; then
        git remote remove origin
        git remote add origin "https://github.com/$github_username/$repo_name.git"
        echo "✅ Remote updated"
    else
        echo "✅ Using existing remote"
    fi
else
    git remote add origin "https://github.com/$github_username/$repo_name.git"
    echo "✅ Remote added"
fi

echo ""
echo "=========================================="
echo "Step 6: Rename Branch to 'main'"
echo "=========================================="

git branch -M main
echo "✅ Branch renamed to 'main'"

echo ""
echo "=========================================="
echo "Step 7: Push to GitHub"
echo "=========================================="

echo ""
echo "⚠️  IMPORTANT: Authentication Required"
echo "   Username: Your GitHub username"
echo "   Password: Your Personal Access Token (NOT your password)"
echo ""
echo "📝 Don't have a token? Generate one here:"
echo "   https://github.com/settings/tokens"
echo "   Required scope: 'repo'"
echo ""

read -p "Press Enter to continue with push..."

git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ SUCCESS!"
    echo "=========================================="
    echo ""
    echo "🎉 Your code is now on GitHub!"
    echo ""
    echo "📍 Repository URL:"
    echo "   https://github.com/$github_username/$repo_name"
    echo ""
    echo "🚂 Next Steps:"
    echo "   1. Go to Railway Dashboard: https://railway.app/dashboard"
    echo "   2. Click 'New Project'"
    echo "   3. Select 'Deploy from GitHub repo'"
    echo "   4. Choose: $repo_name"
    echo "   5. Click 'Deploy Now'"
    echo ""
    echo "✅ No more 'Repository is empty' error!"
    echo ""
else
    echo ""
    echo "=========================================="
    echo "❌ PUSH FAILED"
    echo "=========================================="
    echo ""
    echo "Common issues:"
    echo "   1. Authentication failed"
    echo "      → Use Personal Access Token (not password)"
    echo "      → Generate: https://github.com/settings/tokens"
    echo ""
    echo "   2. Repository doesn't exist"
    echo "      → Create it first: https://github.com/new"
    echo "      → Name: $repo_name"
    echo ""
    echo "   3. Permission denied"
    echo "      → Check repository URL is correct"
    echo "      → Verify you have write access"
    echo ""
    echo "📞 Need help? Email: atantrad@gmail.com"
    echo ""
    exit 1
fi

echo "=========================================="
echo "📋 Summary"
echo "=========================================="
echo ""
echo "✅ Git repository initialized"
echo "✅ .gitignore created"
echo "✅ Files committed"
echo "✅ Remote added: https://github.com/$github_username/$repo_name"
echo "✅ Pushed to GitHub"
echo ""
echo "🎯 Your backend is ready for Railway deployment!"
echo ""
