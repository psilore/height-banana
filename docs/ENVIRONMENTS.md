# 🌍 Environment Configuration Guide

## Overview

Height Banana uses **two environments** for deployment:

1. **Development** - Testing PRs and feature branches
2. **Production** - Live app for end users

---

## 📋 Environment Setup

### GitHub Environments

Navigate to: **Settings → Environments**

Create two environments with the following configurations:

---

## 🧪 Development Environment

### Configuration

- **Name:** `development`
- **Protection rules:** None (allow auto-deployment)
- **Deployment branches:** Any branch
- **URL:** `https://dev.height-banana.app` (optional)

### Required Secrets

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `FIREBASE_APP_ID_DEV` | Firebase App ID for development | Firebase Console → Project Settings → Your apps → App ID |
| `FIREBASE_SERVICE_ACCOUNT` | Firebase service account JSON | Firebase Console → Project Settings → Service Accounts → Generate new private key |

### Firebase Setup (Development)

1. **Create Development App in Firebase:**
   ```
   Firebase Console → Project → Add App → Android
   Package name: app.heightbanana.dev (or your dev package)
   ```

2. **Download google-services.json:**
   ```bash
   # Save as android/app/google-services-dev.json
   ```

3. **Configure App Distribution:**
   ```
   Firebase Console → Release & Monitor → App Distribution
   → Add testers to "testers-dev" group
   ```

4. **Get App ID:**
   ```
   Firebase Console → Project Settings → Your apps
   → Copy "App ID" (e.g., 1:123456789:android:abc123...)
   → Add to GitHub Secrets as FIREBASE_APP_ID_DEV
   ```

5. **Generate Service Account:**
   ```
   Firebase Console → Project Settings → Service Accounts
   → Generate new private key (downloads JSON)
   → Copy entire JSON content
   → Add to GitHub Secrets as FIREBASE_SERVICE_ACCOUNT
   ```

---

## 🏭 Production Environment

### Configuration

- **Name:** `production`
- **Protection rules:**
  - ✅ Required reviewers (1+)
  - ✅ Wait timer: 5 minutes
  - ✅ Deployment branches: `main` only
- **URL:** `https://play.google.com/store/apps/details?id=app.heightbanana`

### Required Secrets

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `FIREBASE_APP_ID_PROD` | Firebase App ID for production | See Firebase setup below |
| `FIREBASE_SERVICE_ACCOUNT` | Firebase service account JSON | Same as dev (project-wide) |
| `KEYSTORE_BASE64` | Android keystore (base64 encoded) | See keystore generation below |
| `KEYSTORE_PASSWORD` | Keystore password | Set during keystore creation |
| `KEY_ALIAS` | Key alias | Set during keystore creation |
| `KEY_PASSWORD` | Key password | Set during keystore creation |
| `GOOGLE_PLAY_SERVICE_ACCOUNT` | Play Store API JSON | Google Play Console setup |

### Firebase Setup (Production)

1. **Create Production App:**
   ```
   Firebase Console → Project → Add App → Android
   Package name: app.heightbanana (production package)
   ```

2. **Download google-services.json:**
   ```bash
   # Save as android/app/google-services.json
   ```

3. **Configure App Distribution:**
   ```
   Firebase Console → App Distribution
   → Create groups: "testers-prod", "beta-users"
   → Add testers
   ```

4. **Get App ID:**
   ```
   Add to GitHub Secrets as FIREBASE_APP_ID_PROD
   ```

---

## 🔑 Android Signing Setup (Production)

### 1. Generate Upload Keystore

```bash
# Generate keystore
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# Enter passwords and details when prompted
# SAVE THESE PASSWORDS SECURELY!
```

### 2. Encode Keystore to Base64

```bash
# Linux/macOS
cat upload-keystore.jks | base64 | tr -d '\n' > keystore_base64.txt

# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Out-File keystore_base64.txt
```

### 3. Add to GitHub Secrets

```
KEYSTORE_BASE64=<content of keystore_base64.txt>
KEYSTORE_PASSWORD=<password you set>
KEY_ALIAS=upload
KEY_PASSWORD=<password you set>
```

### 4. Store Keystore Securely

⚠️ **CRITICAL:** Back up `upload-keystore.jks` securely!

Options:
- Password manager (1Password, LastPass)
- Encrypted cloud storage
- Hardware security key

**Never commit keystore to git!**

---

## 🏪 Google Play Console Setup

### 1. Create Google Play Developer Account

