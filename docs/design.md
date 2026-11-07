# Design

## Runtime package installation

The `pi` user may install Debian packages while the container is running by
using passwordless `sudo`. The Pi container therefore has a writable root
filesystem and Docker's default Linux capability set. Network access remains
limited by the shared gateway firewall.

Packages installed at runtime are ephemeral and disappear when the container
is removed. Repeatedly needed tools should still be added to `pi/Dockerfile`.
