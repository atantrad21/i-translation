#!/bin/bash

# I-Translation Backend - Railway Deployment Helper Script

set -e

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                                                                  ║"
echo "║         🚂 I-Translation Railway Deployment Helper 🚀           ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Check if we're in the right directory
if [ ! -f "app.py" ]; then
    echo "❌ Error: app.py not found. Please run this script from /home/sandbox/medical-app-working/"
    exit 1
fi

echo "📁 Current directory: $(pwd)"
echo ""

# Step 1: Check Git
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1: Checking Git configuration..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -d ".git" ]; then
    echo "⚠️  Git repository not initialized"
    echo ""
    read -p "Initialize git repository? (y/n): " init_git
    
    if [ "$init_git" = "y" ]; then
        echo "🔧 Initializing git repository..."
        git init
        git add .
        git commit -m "Initial commit: I-Translation backend with 10GB support"
        echo "✅ Git repository initialized"
    else
        echo "⚠️  Skipping git initialization"
    fi
else
    echo "✅ Git repository already initialized"
fi

echo ""

# Step 2: Check Railway CLI
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Checking Railway CLI..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! command -v railway &> /dev/null; then
    echo "⚠️  Railway CLI not found"
    echo ""
    read -p "Install Railway CLI? (y/n): " install_railway
    
    if [ "$install_railway" = "y" ]; then
        echo "🔧 Installing Railway CLI..."
        sudo npm install -g @railway/cli
        echo "✅ Railway CLI installed"
    else
        echo "⚠️  Skipping Railway CLI installation"
        echo "ℹ️  You can deploy via Railway web interface instead"
    fi
else
    echo "✅ Railway CLI is installed ($(railway --version))"
fi

echo ""

# Step 3: Verify deployment files
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3: Verifying deployment files..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

files=("app.py" "requirements.txt" "Procfile" "runtime.txt" "railway.json" ".gitignore")

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file (missing)"
    fi
done

echo ""

# Step 4: Show deployment options
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4: Deployment Options"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Choose your deployment method:"
echo ""
echo "1. Railway Web Interface (Easiest - Recommended)"
echo "   → Go to: https://railway.app/"
echo "   → Click 'New Project' → 'Deploy from GitHub'"
echo "   → Select your repository"
echo ""
echo "2. Railway CLI (If installed)"
echo "   → Run: railway login"
echo "   → Run: railway init"
echo "   → Run: railway up"
echo ""
echo "3. Push to GitHub first (Best for production)"
echo "   → Create repo on GitHub"
echo "   → Push this code"
echo "   → Deploy from GitHub on Railway"
echo ""

read -p "Which method do you want to use? (1/2/3): " method

case $method in
    1)
        echo ""
        echo "📋 Manual Deployment Steps:"
        echo ""
        echo "1. Go to: https://railway.app/"
        echo "2. Login or create account (use atantrad@gmail.com)"
        echo "3. Click 'New Project'"
        echo "4. Select 'Deploy from GitHub repo'"
        echo "5. Choose 'i-translation-backend' repository"
        echo "6. Railway will auto-deploy"
        echo ""
        echo "📝 After deployment:"
        echo "- Set memory to 8GB in Settings"
        echo "- Add environment variables (see .env.example)"
        echo "- Copy your production URL"
        echo ""
        ;;
    2)
        if command -v railway &> /dev/null; then
            echo ""
            echo "🚀 Deploying with Railway CLI..."
            echo ""
            
            # Login
            echo "Step 1: Login to Railway"
            railway login
            
            # Initialize
            echo ""
            echo "Step 2: Initialize Railway project"
            railway init
            
            # Deploy
            echo ""
            echo "Step 3: Deploying..."
            railway up
            
            # Set variables
            echo ""
            echo "Step 4: Setting environment variables..."
            railway variables set PORT=5000
            railway variables set FLASK_ENV=production
            railway variables set MAX_CONTENT_LENGTH=10737418240
            railway variables set ANALYTICS_EMAIL=atantrad@gmail.com
            
            # Get URL
            echo ""
            echo "Step 5: Getting your production URL..."
            railway domain
            
            echo ""
            echo "✅ Deployment complete!"
        else
            echo "❌ Railway CLI not installed. Please choose option 1 or 3."
        fi
        ;;
    3)
        echo ""
        echo "📋 GitHub Deployment Steps:"
        echo ""
        echo "1. Create GitHub repository:"
        echo "   → Go to: https://github.com/new"
        echo "   → Name: i-translation-backend"
        echo "   → Visibility: Private"
        echo "   → Click 'Create repository'"
        echo ""
        echo "2. Push code to GitHub:"
        echo "   → git remote add origin https://github.com/USERNAME/i-translation-backend.git"
        echo "   → git branch -M main"
        echo "   → git push -u origin main"
        echo ""
        echo "3. Deploy on Railway:"
        echo "   → Go to: https://railway.app/"
        echo "   → Click 'New Project'"
        echo "   → Select 'Deploy from GitHub repo'"
        echo "   → Choose your repository"
        echo ""
        ;;
esac

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📚 Documentation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Full guide: /home/sandbox/RAILWAY_DEPLOYMENT_GUIDE.md"
echo "Quick start: /home/sandbox/DEPLOY_QUICK_START.txt"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Deployment helper completed!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "After deployment, update your mobile and web apps with the production URL!"
echo ""
