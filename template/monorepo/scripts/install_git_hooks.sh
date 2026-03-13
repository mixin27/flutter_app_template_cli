#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/.." && pwd)"

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/install_git_hooks.sh [--dry-run]

Options:
  --dry-run   Print the command without applying changes.
USAGE
}

dry_run=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      dry_run=1
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

command=(dart run husky install)
echo ">>> (cd ${repo_root} && ${command[*]})"

if [[ ${dry_run} -eq 1 ]]; then
  exit 0
fi

(
  cd "${repo_root}"
  "${command[@]}"
)

chmod +x "${repo_root}/.husky/pre-push" "${repo_root}/.husky/commit-msg"

echo "Git hooks path configured to .husky (husky)"
echo "Pre-push and commit-msg hooks are ready."
