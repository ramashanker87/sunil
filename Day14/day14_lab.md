# Day 14 – Module 3: Containerization & Registry Management
## Lab: Docker Installation and Container Management

## Lab Objectives

After completing this lab, participants will be able to:
- Install Docker Engine
- Verify Docker services
- Run and manage containers
- Pull Docker images
- Monitor container status
- Work with container logs
- Stop, restart, and remove containers

---

# Lab 1: Verify System Information

```bash
uname -a
cat /etc/os-release
```

Record:
- Hostname
- Ubuntu Version
- Kernel Version

---

# Lab 2: Update System

```bash
sudo apt update
sudo apt upgrade -y
```

Verify:

```bash
sudo apt update
```

---

# Lab 3: Install Required Packages

```bash
sudo apt install -y ca-certificates curl gnupg lsb-release
```

---

# Lab 4: Add Docker GPG Key

```bash
sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

Verify:

```bash
ls -l /etc/apt/keyrings/docker.gpg
```

---

# Lab 5: Configure Docker Repository

```bash
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Update Repository:

```bash
sudo apt update
```

---

# Lab 6: Install Docker

```bash
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

---

# Lab 7: Verify Installation

Check Docker Version:

```bash
docker --version
```

Check Service:

```bash
sudo systemctl status docker
```

Check Compose:

```bash
docker compose version
```

---

# Lab 8: Run First Container

```bash
sudo docker run hello-world
```

Expected Result:
- Docker downloads image.
- Container runs successfully.
- Success message displayed.

---

# Lab 9: Pull Docker Images

Pull Ubuntu:

```bash
docker pull ubuntu
```

Pull Nginx:

```bash
docker pull nginx
```

List Images:

```bash
docker images
```

---

# Lab 10: Create and Run Containers

Run Ubuntu Container:

```bash
docker run -it ubuntu bash
```

Inside Container:

```bash
ls
pwd
cat /etc/os-release
```

Exit:

```bash
exit
```

---

# Lab 11: Run Nginx Web Server

```bash
docker run -d --name webserver -p 8080:80 nginx
```

Verify:

```bash
docker ps
```

Browser Test:

```text
http://localhost:8080
```

---

# Lab 12: View Running Containers

```bash
docker ps
```

View All Containers:

```bash
docker ps -a
```

---

# Lab 13: Inspect Container Details

```bash
docker inspect webserver
```

Capture:
- Container ID
- IP Address
- Mounts
- Network Configuration

---

# Lab 14: View Container Logs

```bash
docker logs webserver
```

Follow Logs:

```bash
docker logs -f webserver
```

---

# Lab 15: Execute Commands Inside Container

```bash
docker exec -it webserver bash
```

Run:

```bash
hostname
pwd
ls
```

Exit:

```bash
exit
```

---

# Lab 16: Stop and Start Containers

Stop:

```bash
docker stop webserver
```

Verify:

```bash
docker ps -a
```

Start:

```bash
docker start webserver
```

Restart:

```bash
docker restart webserver
```

---

# Lab 17: Pause and Unpause

Pause:

```bash
docker pause webserver
```

Verify:

```bash
docker ps
```

Resume:

```bash
docker unpause webserver
```

---

# Lab 18: Resource Monitoring

```bash
docker stats
```

Observe:
- CPU Usage
- Memory Usage
- Network Usage

Press Ctrl+C to exit.

---

# Lab 19: Remove Containers

Stop Container:

```bash
docker stop webserver
```

Remove:

```bash
docker rm webserver
```

Verify:

```bash
docker ps -a
```

---

# Lab 20: Remove Images

List Images:

```bash
docker images
```

Remove:

```bash
docker rmi nginx
```

---

# Challenge Exercise

1. Pull Ubuntu image.
2. Launch container.
3. Create a file inside container.
4. Exit container.
5. Restart container.
6. Verify file exists.
7. Remove container.

Document:
- Commands used
- Screenshots
- Observations

---

# Lab Deliverables

Participants must submit:

- Docker installation screenshots
- Docker version output
- Container creation screenshots
- Running container output
- Container logs output
- Challenge exercise results

---

# Expected Learning Outcome

Participants should be able to:

✓ Install Docker

✓ Verify Docker services

✓ Pull images

✓ Run containers

✓ Manage container lifecycle

✓ Monitor containers

✓ Remove containers and images
