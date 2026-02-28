#!/bin/bash

echo "========================================"
echo "📦 Push QUAD-GAN Backend to GitHub"
echo "========================================"
echo ""
echo "Current status:"
echo "  ✅ Code committed locally"
echo "  ✅ Git repository initialized"
echo ""
echo "You need:"
echo "  1. GitHub repository URL"
echo "  2. GitHub authentication (Personal Access Token)"
echo ""
echo "Don't have a repository? Create one at:"
echo "  https://github.com/new"
echo ""
read -p "Enter your GitHub repository URL: " REPO_URL

if [ -z "$REPO_URL" ]; then
    echo "❌ No URL provided. Exiting."
    exit 1
fi

echo ""
echo "Adding remote repository..."
git remote remove origin 2>/dev/null
git remote add origin "$REPO_URL"

echo "✅ Remote added: $REPO_URL"
echo ""
echo "Renaming branch to 'main'..."
git branch -M main

echo ""
echo "Pushing to GitHub..."
echo ""
echo "⚠️  You'll need to authenticate with:"
echo "   Username: Your GitHub username"
echo "   Password: Personal Access Token (NOT your password)"
echo ""
echo "Don't have a token? Generate one:"
echo "  https://github.com/settings/tokens"
echo "  Required scope: 'repo'"
echo ""

git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "✅ SUCCESS! Code pushed to GitHub"
    echo "========================================"
    echo ""
    echo "Repository: $REPO_URL"
    echo ""
    echo "🚂 Next Step: Deploy on Railway"
    echo ""
    echo "1. Go to: https://railway.app/dashboard"
    echo "2. Click 'New Project'"
    echo "3. Select 'Deploy from GitHub repo'"
    echo "4. Choose your repository"
    echo "5. Click 'Deploy Now'"
    echo "6. Wait 3-5 minutes"
    echo ""
    echo "Then verify:"
    echo "  curl https://i-translation-backend-production.up.railway.app/health"
    echo ""
else
    echo ""
    echo "========================================"
    echo "❌ Push failed"
    echo "========================================"
    echo ""
    echo "Common issues:"
    echo "  1. Authentication failed"
    echo "     → Use Personal Access Token, not password"
    echo "     → Generate: https://github.com/settings/tokens"
    echo ""
    echo "  2. Repository doesn't exist"
    echo "     → Create it first: https://github.com/new"
    echo ""
    echo "  3. Permission denied"
    echo "     → Check repository URL"
    echo "     → Verify you have write access"
    echo ""
fi
