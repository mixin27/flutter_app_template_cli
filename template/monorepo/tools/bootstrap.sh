#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"

echo "Bootstrapping workspace dependencies..."
dart pub get

if [ -d "apps" ]; then
  for app in apps/*; do
    if [ -f "$app/pubspec.yaml" ]; then
      echo "Running flutter pub get in $app"
      (cd "$app" && flutter pub get)
    fi
  done
fi

echo "Bootstrap complete."
