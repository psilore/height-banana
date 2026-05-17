# Troubleshooting Guide

Common issues and solutions for Height Banana development.

---

## Installation & Setup Issues

### Flutter Doctor Warnings

#### ❌ Android licenses not accepted
```bash
flutter doctor --android-licenses
# Type 'y' to accept all licenses
```

#### ❌ Android SDK Command-line Tools not found
1. Open Android Studio
2. Tools → SDK Manager → SDK Tools tab
3. Check "Android SDK Command-line Tools"
4. Click "Apply"

#### ❌ Flutter command not found
Add Flutter to PATH:
```bash
# macOS/Linux - Add to ~/.zshrc or ~/.bashrc
export PATH="$HOME/development/flutter/bin:$PATH"

# Windows - Add to Environment Variables
C:\src\flutter\bin
```

---

## Firebase Issues

### google-services.json Not Found

**Error:** "File google-services.json is missing"

**Solution:**
1. Download from Firebase Console → Project Settings → Your apps
2. Place in `android/app/google-services.json`
3. Verify location:
   ```bash
   ls -la android/app/google-services.json
   ```

### Firebase Connection Failed

**Error:** "Firebase initialization failed"

**Solutions:**
1. Check `google-services.json` is in correct location
2. Verify package name matches: `com.psilore.height_banana`
3. Clean and rebuild:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

## Google Sign-In Issues

### Sign-In Button Does Nothing

**Causes:**
- SHA-1 not configured
- OAuth consent screen not set up
- Test user not added

**Solution:**
1. Get SHA-1 fingerprint:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore \
     -alias androiddebugkey -storepass android -keypass android | grep SHA1
   ```
2. Add to Firebase Console → Project Settings → Your apps
3. Configure OAuth consent screen (see QUICKSTART.md)
4. Add your email as test user

### "API not enabled" Error

**Solution:**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Enable these APIs:
   - Google+ API
   - Firebase Authentication API
   - Cloud Firestore API

### Sign-In Works on Emulator but Not Real Device

**Solution:**
Get release SHA-1 and add to Firebase:
```bash
# Get release SHA-1
keytool -list -v -keystore path/to/your/release.keystore \
  -alias your-alias-name | grep SHA1
```

---

## Firestore Issues

### Permission Denied Error

**Error:** "Missing or insufficient permissions"

**Causes:**
- Security rules not published
- User not authenticated
- userId mismatch

**Solution:**
1. Check security rules in Firebase Console → Firestore → Rules
2. Verify user is signed in:
   ```dart
   final user = ref.watch(authStateProvider);
   print('User: $user');  // Should not be null
   ```
3. Ensure `userId` field matches authenticated user
4. Test rules in Firebase Console Rules Playground

### Data Not Syncing

**Solution:**
1. Check internet connection
2. Verify Firestore is initialized
3. Check logs for errors:
   ```bash
   flutter logs
   ```
4. Clear cache and retry:
   ```dart
   await Hive.box('cache_box').clear();
   ```

---

## Build Issues

### Gradle Build Failed

**Error:** Various Gradle errors

**Solution:**
```bash
# Clean Gradle cache
cd android
./gradlew clean
cd ..

# Clean Flutter
flutter clean

# Reinstall dependencies
flutter pub get

# Rebuild
flutter run
```

### "Execution failed for task :app:processDebugGoogleServices"

**Cause:** Invalid or missing google-services.json

**Solution:**
1. Re-download from Firebase Console
2. Verify package name in file matches app
3. Place in `android/app/`

### Out of Memory Error

**Solution:**
Increase Gradle memory in `android/gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=512m
```

---

## Code Generation Issues

### "Generated file not found"

**Error:** Import errors for `.g.dart` or `.freezed.dart` files

**Solution:**
```bash
# Clean generated files
flutter pub run build_runner clean

# Regenerate
flutter pub run build_runner build --delete-conflicting-outputs
```

### "Conflicting outputs"

**Solution:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Camera Issues

### Camera Permission Denied

**Solution:**
Add permissions to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
                 android:maxSdkVersion="28" />
```

### Camera Not Working on Emulator

**Cause:** Emulator has limited camera support

