# Day 14 – Module 3: Containerization & Registry Management
## Theory: Docker Architecture and Container Lifecycle

## Learning Objectives
By the end of this session, participants will be able to:
- Understand containerization concepts.
- Explain Docker architecture and components.
- Differentiate between containers and virtual machines.
- Understand Docker images, containers, registries, and volumes.
- Describe the complete container lifecycle.
- Prepare for hands-on Docker administration tasks.

---

# 1. Introduction to Containerization

## What is Containerization?
Containerization is a lightweight virtualization technology that packages an application and its dependencies into a standardized unit called a container.

### Benefits
- Portability
- Consistency across environments
- Faster deployment
- Efficient resource utilization
- Scalability
- Simplified DevOps workflows

## Containers vs Virtual Machines

| Feature | Containers | Virtual Machines |
|----------|------------|-----------------|
| OS Kernel | Shared | Separate |
| Startup Time | Seconds | Minutes |
| Resource Usage | Low | High |
| Isolation | Process Level | Hardware Level |
| Portability | High | Moderate |

---

# 2. Docker Overview

Docker is an open-source platform used to develop, package, ship, and run applications inside containers.

### Key Components
- Docker Engine
- Docker Client
- Docker Daemon
- Docker Images
- Docker Containers
- Docker Registry
- Docker Networks
- Docker Volumes

---

# 3. Docker Architecture

## Docker Client

The Docker Client is the command-line interface (CLI) used by users.

Example:

```bash
docker run nginx
```

The client communicates with Docker Daemon through REST APIs.

---

## Docker Daemon (dockerd)

Responsibilities:
- Builds images
- Runs containers
- Manages networks
- Manages storage
- Pulls images from registries

---

## Docker Host

The machine where Docker Engine is installed.

Components:
- Docker Daemon
- Images
- Containers
- Networks
- Volumes

---

## Docker Registry

Stores Docker images.

Examples:
- Docker Hub
- AWS ECR
- Azure Container Registry
- Google Artifact Registry
- Harbor
- Nexus Repository

Common Commands:

```bash
docker pull ubuntu
docker push myrepo/app:v1
```

---

## Docker Images

A Docker image is a read-only template used to create containers.

Characteristics:
- Immutable
- Layered architecture
- Version controlled using tags

Example:

```bash
nginx:latest
ubuntu:24.04
mysql:8.0
```

---

## Docker Containers

A running instance of a Docker image.

Container Features:
- Lightweight
- Isolated
- Portable
- Disposable

Example:

```bash
docker run nginx
```

---

# 4. Docker Architecture Workflow

User → Docker Client → Docker Daemon → Registry → Container

Workflow:

1. User executes Docker command.
2. Docker Client sends request.
3. Docker Daemon processes request.
4. Image is downloaded if unavailable.
5. Container is created.
6. Application starts.

---

# 5. Docker Storage Components

## Volumes

Persistent storage for containers.

Benefits:
- Data persistence
- Backup support
- Sharing data among containers

Example:

```bash
docker volume create app-data
```

---

## Bind Mounts

Maps host directories into containers.

Example:

```bash
docker run -v /host/data:/container/data nginx
```

---

# 6. Docker Networking Basics

Network Types:

### Bridge Network
Default network for standalone containers.

### Host Network
Container uses host networking stack.

### Overlay Network
Used in Docker Swarm.

### None Network
No networking.

---

# 7. Container Lifecycle

## Stage 1: Image Creation

```bash
docker build -t myapp:v1 .
```

---

## Stage 2: Image Storage

```bash
docker push myapp:v1
```

Stored in registry.

---

## Stage 3: Container Creation

```bash
docker create nginx
```

Container exists but is not running.

---

## Stage 4: Container Start

```bash
docker start container_id
```

State becomes Running.

---

## Stage 5: Container Running

Container executes application workload.

Monitoring:

```bash
docker ps
docker stats
```

---

## Stage 6: Pause and Resume

Pause:

```bash
docker pause container_id
```

Resume:

```bash
docker unpause container_id
```

---

## Stage 7: Stop Container

```bash
docker stop container_id
```

Graceful shutdown.

---

## Stage 8: Restart Container

```bash
docker restart container_id
```

---

## Stage 9: Remove Container

```bash
docker rm container_id
```

---

## Stage 10: Remove Image

```bash
docker rmi image_name
```

---

# 8. Container States

| State | Description |
|---------|-------------|
| Created | Container created |
| Running | Active |
| Paused | Temporarily suspended |
| Restarting | Restart in progress |
| Exited | Stopped |
| Dead | Failed state |

---

# 9. Best Practices

- Use official images.
- Keep images small.
- Use specific image tags.
- Remove unused containers.
- Regularly update images.
- Store secrets securely.
- Use volumes for persistent data.
- Scan images for vulnerabilities.

---

# Summary

In this session we learned:
- Fundamentals of containerization
- Docker architecture
- Docker components
- Docker image workflow
- Container lifecycle
- Storage and networking basics
- Container management concepts

Next Session:
Dockerfile Creation, Image Building, and Registry Operations.
