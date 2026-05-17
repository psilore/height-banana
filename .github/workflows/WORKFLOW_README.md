# 🔧 GitHub Workflows Documentation

## Overview

This project uses a **sophisticated CI/CD pipeline** with reusable workflows, automated testing, and release automation via Google's release-please.

---

## 📂 Workflow Files

### Reusable Workflows (Building Blocks)

| File | Purpose | Used By |
|------|---------|---------|
| `test.yml` | Run test suite with coverage | deploy-dev, deploy-prod |
| `quality.yml` | Code analysis & security | deploy-dev, deploy-prod |
| `build.yml` | Build APK/AAB for environments | deploy-dev, deploy-prod |

### Deployment Workflows

| File | Purpose | Triggers |
|------|---------|----------|
| `deploy-dev.yml` | Deploy to development | PR to main/develop, Push to develop |
| `deploy-prod.yml` | Deploy to production | Release created |
| `release-please.yml` | Automated releases | Push to main |

### Legacy Workflows

| File | Purpose | Status |
|------|---------|--------|
| `pr_verification.yml` | Quick PR checks | ⚠️ Superseded by deploy-dev |
| `cd_deploy.yml` | Old deployment | ⚠️ Superseded by deploy-prod |
| `security_scan.yml` | Security scanning | ⚠️ Merged into quality.yml |

---

## 🔄 Workflow Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    REUSABLE WORKFLOWS                        │
│  (Called by other workflows, not triggered directly)        │
└─────────────────────────────────────────────────────────────┘

┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  test.yml    │  │ quality.yml  │  │  build.yml   │
│              │  │              │  │              │
│ • Run tests  │  │ • Analyze    │  │ • Build APK  │
│ • Coverage   │  │ • Format     │  │ • Build AAB  │
│ • Report     │  │ • Security   │  │ • Sign       │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘
       │                  │                  │
       │                  │                  │
       └──────────────────┴──────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                   DEPLOYMENT WORKFLOWS                       │
│        (Orchestrate reusable workflows)                     │
└─────────────────────────────────────────────────────────────┘

┌──────────────────────┐        ┌──────────────────────┐
│   deploy-dev.yml     │        │  release-please.yml  │
│                      │        │                      │
│ Trigger:             │        │ Trigger:             │
│ • PR to main/develop │        │ • Push to main       │
│ • Push to develop    │        │                      │
│                      │        │ Actions:             │
│ Steps:               │        │ • Analyze commits    │
│ 1. quality.yml       │        │ • Calculate version  │
│ 2. test.yml          │        │ • Create PR          │
│ 3. build.yml (dev)   │        │ • Trigger prod       │
│ 4. Deploy Firebase   │        └──────────┬───────────┘
└──────────────────────┘                   │
                                           │
                                           ▼
                          ┌──────────────────────┐
                          │  deploy-prod.yml     │
                          │                      │
                          │ Trigger:             │
                          │ • Release created    │
                          │                      │
                          │ Steps:               │
                          │ 1. quality.yml       │
                          │ 2. test.yml          │
                          │ 3. build.yml (prod)  │
                          │ 4. Deploy Play Store │
                          │ 5. Deploy Firebase   │
                          │ 6. GitHub Release    │
                          └──────────────────────┘
