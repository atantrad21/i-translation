#!/bin/bash

# 🚀 QUAD-GAN Backend Deployment Script
# Quick deployment of updated I-Translation backend to Railway

echo "=========================================="
echo "🚀 QUAD-GAN Backend Deployment"
echo "=========================================="
echo ""
echo "This script will deploy your updated backend with 4-generator support"
echo ""

# Navigate to backend directory
cd /home/sandbox/medical-app-working

echo "📂 Current directory: $(pwd)"
echo ""

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "⚠️  Railway CLI not found. Installing..."
    npm install -g @railway/cli
    
    if [ $? -ne 0 ]; then
        echo ""
        echo "❌ Failed to install Railway CLI"
        echo ""
        echo "Please install manually:"
        echo "  npm install -g @railway/cli"
        echo ""
        echo "Or use GitHub deployment method instead."
        exit 1
    fi
    
    echo "✅ Railway CLI installed"
fi

echo ""
echo "🔐 Logging in to Railway..."
echo "   A browser window will open for authentication"
echo ""

railway login

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Railway login failed"
    exit 1
fi

echo ""
echo "✅ Logged in successfully"
echo ""

echo "🔗 Linking to your Railway project..."
echo ""

# Check if already linked
if [ -f ".railway/config.json" ]; then
    echo "✅ Already linked to Railway project"
else
    railway link
    
    if [ $? -ne 0 ]; then
        echo ""
        echo "❌ Failed to link project"
        echo ""
        echo "Please link manually:"
        echo "  railway link"
        exit 1
    fi
fi

echo ""
echo "📦 Deploying to Railway..."
echo "   This may take 2-5 minutes..."
echo ""

railway up

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ DEPLOYMENT SUCCESSFUL!"
    echo "=========================================="
    echo ""
    echo "🎉 Your QUAD-GAN backend is now live!"
    echo ""
    echo "📍 Backend URL:"
    echo "   https://i-translation-backend-production.up.railway.app"
    echo ""
    echo "🧪 Test the deployment:"
    echo "   curl https://i-translation-backend-production.up.railway.app/health"
    echo ""
    echo "   Expected: version 2.0.0 - QUAD-GAN Multi-Conversion"
    echo ""
    echo "🌐 Frontend is already deployed:"
    echo "   https://6nklr38m.scispace.co"
    echo ""
    echo "✅ Your app now supports 4 simultaneous conversions!"
    echo ""
else
    echo ""
    echo "=========================================="
    echo "❌ DEPLOYMENT FAILED"
    echo "=========================================="
    echo ""
    echo "Common issues:"
    echo "  1. Not logged in to Railway"
    echo "     → Run: railway login"
    echo ""
    echo "  2. Project not linked"
    echo "     → Run: railway link"
    echo ""
    echo "  3. Build errors"
    echo "     → Check Railway logs in dashboard"
    echo ""
    echo "📞 Need help? Email: atantrad@gmail.com"
    echo ""
    exit 1
fi

echo "=========================================="
echo "📋 Post-Deployment Checklist"
echo "=========================================="
echo ""
echo "✅ Backend deployed to Railway"
echo "✅ Frontend already live at Scispace"
echo ""
echo "🧪 Testing steps:"
echo "  1. Visit: https://6nklr38m.scispace.co"
echo "  2. Upload a CT or MRI image"
echo "  3. Click 'Convert Image'"
echo "  4. Verify 4 results are displayed in grid"
echo "  5. Test individual downloads"
echo "  6. Test 'Download All 4 Images' button"
echo ""
echo "🎯 All done! Your QUAD-GAN app is ready!"
echo ""
