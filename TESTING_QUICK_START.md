# Testing Quick Start Guide

**Quick reference for running tests during the 3-week testing period**

---

## 🚀 QUICK COMMANDS

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/screens/notifications_screen_test.dart
flutter test test/services/auth_api_test.dart
flutter test test/providers/auth_provider_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### Generate Coverage Report
```bash
# Install genhtml tool (one time)
flutter pub global activate coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open report (Windows)
start coverage/html/index.html
# or (Mac)
open coverage/html/index.html
# or (Linux)
xdg-open coverage/html/index.html
```

### Run Tests in Watch Mode
```bash
flutter test --watch
```

---

## 📊 WEEK-BY-WEEK TESTING

### Week 1: Unit & Widget Tests
```bash
# Day 1: Setup
flutter clean
flutter pub get
flutter test

# Day 2: API Tests
flutter test test/services/

# Day 3: Provider Tests
flutter test test/providers/

# Day 4: Screen Tests
flutter test test/screens/

# Day 5: Generate Report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Week 2: Integration Tests
```bash
# Connect to real backend first!
# Update API endpoint if needed

# Run integration tests
flutter test test/integration/

# Performance tests
flutter test test/performance/

# E2E scenario tests
flutter test test/e2e/
```

### Week 3: Manual Testing
```bash
# Build release for manual testing
flutter build apk --release
flutter build ios --release

# Run automated tests before deployment
flutter test --coverage

# Performance profiling
# Use Android Studio or Xcode profilers
```

---

## 📝 TEST FILE STRUCTURE

```
test/
├── helpers/
│   └── test_helpers.dart          # Common utilities
├── mocks/
│   ├── mock_auth_provider.dart    # Mock auth
│   ├── mock_api_service.dart      # Mock API
│   └── mock_models.dart           # Test data
├── fixtures/
│   └── user_fixtures.dart         # User test data
├── services/
│   ├── auth_api_test.dart        # Auth API tests
│   ├── user_api_test.dart        # User API tests
│   └── ...
├── providers/
│   ├── auth_provider_test.dart   # Auth provider tests
│   ├── user_provider_test.dart   # User provider tests
│   └── ...
├── screens/
│   ├── notifications_screen_test.dart    # ✅ Done
│   ├── language_selection_screen_test.dart # ✅ Done
│   ├── user_management_screen_test.dart   # Week 1
│   └── ...
├── integration/
│   ├── auth_flow_test.dart       # Week 2
│   ├── ride_flow_test.dart       # Week 2
│   └── ...
├── performance/
│   ├── response_time_test.dart   # Week 2
│   └── concurrent_request_test.dart # Week 2
└── widget_test.dart              # Basic widget test
```

---

## 🧪 COMMON TEST PATTERNS

### Test API Service
```dart
test('API call returns data', () async {
  // Arrange
  final expectedUser = UserModel(id: '123', name: 'Test');
  
  // Act
  final result = await UserApi.getUserById('123');
  
  // Assert
  expect(result.id, '123');
  expect(result.name, 'Test');
});
```

### Test Provider
```dart
test('Provider updates state', () async {
  // Arrange
  final provider = AuthProvider();
  
  // Act
  await provider.login('test@example.com', 'password');
  
  // Assert
  expect(provider.currentUser, isNotNull);
  expect(provider.isLoading, false);
});
```

### Test Screen Widget
```dart
testWidgets('Screen renders without errors', (WidgetTester tester) async {
  // Arrange
  await tester.pumpWidget(createTestWidget());
  
  // Act - nothing, screen already rendered
  
  // Assert
  expect(find.text('Title'), findsOneWidget);
});
```

---

## ✅ CHECKLIST BY WEEK

### Week 1
- [ ] Day 1: Test infrastructure set up
- [ ] Day 2: 27 API service tests created & passing
- [ ] Day 3: 27 Provider tests created & passing
- [ ] Day 4: 46 Screen tests created & passing
- [ ] Day 5: Coverage report generated (>80%)
- [ ] All 100 tests passing

### Week 2
- [ ] Day 1-2: 43 Integration tests with real backend passing
- [ ] Day 3-4: 23 Performance tests passing
- [ ] Day 5: 3 E2E scenarios documented
- [ ] All critical APIs tested
- [ ] Performance benchmarks established

### Week 3
- [ ] Day 1-2: 350+ manual tests on 7 devices
- [ ] Day 3-4: All critical bugs fixed, 20% performance improvement
- [ ] Day 5: Go/No-Go meeting, ready to deploy
- [ ] Release notes prepared
- [ ] Team confident for launch

---

## 🐛 DEBUGGING FAILED TESTS

### Test Won't Run
```bash
# Clean and try again
flutter clean
flutter pub get
flutter test

