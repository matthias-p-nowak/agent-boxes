#!/bin/bash
set -eu

# Match the container's pi account and workspace to this caller.
export PI_UID="$(id -u)"
export PI_GID="$(id -g)"
export PI_WORKSPACE="$(readlink -f -- "${PI_WORKSPACE:-$PWD}")"

# Resolve symlinks so the script also works when linked from e.g. ~/bin.
script_dir="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")"

# Derive a stable, collision-resistant container identity from the full path.
workspace_key="$(printf '%s' "${PI_WORKSPACE}" | sha256sum | cut -c1-12)"
container_name="agent-boxes-pi-${workspace_key}"

# Allow local containers to connect to the host X server.
xhost +local:

# Ensure the shared network namespace and firewall are ready before Pi starts.
docker compose -f "${script_dir}/compose.yaml" up --detach --wait gateway

# Create one persistent container per workspace, or restart the existing one.
if ! docker container inspect "${container_name}" >/dev/null 2>&1; then
    docker compose -f "${script_dir}/compose.yaml" run \
        --detach \
        --name "${container_name}" \
        --entrypoint sleep \
        pi infinity
elif [ "$(docker container inspect --format '{{.State.Running}}' "${container_name}")" != "true" ]; then
    docker container start "${container_name}"
fi

# Open an interactive shell without replacing the persistent container.
exec docker container exec --interactive --tty "${container_name}" bash -l
