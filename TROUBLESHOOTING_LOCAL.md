# Troubleshooting Guide - Xwift Local Testnet

## Common Issues and Solutions

---

## Startup Issues

### Error: "Docker is not installed"

**Symptoms:**
```
❌ Docker is not installed.
Please install Docker first. See docs/DOCKER_SETUP_GUIDE.md
```

**Solution:**
Follow [`docs/DOCKER_SETUP_GUIDE.md`](DOCKER_SETUP_GUIDE.md) to install Docker and Docker Compose.

---

### Error: "MINER_ADDRESS is not set in .env"

**Symptoms:**
```
❌ MINER_ADDRESS is not set in .env
Please edit .env and set your testnet wallet address.
```

**Solution:**
1. Create a testnet wallet:
```bash
mkdir -p wallet
docker run --rm -it -v $(pwd)/wallet:/wallet local-xwift:testnet \
  xwift-wallet-cli --testnet --generate-new-wallet /wallet/miner-wallet
```

2. Copy the wallet address from output (starts with "X...")

3. Edit `.env`:
```bash
nano .env
# Set: MINER_ADDRESS=X...your_address_here
```

4. Restart: `./start-testnet.sh`

---

### Error: "Port already in use"

**Symptoms:**
```
Error starting userland proxy: listen tcp4 0.0.0.0:29080: bind: address already in use
```

**Solution:**
```bash
# Find processes using the ports
sudo netstat -tulpn | grep 29080

# Kill the conflicting process
sudo kill -9 <PID>

# Or use different ports by editing docker-compose.yml
```

---

## Node Sync Issues

### Nodes not discovering each other

**Symptoms:**
- Outgoing peer count is 0
- Height not increasing

**Diagnosis:**
```bash
./status-testnet.sh
# Check PEERS column
```

**Solution:**
```bash
# Check Docker network
docker network inspect local-testnet_xwift-testnet

# Restart all nodes
./stop-testnet.sh
./start-testnet.sh

# Check logs for connection errors
./logs-testnet.sh seed1
```

---

### Mining node not producing blocks

**Symptoms:**
- Height stuck at 1
- No "Block found!" messages in logs

**Diagnosis:**
```bash
./logs-testnet.sh mining --follow
```

**Solution:**

1. Verify mining is active:
```bash
curl -s http://127.0.0.1:29087/json_rpc \
  -d '{"jsonrpc":"2.0","id":"0","method":"mining_status"}' \
  -H 'Content-Type: application/json' | jq
```

2. Start mining manually if needed:
```bash
# Replace with your wallet address
curl -s http://127.0.0.1:29087/json_rpc \
  -d '{"jsonrpc":"2.0","id":"0","method":"start_mining","params":{"miner_address":"YOUR_ADDRESS","threads_count":4}}' \
  -H 'Content-Type: application/json'
```

---

## Resource Issues

### High CPU usage

**Symptoms:**
- System slow/unresponsive
- CPU at 100%

**Solution:**

Reduce mining threads in `.env`:
```bash
nano .env
# Change: MINING_THREADS=2    # Down from 4
```

Or adjust Docker CPU limits in `docker-compose.yml`:
```yaml
mining-node:
  cpus: "2.0"    # Down from 3.0
```

Then restart: `./stop-testnet.sh && ./start-testnet.sh`

---

### Out of memory

**Symptoms:**
```
Error: Cannot allocate memory
```
- Containers being killed
- OOM (Out of Memory) errors in `dmesg`

**Diagnosis:**
```bash
# Check memory usage
docker stats

# Check system memory
free -h
```

**Solution:**

1. Reduce memory limits in `docker-compose.yml`:
```yaml
mem_limit: 2g       # Down from 3g
mem_reservation: 1.5g   # Down from 2g
```

2. Stop some nodes temporarily:
```bash
docker stop xwift-seed-3    # Stop least critical node
```

3. Reduce mining threads to free memory:
```bash
# In .env
MINING_THREADS=2
```

---

### Disk space full

**Symptoms:**
```
write /home/xwift/.xwift/lmdb/data.mdb: no space left on device
```

**Diagnosis:**
```bash
# Check disk usage
df -h

# Check testnet data size
du -sh local-testnet/data/*
```

**Solution:**

1. **Quick fix**: Prune Docker
```bash
docker system prune -af
# Warning: This removes ALL unused Docker data
```

2. **Reset blockchain** (WARNING: loses all blocks):
```bash
./reset-testnet.sh
```

3. **Mount external storage** for data directories:
```bash
# Stop testnet
./stop-testnet.sh

# Move data to external drive
sudo mv data /mnt/external/xwift-testnet-data

# Create symlink
ln -s /mnt/external/xwift-testnet-data data

# Restart
./start-testnet.sh
```

---

## Network Issues

### Container healthchecks failing

