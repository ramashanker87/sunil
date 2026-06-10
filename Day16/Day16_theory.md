# Day 16 – 08-Jun-2026 (Monday)
# Module 3 – Containerization & Registry Management

# Theory: Amazon ECS & AWS Fargate Deployment Models

## Learning Objectives

By the end of this session, participants will be able to:

- Understand Amazon ECS architecture.
- Differentiate ECS launch types.
- Understand Fargate deployment models.
- Learn ECS cluster concepts.
- Understand task definitions and services.
- Learn load balancing integration.
- Understand CloudWatch monitoring.
- Prepare applications for container orchestration.

---

# 1. Introduction to Container Orchestration

As applications grow, managing containers manually becomes difficult.

Challenges:
- Scaling containers
- Load balancing
- Monitoring
- High availability
- Automated deployments

Solutions:
- Amazon ECS
- Amazon EKS
- Kubernetes
- Docker Swarm

---

# 2. What is Amazon ECS?

Amazon Elastic Container Service (ECS) is a fully managed container orchestration service.

Benefits:
- Easy deployment
- High availability
- Auto scaling
- Integrated AWS services
- Reduced operational overhead

---

# 3. ECS Architecture

Core Components:

Application
↓
Task Definition
↓
Task
↓
Service
↓
Cluster
↓
Infrastructure

AWS Services:
- ECS
- Fargate
- EC2
- ELB
- CloudWatch
- IAM

---

# 4. ECS Components

## ECS Cluster

Logical grouping of resources.

Responsibilities:
- Host ECS services
- Manage tasks
- Organize workloads

Example:
Production Cluster
Development Cluster

---

## Task Definition

Blueprint for containers.

Contains:
- Container image
- CPU allocation
- Memory allocation
- Port mappings
- Environment variables

Example:

Task Definition:
hello-app-task

Container:
hello-app

Image:
123456789012.dkr.ecr.eu-north-1.amazonaws.com/hello-app:v1

---

## Task

Running instance of a Task Definition.

Similar to:
Docker Container

---

## Service

Maintains desired task count.

Example:

Desired Tasks = 2

If one task fails:
ECS automatically launches replacement.

---

# 5. ECS Launch Types

## EC2 Launch Type

Customer manages:
- EC2 instances
- Scaling
- Patching

Advantages:
- Full control
- Custom AMIs

Disadvantages:
- More administration

---

## Fargate Launch Type

AWS manages:
- Servers
- Infrastructure
- Patching

Advantages:
- Serverless
- Easy management
- Pay per use

Disadvantages:
- Less infrastructure control

---

# 6. AWS Fargate

AWS Fargate is a serverless compute engine for containers.

Supports:
- ECS
- EKS

Benefits:

- No server management
- Automatic scaling
- Enhanced security
- Faster deployments

---

# 7. Fargate Deployment Models

## Public Service Deployment

Architecture:

Internet
↓
Application Load Balancer
↓
Fargate Tasks

Use Cases:
- Web applications
- APIs

---

## Private Service Deployment

Architecture:

Internal Users
↓
Internal Load Balancer
↓
Fargate Tasks

Use Cases:
- Internal applications
- Backend services

---

## Scheduled Tasks

Run containers on schedules.

Examples:
- Backups
- Batch jobs
- Data processing

---

# 8. Load Balancing with ECS

Elastic Load Balancer (ELB)

Types:

### Application Load Balancer (ALB)

Layer 7

Supports:
- HTTP
- HTTPS
- Path routing

Recommended for ECS.

---

### Network Load Balancer (NLB)

Layer 4

Supports:
- TCP
- UDP

High performance workloads.

---

# 9. ECS Networking

Networking Modes:

- awsvpc
- bridge
- host

Fargate requires:

awsvpc

Each task receives:
- Private IP
- Security Group

---

# 10. CloudWatch Integration

CloudWatch provides:

- Metrics
- Logs
- Dashboards
- Alarms

Monitor:

- CPU Utilization
- Memory Utilization
- Task Count
- Request Count

---

# 11. ECS Auto Scaling

Scaling Metrics:

- CPU Usage
- Memory Usage
- Request Count

Benefits:

- Cost optimization
- Improved availability

---

# 12. Security Best Practices

- Use IAM Roles.
- Store secrets in Secrets Manager.
- Use Security Groups.
- Enable CloudWatch monitoring.
- Restrict public access.
- Use private ECR repositories.

---

# 13. ECS Deployment Workflow

Developer
↓
Build Docker Image
↓
Push to Amazon ECR
↓
Create Task Definition
↓
Deploy ECS Service
↓
Expose through ALB
↓
Monitor using CloudWatch

---

# Summary

Topics Covered:

✓ ECS Architecture

✓ ECS Components

✓ Task Definitions

✓ ECS Services

✓ ECS Clusters

✓ Fargate Deployment Models

✓ ELB Integration

✓ CloudWatch Monitoring

✓ ECS Security Best Practices

Next Session:
Docker Compose and Advanced Container Deployments