# Check test file syntax
# Run with verbose output
flutter test -v
```

### Test Passes Locally, Fails in CI
```bash
# Make sure you're using same dependencies
flutter pub get

# Check for timezone issues
# Check for mock/real API issues
# Check for file path issues

# Run with verbose
flutter test -v
```

### Async Timeout
```dart
// Increase timeout in test
testWidgets('description', (WidgetTester tester) async {
  // ... test code ...
}, timeout: Timeout(Duration(seconds: 10)));
```

### Mock Not Working
```dart
// Verify mock is set up before test
setUp(() {
  mockAuthProvider = MockAuthProvider();
  when(mockAuthProvider.currentUser).thenReturn(testUser);
});
```

---

## 📊 REPORTING

### Daily Test Report Template
```
DATE: 2026-06-18
TESTER: Alice

TESTS RUN: 27
TESTS PASSED: 27
TESTS FAILED: 0
COVERAGE: 85%

BLOCKERS: None
NOTES: All tests passing smoothly

NEXT STEPS: Move to provider tests
```

### Weekly Summary Template
```
WEEK: 1
DATES: 2026-06-16 to 2026-06-20

OBJECTIVES:
- [ ] Unit tests for all APIs
- [ ] Unit tests for all providers
- [ ] Widget tests for all screens
- [ ] Coverage >80%

RESULTS:
- Tests Created: 100
- Tests Passing: 100 (100%)
- Coverage: 85%
- Critical Issues: 0
- High Issues: 0

STATUS: ON TRACK ✅
```

---

## 🔄 CI/CD INTEGRATION

### GitHub Actions Example
```yaml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      
      - run: flutter pub get
      - run: flutter test --coverage
      
      - uses: codecov/codecov-action@v2
        with:
          files: coverage/lcov.info
```

---

## 📱 DEVICE TESTING CHECKLIST

When testing on physical device:

### Before Testing
- [ ] Device charged
- [ ] Latest app version installed
- [ ] Network connection stable
- [ ] Device time/language set correctly
- [ ] Enough storage space
- [ ] Device not in low battery mode

### Testing Steps
- [ ] Follow test scenario
- [ ] Take screenshots of issues
- [ ] Note device/OS version
- [ ] Record exact steps to reproduce
- [ ] Note any error messages
- [ ] Report in issue tracker

### After Testing
- [ ] Uninstall test app
- [ ] Clear app data if needed
- [ ] Charge device
- [ ] Document findings

---

## 🎯 SUCCESS METRICS

### Week 1
- **Target:** >80% coverage, 100% tests passing
- **Reality:** Aim for >85%, 100% passing

### Week 2
- **Target:** >95% integration tests passing
- **Reality:** Aim for 98%+, document any failures

### Week 3
- **Target:** Zero critical bugs, >90% manual pass
- **Reality:** Aim for all critical fixed, >95% manual pass

---

## 💡 TIPS

1. **Test Locally First** - Always run tests locally before pushing
2. **Coverage Matters** - Don't just count tests, measure coverage
3. **Real Data** - Week 2 uses real backend, not mocks
4. **Document Issues** - Every failure gets an issue ticket
5. **Automate First** - Automate before manual testing
6. **Device Variety** - Test on multiple devices, OSes
7. **Performance Matters** - Measure response times
8. **Keep Tests Isolated** - Each test should be independent

---

## 📞 GETTING HELP

### Test Fails - Quick Troubleshooting
```
1. Check test code for syntax errors
2. Check mock data is correct
3. Check API endpoints are correct
4. Run flutter clean
5. Run flutter pub get
6. Run test with -v flag for verbose
7. Check test helpers are imported
```

### Can't Figure It Out?
```
1. Read the error message carefully
2. Google the error
3. Check Flutter documentation
4. Ask team member
5. Create GitHub issue for unusual failures
```

---

## 🚀 YOU'RE READY!

**Week 1:** Run unit/widget tests daily  
**Week 2:** Run integration tests with real backend  
**Week 3:** Manual testing on real devices  

**Good luck! 🎉**

---

Generated: 2026-06-15
**For detailed info, see: TESTING_PLAN_3_WEEKS.md**
