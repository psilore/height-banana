# 🚀 Quick Start Guide - From Zero to Running App

Complete step-by-step guide to set up Height Banana from scratch. Estimated time: **30-45 minutes**.

---

## Part 1: Install Development Tools (15-20 minutes)

### Step 1: Install Flutter SDK

#### macOS
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Download Flutter
cd ~/development  # or your preferred directory
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# Add to PATH (add to ~/.zshrc or ~/.bash_profile)
export PATH="$HOME/development/flutter/bin:$PATH"

# Reload shell
source ~/.zshrc  # or source ~/.bash_profile

# Verify installation
flutter doctor
```

#### Windows
1. Download Flutter SDK: https://flutter.dev/docs/get-started/install/windows
2. Extract to `C:\src\flutter`
3. Add to PATH:
   - Search "Environment Variables" in Windows
   - Edit PATH variable
   - Add `C:\src\flutter\bin`
4. Open new Command Prompt and run: `flutter doctor`

#### Linux (Ubuntu/Debian)
```bash
# Install dependencies
sudo apt update
sudo apt install -y curl git unzip xz-utils zip libglu1-mesa

# Download Flutter
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# Add to PATH (add to ~/.bashrc)
export PATH="$HOME/development/flutter/bin:$PATH"

# Reload
source ~/.bashrc

# Verify
flutter doctor
```

### Step 2: Install Android Studio

1. **Download**: https://developer.android.com/studio
2. **Install** and open Android Studio
3. **Setup Android SDK**:
   - Tools → SDK Manager
   - Install "Android SDK Command-line Tools"
   - Install "Android SDK Platform-Tools"
   - Install Android API 34 (or latest)
4. **Accept Licenses**:
   ```bash
   flutter doctor --android-licenses
   # Type 'y' to accept all
   ```

### Step 3: Install Flutter & Dart Plugins

**In Android Studio:**
1. Settings/Preferences → Plugins
2. Search "Flutter" → Install
3. Search "Dart" → Install (usually comes with Flutter)
4. Restart Android Studio

**OR use VS Code:**
1. Install VS Code: https://code.visualstudio.com/
2. Install Extensions:
   - Flutter (by Dart Code)
   - Dart (by Dart Code)

### Step 4: Create Android Emulator

1. In Android Studio: Tools → Device Manager
2. Click "Create Device"
3. Select **Pixel 7** (or any recent device)
4. Select System Image: **Android 14 (API 34)**
5. Download if needed
6. Click "Finish"
7. Test by clicking ▶️ to start emulator

### Step 5: Verify Setup

```bash
flutter doctor -v
```

**Expected output:**
```
✓ Flutter (Channel stable, 3.x.x)
✓ Android toolchain - develop for Android devices
✓ Android Studio (version 2024.x)
✓ Connected device (1 available)
✓ Network resources
```

---

## Part 2: Clone & Set Up Project (5 minutes)

### Step 1: Clone Repository

```bash
# Navigate to your projects folder
cd ~/development  # or your preferred location

# Clone the project
git clone https://github.com/psilore/height-banana.git
cd height-banana
```

### Step 2: Install Dependencies

```bash
# Get Flutter packages
flutter pub get

