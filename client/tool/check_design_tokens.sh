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

run_check() {
  local description="$1"
  local pattern="$2"
  local mode="${3:-default}" # default (exclude theme+dialog), theme_only, l10n
  local matches=""

  echo "Checking for $description..."

  if [ "$CHECK_CMD" = "rg" ]; then
    case "$mode" in
      theme_only)
        matches=$(rg -n "$pattern" lib/ --glob '!lib/core/theme/**' || true)
        ;;
      l10n)
        matches=$(rg -n "$pattern" lib/ --glob '!lib/core/l10n/**' --glob '!lib/l10n/**' || true)
        ;;
      *)
        matches=$(rg -n "$pattern" lib/ --glob '!lib/core/theme/**' --glob '!lib/core/dialog/**' || true)
        ;;
    esac
  else
    case "$mode" in
      theme_only)
        matches=$(grep -rnE "$pattern" lib/ --exclude-dir="theme" || true)
        ;;
      l10n)
        matches=$(grep -rnE "$pattern" lib/ --exclude-dir="l10n" || true)
        ;;
      *)
        matches=$(grep -rnE "$pattern" lib/ --exclude-dir="theme" --exclude-dir="dialog" || true)
        ;;
    esac
  fi

  # Honor inline "// token-check: allow" marker
  if [ -n "$matches" ]; then
    matches=$(printf "%s\n" "$matches" | grep -v "// token-check: allow" || true)
  fi

  if [ -n "$matches" ]; then
    echo "❌ Found $description:"
    echo "$matches"
    FAIL=1
  else
    echo "✅ 0 $description"
  fi
}

# 1. BorderRadius.circular( outside core/theme
run_check "BorderRadius.circular outside core/theme" "BorderRadius\.circular\(" "theme_only"

# 2. fontSize: outside core/theme
run_check "fontSize: outside core/theme" "fontSize:" "theme_only"

# 3. Color(0x outside core/theme
run_check "Color(0x outside core/theme" "Color\(0x" "theme_only"

# 4. Colors.(white|black|grey) outside core/theme and core/dialog
run_check "Colors.(white|black|grey) outside core/theme and core/dialog" "Colors\.(white|black|grey)" "default"

# 5. EdgeInsets.(all|symmetric|only|fromLTRB)(<num> outside core/theme and core/dialog
run_check "EdgeInsets numeric literals outside core/theme and core/dialog" "EdgeInsets\.(all|symmetric|only|fromLTRB)\([[:space:]]*[0-9]" "default"

# 6. SizedBox((width|height): <num> outside core/theme and core/dialog
run_check "SizedBox numeric literals outside core/theme and core/dialog" "SizedBox\((width|height):[[:space:]]*[0-9]" "default"

# 7. AppLocalizations.of( outside core/l10n
run_check "AppLocalizations.of( outside core/l10n" "AppLocalizations\.of\(" "l10n"

# 8. Raw dialogs/sheets/snackbars outside core/theme and core/dialog
run_check "showDialog( outside core/dialog" "showDialog\(" "default"
run_check "showModalBottomSheet( outside core/dialog" "showModalBottomSheet\(" "default"
run_check "AlertDialog( outside core/dialog" "AlertDialog\(" "default"
run_check "ScaffoldMessenger outside core/dialog" "ScaffoldMessenger" "default"

echo "================================================="
if [ $FAIL -ne 0 ]; then
  echo "❌ Design token audit FAILED."
  echo "Please use AppRadius, AppTypography / textTheme, AppColors, AppSpacing, context.l10n, and core dialog/snackbar helpers."
  exit 1
else
  echo "✅ All design token checks PASSED!"
  exit 0
fi
