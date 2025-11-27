# Docker Setup Guide for Xwift Local Testnet

## Prerequisites

This guide assumes you're running **Ubuntu 20.04+** or a similar Debian-based Linux distribution.

---

## Step 1: Install Docker

### Option A: Automated Installation (Recommended)

```bash
# Download and run Docker's official installation script
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to the docker group (avoid using sudo for docker commands)
sudo usermod -aG docker $USER

# Log out and log back in for the group change to take effect
# Or run: newgrp docker
```

### Option B: Manual Installation

```bash
# Update package index
sudo apt update

# Install dependencies
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Add your user to docker group
sudo usermod -aG docker $USER
```

### Verify Installation

```bash
# Check Docker version
docker --version

# Test Docker without sudo
docker run hello-world
```

Expected output:
```
Hello from Docker!
This message shows that your installation appears to be working correctly.
...
```

---

## Step 2: Install Docker Compose

### Option A: Using apt (Ubuntu 20.04+)

```bash
sudo apt update
sudo apt install -y docker-compose-plugin

# Verify installation
docker compose version
```

### Option B: Manual Installation

```bash
# Download the latest version
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make it executable
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker-compose --version
```

---

## Step 3: Configure Docker (Optional but Recommended)

### Increase Docker Storage

If you have limited space on `/var/lib/docker`, move Docker's data directory:

```bash
# Stop Docker
sudo systemctl stop docker

# Edit Docker daemon config
sudo nano /etc/docker/daemon.json
```

Add:
```json
{
  "data-root": "/path/to/larger/disk/docker"
}
```

```bash
# Move existing data
sudo rsync -aP /var/lib/docker/ /path/to/larger/disk/docker/

# Restart Docker
sudo systemctl start docker
```

### Limit Docker Log Size

```bash
# Edit daemon config
sudo nano /etc/docker/daemon.json
```

Add:
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

```bash
# Restart Docker
sudo systemctl restart docker
```

---

## Step 4: Test Docker with Xwift

### Build the Xwift testnet image

```bash
cd /path/to/xwift/local-testnet

# Build the Docker image (takes 10-20 minutes)
docker build -f ../Dockerfile.testnet -t local-xwift:testnet ..

# Verify image was created
docker images | grep local-xwift
```

Expected output:
```
local-xwift   testnet   <image_id>   <created>   <size>
```

### Run a test container

```bash
# Start a temporary container
docker run --rm local-xwift:testnet --version

# Expected output: Xwift 'Fluorine Fermi' (v0.18.x.x-release)
```

---

## Step 5: Network Setup

Docker creates a bridge network automatically, but verify it's working:

```bash
# List Docker networks
docker network ls

# Inspect bridge network
docker network inspect bridge
```

---

## Troubleshooting

### Permission Denied

If you get "permission denied" errors:

```bash
# Verify user is in docker group
groups | grep docker

# If not listed, add user:
sudo usermod -aG docker $USER

# Log out and log back in
```

### Docker Service Not Running

```bash
# Check Docker status
sudo systemctl status docker

# Start Docker if stopped
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker
```

### Out of Disk Space

```bash
# Clean up unused images and containers
docker system prune -af

# Remove specific stopped containers
docker rm $(docker ps -aq)

# Remove dangling images
docker rmi $(docker images -f "dangling=true" -q)
```

### Build Failures

If the Docker build fails:

```bash
# Clean build cache
docker builder prune -af

# Retry with more build context
docker build --no-cache -f ../Dockerfile.testnet -t local-xwift:testnet ..
```

### Container Networking Issues

```bash
# Restart Docker networking
sudo systemctl restart docker

# Recreate networks
docker network prune -f
```

---

## Next Steps

Once Docker is installed and verified:

1. Return to [`LOCAL_TESTNET_README.md`](LOCAL_TESTNET_README.md)
2. Create testnet wallet
3. Configure `.env` file
4. Start testnet with `./start-testnet.sh`

---

## Additional Resources

- Docker Documentation: https://docs.docker.com/
- Docker Compose: https://docs.docker.com/compose/
- Ubuntu Docker Guide: https://docs.docker.com/engine/install/ubuntu/
