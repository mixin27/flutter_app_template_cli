#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "${script_dir}/_workspace.sh"

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/enable_native_flavors.sh [--platform all|android|ios] [--force]

Options:
  --platform   Limit to android or ios. Default: all.
  --force      Overwrite existing generated files (schemes/xcconfig).
  --help, -h   Show this help.
USAGE
}

platform="all"
force=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --platform)
      platform="${2:-}"
      shift 2
      ;;
    --force)
      force=1
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

case "${platform}" in
  all|android|ios)
    ;;
  *)
    echo "Invalid platform: ${platform}. Use all|android|ios." >&2
    usage
    exit 1
    ;;
esac

app_root="$(primary_app_dir)"
if [[ -z "${app_root}" ]]; then
  echo "No app found under apps/. Create an app first." >&2
  exit 1
fi

app_name="$(basename "${app_root}")"

escape_double_quotes() {
  printf '%s' "$1" | sed 's/"/\\"/g'
}

resolve_app_label() {
  local strings_file="$1"
  local fallback="$2"
  local label=""

  if [[ -f "${strings_file}" ]]; then
    label=$(sed -n 's/.*<string name="app_name">\(.*\)<\/string>.*/\1/p' "${strings_file}" | head -n 1)
  fi

  if [[ -z "${label}" ]]; then
    label="${fallback}"
  fi

  echo "${label}"
}

insert_android_flavors() {
  local gradle_file="$1"
  local snippet="$2"

  if grep -q "productFlavors" "${gradle_file}" || grep -q "flavorDimensions" "${gradle_file}"; then
    echo "Android flavors already configured in ${gradle_file}. Skipping."
    return
  fi

  local tmp_file="${gradle_file}.tmp"

  awk -v snippet="${snippet}" '
    function brace_delta(s,    t, opens, closes) {
      t = s
      opens = gsub(/\{/, "", t)
      t = s
      closes = gsub(/\}/, "", t)
      return opens - closes
    }
    BEGIN { in_android = 0; depth = 0; inserted = 0 }
    {
      line = $0
      if (!in_android && line ~ /^[[:space:]]*android[[:space:]]*\{/) {
        in_android = 1
      }
      if (in_android) {
        delta = brace_delta(line)
        depth_next = depth + delta

        if (!inserted && (line ~ /^[[:space:]]*signingConfigs[[:space:]]*\{/ || line ~ /^[[:space:]]*buildTypes[[:space:]]*\{/)) {
          print snippet
          inserted = 1
        } else if (!inserted && depth_next == 0) {
          print snippet
          inserted = 1
        }

        print line
        depth = depth_next
        next
      }

      print line
    }
  ' "${gradle_file}" > "${tmp_file}"

  mv "${tmp_file}" "${gradle_file}"
  echo "Android flavors added to ${gradle_file}."
}

enable_android_flavors() {
  local android_dir="${app_root}/android/app"
  local gradle_kts="${android_dir}/build.gradle.kts"
  local gradle_groovy="${android_dir}/build.gradle"

  if [[ ! -d "${android_dir}" ]]; then
    echo "Android directory not found at ${android_dir}. Skipping Android." >&2
    return
  fi

  local strings_file="${android_dir}/src/main/res/values/strings.xml"
  local app_label
  app_label="$(resolve_app_label "${strings_file}" "${app_name}")"
  app_label="$(escape_double_quotes "${app_label}")"

  if [[ -f "${gradle_kts}" ]]; then
    local snippet
    snippet=$(cat <<EOF_SNIPPET
    flavorDimensions += "environment"

    productFlavors {
        create("development") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "${app_label} Dev")
        }

        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            resValue("string", "app_name", "${app_label} Staging")
        }

        create("production") {
            dimension = "environment"
            resValue("string", "app_name", "${app_label}")
        }
    }
EOF_SNIPPET
)
    insert_android_flavors "${gradle_kts}" "${snippet}"
    return
  fi

  if [[ -f "${gradle_groovy}" ]]; then
    local snippet
    snippet=$(cat <<EOF_SNIPPET
    flavorDimensions "environment"

    productFlavors {
        development {
            dimension "environment"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
            resValue "string", "app_name", "${app_label} Dev"
        }

        staging {
            dimension "environment"
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
            resValue "string", "app_name", "${app_label} Staging"
        }

        production {
            dimension "environment"
            resValue "string", "app_name", "${app_label}"
        }
    }
EOF_SNIPPET
)
    insert_android_flavors "${gradle_groovy}" "${snippet}"
    return
  fi

  echo "No Android Gradle file found (build.gradle(.kts)) under ${android_dir}." >&2
}

enable_ios_flavors() {
  local ios_dir="${app_root}/ios"
  if [[ ! -d "${ios_dir}" ]]; then
    echo "iOS directory not found at ${ios_dir}. Skipping iOS." >&2
    return
  fi

  local scheme_dir="${ios_dir}/Runner.xcodeproj/xcshareddata/xcschemes"
  local runner_scheme="${scheme_dir}/Runner.xcscheme"

  if [[ ! -f "${runner_scheme}" ]]; then
    echo "Runner.xcscheme not found. Open the project in Xcode once to generate it." >&2
    return
  fi

  mkdir -p "${scheme_dir}"

  for flavor in development staging production; do
    local target_scheme="${scheme_dir}/${flavor}.xcscheme"
    if [[ -f "${target_scheme}" && ${force} -eq 0 ]]; then
      echo "Scheme exists: ${target_scheme} (use --force to overwrite)."
    else
      cp "${runner_scheme}" "${target_scheme}"
      echo "Created scheme: ${target_scheme}"
    fi
  done

  local flutter_dir="${ios_dir}/Flutter"
  for flavor in development staging production; do
    for kind in Debug Release Profile; do
      local lower_kind
      lower_kind=$(printf '%s' "${kind}" | tr '[:upper:]' '[:lower:]')
      local xcconfig="${flutter_dir}/${kind}-${flavor}.xcconfig"

      if [[ -f "${xcconfig}" && ${force} -eq 0 ]]; then
        continue
      fi

      cat > "${xcconfig}" <<EOF_XCCONFIG
#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.${lower_kind}-${flavor}.xcconfig"
#include "Generated.xcconfig"
EOF_XCCONFIG
    done
  done

  cat <<'EOF_NOTE'
Note: iOS schemes were added, and flavor xcconfig files were generated.
To fully separate bundle IDs and build settings per flavor, add build
configurations in Xcode and point them to the new xcconfig files.
See docs/native-flavors.md for the full walkthrough.
EOF_NOTE
}

if [[ "${platform}" == "all" || "${platform}" == "android" ]]; then
  enable_android_flavors
fi

if [[ "${platform}" == "all" || "${platform}" == "ios" ]]; then
  enable_ios_flavors
fi
