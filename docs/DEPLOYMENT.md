# Deployment Guide

## Building for Production

### Prerequisites
- Flutter SDK 3.22.0+
- Android SDK with Build Tools
- Release keystore (for signing)
- Firebase project configured

## Android Release Build

### 1. Create Release Keystore

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

**Save the passwords securely!**

### 2. Configure Signing

Create `android/key.properties`:
```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=<path-to-keystore>
```

**⚠️ Never commit `key.properties` to git!**

### 3. Build Release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### 4. Build App Bundle (Recommended)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## GitHub Actions Deployment

### Secrets Configuration

Add to **Settings → Secrets**:
- `KEYSTORE_BASE64` - Base64 encoded keystore
- `KEYSTORE_PASSWORD` - Store password
- `KEY_ALIAS` - Keyalias
- `KEY_PASSWORD` - Key password
- `FIREBASE_SERVICE_ACCOUNT` - Service account JSON

### CI/CD Workflow

The `.github/workflows/cd_deploy.yml` automatically:
1. Builds release APK/AAB on push to `main`
2. Signs with production keystore
3. Uploads artifacts
4. (Optional) Deploys to Play Store

## Google Play Store Submission

### First Release

1. **Create App in Play Console**
   - Go to [Google Play Console](https://play.google.com/console)
   - Create new app
   - Fill in app details

2. **Upload App Bundle**
   - Production → Create new release
   - Upload `app-release.aab`
   - Fill release notes

3. **Content Rating**
   - Complete questionnaire
   - Submit for rating

4. **Pricing & Distribution**
   - Select countries
   - Set price (free/paid)

5. **Submit for Review**
   - Can take 1-7 days

### Subsequent Releases

1. **Increment Version**
   ```yaml
   # pubspec.yaml
   version: 1.0.1+2  # version+build
   ```

2. **Build & Sign**
   ```bash
   flutter build appbundle --release
   ```

3. **Upload to Play Console**
   - Production → Create new release
   - Upload new AAB
   - Add release notes

## Firebase Deployment

### Deploy Security Rules

```bash
firebase deploy --only firestore:rules
```

### Deploy Cloud Functions (if any)

```bash
cd functions
npm install
firebase deploy --only functions
```

## Version Management

### Semantic Versioning

```yaml
version: MAJOR.MINOR.PATCH+BUILD
```

Example: `1.2.3+45`
- **MAJOR**: Breaking changes
- **MINOR**: New features
- **PATCH**: Bug fixes
- **BUILD**: Auto-incremented build number

### Git Tags

```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

## Pre-Release Checklist

- [ ] All tests passing (`flutter test`)
- [ ] No analyzer warnings (`flutter analyze`)
- [ ] Code formatted (`dart format lib/`)
- [ ] Firebase rules deployed
- [ ] Version bumped in `pubspec.yaml`
- [ ] Release notes written
- [ ] Screenshots updated
- [ ] Privacy policy updated (if needed)

## Testing Release Build

### Test APK Locally

```bash
flutter build apk --release
flutter install
```

### Internal Testing

1. **Build AAB**
2. **Upload to Play Console → Internal Testing**
3. **Add test users**
4. **Share testing link**

## Monitoring & Analytics

### Firebase Crashlytics

```bash
flutter pub add firebase_crashlytics
```

### Performance Monitoring

```bash
flutter pub add firebase_performance
```

## Rollback Procedure

If release has critical issues:

1. **Play Console → Production**
2. **Halt rollout** (if gradual)
3. **Promote previous version**
4. **Fix issues**
5. **Release hotfix**

## Best Practices

✅ **Always test release builds** before submission
✅ **Use staged rollouts** (10% → 50% → 100%)
✅ **Monitor crash reports** for 24 hours
✅ **Keep release notes clear** and user-friendly
✅ **Tag releases in git**
✅ **Backup keystores securely**

## Troubleshooting

### Build fails with signing error
```bash
# Verify keystore
keytool -list -v -keystore ~/upload-keystore.jks
```

### App bundle too large
```bash
# Build with split APKs
flutter build apk --release --split-per-abi
```

### Firebase not initialized
```bash
# Regenerate firebase_options.dart
flutterfire configure
```

---

**Ready to deploy!** 🚀