# This will download ~50+ packages, may take 2-3 minutes
```

---

## Part 3: Set Up Firebase & Google Sign-In (15-20 minutes)

### Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click "Select a project" → "New Project"
3. Project name: `height-banana` (or your choice)
4. Click "Create"
5. Wait for project creation (~30 seconds)

### Step 2: Enable Required APIs

1. In Google Cloud Console, go to "APIs & Services" → "Library"
2. Search and enable these APIs:
   - ✅ **Google+ API** (for Google Sign-In)
   - ✅ **Firebase Authentication API**
   - ✅ **Cloud Firestore API**

### Step 3: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. **Project name**: Select `height-banana` (the Google Cloud project)
4. **Google Analytics**: Enable (recommended)
   - Create new account or use existing
   - Choose location (your country)
5. Click "Create project"
6. Wait for setup (~1-2 minutes)
7. Click "Continue"

### Step 4: Add Android App to Firebase

1. In Firebase Console, click Android icon (⚡)
2. **Register app:**
   - Android package name: `com.psilore.height_banana`
   - App nickname: `Height Banana` (optional)
   - Debug signing certificate SHA-1: Get it with:
     ```bash
     # On macOS/Linux
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1
     
     # On Windows
     keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android | findstr SHA1
     ```
   - Copy the SHA-1 and paste it
3. Click "Register app"

### Step 5: Download google-services.json

1. Download `google-services.json` file
2. **IMPORTANT**: Place it in `android/app/` directory
   ```bash
   # From project root
   mv ~/Downloads/google-services.json android/app/
   ```
3. Verify it's in the right place:
   ```bash
   ls -la android/app/google-services.json
   # Should show the file
   ```

### Step 6: Update Android Configuration

**File: `android/build.gradle`**

Add Google Services to dependencies:
```gradle
buildscript {
    ext.kotlin_version = '1.9.0'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version'
        // Add this line ↓
        classpath 'com.google.gms:google-services:4.4.1'
    }
}
```

**File: `android/app/build.gradle`**

Add at the very bottom:
```gradle
// Add this line at the end of the file
apply plugin: 'com.google.gms.google-services'
```

Also ensure minimum SDK version:
```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Must be at least 21
        targetSdkVersion 34
    }
}
```

### Step 7: Enable Firebase Authentication

1. In Firebase Console, click "Authentication" in left menu
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Click "Google" provider
5. Toggle **Enable**
6. **Support email**: Select your email
7. Click "Save"

### Step 8: Configure OAuth Consent Screen

1. You'll see a warning: "To use Google Sign-In, you must configure your OAuth consent screen"
2. Click "Configure" (or go to Google Cloud Console → APIs & Services → OAuth consent screen)
3. **User Type**: Select **External**
4. Click "Create"
5. **Fill in required fields:**
   - App name: `Height Banana`
   - User support email: your email
   - App logo: (optional, skip for now)
   - App domain: (skip for development)
   - Developer contact: your email
6. Click "Save and Continue"
7. **Scopes**: Click "Add or Remove Scopes"
   - Select: `auth/userinfo.email`
   - Select: `auth/userinfo.profile`
   - Select: `openid`
   - Click "Update"
   - Click "Save and Continue"
8. **Test users**: Add your Google account email
   - Click "Add Users"
   - Enter your Gmail address
   - Click "Add"
   - Click "Save and Continue"
9. Click "Back to Dashboard"

### Step 9: Set Up Cloud Firestore

1. In Firebase Console, click "Firestore Database"
2. Click "Create database"
3. **Location**: Choose closest to you:
   - US: `us-central1`
   - Europe: `europe-west1`
   - Asia: `asia-southeast1`
4. **Security rules**: Select "Production mode"
5. Click "Create"
6. Wait for database provisioning (~1 minute)

### Step 10: Configure Firestore Security Rules

1. Go to "Rules" tab
2. Replace the content with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // User profiles - users can only read/write their own profile
    match /users/{userId} {
      allow read, write: if isOwner(userId);
    }
    
    // Training sessions - users can only access their own sessions
    match /training_sessions/{sessionId} {
      // Read: user must own this session
      allow read: if isAuthenticated() && 
                     resource.data.userId == request.auth.uid;
      
      // Create: must set userId to own uid
      allow create: if isAuthenticated() && 
                       request.resource.data.userId == request.auth.uid;
      
      // Update: must be owner and not change userId
      allow update: if isAuthenticated() && 
                       resource.data.userId == request.auth.uid &&
                       request.resource.data.userId == request.auth.uid;
      
      // Delete: must be owner
      allow delete: if isAuthenticated() && 
                       resource.data.userId == request.auth.uid;
    }
  }
}
```