**Symptoms:**
```bash
docker ps
# Shows (unhealthy) status
```

**Diagnosis:**
```bash
docker inspect xwift-seed-1 | grep -A 20 Health
```

**Solution:**

1. Wait 2-3 minutes for initialization

2. Check if RPC is accessible:
```bash
curl -v http://127.0.0.1:29081/get_info
```

3. Inspect logs for errors:
```bash
./logs-testnet.sh seed1
```

4. Restart the specific container:
```bash
docker restart xwift-seed-1
```

---

### Docker network issues

**Symptoms:**
- Containers can't communicate
- No peer connections

**Solution:**

```bash
# Stop testnet
./stop-testnet.sh

# Remove Docker network
docker network rm local-testnet_xwift-testnet

# Prune networks
docker network prune -f

# Restart testnet (will recreate network)
./start-testnet.sh
```

---

## Monitoring Issues

### orphan-rate-tracker-local.sh fails

**Symptoms:**
```
jq: command not found
```

**Solution:**
```bash
sudo apt install -y jq python3 bc curl
```

---

### monitor-nodes.sh shows "OFFLINE"

**Symptoms:**
All nodes show as OFFLINE in dashboard

**Diagnosis:**
```bash
# Check if containers are running
docker ps
```

**Solution:**

If containers are running but showing offline:
```bash
# Test RPC manually
curl http://127.0.0.1:29081/get_info

# If this fails, containers are still starting
# Wait 2-3 minutes and try again
```

---

### emission-validator-local.py fails

**Symptoms:**
```
urllib.error.URLError: Connection refused
```

**Solution:**

1. Ensure mining node is running:
```bash
docker ps | grep xwift-mining
```

2. Test RPC:
```bash
curl http://127.0.0.1:29087/json_rpc \
  -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' \
  -H 'Content-Type: application/json'
```

3. Wait for blockchain to have enough blocks:
```bash
# Need at least 100 blocks for meaningful validation
./status-testnet.sh
```

---

## Performance Issues

### Slow block time (>30 seconds)

**Cause:** Low mining hashrate

**Solution:**

1. Increase mining threads:
```bash
# Edit .env
MINING_THREADS=6    # Up from 4

# Restart
./stop-testnet.sh && ./start-testnet.sh
```

2. Check CPU throttling:
```bash
# Check CPU frequency
lscpu | grep MHz

# Ensure system isn't thermal throttling
sensors    # Install with: sudo apt install lm-sensors
```

---

### High orphan rate (>5%)

**Symptoms:**
orphan-rate-tracker-local.sh shows >5% orphan rate

**Causes:**
- Network latency between containers
- Insufficient CPU resources
- Docker overhead

**Solution:**

1. Increase CPU allocation in `docker-compose.yml`:
```yaml
cpus: "3.0"    # Up from 2.5
```

2. Use faster storage (SSD instead of HDD):
```bash
# Move data to SSD mount
```

3. Reduce mining threads to improve block propagation:
```bash
MINING_THREADS=2    # Slower mining = more time for propagation
```

---

## Docker Issues

### Cannot connect to Docker daemon

**Symptoms:**
```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

**Solution:**
```bash
# Start Docker service
sudo systemctl start docker

# Verify your user is in docker group
groups | grep docker

# Add user to docker group if missing
sudo usermod -aG docker $USER
# Log out and back in
```

---

### Docker build fails

**Symptoms:**
```
Error: failed to solve with frontend dockerfile.v0
```

**Solution:**

1. Clean build cache:
```bash
docker builder prune -af
```

2. Retry build with no cache:
```bash
docker-compose build --no-cache
```

3. Check internet connection (needed for package downloads)

4. Ensure sufficient disk space:
```bash
df -h
# Need at least 20GB free for build
```

---

## Getting Help

If issues persist:

1. **Check logs:**
```bash
./logs-testnet.sh
./logs-testnet.sh mining --follow
```

2. **Inspect containers:**
```bash
docker inspect xwift-seed-1
docker logs xwift-seed-1 --tail=100
```

3. **Check Docker:**
```bash
docker ps -a
docker stats
docker system df
```

4. **System diagnostics:**
```bash
# CPU
htop or top

# Memory
free -h

# Disk
df -h
du -sh local-testnet/data/*

# Network
sudo netstat -tulpn | grep 290
```

5. **Nuclear option (fresh start):**
```bash
./stop-testnet.sh
./reset-testnet.sh
docker system prune -af
./start-testnet.sh
```

---

## Reference

- Main README: [`docs/LOCAL_TESTNET_README.md`](LOCAL_TESTNET_README.md)
- Docker Setup: [`docs/DOCKER_SETUP_GUIDE.md`](DOCKER_SETUP_GUIDE.md)
- VPS Migration: [`docs/UPGRADE_TO_VPS.md`](UPGRADE_TO_VPS.md)
