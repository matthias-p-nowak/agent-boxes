# Architecture

## Pi container privileges

The image runs as the `pi` user, which has passwordless `sudo` through
`/etc/sudoers.d/pi`. Compose leaves the root filesystem writable and uses
Docker's default container capabilities so `apt` and `dpkg` work at runtime.
The container continues to share the gateway network namespace, which applies
the outbound firewall policy.

The gateway allows outbound ADB TCP connections on port 5555 to
`192.168.0.0/16` before dropping other traffic to that network.

Compose publishes host port 8080 from the `gateway` service because the `pi`
service uses `network_mode: service:gateway`. A named `pi-cache` volume is
mounted into the Pi container at `/cache`; the image creates that mount point
with ownership matching the unprivileged `pi` user.

## Launcher

`run-pi.sh` resolves its own path with `readlink -f`, so it locates
`compose.yaml` even when invoked through a symlink (e.g. from `~/bin`).
It also canonicalizes the workspace path and uses the first 12 hexadecimal
characters of its SHA-256 digest in the container name. A missing container is
created as a detached `sleep infinity` process, a stopped container is started,
and `docker exec` opens each interactive shell in the persistent container.
Before either path, the launcher starts the shared gateway and waits for its
firewall health check to pass.
