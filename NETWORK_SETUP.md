# Xwift Network Setup & Seed Node Deployment

This guide describes how to deploy the Xwift bootstrap infrastructure, replace the temporary placeholder seed nodes, and understand the P2P networking parameters that govern node connectivity. The instructions are written for testnet but the same workflow applies to mainnet once the network is ready.

## 1. Goals & Responsibilities
- Stand up at least **three public seed nodes** that serve as the first point of contact for new peers.
- Document the infrastructure so operators can reproduce deployments in multiple regions/providers.
- Update the hardcoded seed list (`src/p2p/net_node.h`) once live DNS entries or static IP:ports are available.
- Provide fallback discovery mechanisms so that the network remains reachable even if a subset of seeds go offline.

## 2. Infrastructure Provisioning
Provision VPS instances with public IPv4, stable bandwidth, and basic DDoS protection. Recommended baseline (per node): 2 vCPU, 4 GB RAM, 80 GB SSD, Ubuntu 22.04 LTS. Open TCP port **19080** (default P2P) in firewalls/security groups.

### DigitalOcean
1. Create a Droplet (Ubuntu 22.04, Premium Intel/AMD).
2. Select regions close to your target user base (e.g., NYC3, AMS3, SFO3).
3. Enable Monitoring + IPv6 if desired. Assign SSH keys only (disable password login).
4. Add `tcp/19080` and `tcp/18089` (optional RPC) to the DigitalOcean firewall for the droplet.

### AWS
1. Launch a t3.small (or better) EC2 instance running Ubuntu 22.04 in at least two regions.
2. Attach an Elastic IP per node.
3. Security Group rules:
   - Inbound TCP 19080 from `0.0.0.0/0` (P2P)
   - (Optional) Inbound TCP 18089 for RPC, restrict to operator IPs.
4. Disable source/dest checks (if running behind a load balancer) and enable detailed monitoring.

### Hetzner Cloud
1. Create a CPX21 instance (2 vCPU/4 GB) with Ubuntu 22.04.
2. Assign public IPv4, optionally public IPv6.
3. Configure Hetzner Firewall: allow TCP 19080/18089, allow SSH only from admin networks.
4. Enable backups or snapshots for quick recovery.

## 3. Base Operating System Preparation
Run the following on every VPS (as root):

```bash
adduser --disabled-password --gecos "" xwift
usermod -aG sudo xwift
ufw allow 22/tcp
ufw allow 19080/tcp
ufw enable

apt update && apt upgrade -y
apt install -y build-essential cmake pkg-config git libboost-all-dev \
               libssl-dev libunbound-dev libsodium-dev libunwind-dev \
               liblzma-dev libreadline-dev libldns-dev libexpat1-dev \
               libgtest-dev doxygen graphviz
```

Switch to the non-root operator account (`su - xwift`) for the remaining steps.

## 4. Building and Installing the Seed Node Daemon
```bash
mkdir -p ~/src && cd ~/src
git clone https://github.com/xwiftnetwork/xwift.git
cd xwift
make release -j$(nproc)

# Optional: strip binary to reduce size
strip build/release/bin/monerod

sudo install -o root -g root -m 755 build/release/bin/monerod /usr/local/bin/xwiftseed
sudo mkdir -p /var/lib/xwiftseed
sudo chown xwift:xwift /var/lib/xwiftseed
```

### Systemd service
Create `/etc/systemd/system/xwiftseed.service`:

```ini
[Unit]
Description=Xwift Seed Node
after=network.target

[Service]
User=xwift
Group=xwift
ExecStart=/usr/local/bin/xwiftseed \
  --data-dir /var/lib/xwiftseed \
  --p2p-bind-ip 0.0.0.0 \
  --p2p-bind-port 19080 \
  --rpc-bind-ip 127.0.0.1 \
  --rpc-bind-port 18089 \
  --enable-dns-blocklist \
  --restricted-rpc
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now xwiftseed
journalctl -u xwiftseed -f
```

Add monitoring (Prometheus node exporter, system metrics, etc.) and log forwarding as needed.