3. Click "Publish"

---

## Part 4: Run the App (5 minutes)

### Step 1: Start Emulator

```bash
# List available devices
flutter devices

# Start Android emulator (if not running)
# Open Android Studio → Device Manager → Click ▶️
```

### Step 2: Run Code Generation

```bash
# Generate code for Freezed models and Riverpod
flutter pub run build_runner build --delete-conflicting-outputs

# This may take 1-2 minutes
```

### Step 3: Run the App!

```bash
# Run in debug mode
flutter run

# Or specify device
flutter run -d <device-id>
```

**Expected output:**
```
Launching lib/main.dart on Android SDK built for x86 in debug mode...
✓ Built build/app/outputs/flutter-apk/app-debug.apk
Installing build/app/outputs/flutter-apk/app-debug.apk...
Debug service listening on ws://127.0.0.1:xxxxx/
```

### Step 4: Test Google Sign-In

1. App should open on emulator
2. Click "Sign in with Google"
3. Select your test user account
4. Grant permissions
5. You should be signed in! 🎉

---

## 🎯 Verification Checklist

Before you start developing, verify:

- [ ] Flutter doctor shows all ✓
- [ ] Android emulator runs smoothly
- [ ] App builds without errors
- [ ] Firebase is connected (check logs)
- [ ] Google Sign-In works
- [ ] Firestore security rules are active
- [ ] No build warnings (`flutter analyze`)

---

## 🐛 Troubleshooting

### Issue: "google-services.json not found"

**Solution:**
```bash
# Verify file location
ls -la android/app/google-services.json

# If not there, download again from Firebase Console
# Project Settings → Your apps → Download google-services.json
```

### Issue: "Google Sign-In failed"

**Symptoms:** Error message or redirect loop

**Solutions:**
1. Verify SHA-1 is added in Firebase Console
2. Check OAuth consent screen is configured
3. Ensure test user is added
4. Try on real device (emulator sometimes has issues)
5. Clear app data and try again

### Issue: "Permission denied" in Firestore

**Solution:**
1. Check security rules are published
2. Verify user is signed in (`request.auth != null`)
3. Check `userId` field matches authenticated user

### Issue: "BUILD FAILED" errors

**Solution:**
```bash
# Clean everything
flutter clean
cd android && ./gradlew clean && cd ..
rm -rf build/
flutter pub get
flutter run
```

### Issue: Emulator is slow

**Solutions:**
1. Increase RAM allocated to emulator (8GB recommended)
2. Enable hardware acceleration (Intel HAXM or AMD Hypervisor)
3. Use a physical device instead

---

## 🚀 Next Steps

✅ Development environment ready  
✅ Firebase configured  
✅ App running  

**Now you can:**

1. **Explore the codebase**: Start with `lib/main.dart`
2. **Read architecture docs**: See `docs/ARCHITECTURE.md`
3. **Start developing**: Follow `docs/CONTRIBUTING.md`
4. **Run tests**: `flutter test`
5. **Build features**: Check issues labeled `good first issue`

---

## 📚 Additional Resources

- **Flutter Docs**: https://flutter.dev/docs
- **Firebase Docs**: https://firebase.google.com/docs
- **Riverpod Docs**: https://riverpod.dev/
- **Effective Dart**: https://dart.dev/guides/language/effective-dart

---

## 💡 Pro Tips

1. **Use hot reload**: Press `r` in terminal while app runs
2. **Use hot restart**: Press `R` for full restart
3. **Enable DevTools**: Press `w` to open Flutter DevTools
4. **Watch logs**: Use `flutter logs` in separate terminal
5. **Format code**: Run `dart format .` before committing

---

**Need help?** Open an issue or check `docs/TROUBLESHOOTING.md`

Happy coding! 🎯✨
