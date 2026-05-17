# 🔄 GitHub Flow & Release Process

## Overview

This project uses **Google's release-please** with a sophisticated GitHub Actions workflow for automated testing, building, and deployment across two environments.

---

## 🌊 Git Flow

### Branch Strategy

```
main (production)
  ↑
  └─ develop (staging)
       ↑
       └─ feature/* (development)
```

### Environments

| Environment | Branch | Auto-Deploy | Purpose |
|-------------|--------|-------------|---------|
| **Development** | feature branches, PRs | ✅ Yes | Testing PRs |
| **Production** | main | ✅ Yes (via release-please) | Live app |

---

## 🚀 Development Workflow

### 1. Create Feature Branch

```bash
# From develop or main
git checkout -b feature/amazing-feature

# Make changes
git add .
git commit -m "feat(scope): add amazing feature"
git push origin feature/amazing-feature
```

### 2. Open Pull Request

When you open a PR to `main` or `develop`:

**Automatic Actions:**
1. ✅ **Quality Checks** - Code analysis, formatting, security scan
2. ✅ **Test Suite** - Unit tests, widget tests, coverage report
3. ✅ **Build Development** - Debug APK built
4. ✅ **Deploy to Development** - Uploaded to Firebase App Distribution
5. 💬 **PR Comment** - Deployment link and coverage stats

**Result:** Your PR is automatically tested and deployed to testers!

### 3. Review & Merge

Once approved and merged to `develop` or `main`:
- **Develop merge:** Builds development version
- **Main merge:** Triggers release-please

---

## 📦 Release Process (Production)

### Automated with Release Please

**How it works:**

1. **Commits to main** - Release-please analyzes commits
2. **Create Release PR** - Automatic PR with:
   - Version bump (major.minor.patch)
   - Generated CHANGELOG.md
   - Updated version in pubspec.yaml
3. **Review & Merge PR** - Team reviews and merges
4. **Automatic Production Deployment:**
   - ✅ Full test suite
   - ✅ Build signed APK & AAB
   - ✅ Deploy to Play Store (Internal Testing)
   - ✅ Deploy to Firebase App Distribution
   - ✅ Create GitHub Release with artifacts
   - ✅ Tag release

---

## 📝 Commit Message Format

Use **Conventional Commits** for automatic versioning:

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### Types & Version Bumps

| Type | Version Bump | Description |
|------|--------------|-------------|
| `feat` | **minor** (0.X.0) | New feature |
| `fix` | **patch** (0.0.X) | Bug fix |
| `perf` | **patch** | Performance improvement |
| `feat!` or `BREAKING CHANGE` | **major** (X.0.0) | Breaking change |
| `docs` | none | Documentation only |
| `test` | none | Tests only |
| `ci` | none | CI/CD changes |
| `chore` | none | Maintenance |

### Examples

```bash
# Feature (minor bump)
git commit -m "feat(auth): add biometric authentication"

# Bug fix (patch bump)
git commit -m "fix(camera): resolve permission crash on Android 13"

# Breaking change (major bump)
git commit -m "feat(api)!: redesign session storage format

BREAKING CHANGE: Sessions now use new schema"

# Documentation (no bump)
git commit -m "docs: update quickstart guide"

# Performance (patch bump)
git commit -m "perf(heatmap): optimize rendering with canvas caching"
```

---

## 🔄 Workflow Details

### Development Deployment (`deploy-dev.yml`)

**Triggers:**
- PR opened/updated to `main` or `develop`
- Push to `develop`

**Steps:**
1. Run quality checks (analyzer, formatting, security)
2. Run test suite (unit, widget, coverage)
3. Build debug APK
4. Deploy to Firebase App Distribution (dev group)
5. Comment on PR with deployment info

**Artifacts:**
- Debug APK (30 days retention)

---

### Release Please (`release-please.yml`)

**Triggers:**
- Push to `main` (after PR merge)

**Steps:**
1. Analyze commits since last release
2. Calculate next version
3. Generate CHANGELOG.md
4. Create/update release PR
5. When release PR is merged:
   - Tag release
   - Trigger production deployment

