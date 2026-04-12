# NixOS Server containing an Observability stack

The Server contains the following stack:

| Service              | Purpose                      |
| -------------------- | ---------------------------- |
| Gatus                | Uptime Monitoring            |
| Grafana (TODO)       | Dashboard for Metrics & Logs |
| Loki (TODO)          | Log Aggregator               |
| Prometheus (TODO)    | Metrics Aggregator           |
| Alertmanager (TODO)  | For triggering alerts        |
| Matrix Server (TODO) | For sending alerts           |

The configuration follows the
[Dendritic Pattern](https://github.com/Doc-Steve/dendritic-design-with-flake-parts).

## Test in a Virtual Machine

You can run the server inside a VM with

```
nix run .#vm
```

After starting the VM you should be able to access all services on the host
machine under the `localhost` domain using the port 8443, e.g.
https://health.localhost:8443. Note that the VM will use a self signed
certificate for SSL which the browser won't trust.

## Deployment

### Fresh Installation

Deployment can be done using nixos-anywhere with:

```bash
temp=$(mktemp -d)
trap "rm -rf $temp" EXIT

install -d -m755 "$temp/etc/ssh"
# Assuming /etc/ssh/ssh_host_ed25519_key is the key used for encrypting/decrypting sops secrets
cp /etc/ssh/ssh_host_* "$temp/etc/ssh/"
chmod 600 "$temp/etc/ssh/"*_key  

nix run github:nix-community/nixos-anywhere -- \
    --generate-hardware-config nixos-facter ./modules/facter.json \
    --flake github:EphraimSiegfried/nix-o11y-server#o11y \
    --extra-files "$temp" \
    --target-host root@<ip address>
```

### Remote Deployment

Update your machine remotely with:

```bash
nixos-rebuild --flake .#o11y --target-host <ip address> --sudo --ask-sudo-password switch
```
