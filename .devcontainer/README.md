# Dev Container Setup for Height Banana

This project includes a fully configured **Dev Container** that provides a complete Flutter development environment without requiring local installation of Flutter, Android SDK, or other dependencies.

## 🎯 Benefits

- ✅ **Zero Local Setup** - No Flutter or Android SDK installation needed
- ✅ **Consistent Environment** - Same setup for all developers
- ✅ **Clean Host System** - All dependencies contained
- ✅ **Pre-configured VS Code** - Extensions and settings included
- ✅ **Fast Onboarding** - Ready to code in minutes
- ✅ **Automated Setup** - Post-create scripts handle everything

## 📋 Prerequisites

### Required
- **Docker Desktop** ([Install](https://www.docker.com/products/docker-desktop))
- **Visual Studio Code** ([Install](https://code.visualstudio.com/))
- **Dev Containers Extension** ([Install](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers))

### Optional (but recommended)
- **Android Device** or **Android Emulator** (see below)

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/psilore/height-banana.git
cd height-banana
```

### 2. Open in Dev Container

**Option A: VS Code Command Palette**
1. Open folder in VS Code
2. Press `F1` or `Ctrl+Shift+P` (Cmd+Shift+P on Mac)
3. Select **"Dev Containers: Reopen in Container"**
4. Wait for container to build (first time takes 5-10 minutes)

**Option B: VS Code Notification**
1. Open folder in VS Code
2. Click **"Reopen in Container"** when prompted

### 3. Wait for Automatic Setup

The container will automatically:
- ✅ Install Flutter SDK
- ✅ Install Android SDK
- ✅ Accept Android licenses
- ✅ Run `flutter pub get`
- ✅ Run code generation (`build_runner`)
- ✅ Create debug keystore
- ✅ Verify installation with `flutter doctor`

**This takes ~5-10 minutes on first run.**

### 4. Verify Installation

Open integrated terminal in VS Code and run:

```bash
flutter doctor -v
```

You should see all checkmarks! ✅

## 🔧 Firebase Configuration

The Dev Container doesn't include Firebase credentials (for security). You still need to configure Firebase:

### Quick Firebase Setup

```bash
# Inside the Dev Container terminal:

# 1. Install Firebase CLI
npm install -g firebase-tools

# 2. Login to Firebase
firebase login --no-localhost

# 3. Configure FlutterFire
dart pub global activate flutterfire_cli
flutterfire configure
```

See [QUICKSTART.md](../docs/QUICKSTART.md) for detailed Firebase setup instructions.

## 📱 Running the App

### Option 1: Connected Android Device

1. **Enable USB Debugging** on your Android device
2. **Connect via USB** to your host machine
3. **Allow USB debugging** when prompted on device
4. In Dev Container terminal:
   ```bash
   flutter devices  # Should show your device
   flutter run
   ```

### Option 2: Android Emulator (Host Machine)

Since the Dev Container doesn't include the emulator, you can:

1. **Install Android Studio on host** (just for emulator)
2. **Start emulator on host:**
   ```bash
   # On your host machine (not in container)
   emulator -avd Pixel_5_API_33
   ```
3. **Connect to container:**
   ```bash
   # In Dev Container terminal
   adb connect host.docker.internal:5555
   flutter devices
   flutter run
   ```

### Option 3: Physical Device over Wi-Fi

1. **Connect device to same network** as host
2. **Enable wireless debugging** (Android 11+)
3. **Connect via ADB:**
   ```bash
   adb connect <device-ip>:5555
   flutter run
   ```

## 🛠️ Development Workflow

### Running Commands

All Flutter commands work as expected inside the container:

```bash
# Get dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Analyze code
flutter analyze

# Run tests
flutter test

# Format code
dart format lib/

# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### VS Code Features

The Dev Container includes pre-configured extensions:
- ✅ Dart & Flutter syntax highlighting
- ✅ Code snippets
- ✅ Auto-formatting on save
- ✅ Hot reload support
- ✅ Debugging
- ✅ GitLens
- ✅ GitHub Copilot (if you have access)

### Port Forwarding

The following ports are automatically forwarded:
- **8080** - Local development server
- **5000** - Firebase emulator
- **9099** - Firestore emulator

## 🔄 Rebuilding the Container

If you update dependencies or Dev Container config:

```bash
# Command Palette (F1)
Dev Containers: Rebuild Container
```

## 📂 Persisted Data

The Dev Container mounts:
- ✅ `~/.ssh` - SSH keys (for git)
- ✅ `~/.gitconfig` - Git configuration
- ✅ Project workspace

Everything else is isolated in the container.

## 🐛 Troubleshooting

### "Flutter not found"

**Symptom:** `flutter: command not found`

**Solution:**
```bash
export PATH="/sdks/flutter/bin:$PATH"
source ~/.bashrc
```

### "No devices found"

**Symptom:** `flutter devices` shows nothing

**Solutions:**
1. **Check USB connection:** `adb devices` should show device
2. **Restart ADB server:**
   ```bash
   adb kill-server
   adb start-server
   ```
3. **Check device has USB debugging enabled**

### Container build fails

**Solution:**
1. Check Docker has enough resources (4GB+ RAM)
2. Clear Docker cache:
   ```bash
   docker system prune -a
   ```
3. Rebuild container from scratch

### "Permission denied" errors

**Solution:**
```bash
# Inside container
chmod +x .devcontainer/post-create.sh
chmod +x android/gradlew
```

### Android licenses not accepted

**Solution:**
```bash
flutter doctor --android-licenses
# Press 'y' for all prompts
```

## 🔒 Security Notes

- **SSH Keys:** Mounted read-only from host
- **Git Config:** Mounted read-only from host
- **Firebase Credentials:** NOT included, must configure manually
- **Keystore:** Debug keystore auto-generated (not for production)
- **Secrets:** Never commit secrets to Dev Container config

## 🎓 Learn More

- [VS Code Dev Containers Documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [Flutter in Containers](https://flutter.dev/docs/get-started/install/linux#docker)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

## ⚡ Performance Tips

1. **Allocate enough resources** to Docker:
   - 4GB+ RAM
   - 4+ CPU cores
   - 20GB+ disk space

2. **Use named volumes** for Gradle cache (coming soon):
   ```json
   "mounts": [
     "source=gradle-cache,target=/root/.gradle,type=volume"
   ]
   ```

3. **Pre-download dependencies** before working offline:
   ```bash
   flutter pub get
   flutter precache
   ```

## 🤝 Contributing

When contributing, please use the Dev Container to ensure consistency:
1. Open project in Dev Container
2. Make changes
3. Run tests: `flutter test`
4. Run analyzer: `flutter analyze`
5. Format code: `dart format lib/`
6. Commit and push

---

**Happy Coding!** 🎯✨

*Need help? Check [TROUBLESHOOTING.md](../docs/TROUBLESHOOTING.md) or open an issue.*
