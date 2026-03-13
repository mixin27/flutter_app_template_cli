#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/_workspace.sh"

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/env_init.sh [--environment development|staging|production] [--force]

Options:
  --environment, -e   Environment template to copy. Default: development
  --force             Overwrite existing .env file.
  --help, -h          Show this help.

Examples:
  ./scripts/env_init.sh
  ./scripts/env_init.sh --environment staging
  ./scripts/env_init.sh -e production --force
USAGE
}

environment="development"
force=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --environment|-e)
      environment="${2:-}"
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

case "${environment}" in
  development|staging|production)
    ;;
  *)
    echo "Invalid environment: ${environment}. Use development, staging, or production." >&2
    exit 1
    ;;
esac

root="$(workspace_root)"
source_template="${root}/.env.${environment}.example"
fallback_template="${root}/env_examples/env.${environment}.example"
env_examples_dir="${root}/env_examples"
target_env="${root}/.env"

envs=(development staging production)
missing_selected=0

for env in "${envs[@]}"; do
  example_source="${env_examples_dir}/env.${env}.example"
  if [[ -f "${example_source}" ]]; then
    example_target="${root}/.env.${env}.example"
    if [[ ! -f "${example_target}" ]]; then
      cp "${example_source}" "${example_target}"
    fi

    env_target="${root}/.env.${env}"
    if [[ ! -f "${env_target}" ]]; then
      cp "${example_source}" "${env_target}"
    fi
  else
    if [[ "${env}" == "${environment}" ]]; then
      missing_selected=1
    fi
    echo "Warning: missing env template: ${example_source}" >&2
  fi
done

template_path="${source_template}"
if [[ ! -f "${template_path}" ]]; then
  if [[ -f "${fallback_template}" ]]; then
    template_path="${fallback_template}"
  else
    echo "Template not found: ${source_template}" >&2
    echo "Fallback template not found: ${fallback_template}" >&2
    exit 1
  fi
fi

if [[ ${missing_selected} -eq 1 && ! -f "${template_path}" ]]; then
  exit 1
fi

if [[ -f "${target_env}" && ${force} -ne 1 ]]; then
  echo ".env already exists. Use --force to overwrite." >&2
  exit 1
fi

cp "${template_path}" "${target_env}"

echo "Created .env from $(basename "${template_path}")"
echo "Next: run 'make codegen' after editing .env values."