```

---

## 🎯 Workflow Details

### 1. test.yml (Reusable)

**Purpose:** Run comprehensive test suite with coverage reporting

**Inputs:**
- `flutter-version` (optional): Flutter version to use

**Outputs:**
- `coverage`: Test coverage percentage

**Steps:**
1. Checkout code
2. Setup Flutter
3. Get dependencies
4. Generate code (Freezed/JSON)
5. Run unit tests with coverage
6. Run widget tests
7. Generate coverage report
8. Upload to Codecov
9. Comment on PR with results

**Called by:** deploy-dev.yml, deploy-prod.yml

---

### 2. quality.yml (Reusable)

**Purpose:** Code quality checks and security scanning

**Inputs:**
- `flutter-version` (optional): Flutter version to use

**Jobs:**
- **analyze:** Static analysis, formatting, TODO check
- **security:** Trivy vulnerability scanner
- **dependency-review:** Check for vulnerable dependencies (PR only)

**Steps:**
1. Checkout code
2. Setup Flutter
3. Get dependencies
4. Generate code
5. Run analyzer (fatal on warnings)
6. Check formatting
7. Scan for TODO/FIXME
8. Run security scans

**Called by:** deploy-dev.yml, deploy-prod.yml

---

### 3. build.yml (Reusable)

**Purpose:** Build Android APK and AAB for different environments

**Inputs:**
- `flutter-version` (optional): Flutter version
- `build-number` (required): Build number
- `environment` (required): 'development' or 'production'

**Secrets (Production only):**
- `KEYSTORE_BASE64`: Encoded keystore
- `KEYSTORE_PASSWORD`: Keystore password
- `KEY_ALIAS`: Key alias
- `KEY_PASSWORD`: Key password

**Outputs:**
- `apk-path`: Path to built APK
- `aab-path`: Path to built AAB

**Steps:**
1. Checkout code
2. Setup Flutter & Java
3. Get dependencies
4. Generate code
5. Decode keystore (production only)
6. Build APK (debug or release)
7. Build AAB (production only)
8. Upload artifacts
9. Cleanup sensitive files

**Called by:** deploy-dev.yml, deploy-prod.yml

---

### 4. deploy-dev.yml (Deployment)

**Purpose:** Deploy to development environment on PR

**Triggers:**
- Pull request (opened/updated) to main/develop
- Push to develop

**Concurrency:** Cancels previous runs for same ref

**Jobs:**
1. **quality:** Run quality checks
2. **test:** Run test suite
3. **build:** Build development APK
4. **deploy-dev:** Deploy to Firebase App Distribution
5. **notify:** Post results

**Environment:** `development`

**Secrets Required:**
- `FIREBASE_APP_ID_DEV`
- `FIREBASE_SERVICE_ACCOUNT`

**Artifacts:**
- Debug APK (30 days retention)

**PR Comment:**
- Deployment status
- Build number
- Download link

---

### 5. release-please.yml (Release Automation)

**Purpose:** Automated semantic versioning and releases

**Triggers:**
- Push to main

**Permissions:**
- contents: write
- pull-requests: write

**Steps:**
1. **Analyze commits:** Parse conventional commits
2. **Calculate version:** Determine next version (major.minor.patch)
3. **Generate CHANGELOG:** Create/update CHANGELOG.md
4. **Create PR:** Release PR with version bump
5. **On PR merge:**
   - Tag release
   - Trigger deploy-prod.yml

**Release Please Configuration:**
- Type: simple
- Package name: height-banana
- Changelog types: feat, fix, perf, refactor, docs, test, build, ci

**Outputs:**
- `release-created`: Whether release was created
- `tag-name`: Git tag (e.g., v1.2.3)
- `version`: Version number (e.g., 1.2.3)

---

### 6. deploy-prod.yml (Production Deployment)

**Purpose:** Deploy to production on release

**Triggers:**
- Called by release-please.yml (automatic)
- Workflow dispatch (manual)

**Inputs:**
- `version`: Version number
- `tag-name`: Git tag

**Jobs:**
1. **test:** Full test suite
2. **quality:** Quality checks
3. **build:** Build signed production artifacts
4. **deploy-play-store:** Deploy to Google Play (Internal Testing)
5. **deploy-firebase:** Deploy to Firebase App Distribution
6. **create-release:** Create GitHub Release with artifacts
7. **notify:** Post results

**Environment:** `production`

**Secrets Required:**
- `FIREBASE_APP_ID_PROD`
- `FIREBASE_SERVICE_ACCOUNT`
- `KEYSTORE_BASE64`
- `KEYSTORE_PASSWORD`
- `KEY_ALIAS`
- `KEY_PASSWORD`
- `GOOGLE_PLAY_SERVICE_ACCOUNT`

**Artifacts:**
- Release APK (90 days retention)
- Release AAB (90 days retention)

**Play Store:**
- Track: Internal Testing
- Status: Completed

**GitHub Release:**
- Tag: From release-please
- Assets: APK, AAB
- Notes: Auto-generated from commits

---

## 🔐 Secrets Configuration

### Required Secrets

**Development:**
```
FIREBASE_APP_ID_DEV          # Firebase App ID
FIREBASE_SERVICE_ACCOUNT     # Firebase service account JSON
```

**Production:**
```
FIREBASE_APP_ID_PROD         # Firebase App ID
FIREBASE_SERVICE_ACCOUNT     # Firebase service account JSON (same as dev)
KEYSTORE_BASE64              # Base64 encoded keystore
KEYSTORE_PASSWORD            # Keystore password
KEY_ALIAS                    # Key alias
KEY_PASSWORD                 # Key password
GOOGLE_PLAY_SERVICE_ACCOUNT  # Play Store API JSON
```

### Adding Secrets

1. **Navigate to:** Repository Settings → Secrets → Actions
2. **Click:** New repository secret (or New environment secret)
3. **Add each secret** with exact name and value

---

## 📝 Conventional Commits

All commits must follow **Conventional Commits** format for release-please to work:

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### Types & Version Bumps

| Type | Bump | Example |
|------|------|---------|
| `feat` | minor (0.X.0) | `feat(auth): add biometric login` |
| `fix` | patch (0.0.X) | `fix(camera): resolve permission crash` |
| `feat!` | major (X.0.0) | `feat(api)!: redesign session format` |
| `docs` | none | `docs: update setup guide` |
| `test` | none | `test: add score calculation tests` |
| `ci` | none | `ci: add automated deployment` |

---

## 🔄 Workflow Execution Flow

### Development Flow (PR)

```
1. Developer creates feature branch
   ↓
