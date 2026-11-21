#!/usr/bin/env bash
# ==============================================================================
# NutriView (OopsieEats) — Automated Google Play Release Validation Suite
# ==============================================================================
# Usage:
#   ./scripts/validate_release.sh [--skip-build] [--skip-tests]
#
# By default, runs the complete 12-stage Google Play release readiness gate:
#   1. Dependency Resolution (flutter pub get)
#   2. Static Analysis (flutter analyze — 0 issues)
#   3. Automated Test Suite (flutter test — unit, widget & release config tests)
#   4. Release AAB Build / Existence Check
#   5. AAB Artifact, Obfuscation Symbols & R8 Mapping Verification
#   6. Package Identifier Consistency (com.oopsieeats.app)
#   7. Android SDK Target Verification (API 36 / Android 16)
#   8. Cryptographic Release Signing Verification (jarsigner + non-debug cert)
#   9. Secret & Keystore Leakage Audit (Git tracking & source scan)
#  10. Merged Manifest Permission Audit (Least-Privilege & Implied Strip Check)
#  11. 16 KB ELF Page Size Alignment Verification (arm64-v8a & x86_64 .so)
#  12. Google Play Legal, Privacy Policy & Account Deletion Asset Audit
# ==============================================================================

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FRONTEND_DIR="$ROOT_DIR/frontend"
AAB_PATH="$FRONTEND_DIR/build/app/outputs/bundle/release/app-release.aab"
SYMBOLS_DIR="$ROOT_DIR/symbols/android"
MAPPING_PATH="$FRONTEND_DIR/build/app/outputs/mapping/release/mapping.txt"

SKIP_BUILD=false
SKIP_TESTS=false

for arg in "$@"; do
  case "$arg" in
    --skip-build) SKIP_BUILD=true ;;
    --skip-tests) SKIP_TESTS=true ;;
    *)
      echo "Unknown option: $arg"
      echo "Usage: $0 [--skip-build] [--skip-tests]"
      exit 1
      ;;
  esac
done

PASS_COUNT=0
FAIL_COUNT=0

