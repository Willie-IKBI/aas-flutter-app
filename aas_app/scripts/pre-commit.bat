@echo off
REM Pre-commit script for Flutter project (Windows)
REM This script runs all the checks that should pass before committing

echo 🔍 Running pre-commit checks...

REM Check if we're in a Flutter project
if not exist "pubspec.yaml" (
    echo ❌ Error: Not in a Flutter project directory
    exit /b 1
)

REM Run Flutter format check
echo 📝 Checking code formatting...
dart format --set-exit-if-changed .
if errorlevel 1 (
    echo ❌ Code formatting issues found. Run 'dart format .' to fix.
    exit /b 1
)

REM Run Flutter analyze
echo 🔍 Running static analysis...
flutter analyze --no-fatal-infos
if errorlevel 1 (
    echo ❌ Static analysis issues found. Fix the errors above.
    exit /b 1
)

REM Check for print statements
echo 🚫 Checking for print statements...
findstr /r /s "print(" lib\*.dart >nul 2>&1
if not errorlevel 1 (
    echo ❌ Print statements found. Use Logger instead.
    echo Found in:
    findstr /r /s "print(" lib\*.dart
    exit /b 1
)

REM Check for unused imports
echo 📦 Checking for unused imports...
flutter analyze --no-fatal-infos 2>&1 | findstr "unused_import" >nul
if not errorlevel 1 (
    echo ❌ Unused imports found. Remove them or run 'dart fix --apply'.
    exit /b 1
)

REM Check for deprecated member use
echo ⚠️  Checking for deprecated member use...
flutter analyze --no-fatal-infos 2>&1 | findstr "deprecated_member_use" >nul
if not errorlevel 1 (
    echo ❌ Deprecated member use found. Update to modern APIs.
    exit /b 1
)

echo ✅ All pre-commit checks passed!
