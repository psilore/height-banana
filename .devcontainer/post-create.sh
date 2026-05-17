#!/bin/bash
set -e

echo "🚀 Setting up Flutter development environment..."

# Update package lists
apt-get update

# Install additional dependencies
apt-get install -y \
  openjdk-17-jdk \
  unzip \
  wget \
  curl \
  git \
  libglu1-mesa \
  clang \
  cmake \
  ninja-build \
  pkg-config \
  libgtk-3-dev \
  liblzma-dev

# Accept Android licenses
yes | flutter doctor --android-licenses || true

# Run flutter doctor to verify installation
echo "📱 Verifying Flutter installation..."
flutter doctor -v

# Get Flutter dependencies
echo "📦 Installing Flutter dependencies..."
flutter pub get

# Run code generation for Freezed models
echo "🔨 Running code generation..."
flutter pub run build_runner build --delete-conflicting-outputs || true

# Pre-download Gradle
echo "⚙️ Pre-downloading Gradle..."
cd android && ./gradlew --version && cd .. || true

# Create Android debug keystore if it doesn't exist
if [ ! -f ~/.android/debug.keystore ]; then
  echo "🔑 Creating debug keystore..."
  mkdir -p ~/.android
  keytool -genkey -v \
    -keystore ~/.android/debug.keystore \
    -storepass android \
    -alias androiddebugkey \
    -keypass android \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -dname "CN=Android Debug,O=Android,C=US" || true
fi

# Configure git (if not already configured)
if [ ! -f ~/.gitconfig ]; then
  git config --global user.email "developer@height-banana.local"
  git config --global user.name "Height Banana Developer"
fi

echo "✅ Development environment ready!"
echo ""
echo "🎯 Quick Start Commands:"
echo "  flutter doctor          - Check Flutter installation"
echo "  flutter pub get         - Get dependencies"
echo "  flutter run             - Run on emulator/device"
echo "  flutter test            - Run tests"
echo "  flutter analyze         - Analyze code"
echo ""
echo "📝 Note: You'll need to configure Firebase before running the app."
echo "    See docs/QUICKSTART.md for instructions."
