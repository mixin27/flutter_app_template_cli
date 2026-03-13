#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "${script_dir}/../_workspace.sh"
repo_root="$(workspace_root)"
app_root="$(primary_app_dir)"

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/ci/install_firebase_from_secrets.sh <development|staging|production> [all|android|ios]

Expected environment variables (base64-encoded):
  ANDROID_FIREBASE_DEVELOPMENT_JSON_B64
  ANDROID_FIREBASE_STAGING_JSON_B64
  ANDROID_FIREBASE_PRODUCTION_JSON_B64
  IOS_FIREBASE_DEVELOPMENT_PLIST_B64
  IOS_FIREBASE_STAGING_PLIST_B64
  IOS_FIREBASE_PRODUCTION_PLIST_B64

Notes:
  Writes configs into apps/<app>/android/firebase/<flavor>/google-services.json
  and apps/<app>/ios/firebase/<flavor>/GoogleService-Info.plist.
USAGE
}

decode_base64_to_file() {
  local value="$1"
  local output_file="$2"

  mkdir -p "$(dirname -- "${output_file}")"
  if printf '' | base64 --decode >/dev/null 2>&1; then
    printf '%s' "${value}" | base64 --decode > "${output_file}"
  else
    printf '%s' "${value}" | base64 -D > "${output_file}"
  fi
}

flavor="${1:-}"
platform="${2:-all}"
case "${platform}" in
  all|android|ios)
    ;;
  *)
    usage
    exit 1
    ;;
esac

case "${flavor}" in
  development)
    android_b64="${ANDROID_FIREBASE_DEVELOPMENT_JSON_B64:-}"
    ios_b64="${IOS_FIREBASE_DEVELOPMENT_PLIST_B64:-}"
    ;;
  staging)
    android_b64="${ANDROID_FIREBASE_STAGING_JSON_B64:-}"
    ios_b64="${IOS_FIREBASE_STAGING_PLIST_B64:-}"
    ;;
  production)
    android_b64="${ANDROID_FIREBASE_PRODUCTION_JSON_B64:-}"
    ios_b64="${IOS_FIREBASE_PRODUCTION_PLIST_B64:-}"
    ;;
  *)
    usage
    exit 1
    ;;
esac

if [[ -z "${app_root}" ]]; then
  echo "No app found under apps/. Create an app first." >&2
  exit 1
fi

if [[ "${platform}" == "all" || "${platform}" == "android" ]]; then
  if [[ -n "${android_b64}" ]]; then
    decode_base64_to_file "${android_b64}" "${app_root}/android/firebase/${flavor}/google-services.json"
    echo "Installed Android Firebase config for ${flavor}."
  else
    echo "No Android Firebase secret provided for ${flavor}."
  fi
fi

if [[ "${platform}" == "all" || "${platform}" == "ios" ]]; then
  if [[ -n "${ios_b64}" ]]; then
    decode_base64_to_file "${ios_b64}" "${app_root}/ios/firebase/${flavor}/GoogleService-Info.plist"
    echo "Installed iOS Firebase config for ${flavor}."
  else
    echo "No iOS Firebase secret provided for ${flavor}."
  fi
fi

"${repo_root}/scripts/prepare_firebase.sh" --flavor "${flavor}" --platform "${platform}"
