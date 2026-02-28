#!/bin/bash

# Quick verification script - Check if files are ready for GitHub

echo "🔍 Checking backend files for GitHub deployment..."
echo ""

cd /home/sandbox/medical-app-working

# Check required files
echo "📋 Required Files Check:"
echo "─────────────────────────────────────"

files=("app.py" "requirements.txt" "Procfile" "runtime.txt" "railway.json")
all_present=true

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        size=$(du -h "$file" | cut -f1)
        echo "✅ $file ($size)"
    else
        echo "❌ $file (MISSING!)"
        all_present=false
    fi
done

echo ""

if [ "$all_present" = true ]; then
    echo "✅ All required files are present!"
    echo ""
    echo "📊 File Summary:"
    echo "─────────────────────────────────────"
    echo "Total files: $(find . -type f | wc -l)"
    echo "Total size: $(du -sh . | cut -f1)"
    echo ""
    echo "🚀 Ready to push to GitHub!"
    echo ""
    echo "Next steps:"
    echo "1. Run: bash push-to-github.sh"
    echo "   OR"
    echo "2. Follow manual commands in FIX_EMPTY_REPO_ERROR.txt"
    echo ""
else
    echo "❌ Some files are missing!"
    echo ""
    echo "Please ensure all required files are present before pushing."
    exit 1
fi

# Check if git is initialized
if [ -d ".git" ]; then
    echo "📁 Git Status:"
    echo "─────────────────────────────────────"
    echo "✅ Git repository already initialized"
    
    # Check if there's a remote
    if git remote | grep -q "origin"; then
        echo "✅ Remote 'origin' configured:"
        git remote get-url origin
    else
        echo "⚠️  No remote configured yet"
    fi
    
    # Check current branch
    current_branch=$(git branch --show-current 2>/dev/null)
    if [ -n "$current_branch" ]; then
        echo "✅ Current branch: $current_branch"
    fi
    
    # Check for uncommitted changes
    if git status --porcelain | grep -q .; then
        echo "⚠️  Uncommitted changes detected"
        echo ""
        echo "Files with changes:"
        git status --short
    else
        echo "✅ No uncommitted changes"
    fi
else
    echo "📁 Git Status:"
    echo "─────────────────────────────────────"
    echo "⚠️  Git not initialized yet"
    echo ""
    echo "Run: bash push-to-github.sh"
    echo "This will initialize git and push to GitHub"
fi

echo ""
echo "════════════════════════════════════════"
echo "✅ Verification Complete!"
echo "════════════════════════════════════════"
