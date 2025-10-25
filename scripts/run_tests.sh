# Test Execution Script
# Runs all tests: unit, widget, integration, and edge cases

echo "🧪 Running All Tests..."

# Backend tests (Cloud Functions)
echo ""
echo "=== Backend Unit Tests ==="
cd functions
npm test
BACKEND_EXIT=$?
cd ..

# Flutter widget tests
echo ""
echo "=== Flutter Widget Tests ==="
flutter test test/widgets/
WIDGET_EXIT=$?

# Flutter controller tests
echo ""
echo "=== Flutter Controller Tests ==="
flutter test test/controllers/
CONTROLLER_EXIT=$?

# Integration tests (requires emulator or real Firebase)
echo ""
echo "=== Integration Tests ==="
flutter test integration_test/multiplayer_flow_test.dart
INTEGRATION_EXIT=$?

# Edge case tests
echo ""
echo "=== Edge Case Tests ==="
flutter test integration_test/edge_cases_test.dart
EDGE_EXIT=$?

# Summary
echo ""
echo "================================"
echo "Test Results Summary:"
echo "================================"
echo "Backend Tests: $([ $BACKEND_EXIT -eq 0 ] && echo '✅ PASSED' || echo '❌ FAILED')"
echo "Widget Tests: $([ $WIDGET_EXIT -eq 0 ] && echo '✅ PASSED' || echo '❌ FAILED')"
echo "Controller Tests: $([ $CONTROLLER_EXIT -eq 0 ] && echo '✅ PASSED' || echo '❌ FAILED')"
echo "Integration Tests: $([ $INTEGRATION_EXIT -eq 0 ] && echo '✅ PASSED' || echo '❌ FAILED')"
echo "Edge Case Tests: $([ $EDGE_EXIT -eq 0 ] && echo '✅ PASSED' || echo '❌ FAILED')"
echo "================================"

# Exit with failure if any test failed
if [ $BACKEND_EXIT -ne 0 ] || [ $WIDGET_EXIT -ne 0 ] || [ $CONTROLLER_EXIT -ne 0 ] || [ $INTEGRATION_EXIT -ne 0 ] || [ $EDGE_EXIT -ne 0 ]; then
  echo "❌ Some tests failed!"
  exit 1
else
  echo "✅ All tests passed!"
  exit 0
fi