1. Go to [Google Play Console](https://play.google.com/console)
2. Pay $25 one-time registration fee
3. Complete account verification

### 2. Create App

1. **Create app:**
   ```
   All apps → Create app
   Name: Height Banana
   Default language: English
   App/Game: App
   Free/Paid: Free
   ```

2. **Set up app:**
   - Fill in store listing
   - Add screenshots
   - Set content rating
   - Select target audience
   - Add privacy policy URL

### 3. Create Internal Testing Track

1. **Go to:** Testing → Internal testing
2. **Create release:**
   - Upload APK/AAB manually (first time)
   - Add release notes
   - Add testers
3. **Save and review**

### 4. Enable Play Store API

1. **Go to:** Google Cloud Console
2. **Enable APIs:**
   ```
   APIs & Services → Enable APIs
   → Search "Google Play Android Developer API"
   → Enable
   ```

3. **Create Service Account:**
   ```
   IAM & Admin → Service Accounts
   → Create Service Account
   Name: github-actions-deploy
   Role: Service Account User
   → Create Key (JSON)
   ```

4. **Grant Permissions in Play Console:**
   ```
   Play Console → Settings → API access
   → Link service account
   → Grant access: Release manager
   ```

5. **Add to GitHub Secrets:**
   ```
   GOOGLE_PLAY_SERVICE_ACCOUNT=<entire JSON content>
   ```

---

## 📝 Environment Variables in Code

### Build-time Configuration

Create environment-specific files:

**android/app/build.gradle:**
```groovy
android {
    ...
    
    flavorDimensions "environment"
    productFlavors {
        development {
            dimension "environment"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
        }
        production {
            dimension "environment"
        }
    }
}
```

**lib/config/environment.dart:**
```dart
enum Environment {
  development,
  production,
}

class EnvironmentConfig {
  static Environment get current {
    const environment = String.fromEnvironment('ENV', defaultValue: 'development');
    return environment == 'production' ? Environment.production : Environment.development;
  }
  
  static String get apiUrl {
    switch (current) {
      case Environment.development:
        return 'https://dev-api.height-banana.app';
      case Environment.production:
        return 'https://api.height-banana.app';
    }
  }
}
```

---

## 🔒 Security Best Practices

### Secrets Management

✅ **DO:**
- Store all sensitive data in GitHub Secrets
- Use environment-specific secrets
- Rotate credentials regularly
- Limit secret access to necessary workflows

❌ **DON'T:**
- Commit secrets to git
- Share secrets in plain text
- Use production secrets in development
- Log secret values

### Access Control

**Development:**
- Allow all team members
- No approval required
- Automatic deployment

**Production:**
- Require code review approval
- Add deployment wait timer
- Restrict to main branch only
- Enable manual approval gates

---

## 🧪 Testing Environments

### Local Development

```bash
# Run with development config
flutter run --dart-define=ENV=development

# Run with production config
flutter run --dart-define=ENV=production
```

### CI/CD Testing

**Development:**
- Automatic on PR
- Deploy to Firebase App Distribution
- Available to testers-dev group

**Production:**
- Automatic on release
- Deploy to Play Store (Internal Testing)
- Deploy to Firebase App Distribution (prod group)

---

## 📊 Environment Comparison

| Feature | Development | Production |
|---------|-------------|------------|
| **Deployment** | Automatic (PR merge) | Automatic (release PR merge) |
| **Approval** | None | Required |
| **Signing** | Debug | Release (signed) |
| **Distribution** | Firebase (testers-dev) | Play Store + Firebase |
| **Version** | Git commit | Semantic versioning |
| **Monitoring** | Basic logs | Full analytics |
| **Rollback** | Easy (re-deploy) | Via Play Store |

---

## 🔄 Switching Environments

### Update Firebase Config

```bash
# Development
cp android/app/google-services-dev.json android/app/google-services.json

# Production
cp android/app/google-services-prod.json android/app/google-services.json
```

### Build for Specific Environment

```bash
# Development
flutter build apk --debug --flavor development

# Production
flutter build appbundle --release --flavor production
```

---

## 🐛 Troubleshooting

### "Environment not found"

**Check:**
1. Environment exists in GitHub Settings
2. Environment name matches workflow exactly
3. Secrets are configured for that environment

### "Secret not found"

**Check:**
1. Secret exists in correct environment
2. Secret name matches workflow exactly
3. No typos in secret name (case-sensitive)

### "Firebase App Distribution failed"

**Check:**
1. Service account JSON is valid
2. App ID is correct for environment
3. Testers group exists
4. Service account has App Distribution Admin role

### "Play Store upload failed"

**Check:**
1. App is created in Play Console
2. Internal testing track exists
3. Service account has Release Manager role
4. API is enabled in Google Cloud Console

---

## 📞 Support

- 📖 **Documentation:** See `docs/GITHUB_FLOW.md`
- 🔧 **CI/CD Issues:** Check workflow logs in Actions tab
- 🔐 **Security:** See `.github/SECURITY.md`

---

**Environment setup complete!** 🚀
