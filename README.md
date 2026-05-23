# 🎯 Height Banana - Archery Analytics

<div align="center">

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

*A cross-platform Flutter application for archery training analytics with computer vision*

**[�� Quick Start](#-quick-start)** •
**[Features](#-features)** •
**[Documentation](#-documentation)** •
**[Contributing](#-contributing)**

</div>

---

## 📖 Overview

Height Banana is a specialized mobile application designed to help archers track training sessions, analyze performance, and improve accuracy. Using computer vision and machine learning, the app can automatically detect and score arrows from target photos.

### ✨ Features

#### Core Functionality
- 🔐 **Google Authentication** - Secure sign-in with Google accounts
- ☁️ **Cloud Sync** - Data synced across devices via Firebase Firestore
- 📴 **Offline Support** - Full functionality offline with automatic sync (Hive)
- 📷 **Smart Scoring** - ML-powered target and arrow detection (Google ML Kit)
- 📊 **Analytics Dashboard** - Score trends, grouping analysis, and statistics
- 🎯 **Session Tracking** - Log training sessions with multiple ends
- 🎨 **Grouping Heatmap** - Visual arrow plot with quality ratings
- 📱 **Material Design** - Beautiful, intuitive UI with archery-inspired theme

#### Developer Experience
- 🐳 **Dev Container** - Zero-setup development environment (10 minutes)
- 🔄 **GitHub Actions** - Automated testing, building, and deployment
- 📦 **Release Automation** - Semantic versioning with release-please
- 🌍 **Dual Environments** - Separate development and production deployments
- 🔒 **Security Scanning** - CodeQL, Trivy, and Dependabot
- 🧪 **Automated Testing** - Complete test suite with coverage reporting

---

## 🚀 Quick Start

### Option 1: 🐳 Dev Container (Recommended - Zero Setup!)

**No local Flutter/Android SDK installation needed!** Everything runs in a container:

#### Prerequisites
- [Docker Engine (docker-ce)](https://docs.docker.com/engine/install/)
- [VS Code](https://code.visualstudio.com/)
- [Dev Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

#### Quick Start
```bash
git clone https://github.com/psilore/height-banana.git
cd height-banana
code .
# Press F1 → "Dev Containers: Reopen in Container"
# Wait ~5-10 minutes for automatic setup ☕
```

📖 **[Full Dev Container Guide →](.devcontainer/README.md)**

---

### Option 2: 🛠️ Manual Setup (Traditional)

**Want to run the app in 30 minutes with local installation?** 

👉 **[Follow the Complete Quick Start Guide](QUICKSTART.md)** 👈

It covers:
1. ✅ Installing Flutter & Android Studio
2. ✅ Setting up Firebase & Google Sign-In
3. ✅ Configuring OAuth & Firestore
4. ✅ Running the app on emulator
5. ✅ Troubleshooting common issues

---

### 📚 Additional Resources

- **[🔥 Firebase Setup](docs/FIREBASE_SETUP.md)** - Configure Firebase & Google Sign-In
- **[🔄 GitHub Flow](docs/GITHUB_FLOW.md)** - CI/CD & release process
- **[🌍 Environments](docs/ENVIRONMENTS.md)** - Development & production setup
- **[🔧 Workflow Docs](.github/workflows/WORKFLOW_README.md)** - Technical CI/CD details

---

### TL;DR - For Experienced Developers

```bash
# Prerequisites: Flutter 3.0+, Android Studio, Firebase account

# 1. Clone & install
git clone https://github.com/psilore/height-banana.git
cd height-banana
flutter pub get

# 2. Firebase Setup (see QUICKSTART.md for details)
# - Create Firebase project
# - Add Android app with package: com.psilore.height_banana
# - Download google-services.json to android/app/
# - Enable Authentication (Google)
# - Enable Firestore with security rules

# 3. Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Run app
flutter run
```

**Having issues?** Check [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

---

## 🛠️ Tech Stack

| Category | Technologies |
|----------|-------------|
| **Framework** | Flutter 3.22+, Dart |
| **State Management** | Riverpod (with code generation) |
| **Authentication** | Firebase Auth, Google Sign-In |
| **Database** | Cloud Firestore (cloud), Hive (local cache) |
| **Computer Vision** | Google ML Kit, OpenCV-style detection |
| **Charts & Viz** | fl_chart, Custom Canvas Painters |
| **Architecture** | Clean Architecture, Domain-Driven Design |
| **Code Generation** | Freezed, JSON Serializable, Riverpod Generator |
| **CI/CD** | GitHub Actions, Release-Please, Firebase App Distribution |
| **Security** | CodeQL, Trivy, Dependabot, Secret Scanning |
| **Dev Tools** | Dev Containers (Docker), VS Code |

---

## 📁 Project Structure

```
lib/
├── app/                    # App initialization, routing, theme
├── core/                   # Shared utilities, constants, services
└── features/
    ├── auth/              # Authentication & user management
    ├── session_logger/    # Training session tracking
    ├── target_analyzer/   # Camera & ML target detection
    └── statistics/        # Analytics & reporting
```

Each feature follows **Clean Architecture**:
- `domain/` - Business logic & entities
- `data/` - Repositories & data sources
- `presentation/` - UI screens & Riverpod providers

---

## 📚 Documentation

### Getting Started
- **[🚀 QUICKSTART.md](QUICKSTART.md)** - Complete setup guide (30 mins)
- **[🔥 FIREBASE_SETUP.md](docs/FIREBASE_SETUP.md)** - Firebase configuration
- **[🐳 Dev Container Guide](.devcontainer/README.md)** - Zero-setup development
- **[🐛 TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Common issues & solutions

### CI/CD & Deployment
- **[🔄 GITHUB_FLOW.md](docs/GITHUB_FLOW.md)** - Complete CI/CD workflow guide
- **[🌍 ENVIRONMENTS.md](docs/ENVIRONMENTS.md)** - Development & production setup
- **[🔧 Workflow Docs](.github/workflows/WORKFLOW_README.md)** - Technical workflow details
- **[🚢 DEPLOYMENT.md](docs/DEPLOYMENT.md)** - Release process

### Architecture & Development
- **[🏗️ ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Technical design overview
- **[📖 API_REFERENCE.md](docs/API_REFERENCE.md)** - API documentation
- **[🤝 CONTRIBUTING.md](docs/CONTRIBUTING.md)** - Contribution guidelines

### Security & Maintenance
- **[🔒 SECURITY.md](.github/SECURITY.md)** - Security policy
- **[🔍 SECURITY_AUDIT.md](SECURITY_AUDIT.md)** - Security audit report
- **[🧹 CLEANUP_GUIDE.md](CLEANUP_GUIDE.md)** - Repository cleanup instructions

---

## 🤝 Contributing

We welcome contributions! Please read our [Contributing Guide](docs/CONTRIBUTING.md) to get started.

### Quick Contribution Steps

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Run checks:
   ```bash
   dart format .
   flutter analyze
   flutter test
   ```
5. **Use conventional commits:** `git commit -m 'feat(scope): Add amazing feature'`
6. Push: `git push origin feature/amazing-feature`
7. Open a Pull Request

**Note:** We use [Conventional Commits](https://www.conventionalcommits.org/) for automatic versioning and changelog generation. See [GITHUB_FLOW.md](docs/GITHUB_FLOW.md) for details.

### What Happens on PR

When you open a PR, our CI/CD automatically:
- ✅ Runs code quality checks (analyzer + formatter)
- ✅ Executes full test suite with coverage
- ✅ Builds debug APK
- ✅ Deploys to Firebase App Distribution (development)
- 💬 Comments results on your PR

See [GITHUB_FLOW.md](docs/GITHUB_FLOW.md) for the complete workflow.

### Looking for First Issues?

Check issues labeled:
- `good first issue` - Perfect for newcomers
- `documentation` - Help improve docs
- `bug` - Fix existing issues
- `enhancement` - Add new features

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test
flutter test test/unit/domain/arrow_test.dart

# Open coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 🔒 Security

We take security seriously. **Security audit performed:** ✅ **No secrets found**

- ✅ **GitHub CodeQL** - Automated vulnerability scanning (weekly)
- ✅ **Trivy Scanner** - Container & dependency scanning
- ✅ **Dependabot** - Automatic dependency updates (weekly)
- ✅ **Secret Scanning** - Prevents accidental secret commits
- ✅ **Firestore Rules** - Production-ready, UID-scoped data access
- ✅ **Security Audit** - Comprehensive audit completed ([Report](SECURITY_AUDIT.md))
- ✅ **Security Policy** - Responsible disclosure process ([.github/SECURITY.md](.github/SECURITY.md))

Found a security issue? See our [Security Policy](.github/SECURITY.md) for responsible disclosure.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Flutter Team** - Amazing framework
- **Firebase** - Backend infrastructure
- **Google ML Kit** - Computer vision capabilities
- **Archery Community** - Domain expertise and feedback

---

## 📊 Project Status

- ✅ **Status**: **PRODUCTION-READY**
- 🎯 **Progress**: **100% Complete** (49/49 features + CI/CD)
- 📱 **Platform**: Android (iOS architecture ready)
- 🔄 **Last Updated**: May 17, 2026

### ✅ Complete Features

**Core Application (12 Screens)**
- ✅ Google Authentication & User Profiles
- ✅ Firebase Integration (Auth + Firestore + offline sync)
- ✅ Session Management (Create, View, Edit, Delete)
- ✅ End Logging (Manual score entry)
- ✅ Camera Integration (High-quality target capture)
- ✅ ML Target Detection (Google ML Kit + fallback)
- ✅ Arrow Detection (Edge detection with coordinate mapping)
- ✅ Score Calculation (Archery line-touching rules)
- ✅ Statistics Dashboard (Charts, trends, averages)
- ✅ Grouping Heatmap (Visual arrow plot with metrics)
- ✅ Session History (Filter, sort, search)
- ✅ Offline-First Architecture (Hive cache + Firestore sync)

**Developer Experience & CI/CD**
- ✅ Dev Container (Zero-setup development)
- ✅ Automated Testing (Unit, widget, integration)
- ✅ GitHub Actions Workflows (7 active)
- ✅ Release-Please (Semantic versioning)
- ✅ Dual Environments (Development & Production)
- ✅ Firebase App Distribution (Automated)
- ✅ Google Play Deployment (Ready)
- ✅ Security Scanning (Triple layer)
- ✅ Comprehensive Documentation (24 files)

---

<div align="center">

**Built with ❤️ for the Archery Community**

[⭐ Star this repo](https://github.com/psilore/height-banana) •
[🐛 Report Bug](https://github.com/psilore/height-banana/issues) •
[💡 Request Feature](https://github.com/psilore/height-banana/issues)

</div>
