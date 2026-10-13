#!/usr/bin/env bash
set -euo pipefail

echo "================================================="
echo "  ProjectHub Client Design Tokens Verification   "
echo "================================================="

if ! command -v rg >/dev/null 2>&1; then
  echo "❌ Error: ripgrep (rg) is required to run design token checks."
  exit 1
fi

FAIL=0

run_check() {
  local description="$1"
  local pattern="$2"
  local mode="${3:-default}" # default (exclude theme+dialog), theme_only, l10n
  local matches=""

  echo "Checking for $description..."

  case "$mode" in
    theme_only)
      matches=$(rg -n -U "$pattern" lib/ --glob '!**/core/theme/**' || true)
      ;;
    l10n)
      matches=$(rg -n -U "$pattern" lib/ --glob '!**/core/extensions/**' --glob '!**/core/l10n/**' --glob '!**/l10n/**' || true)
      ;;
    *)
      matches=$(rg -n -U "$pattern" lib/ --glob '!**/core/theme/**' --glob '!**/core/dialog/**' || true)
      ;;
  esac

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

# 1. BorderRadius.circular(, Radius.circular(, legacy AppRadius.(r<num>|circular(), and (CircleAvatar|radius): <num> outside core/theme
run_check "BorderRadius.circular outside core/theme" "BorderRadius\.circular\(" "theme_only"
run_check "Radius.circular outside core/theme" "\bRadius\.circular\(" "theme_only"
run_check "AppRadius.(r[0-9]+|circular() outside core/theme" "AppRadius\.(r[0-9]+|circular\()" "theme_only"
run_check "(CircleAvatar|radius): numeric literals outside core/theme" "(CircleAvatar|radius):\s*[0-9]" "theme_only"
run_check "radius: AppRadius. outside core/theme" "radius:\s*AppRadius\." "theme_only"
run_check "AppAvatar size numeric literals outside core/theme" "AppAvatar\([^)]*size:\s*[0-9]" "theme_only"

# 2. fontSize: outside core/theme
run_check "fontSize: outside core/theme" "fontSize:" "theme_only"

# 3. Color(0x outside core/theme
run_check "Color(0x outside core/theme" "Color\(0x" "theme_only"

# 4. Colors.(white|black|grey) outside core/theme and core/dialog
run_check "Colors.(white|black|grey) outside core/theme and core/dialog" "Colors\.(white|black|grey)" "default"

# 5. EdgeInsets numeric literals outside core/theme and core/dialog
run_check "EdgeInsets numeric literals outside core/theme and core/dialog" "EdgeInsets\.[A-Za-z]+\(([^)]*[:,])?\s*[0-9]" "default"

# 6. SizedBox numeric literals outside core/theme and core/dialog
run_check "SizedBox numeric literals outside core/theme and core/dialog" "SizedBox\(\s*(width|height):\s*[0-9]" "default"

# 7. Layout spacing numeric literals outside core/theme and core/dialog
run_check "spacing/runSpacing/mainAxisSpacing/crossAxisSpacing numeric literals" "(spacing|runSpacing|mainAxisSpacing|crossAxisSpacing):\s*[0-9]" "default"

# 8. Duration(milliseconds: outside core/theme and core/dialog
run_check "Duration(milliseconds: outside core/theme and core/dialog" "Duration\(milliseconds:" "default"

# 9. Icon size and iconSize numeric literals outside core/theme and core/dialog
run_check "Icon size numeric literals outside core/theme and core/dialog" "Icon\((?:[^()]|\([^()]*\))*?size:\s*[0-9]" "default"
run_check "iconSize numeric literals outside core/theme and core/dialog" "iconSize:\s*[0-9]" "default"

# 10. AppLocalizations.of( outside core/l10n
run_check "AppLocalizations.of( outside core/l10n" "AppLocalizations\.of\(" "l10n"

# 11. Raw dialogs/sheets/snackbars outside core/theme and core/dialog
run_check "showDialog( outside core/dialog" "showDialog\(" "default"
run_check "DialogRoute< outside core/dialog" "DialogRoute<" "default"
run_check "showModalBottomSheet( outside core/dialog" "showModalBottomSheet\(" "default"
run_check "AlertDialog( outside core/dialog" "AlertDialog\(" "default"
run_check "ScaffoldMessenger outside core/dialog" "ScaffoldMessenger" "default"

# 12. Legacy AppColors static helpers outside core/theme
run_check "Legacy AppColors static helpers outside core/theme" "AppColors\.(subtleSurface|subtleSurfaceStrong|subtleBorder|textSecondaryColor|badgeBackground)\(" "theme_only"

echo "================================================="
if [ $FAIL -ne 0 ]; then
  echo "❌ Design token audit FAILED."
  echo "Please use AppRadius, AppTypography / textTheme, AppColors, AppSpacing, AppDurations, AppIconSize, context.l10n, and core dialog/snackbar helpers."
  exit 1
else
  echo "✅ All design token checks PASSED!"
  exit 0
fi
