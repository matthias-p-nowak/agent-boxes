# Design

## Runtime package installation

The `pi` user may install Debian packages while the container is running by
using passwordless `sudo`. The Pi container therefore has a writable root
filesystem and Docker's default Linux capability set. Network access remains
limited by the shared gateway firewall.

Packages installed at runtime are ephemeral and disappear when the container
is removed. Repeatedly needed tools should still be added to `pi/Dockerfile`.

## Network access

The shared gateway permits ADB TCP connections on port 5555 to devices in
`192.168.0.0/16`.

The Pi workload may expose an HTTP service on container port 8080. Compose
publishes that port on the host through the shared gateway network namespace.

## Cache persistence

The Pi workload has a Docker-managed volume mounted at `/cache` so cached data
survives container replacement without being stored in the workspace.

## Workspace container lifecycle

Each canonical workspace path has one stable Pi container. Running the launcher
again for that workspace reuses the running container or restarts it when
stopped; a different workspace path selects a different container. Containers
remain until explicitly removed so runtime package installations persist.
