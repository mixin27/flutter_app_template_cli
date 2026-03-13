#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [ -d "packages" ]; then
  for pkg in packages/*; do
    if [ -f "$pkg/pubspec.yaml" ]; then
      echo "Running dart test in $pkg"
      (cd "$pkg" && dart test)
    fi
  done
fi

if [ -d "apps" ]; then
  for app in apps/*; do
    if [ -f "$app/pubspec.yaml" ]; then
      echo "Running flutter test in $app"
      (cd "$app" && flutter test)
    fi
  done
fi
