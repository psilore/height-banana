# Contributing to Height Banana

Thank you for your interest in contributing! 🎯

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Help others learn

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/height-banana.git`
3. Follow [QUICKSTART.md](../QUICKSTART.md) to set up your environment
4. Create a branch: `git checkout -b feature/your-feature-name`

## Development Workflow

### 1. Code Style

We follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines:

- Use `lowerCamelCase` for variables and functions
- Use `UpperCamelCase` for classes
- Use single quotes for strings
- Add trailing commas for better formatting
- Document public APIs with dartdoc comments

### 2. Architecture

Follow Clean Architecture principles:

```
lib/features/<feature>/
├── domain/           # Business logic (no dependencies)
│   ├── models/      # Domain entities
│   └── repositories/ # Repository interfaces
├── data/            # Data layer
│   ├── datasources/ # API, local storage
│   └── repositories/ # Repository implementations
└── presentation/    # UI layer
    ├── providers/   # Riverpod providers
    ├── screens/     # Screen widgets
    └── widgets/     # Reusable widgets
```

### 3. Before Committing

Run these checks:

```bash
# Format code
dart format .

# Analyze code (must pass with zero warnings)
flutter analyze

# Run tests
flutter test

# Verify no breaking changes
flutter build apk --debug
```

### 4. Commit Messages

Use conventional commits:

```
feat: Add arrow grouping heatmap
fix: Resolve camera permission crash
docs: Update Firebase setup guide
test: Add unit tests for score calculation
refactor: Simplify session repository
chore: Update dependencies
```

### 5. Pull Requests

**Before submitting:**
- [ ] Code is formatted (`dart format .`)
- [ ] Analysis passes (`flutter analyze`)
- [ ] Tests pass (`flutter test`)
- [ ] New features have tests
- [ ] Documentation is updated
- [ ] PR description explains changes

**PR Template:**
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
How was this tested?

## Screenshots (if UI changes)
Before / After images
```

## Testing Guidelines

### Unit Tests

Test business logic thoroughly:

```dart
// test/unit/domain/arrow_test.dart
test('Arrow calculates distance from center correctly', () {
  final arrow = Arrow(
    id: '1',
    scoreValue: '10',
    x: 3.0,
    y: 4.0,
    timestamp: DateTime.now(),
  );
  
  expect(arrow.distanceFromCenter, 25.0); // 3^2 + 4^2 = 25
});
```

### Widget Tests

Test UI components:

```dart
testWidgets('Session list displays sessions', (tester) async {
  await tester.pumpWidget(SessionListScreen());
  expect(find.text('Training Sessions'), findsOneWidget);
});
```

### Integration Tests

Test complete flows (sparingly - they're slow).

## Code Review Process

1. **Automated Checks**: GitHub Actions runs tests and analysis
2. **Peer Review**: At least one maintainer reviews code
3. **Feedback**: Address review comments
4. **Approval**: Maintainer approves and merges

## Areas to Contribute

### Good First Issues

- Documentation improvements
- UI enhancements
- Unit test coverage
- Bug fixes

### Feature Requests

- iOS support
- Target face customization
- Advanced statistics
- Export to PDF/CSV

### Performance

- Optimize ML inference
- Improve offline sync
- Reduce app size

## Questions?

- Open an issue for bugs
- Start a discussion for features
- Ask in pull request comments

Thank you for contributing! 🙏

### 5. Push and Create Pull Request

```bash
# Push your changes
git push origin feature/your-feature-name

# Open PR on GitHub
# Our CI/CD will automatically:
# ✅ Run quality checks (analyzer + formatter)
# ✅ Execute test suite with coverage
# ✅ Build debug APK
# ✅ Deploy to Firebase App Distribution (dev)
# ✅ Comment results on your PR
```

See what happens on PR in [docs/GITHUB_FLOW.md](GITHUB_FLOW.md).

---

## 📋 Pull Request Guidelines

### PR Title

Use conventional commit format:
```
feat(scope): add amazing feature
fix(camera): resolve crash on Android 13
docs: update contributing guide
```

### PR Description

Include:
- **What:** Summary of changes
- **Why:** Reason for changes
- **Testing:** How you tested
- **Screenshots:** For UI changes
- **Breaking Changes:** If any

### PR Review Process

1. **Automated Checks:** Must pass CI/CD
2. **Code Review:** At least 1 approval required
3. **Testing:** Reviewer tests on emulator/device
4. **Merge:** Squash and merge to main

---

## 🧪 Testing Guidelines

### Writing Tests

- **Unit Tests:** `test/unit/` - Pure logic
- **Widget Tests:** `test/widget/` - UI components
- **Integration Tests:** `integration_test/` - Full flows

### Test Coverage

- Aim for >80% coverage on new code
- Required for domain logic and repositories
- UI tests for complex interactions

### Running Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/unit/domain/arrow_test.dart

# With coverage
flutter test --coverage

# Integration tests
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart
```

---

## 📝 Documentation Guidelines

### Code Documentation

- Document all public APIs
- Use dartdoc format (`///`)
- Include examples for complex functions
- Explain "why" not just "what"

### File Documentation

Update relevant docs when changing:
- Architecture → `docs/ARCHITECTURE.md`
- APIs → `docs/API_REFERENCE.md`
- Setup → `QUICKSTART.md`
- Deployment → `docs/DEPLOYMENT.md`

---

## 🎯 Feature Development Workflow

1. **Discuss:** Open an issue to discuss feature
2. **Design:** Review architecture implications
3. **Branch:** Create feature branch
4. **Implement:** Write code + tests
5. **Document:** Update relevant docs
6. **PR:** Open pull request
7. **Review:** Address feedback
8. **Merge:** Maintainer merges
9. **Release:** Automated via release-please

---

## 🐛 Bug Report Guidelines

When reporting bugs, include:

1. **Description:** Clear summary
2. **Steps to Reproduce:** Detailed steps
3. **Expected Behavior:** What should happen
4. **Actual Behavior:** What actually happens
5. **Environment:**
   - Flutter version
   - Dart version
   - OS (Linux/Debian)
   - Device/Emulator
6. **Logs:** Stack traces, console output
7. **Screenshots:** If UI-related

---

## 💡 Feature Request Guidelines

When requesting features:

1. **Use Case:** Why is this needed?
2. **Proposed Solution:** How should it work?
3. **Alternatives:** Other approaches considered
4. **Additional Context:** Screenshots, mockups, examples

---

## 🏆 Recognition

Contributors will be:
- Listed in release notes
- Mentioned in CHANGELOG.md
- Added to GitHub contributors

---

## 📞 Questions?

- 💬 **Discussions:** Use GitHub Discussions for questions
- 🐛 **Issues:** GitHub Issues for bugs/features
- 📖 **Docs:** Check existing documentation first
- 🔄 **Workflow:** See `docs/GITHUB_FLOW.md`

---

**Thank you for contributing to Height Banana!** 🎯🏹

Together we're building the best archery training app! 🎉
