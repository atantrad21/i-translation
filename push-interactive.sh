#!/bin/bash

# Interactive script to push to GitHub

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║         🚀 Push I-Translation Backend to GitHub             ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

cd /home/sandbox/medical-app-working

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not a git repository!"
    echo "This shouldn't happen. Please report this issue."
    exit 1
fi

echo "✅ Git repository detected"
echo ""

# Ask for GitHub username
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 STEP 1: GitHub Username"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Please enter your GitHub username:"
read -p "Username: " github_username

if [ -z "$github_username" ]; then
    echo "❌ Error: Username cannot be empty!"
    exit 1
fi

echo ""
echo "✅ Username: $github_username"
echo ""

# Ask for repository name
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 STEP 2: Repository Name"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Enter repository name (press Enter for default):"
read -p "Repository [i-translation-backend]: " repo_name

if [ -z "$repo_name" ]; then
    repo_name="i-translation-backend"
fi

echo ""
echo "✅ Repository: $repo_name"
echo ""

# Confirm details
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 CONFIRMATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "GitHub URL: https://github.com/$github_username/$repo_name"
echo ""
read -p "Is this correct? (y/n): " confirm

if [ "$confirm" != "y" ]; then
    echo "❌ Cancelled. Please run the script again."
    exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 STEP 3: Adding Remote"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if remote already exists
if git remote | grep -q "origin"; then
    echo "⚠️  Remote 'origin' already exists"
    echo "Current URL: $(git remote get-url origin)"
    echo ""
    read -p "Update to new URL? (y/n): " update_remote
    if [ "$update_remote" == "y" ]; then
        git remote remove origin
        git remote add origin "https://github.com/$github_username/$repo_name.git"
        echo "✅ Remote updated"
    else
        echo "✅ Keeping existing remote"
    fi
else
    git remote add origin "https://github.com/$github_username/$repo_name.git"
    echo "✅ Remote added: https://github.com/$github_username/$repo_name.git"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 STEP 4: Renaming Branch"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

git branch -M main
echo "✅ Branch renamed to 'main'"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 STEP 5: Pushing to GitHub"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⚠️  IMPORTANT: Authentication Required"
echo ""
echo "You will be prompted for:"
echo "  • Username: Your GitHub username"
echo "  • Password: Your Personal Access Token (NOT your password!)"
echo ""
echo "🔑 Don't have a token?"
echo "   Generate one: https://github.com/settings/tokens"
echo "   Required scope: 'repo'"
echo ""
read -p "Press Enter to continue with push..."
echo ""

git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║                    ✅ SUCCESS!                               ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "🎉 Your code is now on GitHub!"
    echo ""
    echo "📍 Repository URL:"
    echo "   https://github.com/$github_username/$repo_name"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🚂 NEXT: Deploy to Railway"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "1. Go to: https://railway.app/dashboard"
    echo "2. Click: 'New Project'"
    echo "3. Select: 'Deploy from GitHub repo'"
    echo "4. Choose: $repo_name"
    echo "5. Click: 'Deploy Now'"
    echo ""
    echo "✅ No more 'Repository is empty' error!"
    echo ""
else
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║                    ❌ PUSH FAILED                            ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Common issues:"
    echo ""
    echo "1. Authentication failed"
    echo "   → Use Personal Access Token (not password)"
    echo "   → Generate: https://github.com/settings/tokens"
    echo ""
    echo "2. Repository doesn't exist"
    echo "   → Create it: https://github.com/new"
    echo "   → Name: $repo_name"
    echo "   → Then run this script again"
    echo ""
    echo "3. Permission denied"
    echo "   → Check repository URL is correct"
    echo "   → Verify you have write access"
    echo ""
    echo "📞 Need help? Email: atantrad@gmail.com"
    echo ""
    exit 1
fi
