#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/_workspace.sh"

root="$(workspace_root)"

if directory_uses_flutter "${root}"; then
  run_in_directory "${root}" flutter clean
fi

while IFS= read -r member; do
  member_dir="${root}/${member}"
  if directory_uses_flutter "${member_dir}"; then
    run_in_directory "${member_dir}" flutter clean
  else
    echo ">>> ${member}: dart package, skipping flutter clean"
  fi
done < <(workspace_members)
