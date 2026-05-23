# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0](https://github.com/psilore/height-banana/compare/height-banana-v1.0.2...height-banana-v1.1.0) (2026-05-23)


### ✨ Features

* add JsonConverter implementations for Offset and Map&lt;double, St… ([#27](https://github.com/psilore/height-banana/issues/27)) ([402e424](https://github.com/psilore/height-banana/commit/402e424de838d4cbda6d5517b4ef878de749ee1a))


### ♻️ Refactoring

* rely on native flutter test coverage output instead of exte… ([#30](https://github.com/psilore/height-banana/issues/30)) ([ddf54ec](https://github.com/psilore/height-banana/commit/ddf54ec3cfec1bf3a6da871b6d1692d022a63bee))


### 📖 Documentation

* update Docker prerequisites to docker-ce and add host networking and CLI debugging steps to devcontainer configuration ([#40](https://github.com/psilore/height-banana/issues/40)) ([2fb0205](https://github.com/psilore/height-banana/commit/2fb02053cda7bd535e8d9a504c71a45b9ffcaa7a))


### 👷 CI/CD

* **actions:** bump actions/download-artifact from 4.3.0 to 8.0.1 ([#33](https://github.com/psilore/height-banana/issues/33)) ([66b826a](https://github.com/psilore/height-banana/commit/66b826a29ea7f7fd11f26435ba1d6bf89495ff23))
* **actions:** bump codecov/codecov-action from 3.1.6 to 6.0.1 ([#34](https://github.com/psilore/height-banana/issues/34)) ([f4040a4](https://github.com/psilore/height-banana/commit/f4040a4a51f9aae20f221dbb13fc37b82ec73cf1))
* **actions:** bump softprops/action-gh-release from 1 to 3 ([#32](https://github.com/psilore/height-banana/issues/32)) ([edacd28](https://github.com/psilore/height-banana/commit/edacd281eeba5f5ffa5f433c9f31d389e0afd670))

## [1.0.2](https://github.com/psilore/height-banana/compare/height-banana-v1.0.1...height-banana-v1.0.2) (2026-05-23)


### 🐛 Bug Fixes

* update secret scanning logic and ignore patterns to correctly identify and exclude firebase configuration files ([#23](https://github.com/psilore/height-banana/issues/23)) ([27a0368](https://github.com/psilore/height-banana/commit/27a03680be56a4cf0397522eb5591173c3038c65))

## [1.0.1](https://github.com/psilore/height-banana/compare/height-banana-v1.0.0...height-banana-v1.0.1) (2026-05-23)


### 👷 CI/CD

* **actions:** bump actions/checkout from 4 to 6 ([#1](https://github.com/psilore/height-banana/issues/1)) ([b719933](https://github.com/psilore/height-banana/commit/b719933eeb0843f32d32929f1a8311b7881f97fd))
* **actions:** bump actions/dependency-review-action from 4 to 5 ([#9](https://github.com/psilore/height-banana/issues/9)) ([fbf5b35](https://github.com/psilore/height-banana/commit/fbf5b35a6b8e82d6bc2bf1789f3234e0de4bbfa1))
* **actions:** bump actions/github-script from 7 to 9 ([#11](https://github.com/psilore/height-banana/issues/11)) ([3564ad1](https://github.com/psilore/height-banana/commit/3564ad1ec6ccdacddf87562f20a73565e7081bc9))
* **actions:** bump actions/setup-java from 4 to 5 ([#2](https://github.com/psilore/height-banana/issues/2)) ([0a0ed51](https://github.com/psilore/height-banana/commit/0a0ed51a6af8f660bdb7cf2fbbf1c607e6b1e49f))
* **actions:** bump actions/upload-artifact from 4 to 7 ([#10](https://github.com/psilore/height-banana/issues/10)) ([2f46c46](https://github.com/psilore/height-banana/commit/2f46c46b449a644c2bfe5f24d5095da47884fc46))
* **actions:** bump github/codeql-action from 3 to 4 ([#3](https://github.com/psilore/height-banana/issues/3)) ([2dc46ce](https://github.com/psilore/height-banana/commit/2dc46cea7082925a2ab62595be7b946f5f826180))
* add security-events write permission to release-please workflow ([#16](https://github.com/psilore/height-banana/issues/16)) ([7738fa3](https://github.com/psilore/height-banana/commit/7738fa3403ed5bf737689c7fb0eb0265bf8ce9f8))

## [Unreleased]

### Added
- Complete Flutter archery training app with AI-powered arrow detection
- Google Sign-In authentication with Firebase
- Offline-first architecture with Hive + Firestore
- Computer vision for target and arrow detection using Google ML Kit
- Advanced statistics dashboard with score trends and analytics
- Grouping heatmap visualization with quality ratings
- Session history with filtering and sorting
- Dev Container for zero-setup development
- Comprehensive CI/CD pipelines with GitHub Actions
- Automated testing in workflows with coverage reporting
- Release-please integration for semantic versioning
- Two-environment deployment (development and production)
- GitHub Flow with automated PR testing and deployment
- Security scanning with CodeQL and Trivy
- Dependabot for automated dependency updates
- Complete documentation for all project aspects

### Infrastructure
- Reusable GitHub Actions workflows for quality, testing, and building
- Development deployment via Firebase App Distribution
- Production deployment to Google Play Store and Firebase
- Automated release creation with changelog generation
- Environment-specific configurations and secrets management

---

**Note:** This changelog will be automatically updated by release-please when releases are created.

[Unreleased]: https://github.com/psilore/height-banana/compare/v1.0.0...HEAD