2. Opens PR to main/develop
   ↓
3. deploy-dev.yml triggers
   ↓
4. Runs quality.yml (analyze + security)
   ↓
5. Runs test.yml (tests + coverage)
   ↓
6. Runs build.yml (debug APK)
   ↓
7. Deploys to Firebase App Distribution
   ↓
8. Comments on PR with results
   ↓
9. Team reviews and merges
```

### Production Flow (Release)

```
1. PRs merged to main
   ↓
2. release-please.yml triggers
   ↓
3. Analyzes commits since last release
   ↓
4. Creates Release PR with:
   - Version bump in pubspec.yaml
   - Generated CHANGELOG.md
   - Git tag preparation
   ↓
5. Team reviews Release PR
   ↓
6. Release PR merged
   ↓
7. release-please tags release
   ↓
8. deploy-prod.yml triggers
   ↓
9. Runs quality.yml + test.yml
   ↓
10. Runs build.yml (signed APK/AAB)
   ↓
11. Deploys to Google Play Store
   ↓
12. Deploys to Firebase App Distribution
   ↓
13. Creates GitHub Release
   ↓
14. Notifies team
```

---

## 🧪 Testing Workflows Locally

### Using act (GitHub Actions locally)

```bash
# Install act
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Test quality workflow
act -j quality

# Test test workflow
act -j test

# Test with secrets
act -j build --secret-file .secrets
```

### Manual Testing

```bash
# Test code quality
flutter analyze
dart format --set-exit-if-changed .

# Test build
flutter test --coverage
flutter build apk --debug

# Test security
trivy fs .
```

---

## 📊 Monitoring & Debugging

### View Workflow Runs

1. **Go to:** Repository → Actions tab
2. **Select workflow:** From left sidebar
3. **View runs:** Click on any run to see details
4. **Check logs:** Expand job and step to see logs

### Common Issues

**Test failures:**
```bash
# Run locally first
flutter test

# Check specific test
flutter test test/path/to/test.dart
```

**Build failures:**
```bash
# Check dependencies
flutter pub get

# Generate code
flutter pub run build_runner build
```

**Deployment failures:**
- Verify secrets are configured
- Check environment permissions
- Validate service account roles

---

## 🎯 Best Practices

### Workflow Design

✅ **DO:**
- Use reusable workflows for common tasks
- Cache dependencies (Flutter, Gradle)
- Set timeouts on jobs
- Use concurrency groups to cancel old runs
- Add meaningful job/step names with emojis

❌ **DON'T:**
- Duplicate code across workflows
- Run unnecessary jobs on doc changes
- Skip security checks
- Commit workflow secrets

### Commit Messages

✅ **DO:**
- Follow conventional commits format
- Use imperative mood ("add" not "added")
- Keep subject under 100 characters
- Reference issues (#123)

❌ **DON'T:**
- Use vague messages ("fix bug", "update code")
- Skip type prefix
- Break format

---

## 📚 Additional Resources

- **GitHub Actions Docs:** https://docs.github.com/en/actions
- **Release Please:** https://github.com/googleapis/release-please
- **Conventional Commits:** https://www.conventionalcommits.org/
- **Firebase App Distribution:** https://firebase.google.com/docs/app-distribution

---

**Happy automating!** 🚀✨
