# I-Translation Backend Deployment Guide

## Quick Deploy to Railway (Recommended - 5 Minutes)

Railway offers free hosting with automatic HTTPS and is perfect for this backend.

### Prerequisites
- GitHub account (free)
- Railway account (free - sign up at https://railway.app)

---

## Step-by-Step Deployment

### Option 1: Deploy via Railway Dashboard (Easiest)

#### Step 1: Prepare Backend for Git

```bash
cd /home/sandbox/medical-app-working

# Initialize git repository
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - I-Translation backend"
```

#### Step 2: Push to GitHub

```bash
# Create new repository on GitHub (https://github.com/new)
# Name it: i-translation-backend
# Make it private if it contains sensitive code

# Add remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/i-translation-backend.git

# Push to GitHub
git branch -M main
git push -u origin main
```

#### Step 3: Deploy on Railway

1. **Go to Railway**: https://railway.app
2. **Sign up/Login** with GitHub
3. **Click "New Project"**
4. **Select "Deploy from GitHub repo"**
5. **Choose** your `i-translation-backend` repository
6. **Railway will auto-detect** Python and deploy

#### Step 4: Get Your Backend URL

1. In Railway dashboard, click your project
2. Go to **Settings** → **Domains**
3. Click **Generate Domain**
4. You'll get a URL like: `https://i-translation-backend-production.up.railway.app`
5. **Copy this URL** - you'll need it for the mobile app

#### Step 5: Test Your Backend

```bash
# Replace with your Railway URL
curl https://your-app.up.railway.app/health

# Should return: {"status": "healthy", "timestamp": "..."}
```

---

### Option 2: Deploy via Railway CLI

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Initialize project
cd /home/sandbox/medical-app-working
railway init

# Deploy
railway up

# Get URL
railway domain
```

---

## Alternative: Deploy to Heroku

### Step 1: Install Heroku CLI

```bash
# Download from: https://devcenter.heroku.com/articles/heroku-cli
# Or use npm:
npm install -g heroku
```

### Step 2: Login and Create App

```bash
cd /home/sandbox/medical-app-working

# Login
heroku login

# Create app
heroku create i-translation-backend

# Deploy
git init
git add .
git commit -m "Initial commit"
heroku git:remote -a i-translation-backend
git push heroku main
```

### Step 3: Get Your URL

```bash
heroku open
# Or check: https://i-translation-backend.herokuapp.com
```

---

## Alternative: Deploy to Render

### Steps:

1. **Go to**: https://render.com
2. **Sign up** with GitHub
3. **New Web Service**
4. **Connect** your GitHub repo
5. **Configure**:
   - Name: `i-translation-backend`
   - Environment: `Python 3`
   - Build Command: `pip install -r requirements.txt`
   - Start Command: `gunicorn app:app --bind 0.0.0.0:$PORT`
6. **Deploy**
7. **Get URL**: `https://i-translation-backend.onrender.com`

---

## Update Mobile App with Backend URL

Once deployed, update the mobile app:

### Edit API Configuration

```bash
cd /home/sandbox/medical-converter-mobile
```

Edit `src/services/api.js`:

```javascript
// Replace this line:
const BASE_URL = Platform.select({
  android: 'http://10.0.2.2:5000',
  ios: 'http://localhost:5000',
});

// With your production URL:
const BASE_URL = 'https://your-app.up.railway.app';
```

Or create environment-based configuration:

```javascript
const BASE_URL = __DEV__ 
  ? Platform.select({
      android: 'http://10.0.2.2:5000',
      ios: 'http://localhost:5000',
    })
  : 'https://your-app.up.railway.app'; // Production URL
```

---

## Files Created for Deployment

### Procfile
Tells the platform how to run the app:
```
web: gunicorn app:app --bind 0.0.0.0:$PORT --timeout 120 --workers 2
```

### runtime.txt
Specifies Python version:
```
python-3.11.0
```

### requirements.txt
Already exists with all dependencies:
```
Flask==3.0.0
Pillow==10.1.0
numpy
gunicorn
pydicom==2.4.4
```

### .gitignore
Excludes unnecessary files from deployment

---

## Environment Variables (Optional)

If you need to set environment variables:

### Railway
1. Go to project → **Variables**
2. Add variables like:
   - `FLASK_ENV=production`
   - `MAX_UPLOAD_SIZE=33554432`

### Heroku
```bash
heroku config:set FLASK_ENV=production
```

---

## CORS Configuration

The backend already has CORS enabled for all origins. For production, you might want to restrict it:

Edit `app.py`:

```python
from flask_cors import CORS

# Current (allows all):
CORS(app)

# Production (restrict to your domain):
CORS(app, resources={
    r"/*": {
        "origins": ["https://your-frontend-domain.com", "capacitor://localhost"]
    }
})
```

---

## Testing Deployment

### 1. Health Check
```bash
curl https://your-backend-url.com/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2026-02-27T18:30:00"
}
```

### 2. Test Image Conversion

```bash
# Upload test image
curl -X POST https://your-backend-url.com/convert \
  -F "image=@/path/to/test-image.png" \
  -F "conversion_type=ct_to_mri"
```

Should return JSON with converted image data.

---

## Monitoring & Logs

### Railway
- Dashboard → Logs tab
- Real-time log streaming
- Metrics and usage stats

### Heroku
```bash
heroku logs --tail
```

### Render
- Dashboard → Logs tab

---

## Cost Breakdown

### Railway Free Tier
- ✅ 500 hours/month
- ✅ Automatic HTTPS
- ✅ Custom domains
- ✅ GitHub integration
- **Cost**: $0 (then $5/month if exceeded)

### Heroku
- ✅ 550 hours/month (Free Dyno)
- ⚠️ Sleeps after 30 min inactivity
- **Cost**: $0 (or $7/month for Hobby)

### Render
- ✅ Free tier available
- ⚠️ Slower cold starts
- **Cost**: $0 (or $7/month for paid)

---

## Troubleshooting

### "Application Error" on Railway
- Check logs in Railway dashboard
- Ensure requirements.txt has all dependencies
- Verify Procfile is correct

### "Port already in use"
- Railway/Heroku automatically set PORT
- Code already handles this: `port = int(os.environ.get('PORT', 5000))`

### "Module not found"
- Add missing package to requirements.txt
- Redeploy

### CORS errors in mobile app
- Backend already has CORS enabled
- Check if URL is correct in mobile app
- Verify backend is accessible

---

## Security Checklist

Before sharing publicly:

- [ ] Set `debug=False` in app.py (already done)
- [ ] Add rate limiting (optional)
- [ ] Implement authentication (optional)
- [ ] Restrict CORS to specific origins (optional)
- [ ] Add input validation (already implemented)
- [ ] Set up monitoring/alerts
- [ ] Review uploaded file handling
- [ ] Add HTTPS (automatic on Railway/Heroku)

---

## Quick Reference

### Your Deployment Checklist

1. ✅ Backend files prepared (Procfile, runtime.txt, .gitignore)
2. ⬜ Push to GitHub
3. ⬜ Deploy to Railway/Heroku/Render
4. ⬜ Get production URL
5. ⬜ Update mobile app API URL
6. ⬜ Build mobile app APK
7. ⬜ Test end-to-end
8. ⬜ Share APK with users

### Commands Quick Copy

```bash
# Git setup
cd /home/sandbox/medical-app-working
git init
git add .
git commit -m "I-Translation backend"

# Railway
npm install -g @railway/cli
railway login
railway init
railway up
railway domain

# Heroku
heroku login
heroku create i-translation-backend
git push heroku main
heroku open

# Test
curl https://your-url.com/health
```

---

## Next Steps

1. **Choose platform**: Railway (recommended)
2. **Deploy backend** following steps above
3. **Copy production URL**
4. **Update mobile app** with URL
5. **Build APK** with production backend
6. **Test** full workflow
7. **Share** with users

---

**Ready to deploy? Start with Railway - it's the easiest!**

**Last Updated**: February 27, 2026
