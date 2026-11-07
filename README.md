# Pi Docker sandbox

The Pi container shares the gateway container's network namespace. The gateway installs firewall rules before reporting healthy. Pi has no NET_ADMIN capability.
The Pi image includes Node.js, Python with virtual-environment support, Go
1.27.3, `uv`, and `uvx`.
The `pi` user has passwordless `sudo`, so Debian packages can be installed at
runtime with `sudo apt-get update && sudo apt-get install PACKAGE`. These
changes are ephemeral and disappear when the container is removed.

## Run on Linux (from the repository you want Pi to edit)

`run-pi.sh` sets `PI_UID`/`PI_GID` to the caller's IDs, mounts `$PWD` (or
`$PI_WORKSPACE`) as `/workspace`, rebuilds the images if needed, and starts an
interactive Pi container:

```sh
/absolute/path/to/agent-boxes/run-pi.sh
```

To call it from anywhere, link it into a directory on your `PATH` using an
absolute target; the script resolves the link back to the repository:

```sh
ln -s /absolute/path/to/agent-boxes/run-pi.sh ~/bin/run-pi
```

Manual equivalent:

```sh
export PI_WORKSPACE="$PWD" PI_UID="$(id -u)" PI_GID="$(id -g)"
docker compose -f /absolute/path/to/agent-boxes/compose.yaml run --build --rm pi
```

## Run on Windows PowerShell (from the repository you want Pi to edit)

```powershell
$env:PI_WORKSPACE = (Get-Location).Path
docker compose -f C:\path\to\agent-boxes\compose.yaml run --build --rm pi
```

The bind mount uses `${PI_WORKSPACE:?}` so Compose fails instead of silently mounting an unintended directory if the variable is missing. `-f` can refer to the Compose file from any working directory. Docker Compose resolves `build: ./gateway` and `build: ./pi` relative to the Compose project directory, while the workspace is set explicitly.

## Network policy

- TCP port 9931 and TCP destination ports above 15000 are allowed to **any** IP
  in `192.168.0.0/16`.
- All other traffic to `10.0.0.0/8`, `169.254.0.0/16`,
  `172.16.0.0/12`, and `192.168.0.0/16` is blocked.
- Other IPv4 destinations, including public internet, are allowed.
- Outbound IPv6 is blocked.

This is a starting point, **not a hardened security boundary**. The coding
agent has passwordless root access inside its writable container. Other private
ranges, Docker's DNS proxy, host services, and allowed HTTP endpoints may permit
indirect access. A local LLM server that accepts arbitrary requests is itself a
trusted destination. Test the rules on both Docker Desktop WSL2 and Linux
before trusting them with untrusted code.

## Notes

- The gateway prefers nft-backed `iptables` and falls back to
  `iptables-legacy` when the host kernel does not support nftables inside its
  Docker network namespace.
- To change the LLM port, edit the `--dport 9931` rule in
  `gateway/firewall.sh` and rebuild the gateway.
- `depends_on: condition: service_healthy` gates Pi startup; it does not stop Pi if the gateway later becomes unhealthy.
- Pi configuration persists in the named volume `pi-config` (`/home/pi/.pi`).
  Docker sets its ownership only when the volume is first created, so after
  changing `PI_UID`/`PI_GID` either remove it (`docker volume rm
  agent-boxes_pi-config`) or `chown` its contents to the new IDs.
- `pi/scripts/` is installed as `/home/pi/bin` (on `PATH`). `run-agx.sh` and
  `run-xen.sh` start Pi against the LLM server on the respective LAN host.
- Never mount Docker's socket or host credentials into Pi.
- Keep your work in Git; Pi can modify everything in the mounted workspace.
