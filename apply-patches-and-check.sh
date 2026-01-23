#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# apply-patches-and-check.sh
# Applies prepared patch files, runs backend checks/migrations, and builds the iOS app for simulator.
# Usage: ./apply-patches-and-check.sh [IOS_SCHEME] [SIM_DEST]
# Example: ./apply-patches-and-check.sh circl_test_app "platform=iOS Simulator,name=iPhone 14"

REPO_ROOT="/Users/ryancamp/Desktop/Circl/Circl_app"
PATCH_DIR="$REPO_ROOT/patches"
BACKEND_DIR="$REPO_ROOT/circl-backend"
IOS_DIR="$REPO_ROOT/circl_test_app"

IOS_SCHEME="${1:-circl_test_app}"
SIM_DEST="${2:-platform=iOS Simulator,name=iPhone 14}"

echo "=== apply-patches-and-check.sh ==="
echo "Repo root: $REPO_ROOT"
echo "Patch dir: $PATCH_DIR"

# Basic validations
if [ ! -d "$REPO_ROOT" ]; then
  echo "ERROR: repo root not found: $REPO_ROOT"
  exit 1
fi

if [ ! -d "$PATCH_DIR" ]; then
  echo "ERROR: patches directory not found: $PATCH_DIR"
  exit 1
fi

# Ensure git working tree is clean to avoid accidental overwrites
echo "Checking git working tree cleanliness..."
if ! git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: $REPO_ROOT is not a git repository"
  exit 1
fi

# abort if there are unstaged or uncommitted changes
if [ -n "$(git -C "$REPO_ROOT" status --porcelain)" ]; then
  echo "ERROR: working tree at $REPO_ROOT is not clean. Commit or stash changes (GitHub Desktop can do this). Aborting."
  git -C "$REPO_ROOT" status --porcelain
  exit 1
fi

# Dry-run check all patches
echo "Running dry-run check for patches..."
if ! git -C "$REPO_ROOT" apply --check "$PATCH_DIR"/*.patch; then
  echo "ERROR: one or more patches failed --check. Inspect patches/ and resolve conflicts before proceeding."
  exit 1
fi

# Apply patches sequentially
echo "Applying patches..."
for p in "$PATCH_DIR"/*.patch; do
  echo "-> Applying: $p"
  git -C "$REPO_ROOT" apply "$p"
done

echo "Patches applied. Showing modified files:"
git -C "$REPO_ROOT" --no-pager diff --name-only

# Backend checks and migrations
if [ -d "$BACKEND_DIR" ]; then
  echo "\n=== Backend: $BACKEND_DIR ==="
  cd "$BACKEND_DIR"

  # Activate venv if present
  if [ -f venv/bin/activate ]; then
    echo "Activating virtualenv venv/..."
    # shellcheck disable=SC1091
    source venv/bin/activate
  fi

  echo "Installing requirements (if needed)... (will continue on failure)"
  pip install -r requirements.txt || true

  echo "Running Django check..."
  python manage.py check

  echo "Making migrations for notifications app..."
  python manage.py makemigrations notifications || true

  echo "Applying migrations..."
  python manage.py migrate

  echo "Running notifications app tests (if any)..."
  python manage.py test notifications || true
else
  echo "WARNING: Backend dir not found: $BACKEND_DIR — skipping backend steps"
fi

# iOS build (simulator)
if [ -d "$IOS_DIR" ]; then
  echo "\n=== iOS: building scheme '$IOS_SCHEME' for simulator ($SIM_DEST) ==="
  cd "$IOS_DIR"

  # Attempt a simulator build (does not require device signing)
  xcodebuild -workspace circl_test_app.xcworkspace -scheme "$IOS_SCHEME" -configuration Debug -sdk iphonesimulator -destination "$SIM_DEST" build
else
  echo "WARNING: iOS dir not found: $IOS_DIR — skipping iOS build"
fi

echo "\nAll done. Review changes in GitHub Desktop and run any manual tests you prefer." 
exit 0
