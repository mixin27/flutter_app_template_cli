#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/ci/setup_ios_signing.sh [--required]

Expected environment variables:
  IOS_P12_BASE64
  IOS_P12_PASSWORD
  IOS_PROVISIONING_PROFILE_BASE64
Optional:
  IOS_KEYCHAIN_PASSWORD
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

if [[ "$(uname -s)" != "Darwin" ]]; then
  if [[ ${required} -eq 1 ]]; then
    echo "iOS signing setup requires macOS." >&2
    exit 1
  fi
  echo "Not running on macOS. Skipping iOS signing setup."
  exit 0
fi

p12_b64="${IOS_P12_BASE64:-}"
p12_password="${IOS_P12_PASSWORD:-}"
profile_b64="${IOS_PROVISIONING_PROFILE_BASE64:-}"
keychain_password="${IOS_KEYCHAIN_PASSWORD:-$(uuidgen)}"

if [[ -z "${p12_b64}" || -z "${p12_password}" || -z "${profile_b64}" ]]; then
  if [[ ${required} -eq 1 ]]; then
    echo "Missing required iOS signing environment variables." >&2
    exit 1
  fi
  echo "iOS signing secrets not fully provided. Skipping signing setup."
  exit 0
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

p12_path="${tmp_dir}/certificate.p12"
profile_path="${tmp_dir}/profile.mobileprovision"
decode_base64_to_file "${p12_b64}" "${p12_path}"
decode_base64_to_file "${profile_b64}" "${profile_path}"

keychain_path="${HOME}/Library/Keychains/__APP_NAME__-build.keychain-db"
if [[ -f "${keychain_path}" ]]; then
  security delete-keychain "${keychain_path}" || true
fi
security create-keychain -p "${keychain_password}" "${keychain_path}"
security set-keychain-settings -lut 21600 "${keychain_path}"
security unlock-keychain -p "${keychain_password}" "${keychain_path}"
security import "${p12_path}" -P "${p12_password}" -A -t cert -f pkcs12 -k "${keychain_path}"
security set-key-partition-list -S apple-tool:,apple: -k "${keychain_password}" "${keychain_path}"
security list-keychains -d user -s "${keychain_path}" $(security list-keychains -d user | tr -d '"')
security default-keychain -d user -s "${keychain_path}"

mkdir -p "${HOME}/Library/MobileDevice/Provisioning Profiles"
profile_plist="${tmp_dir}/profile.plist"
security cms -D -i "${profile_path}" > "${profile_plist}"
profile_uuid="$(/usr/libexec/PlistBuddy -c 'Print :UUID' "${profile_plist}")"
cp "${profile_path}" "${HOME}/Library/MobileDevice/Provisioning Profiles/${profile_uuid}.mobileprovision"

if [[ -n "${GITHUB_ENV:-}" ]]; then
  {
    echo "IOS_BUILD_KEYCHAIN=${keychain_path}"
    echo "IOS_KEYCHAIN_PASSWORD=${keychain_password}"
    echo "IOS_PROFILE_UUID=${profile_uuid}"
  } >> "${GITHUB_ENV}"
fi

echo "iOS signing configured (keychain + provisioning profile ${profile_uuid})."