## 5. DNS & Networking
- Create DNS records (e.g., `seed1.xwift.testnet`, `seed2...`) that point to each VPS public IP.
- Ensure reverse DNS is configured (helps with some relay providers).
- Test connectivity from external hosts using `nc -vz seed1.xwift.testnet 19080`.

## 6. Updating the Hardcoded Seed List
Once the nodes are live:
1. Edit `src/p2p/net_node.h`.
2. Replace the placeholder entries under `m_seed_nodes_list` with the actual FQDNs or static IP:port combinations.
3. Keep the list sorted by priority/region and include at least three entries (recommended five).
4. Build & test: `make release-testnet -j$(nproc)` (or the appropriate target).
5. Submit the change via the regular review process.

> Tip: Keep at least one fallback IP-based entry in case DNS resolution is unavailable for some peers.

## 7. Seed Node Operations Checklist
- Monitor disk usage and prune old log files.
- Keep the OS patched (`unattended-upgrades` or Ansible).
- Use `monerod --log-level 1` (or via systemd) for manageable log sizes.
- Periodically restart during maintenance windows to apply binary updates.

## 8. P2P Configuration Reference
| Parameter | Value | Purpose |
|-----------|-------|---------|
| `P2P_DEFAULT_CONNECTIONS_COUNT` | **16** | Target number of outgoing peers maintained by every node. Higher counts help 30s block propagation and should remain unchanged. |
| `P2P_DEFAULT_HANDSHAKE_INTERVAL` | **30 seconds** | Frequency of handshake refreshes; aligned with the 30s block time. |
| `P2P_DEFAULT_CONNECTION_TIMEOUT` | **5 seconds** | Base timeout for establishing new TCP connections. |
| `P2P_DEFAULT_PING_CONNECTION_TIMEOUT` | **2 seconds** | Timeout for keepalive (ping) packets. |
| `P2P_DEFAULT_SOCKS_CONNECT_TIMEOUT` | **45 seconds** | Timeout when connecting via SOCKS/tor/i2p proxies. |
| `P2P_DEFAULT_INVOKE_TIMEOUT` | **120 seconds** | Upper bound for generic P2P RPC calls. |

These values are defined in `src/cryptonote_config.h` and should only be modified when a protocol-wide change is planned (e.g., new block interval). For 30-second blocks, the current defaults are already optimized.

### Connection Timeout Guidance
- Maintaining short base timeouts (5s/2s) prevents stalled peers from blocking outbound slots.
- Operators can override via CLI (`--p2p-connect-timeout`) but the defaults should work across high-latency regions.

## 9. Peer Discovery & Fallback Mechanisms
1. **Hardcoded seeds** — first-contact nodes defined in `m_seed_nodes_list`.
2. **Peerlist exchange** — each handshake exchanges up to `P2P_DEFAULT_PEERS_IN_HANDSHAKE` entries (250 by default).
3. **Persistent peer storage** — peers are stored under the node data directory and retried on restart.
4. **CLI overrides** — operators can use `--add-priority-node host:port`, `--add-exclusive-node`, or `--seed-node` flags to bootstrap from alternative nodes during maintenance events.
5. **DNS seed nodes** — once operational, consider running DNS-based seeders (similar to Monero) so nodes can resolve dynamic peer lists without code changes.

If every hardcoded seed fails, instruct testers to connect manually:
```bash
monerod --add-priority-node seed1.xwift.testnet:19080
```
This immediately places the seed in the outbound peer set and triggers peerlist syncing.

## 10. Launch Checklist Before Replacing Placeholders
- [ ] At least three public VPS instances deployed across different providers/regions.
- [ ] Seeds online for 48h without interruption.
- [ ] Connectivity verified from multiple ISPs (use VPNs/probes).
- [ ] Monitoring & alerting configured (CPU, disk, port availability).
- [ ] Placeholder entries replaced with live DNS names/IPs and merged to `main`.

Following the above steps ensures that every new Xwift node can reliably bootstrap without depending on Monero infrastructure, closing the CRITICAL #2 and #5 issues.
