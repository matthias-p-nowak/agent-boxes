#!/bin/bash
set -eu

# Match the container's pi account to the owner identity used by this caller.
export PI_UID="$(id -u)"
export PI_GID="$(id -g)"
export PI_WORKSPACE="${PI_WORKSPACE:-$PWD}"

# Resolve symlinks so the script also works when linked from e.g. ~/bin.
script_dir="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")"
exec docker compose -f "${script_dir}/compose.yaml" run --build --rm pi