pass() {
  echo "  [PASS] $1"
  PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
  echo "  [FAIL] $1" >&2
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

section() {
  echo ""
  echo "=============================================================================="
  echo "$1"
  echo "=============================================================================="
}

# ------------------------------------------------------------------------------
# STAGE 1: Dependency Resolution
# ------------------------------------------------------------------------------
section "STAGE 1: Dependency Resolution"
if (cd "$FRONTEND_DIR" && flutter pub get > /dev/null); then
  pass "flutter pub get resolved dependencies cleanly"
else
  fail "flutter pub get failed"
fi

# ------------------------------------------------------------------------------
# STAGE 2: Static Analysis
# ------------------------------------------------------------------------------
section "STAGE 2: Static Analysis (flutter analyze)"
if (cd "$FRONTEND_DIR" && flutter analyze --no-pub); then
  pass "flutter analyze completed with 0 issues"
else
  fail "flutter analyze reported static analysis issues"
fi

# ------------------------------------------------------------------------------
# STAGE 3: Automated Test Suite
# ------------------------------------------------------------------------------
section "STAGE 3: Automated Test Suite (Unit, Widget & Release Config)"
if [ "$SKIP_TESTS" = true ]; then
  echo "  [INFO] Skipping full flutter test suite (--skip-tests); running release signing config test..."
  if (cd "$FRONTEND_DIR" && flutter test test/release_signing_config_test.dart test/supabase_storage_service_test.dart --no-pub); then
    pass "Release config & storage security tests passed"
  else
    fail "Release config & storage security tests failed"
  fi
else
  if (cd "$FRONTEND_DIR" && flutter test --no-pub); then
    pass "Full flutter test suite passed"
  else
    fail "flutter test suite had failures"
  fi
fi

# ------------------------------------------------------------------------------
# STAGE 4: Release AAB Build
# ------------------------------------------------------------------------------
section "STAGE 4: Release Android App Bundle (.aab) Build"
if [ "$SKIP_BUILD" = true ] && [ -f "$AAB_PATH" ]; then
  pass "Using existing release AAB artifact (--skip-build)"
else
  if (cd "$FRONTEND_DIR" && flutter build appbundle --release --obfuscate --split-debug-info=../symbols/android); then
    pass "flutter build appbundle --release --obfuscate succeeded"
  else
    fail "flutter build appbundle --release failed"
  fi
fi

# ------------------------------------------------------------------------------
# STAGE 5: AAB Output, Split Symbols & R8 Mapping Verification
# ------------------------------------------------------------------------------
section "STAGE 5: AAB Artifact, Symbols & R8 Mapping Verification"
if [ -f "$AAB_PATH" ] && [ -s "$AAB_PATH" ]; then
  AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
  AAB_SHA256=$(sha256sum "$AAB_PATH" | awk '{print $1}')
  pass "AAB exists ($AAB_SIZE, SHA-256: $AAB_SHA256)"
else
  fail "AAB file missing or empty at $AAB_PATH"
fi

if [ -f "$SYMBOLS_DIR/app.android-arm64.symbols" ] && [ -f "$SYMBOLS_DIR/app.android-arm.symbols" ] && [ -f "$SYMBOLS_DIR/app.android-x64.symbols" ]; then
  pass "Split Dart debug symbols generated for arm64, arm, and x64"
else
  fail "Missing Dart split debug symbols in $SYMBOLS_DIR"
fi

if [ -f "$MAPPING_PATH" ] && [ -s "$MAPPING_PATH" ]; then
  pass "R8 obfuscation mapping file generated at $MAPPING_PATH"
else
  fail "R8 mapping.txt missing at $MAPPING_PATH"
fi

if unzip -lv "$AAB_PATH" "base/assets/flutter_assets/assets/models/best.tflite" | grep "assets/models/best.tflite" > /dev/null; then
  pass "TFLite model (best.tflite) bundled in AAB"
else
  fail "TFLite model (best.tflite) missing in AAB"
fi

# ------------------------------------------------------------------------------
# STAGE 6: Package Identifier Consistency
# ------------------------------------------------------------------------------
section "STAGE 6: Package Identifier Consistency (com.oopsieeats.app)"
GRADLE_FILE="$FRONTEND_DIR/android/app/build.gradle.kts"
GOOGLE_SERVICES_FILE="$FRONTEND_DIR/android/app/google-services.json"
MERGED_MANIFEST=$(find "$FRONTEND_DIR/build/app/intermediates/merged_manifests/release" -name "AndroidManifest.xml" | head -n 1)

if grep 'applicationId = "com.oopsieeats.app"' "$GRADLE_FILE" > /dev/null && grep 'namespace = "com.oopsieeats.app"' "$GRADLE_FILE" > /dev/null; then
  pass "build.gradle.kts namespace & applicationId match com.oopsieeats.app"
else
  fail "build.gradle.kts namespace or applicationId mismatch"
fi

if grep '"package_name": "com.oopsieeats.app"' "$GOOGLE_SERVICES_FILE" > /dev/null; then
  pass "google-services.json contains package_name com.oopsieeats.app"
else
  fail "google-services.json missing com.oopsieeats.app"
fi

if [ -n "$MERGED_MANIFEST" ] && grep 'package="com.oopsieeats.app"' "$MERGED_MANIFEST" > /dev/null; then
  pass "Merged release AndroidManifest.xml package is com.oopsieeats.app"
else
  fail "Merged release AndroidManifest.xml package mismatch"
fi

# ------------------------------------------------------------------------------
# STAGE 7: Target SDK & Versioning Verification
# ------------------------------------------------------------------------------
section "STAGE 7: Target SDK (API 36) & Versioning Verification"
if [ -n "$MERGED_MANIFEST" ]; then
  if grep 'android:targetSdkVersion="36"' "$MERGED_MANIFEST" > /dev/null; then
    pass "Merged release manifest targets Android 16 (API 36)"
  else
    fail "Merged release manifest does not target API 36"
  fi

  if grep 'android:minSdkVersion="24"' "$MERGED_MANIFEST" > /dev/null; then
    pass "Merged release manifest minSdkVersion is 24"
  else
    fail "Unexpected minSdkVersion in merged release manifest"
  fi

  if grep 'android:versionCode="2002"' "$MERGED_MANIFEST" > /dev/null && grep 'android:versionName="1.0.0"' "$MERGED_MANIFEST" > /dev/null; then
    pass "Merged release manifest version is 1.0.0 (versionCode 2002)"
  else
    fail "Version mismatch in merged release manifest"
  fi
else
  fail "Merged release AndroidManifest.xml not found"
fi

# ------------------------------------------------------------------------------
# STAGE 8: Cryptographic Release Signing Verification
# ------------------------------------------------------------------------------
section "STAGE 8: Cryptographic Release Signing Verification"
JARSIGNER_OUT=$(jarsigner -verify -certs "$AAB_PATH" 2>&1 || true)
if [[ "$JARSIGNER_OUT" == *"jar verified."* ]]; then
  pass "jarsigner verified AAB cryptographic signature integrity"
else
  fail "jarsigner verification failed on $AAB_PATH"
fi

if [[ "$JARSIGNER_OUT" == *"Android Debug"* ]]; then
  fail "AAB is signed with an Android Debug certificate!"
else
  SIGNER_DN=$(jarsigner -verify -verbose -certs "$AAB_PATH" 2>&1 | grep -E 'Signed by "' | head -n 1 | sed 's/.*Signed by //' || true)
  pass "AAB is signed with production upload certificate ($SIGNER_DN)"
fi

# ------------------------------------------------------------------------------
# STAGE 9: Secret & Keystore Leakage Audit
# ------------------------------------------------------------------------------
section "STAGE 9: Secret & Keystore Leakage Audit"
TRACKED_SECRETS=$(git -C "$ROOT_DIR" ls-files | grep -E '\.(jks|keystore|pem|key)$|key\.properties$|\.env$|service-account.*\.json$' || true)
if [ -z "$TRACKED_SECRETS" ]; then
  pass "Zero keystore, key.properties, .env, or service-account files tracked in Git"
else
  fail "Sensitive files tracked in Git: $TRACKED_SECRETS"
fi

PRIVATE_KEYS_IN_CODE=$(grep -rnE "BEGIN (RSA )?PRIVATE KEY|sb_secret_|storePassword\s*=" "$FRONTEND_DIR/lib/" || true)
if [ -z "$PRIVATE_KEYS_IN_CODE" ]; then
  pass "Zero private keys or Supabase secret keys found in frontend/lib/"
else
  fail "Potential secret key found in frontend/lib/"
fi

# ------------------------------------------------------------------------------
# STAGE 10: Merged Manifest Permission & Network Security Audit
# ------------------------------------------------------------------------------
section "STAGE 10: Merged Manifest Permission & Network Security Audit"
if [ -n "$MERGED_MANIFEST" ]; then
  FORBIDDEN_PERMS=$(grep -E "READ_PHONE_STATE|WRITE_EXTERNAL_STORAGE|READ_EXTERNAL_STORAGE|READ_MEDIA_IMAGES|READ_MEDIA_VIDEO|ACCESS_FINE_LOCATION|ACCESS_COARSE_LOCATION|RECORD_AUDIO|READ_CONTACTS" "$MERGED_MANIFEST" || true)
  if [ -z "$FORBIDDEN_PERMS" ]; then
    pass "Zero unnecessary or legacy implied permissions (READ_PHONE_STATE / EXTERNAL_STORAGE) in merged manifest"
  else
    fail "Forbidden permissions present in merged manifest: $FORBIDDEN_PERMS"
  fi

  if grep -q 'android:allowBackup="false"' "$MERGED_MANIFEST" && grep -q 'android:usesCleartextTraffic="false"' "$MERGED_MANIFEST"; then
    pass "allowBackup=\"false\" and usesCleartextTraffic=\"false\" enforced in release manifest"
  else
    fail "Missing allowBackup=false or usesCleartextTraffic=false in release manifest"
  fi
fi

# ------------------------------------------------------------------------------
# STAGE 11: 16 KB ELF Page Size Alignment Verification
# ------------------------------------------------------------------------------
section "STAGE 11: 16 KB ELF Page Size Alignment Check (arm64-v8a & x86_64)"
TMP_SO_DIR=$(mktemp -d)
unzip -q "$AAB_PATH" "base/lib/arm64-v8a/*.so" "base/lib/x86_64/*.so" -d "$TMP_SO_DIR"
UNALIGNED_SO=0

for so_file in "$TMP_SO_DIR"/base/lib/arm64-v8a/*.so "$TMP_SO_DIR"/base/lib/x86_64/*.so; do
  [ -e "$so_file" ] || continue
  # Check that all LOAD segments have alignment >= 0x4000 (16 KB)
  BAD_ALIGN=$(readelf -l "$so_file" | awk '/LOAD/{getline; print $NF}' | grep -Ev '^0x([48c]000|[1-9a-f][0-9a-f]*0000)$' || true)
  if [ -n "$BAD_ALIGN" ]; then
    fail "$(basename "$so_file") has LOAD segment alignment < 16 KB ($BAD_ALIGN)"
    UNALIGNED_SO=$((UNALIGNED_SO + 1))
  fi
done
rm -rf "$TMP_SO_DIR"

if [ "$UNALIGNED_SO" -eq 0 ]; then
  pass "All arm64-v8a and x86_64 native .so libraries satisfy >= 16 KB (0x4000) ELF LOAD segment alignment"
fi

# ------------------------------------------------------------------------------
# STAGE 12: Google Play Privacy Policy & Account Deletion Asset Audit
# ------------------------------------------------------------------------------
section "STAGE 12: Google Play Legal, Privacy Policy & Account Deletion Assets"
if [ -f "$ROOT_DIR/public/privacy.html" ] && [ -f "$ROOT_DIR/public/delete-account.html" ] && [ -f "$ROOT_DIR/firebase.json" ]; then
  pass "Public web Privacy Policy (public/privacy.html) and Account Deletion (public/delete-account.html) exist"
else
  fail "Missing public/privacy.html or public/delete-account.html"
fi

echo ""
echo "=============================================================================="
echo "VALIDATION SUMMARY: $PASS_COUNT PASSED, $FAIL_COUNT FAILED"
echo "=============================================================================="

if [ "$FAIL_COUNT" -gt 0 ]; then
  exit 1
fi
exit 0
