#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

workspace_root() {
  printf '%s\n' "${WORKSPACE_ROOT}"
}

_workspace_members_raw() {
  awk '
    /^workspace:[[:space:]]*$/ {in_ws=1; next}
    in_ws {
      if ($0 ~ /^[[:space:]]*#/) next
      if ($0 ~ /^[^[:space:]-]/) {in_ws=0; next}
      if ($0 ~ /^[[:space:]]*-[[:space:]]+/) {
        line=$0
        sub(/^[[:space:]]*-[[:space:]]+/, "", line)
        sub(/[[:space:]]+#.*$/, "", line)
        gsub(/[[:space:]]+$/, "", line)
        if (length(line) > 0) {
          print line
        }
      }
    }
  ' "${WORKSPACE_ROOT}/pubspec.yaml"
}

workspace_members() {
  local root
  root="$(workspace_root)"
  local entry
  while IFS= read -r entry; do
    [[ -z "${entry}" ]] && continue

    if [[ "${entry}" == *"*"* || "${entry}" == *"?"* || "${entry}" == *"["* ]]; then
      while IFS= read -r match; do
        [[ -d "${match}" ]] || continue
        printf '%s\n' "${match#${root}/}"
      done < <(compgen -G "${root}/${entry}")
    else
      if [[ -d "${root}/${entry}" ]]; then
        printf '%s\n' "${entry}"
      fi
    fi
  done < <(_workspace_members_raw)
}

workspace_apps() {
  local root
  root="$(workspace_root)"
  if [[ ! -d "${root}/apps" ]]; then
    return 0
  fi

  local dir
  for dir in "${root}/apps"/*; do
    [[ -d "${dir}" ]] || continue
    if [[ -f "${dir}/pubspec.yaml" ]]; then
      printf '%s\n' "${dir#${root}/}"
    fi
  done
}

primary_app_dir() {
  local root
  root="$(workspace_root)"
  local app
  app="$(workspace_apps | head -n 1)"
  if [[ -n "${app}" ]]; then
    printf '%s\n' "${root}/${app}"
  fi
}

run_in_directory() {
  local directory="$1"
  shift

  local display="${directory#${WORKSPACE_ROOT}/}"
  if [[ "${directory}" == "${WORKSPACE_ROOT}" ]]; then
    display="."
  fi

  echo ">>> ${display}: $*"
  (
    cd "${directory}"
    "$@"
  )
}

package_has_tests() {
  local package_directory="$1"
  if [[ ! -d "${package_directory}/test" ]]; then
    return 1
  fi

  find "${package_directory}/test" -type f -name '*_test.dart' -print -quit | grep -q .
}

directory_has_build_runner() {
  local directory="$1"
  grep -Eq '^[[:space:]]+build_runner:' "${directory}/pubspec.yaml"
}

directory_uses_flutter() {
  local directory="$1"
  grep -Eq '^[[:space:]]+flutter:' "${directory}/pubspec.yaml"
}

runner_for_directory() {
  local directory="$1"
  if directory_uses_flutter "${directory}"; then
    printf '%s\n' "flutter"
  else
    printf '%s\n' "dart"
  fi
}