**Solution:**
- Use a real Android device for camera testing
- Or configure emulator to use webcam:
  1. AVD Manager → Edit → Advanced Settings
  2. Camera: Front/Back → Webcam

### Black Screen in Camera

**Solution:**
1. Check camera permissions granted
2. Restart app
3. Try different ResolutionPreset:
   ```dart
   CameraController(camera, ResolutionPreset.medium)
   ```

---

## ML Kit Issues

### "Model not found"

**Solution:**
ML Kit models download on first use. Ensure:
1. Device has internet connection
2. Wait for download to complete
3. Check logs for download progress

### Detection Not Working

**Causes:**
- Image quality too low
- Target not clearly visible
- Lighting conditions poor

**Solutions:**
1. Use higher resolution preset
2. Improve lighting
3. Hold device steadier
4. Adjust confidence threshold

---

## Performance Issues

### App is Slow

**Solutions:**
1. **Release Mode**: Always test performance in release mode:
   ```bash
   flutter run --release
   ```
2. **Profile Mode**: Use for performance debugging:
   ```bash
   flutter run --profile
   ```
3. **DevTools**: Analyze performance:
   ```bash
   flutter pub global activate devtools
   flutter pub global run devtools
   ```

### Image Processing Lag

**Solution:**
Ensure image processing runs in isolate:
```dart
// Run heavy computation in background
await compute(processImage, imageData);
```

### App Size Too Large

**Solution:**
```bash
# Analyze app size
flutter build apk --analyze-size

# Build with split ABIs to reduce size
flutter build apk --split-per-abi
```

---

## Testing Issues

### Tests Failing

**Solution:**
1. Check test dependencies are installed
2. Mock external services (Firebase, etc.)
3. Run with verbose output:
   ```bash
   flutter test --verbose
   ```

### Coverage Not Generated

**Solution:**
```bash
# Generate coverage
flutter test --coverage

# View coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Emulator Issues

### Emulator Won't Start

**Causes:**
- Virtualization not enabled
- Insufficient disk space
- Memory allocation too low

**Solutions:**
1. **Enable Virtualization** (in BIOS):
   - Intel: Enable VT-x
   - AMD: Enable SVM
2. **Free up space**: Need 7GB+ free
3. **Increase RAM**: AVD Manager → Edit → RAM: 2048MB+

### Emulator is Very Slow

**Solutions:**
1. Enable hardware acceleration
2. Use x86 system image (not ARM)
3. Allocate more RAM (4GB recommended)
4. Close other applications
5. Use real device instead

---

## Git & Version Control

### Accidentally Committed Secrets

**If you committed google-services.json or API keys:**

```bash
# Remove from Git history (⚠️ CAREFUL)
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch android/app/google-services.json' \
  --prune-empty --tag-name-filter cat -- --all

# Force push (only if necessary)
git push origin --force --all

# Rotate secrets in Firebase Console immediately
```

---

## Debug Tips

### Enable Verbose Logging

```bash
# Run with verbose output
flutter run -v

# Watch logs
flutter logs

# Filter logs
flutter logs | grep Firebase
```

### Inspect App State

Use Flutter DevTools:
```bash
# While app is running, press 'w' in terminal
# Or visit: http://127.0.0.1:9100/
```

### Debug Network Requests

Add logging interceptor for HTTP:
```dart
// Check Firebase connection
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

---

## Getting Help

If your issue isn't listed here:

1. **Check logs**: `flutter logs`
2. **Search issues**: GitHub Issues tab
3. **Ask community**: Stack Overflow with tags `flutter`, `firebase`
4. **Open issue**: Include:
   - Flutter version (`flutter --version`)
   - Error message
   - Steps to reproduce
   - Logs

---

## Useful Commands Reference

```bash
# Clean everything
flutter clean && cd android && ./gradlew clean && cd ..

# Update Flutter
flutter upgrade

# Fix dependencies
flutter pub get
flutter pub upgrade

# Code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Analyze code
flutter analyze

# Format code
dart format .

# Run tests
flutter test

# Check app size
flutter build apk --analyze-size
```

---

**Still stuck?** Open an issue on GitHub with detailed logs and error messages.
