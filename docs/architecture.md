# Architecture

## Pi container privileges

The image runs as the `pi` user, which has passwordless `sudo` through
`/etc/sudoers.d/pi`. Compose leaves the root filesystem writable and uses
Docker's default container capabilities so `apt` and `dpkg` work at runtime.
The container continues to share the gateway network namespace, which applies
the outbound firewall policy.

## Launcher

`run-pi.sh` resolves its own path with `readlink -f`, so it locates
`compose.yaml` even when invoked through a symlink (e.g. from `~/bin`).
