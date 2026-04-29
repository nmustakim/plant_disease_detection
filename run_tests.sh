#!/usr/bin/env bash
# run_tests.sh — generate mocks, then run all unit tests with coverage
# Usage: bash run_tests.sh

set -e

echo "=========================================="
echo "  Plant DD AI — Unit Test Runner"
echo "=========================================="

echo ""
echo "[1/3] Installing dependencies..."
flutter pub get

echo ""
echo "[2/3] Generating Mockito mocks..."
dart run build_runner build --delete-conflicting-outputs

echo ""
echo "[3/3] Running unit tests with coverage..."
flutter test test/unit/ --coverage

echo ""
echo "Done. Coverage report written to coverage/lcov.info"
echo "To view HTML report, run:"
echo "  genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html"