**Release PR includes:**
- Version bump in `pubspec.yaml`
- Generated CHANGELOG.md
- Git tag preparation

---

### Production Deployment (`deploy-prod.yml`)

**Triggers:**
- Release-please creates release (automatic)
- Manual workflow dispatch (for hotfixes)

**Steps:**
1. Run full test suite
2. Run quality checks
3. Build signed production APK & AAB
4. Deploy to Google Play Store (Internal Testing track)
5. Deploy to Firebase App Distribution (prod group)
6. Create GitHub Release with artifacts
7. Notify team

**Artifacts:**
- Release APK (90 days retention)
- Release AAB (90 days retention)

---

## 🔐 Required Secrets

### GitHub Secrets Configuration

Navigate to: **Settings → Secrets → Actions**

#### Development Environment

```
FIREBASE_APP_ID_DEV
FIREBASE_SERVICE_ACCOUNT
```

#### Production Environment

```
FIREBASE_APP_ID_PROD
KEYSTORE_BASE64          # Base64 encoded keystore
KEYSTORE_PASSWORD        # Keystore password
KEY_ALIAS                # Key alias
KEY_PASSWORD             # Key password
GOOGLE_PLAY_SERVICE_ACCOUNT  # Play Store API key
```

#### How to Create Secrets

**Keystore (Production):**
```bash
# Encode keystore to base64
cat upload-keystore.jks | base64 > keystore_base64.txt
# Copy content to KEYSTORE_BASE64 secret
```

**Firebase Service Account:**
```bash
# Download from Firebase Console
# Settings → Service Accounts → Generate New Private Key
# Copy JSON content to FIREBASE_SERVICE_ACCOUNT
```

---

## 📊 Workflow Diagram

```
┌─────────────────────────────────────────────────────────┐
│ Developer creates feature branch                         │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│ Opens PR to main/develop                                 │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│ Automated CI/CD:                                         │
│  ✅ Quality Checks                                       │
│  ✅ Test Suite (with coverage)                          │
│  ✅ Build Development APK                               │
│  ✅ Deploy to Firebase (testers-dev)                    │
│  💬 Comment on PR                                        │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│ Code review & approval                                   │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│ Merge to main                                            │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│ Release Please:                                          │
│  📝 Analyze commits                                      │
│  🔢 Calculate version                                    │
│  📄 Generate CHANGELOG                                   │
│  🔀 Create Release PR                                    │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│ Review & Merge Release PR                               │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│ Production Deployment:                                   │
│  ✅ Full test suite                                      │
│  🏗️ Build signed APK/AAB                                │
│  🏪 Deploy to Play Store                                │
│  🔥 Deploy to Firebase (prod)                           │
│  🎉 Create GitHub Release                               │
│  🏷️ Tag release                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 Best Practices

### Commits
✅ Use conventional commit format
✅ Keep commits focused and atomic
✅ Write descriptive commit messages
✅ Reference issue numbers (#123)

### Pull Requests
✅ Create from feature branches
✅ Keep PRs small and focused
✅ Wait for CI checks to pass
✅ Request reviews before merging
✅ Squash commits when merging

### Releases
✅ Let release-please handle versioning
✅ Review release PRs carefully
✅ Test in development before production
✅ Monitor deployment notifications
✅ Check Firebase App Distribution after deploy

---

## 🐛 Troubleshooting

### CI Fails on PR

**Quality check fails:**
```bash
# Run locally
flutter analyze
dart format --set-exit-if-changed .
```

**Tests fail:**
```bash
# Run locally
flutter test
```

### Release PR Not Created

**Check:**
- Commits use conventional format
- At least one `feat` or `fix` commit since last release
- Push is to `main` branch
- GitHub Actions have proper permissions

### Production Deployment Fails

**Check:**
- All secrets are configured
- Keystore is valid
- Firebase service account has permissions
- Play Store API is enabled

---

## 📞 Support

- 🐛 **Issues:** GitHub Issues
- 💬 **Discussions:** GitHub Discussions
- 📖 **Docs:** See `docs/` folder

---

**Happy releasing!** 🚀✨
