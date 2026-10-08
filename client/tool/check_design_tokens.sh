#!/usr/bin/env bash
set -euo pipefail

echo "================================================="
echo "  ProjectHub Client Design Tokens Verification   "
echo "================================================="

FAIL=0

# Determine grep tool (ripgrep preferred)
if command -v rg >/dev/null 2>&1; then
  CHECK_CMD="rg"
else
  CHECK_CMD="grep"
fi

echo "Using search tool: $CHECK_CMD"

# 1. Check BorderRadius.circular( outside core/theme
echo "Checking for BorderRadius.circular outside core/theme..."
if [ "$CHECK_CMD" = "rg" ]; then
  CIRCULAR_MATCHES=$(rg "BorderRadius\.circular\(" lib/ --glob '!lib/core/theme/**' || true)
else
  CIRCULAR_MATCHES=$(grep -rn "BorderRadius\.circular(" lib/ --exclude-dir="theme" || true)
fi

if [ -n "$CIRCULAR_MATCHES" ]; then
  echo "❌ Found BorderRadius.circular outside core/theme:"
  echo "$CIRCULAR_MATCHES"
  FAIL=1
else
  echo "✅ 0 BorderRadius.circular outside core/theme"
fi

# 2. Check fontSize: outside core/theme
echo "Checking for fontSize: outside core/theme..."
if [ "$CHECK_CMD" = "rg" ]; then
  FONTSIZE_MATCHES=$(rg "fontSize:" lib/ --glob '!lib/core/theme/**' || true)
else
  FONTSIZE_MATCHES=$(grep -rn "fontSize:" lib/ --exclude-dir="theme" || true)
fi

if [ -n "$FONTSIZE_MATCHES" ]; then
  echo "❌ Found fontSize: outside core/theme:"
  echo "$FONTSIZE_MATCHES"
  FAIL=1
else
  echo "✅ 0 fontSize: outside core/theme"
fi

# 3. Check Color(0x outside core/theme
echo "Checking for Color(0x outside core/theme..."
if [ "$CHECK_CMD" = "rg" ]; then
  COLOR_MATCHES=$(rg "Color\(0x" lib/ --glob '!lib/core/theme/**' || true)
else
  COLOR_MATCHES=$(grep -rn "Color(0x" lib/ --exclude-dir="theme" || true)
fi

if [ -n "$COLOR_MATCHES" ]; then
  echo "❌ Found Color(0x outside core/theme:"
  echo "$COLOR_MATCHES"
  FAIL=1
else
  echo "✅ 0 Color(0x outside core/theme"
fi

echo "================================================="
if [ $FAIL -ne 0 ]; then
  echo "❌ Design token audit FAILED."
  echo "Please use AppRadius, AppTypography / textTheme, and AppColors."
  exit 1
else
  echo "✅ All design token checks PASSED!"
  exit 0
fi

