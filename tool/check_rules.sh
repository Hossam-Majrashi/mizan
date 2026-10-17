#!/bin/bash
set -e

FAILED=0
echo "=== Running Mizan Rule Verification Gates ==="

# 1. MediaQuery.of(context).size in lib/
echo "Checking rule 1: MediaQuery.of(context).size..."
if grep -rn "MediaQuery\.of(context)\.size" lib/; then
  echo "FAIL: Found MediaQuery.of(context).size in lib/. Use MediaQuery.sizeOf(context) or LayoutBuilder."
  FAILED=1
else
  echo "PASS: No MediaQuery.of(context).size found."
fi

# 2. flutter_launcher_icons in any file (excluding specification text and check_rules.sh itself)
echo "Checking rule 2: flutter_launcher_icons..."
if grep -rn "flutter_launcher_icons" --exclude="check_rules.sh" --exclude="*Flutter_Template*" --exclude-dir=".git" .; then
  echo "FAIL: Found forbidden flutter_launcher_icons reference."
  FAILED=1
else
  echo "PASS: No flutter_launcher_icons found."
fi

# 3. abstract class or interface inside lib/platform
echo "Checking rule 3: abstract class or interface in lib/platform..."
if grep -rnE "(abstract class|interface class)" lib/platform/; then
  echo "FAIL: Found abstract class or interface in lib/platform. Platform must contain concrete implementations only."
  FAILED=1
else
  echo "PASS: lib/platform has concrete implementations only."
fi

# 4. TODO, FIXME, or UnimplementedError in lib/
echo "Checking rule 4: TODO, FIXME, or UnimplementedError in lib/..."
if grep -rnE "(TODO|FIXME|UnimplementedError)" lib/; then
  echo "FAIL: Found TODO, FIXME, or UnimplementedError in lib/."
  FAILED=1
else
  echo "PASS: No TODO, FIXME, or UnimplementedError found in lib/."
fi

# 5. Hard-coded colors outside lib/core/theme (unless marked rule-exempt: content-color)
echo "Checking rule 5: Hard-coded colors..."
HARD_COLORS=$(grep -rnE "(\bColor\(0x|\bColors\.[a-zA-Z]+)" lib/ \
  | grep -v "lib/core/theme/" \
  | grep -v "Colors.transparent" \
  | grep -v "rule-exempt: content-color" || true)

if [ -n "$HARD_COLORS" ]; then
  echo "FAIL: Found hard-coded colors outside lib/core/theme:"
  echo "$HARD_COLORS"
  FAILED=1
else
  echo "PASS: All colors sourced from theme."
fi

# 6. Literal string directly inside Text('...') or Text("...") in UI (except interpolation/variables)
echo "Checking rule 6: Literal strings in Text()..."
LITERAL_TEXT=$(grep -rnE "Text\(['\"][a-zA-Z]{2,}" lib/screens/ lib/features/*/widgets/ lib/features/*/screens/ 2>/dev/null || true)
if [ -n "$LITERAL_TEXT" ]; then
  echo "FAIL: Found literal string inside Text() in UI widgets. All UI strings must come from AppLocalizations:"
  echo "$LITERAL_TEXT"
  FAILED=1
else
  echo "PASS: UI strings use localization."
fi

# 7. Targeted screens directories exist
echo "Checking rule 7: screens/mobile, desktop, web presence..."
if [ ! -d "lib/screens/mobile" ] || [ ! -d "lib/screens/desktop" ] || [ ! -d "lib/screens/web" ]; then
  echo "FAIL: Missing targeted screens directories."
  FAILED=1
else
  echo "PASS: All targeted platform screen directories exist."
fi

# 8. GitHub Actions build workflow
echo "Checking rule 8: .github/workflows/build.yml existence..."
if [ ! -f ".github/workflows/build.yml" ]; then
  echo "FAIL: Missing .github/workflows/build.yml"
  FAILED=1
else
  echo "PASS: .github/workflows/build.yml exists."
fi

if [ $FAILED -ne 0 ]; then
  echo "=== Rule Verification FAILED ==="
  exit 1
fi

echo "=== All Rule Verification Gates PASSED ==="
exit 0
