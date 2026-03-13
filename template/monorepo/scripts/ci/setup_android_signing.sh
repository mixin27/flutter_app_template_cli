#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "${script_dir}/../_workspace.sh"
repo_root="$(workspace_root)"
app_root="$(primary_app_dir)"

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/ci/setup_android_signing.sh [--required]

Expected environment variables:
  ANDROID_KEYSTORE_BASE64
  ANDROID_KEYSTORE_PASSWORD
  ANDROID_KEY_ALIAS
  ANDROID_KEY_PASSWORD
Optional:
  ANDROID_KEYSTORE_PATH (default: android/app/upload-keystore.jks, relative to apps/<app>)
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

required=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --required)
      required=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

keystore_b64="${ANDROID_KEYSTORE_BASE64:-}"
store_password="${ANDROID_KEYSTORE_PASSWORD:-}"
key_alias="${ANDROID_KEY_ALIAS:-}"
key_password="${ANDROID_KEY_PASSWORD:-}"
if [[ -z "${app_root}" ]]; then
  echo "No app found under apps/. Create an app first." >&2
  exit 1
fi

keystore_path="${ANDROID_KEYSTORE_PATH:-android/app/upload-keystore.jks}"

if [[ -z "${keystore_b64}" || -z "${store_password}" || -z "${key_alias}" || -z "${key_password}" ]]; then
  if [[ ${required} -eq 1 ]]; then
    echo "Missing required Android signing environment variables." >&2
    exit 1
  fi
  echo "Android signing secrets not fully provided. Skipping signing setup."
  exit 0
fi

if [[ "${keystore_path}" != android/* ]]; then
  echo "ANDROID_KEYSTORE_PATH must be within the app's android/ directory (android/*)."
  exit 1
fi

keystore_abs_path="${app_root}/${keystore_path}"
decode_base64_to_file "${keystore_b64}" "${keystore_abs_path}"
chmod 600 "${keystore_abs_path}"

store_file_in_properties="${keystore_path#android/}"

cat > "${app_root}/android/key.properties" <<EOF_PROPS
storeFile=${store_file_in_properties}
storePassword=${store_password}
keyAlias=${key_alias}
keyPassword=${key_password}
EOF_PROPS

chmod 600 "${app_root}/android/key.properties"
echo "Android signing configured (${keystore_path} + android/key.properties)."
