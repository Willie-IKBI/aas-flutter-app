#!/bin/bash

# Pre-commit script for Flutter project
# This script runs all the checks that should pass before committing

set -e

echo "🔍 Running pre-commit checks..."

# Check if we're in a Flutter project
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Not in a Flutter project directory"
    exit 1
fi

# Run Flutter format check
echo "📝 Checking code formatting..."
if ! dart format --set-exit-if-changed .; then
    echo "❌ Code formatting issues found. Run 'dart format .' to fix."
    exit 1
fi

# Run Flutter analyze
echo "🔍 Running static analysis..."
if ! flutter analyze --no-fatal-infos; then
    echo "❌ Static analysis issues found. Fix the errors above."
    exit 1
fi

# Check for print statements
echo "🚫 Checking for print statements..."
if grep -r "print(" lib/ --include="*.dart" > /dev/null 2>&1; then
    echo "❌ Print statements found. Use Logger instead."
    echo "Found in:"
    grep -r "print(" lib/ --include="*.dart"
    exit 1
fi

# Check for unused imports
echo "📦 Checking for unused imports..."
if flutter analyze --no-fatal-infos 2>&1 | grep -q "unused_import"; then
    echo "❌ Unused imports found. Remove them or run 'dart fix --apply'."
    exit 1
fi

# Check for deprecated member use
echo "⚠️  Checking for deprecated member use..."
if flutter analyze --no-fatal-infos 2>&1 | grep -q "deprecated_member_use"; then
    echo "❌ Deprecated member use found. Update to modern APIs."
    exit 1
fi

echo "✅ All pre-commit checks passed!"
