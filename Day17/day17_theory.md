# Day 17 – 09-Jun-2026 (Tuesday)
# Module 4 – Kubernetes with Amazon EKS

# Theory: Kubernetes Architecture & Core Concepts

## Learning Objectives

By the end of this session, participants will be able to:

- Understand Kubernetes architecture.
- Identify Kubernetes control plane components.
- Understand worker node responsibilities.
- Learn Kubernetes core objects.
- Understand Pods, Deployments, and Services.
- Learn Kubernetes networking concepts.
- Understand Amazon EKS architecture.
- Prepare applications for Kubernetes deployment.

---

# 1. Introduction to Kubernetes

Kubernetes (K8s) is an open-source container orchestration platform.

It automates:

- Container deployment
- Scaling
- Load balancing
- High availability
- Service discovery
- Self-healing

Originally developed by Google and now maintained by CNCF.

---

# 2. Why Kubernetes?

Challenges with Containers:

- Managing hundreds of containers
- Scaling applications
- Monitoring workloads
- Service communication
- Rolling updates

Kubernetes solves these challenges.

Benefits:

- Automated deployment
- High availability
- Auto scaling
- Self-healing
- Vendor neutrality

---

# 3. Kubernetes Architecture

Architecture consists of:

Control Plane
↓
Worker Nodes
↓
Pods

Components:

- API Server
- etcd
- Scheduler
- Controller Manager
- Worker Nodes
- kubelet
- kube-proxy

---

# 4. Control Plane Components

## API Server

Central management component.

Responsibilities:

- Receives requests
- Validates configurations
- Updates cluster state

Example:

kubectl commands communicate with API Server.

---

## etcd

Distributed key-value database.

Stores:

- Cluster state
- Configurations
- Secrets
- Metadata

Critical component of Kubernetes.

---

## Scheduler

Determines where Pods run.

Decision Factors:

- CPU
- Memory
- Node Availability
- Affinity Rules

---

## Controller Manager

Maintains desired state.

Examples:

- Deployment Controller
- ReplicaSet Controller
- Node Controller

---

# 5. Worker Node Components

## kubelet

Node agent.

Responsibilities:

- Receives instructions
- Starts containers
- Reports status

---

## kube-proxy

Handles networking.

Functions:

- Service routing
- Load balancing
- Traffic forwarding

---

## Container Runtime

Executes containers.

Examples:

- containerd
- CRI-O

---

# 6. Kubernetes Core Concepts

## Pod

Smallest deployable unit.

Contains:

- One or more containers
- Shared networking
- Shared storage

Example:

Application Pod

---

## ReplicaSet

Ensures required Pod count.

Example:

Desired Replicas = 3

If one Pod fails:

Kubernetes automatically recreates it.

---

## Deployment

Manages ReplicaSets and Pods.

Supports:

- Rolling Updates
- Rollbacks
- Scaling

---

## Service

Provides stable network access.

Types:

- ClusterIP
- NodePort
- LoadBalancer

---

# 7. Kubernetes Networking

Every Pod receives:

- Unique IP Address

Communication:

Pod → Pod

Service → Pod

External User → Service

---

# 8. Namespaces

Used for logical isolation.

Examples:

- dev
- test
- prod

Commands:

kubectl get namespaces

---

# 9. ConfigMaps

Store application configuration.

Benefits:

- Decouple configuration from code

---

# 10. Secrets

Store sensitive information.

Examples:

- Passwords
- API Keys
- Tokens

---

# 11. Amazon EKS Overview

Amazon Elastic Kubernetes Service (EKS)

Managed Kubernetes service on AWS.

AWS manages:

- Control Plane
- etcd
- API Server

Customers manage:

- Worker Nodes
- Applications

---

# 12. EKS Architecture

Developer
↓
kubectl
↓
EKS Control Plane
↓
Worker Nodes (EC2)
↓
Pods

AWS Services:

- EKS
- EC2
- IAM
- CloudWatch
- VPC

---

# 13. IAM Integration

IAM provides:

- Authentication
- Authorization

Benefits:

- Secure cluster access
- Role-based access control

---

# 14. Kubernetes Resource Lifecycle

YAML Manifest
↓
kubectl apply
↓
API Server
↓
Scheduler
↓
Worker Node
↓
Pod Running

---

# Summary

Topics Covered:

✓ Kubernetes Architecture

✓ Control Plane Components

✓ Worker Node Components

✓ Pods

✓ ReplicaSets

✓ Deployments

✓ Services

✓ Namespaces

✓ ConfigMaps

✓ Secrets

✓ Amazon EKS Architecture

✓ IAM Integration

Next Session:
Advanced Kubernetes Workloads and Scaling
