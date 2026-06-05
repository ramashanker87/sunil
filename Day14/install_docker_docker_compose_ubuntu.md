# Install Docker and Docker Compose on Ubuntu

## 1. Update the System

```bash
sudo apt update
sudo apt upgrade -y
```

## 2. Install Required Packages

```bash
sudo apt install -y ca-certificates curl gnupg lsb-release
```

## 3. Add Docker's Official GPG Key

```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

## 4. Add Docker Repository

```bash
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg]   https://download.docker.com/linux/ubuntu   $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

## 5. Install Docker Engine

```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## 6. Verify Docker Installation

```bash
docker --version
sudo docker run hello-world
```

## 7. Verify Docker Compose Installation

```bash
docker compose version
```

## 8. (Optional) Run Docker Without sudo

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Verify:

```bash
docker run hello-world
```

## Useful Commands

### Start Docker

```bash
sudo systemctl start docker
```

### Enable Docker at Boot

```bash
sudo systemctl enable docker
```

### Check Docker Status

```bash
sudo systemctl status docker
```

### Stop Docker

```bash
sudo systemctl stop docker
```

## Uninstall Docker

```bash
sudo apt remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
```
