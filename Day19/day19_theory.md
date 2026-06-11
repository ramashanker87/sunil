# Day 19 – 11-Jun-2026 (Thursday)
# Module 4 – Kubernetes with Amazon EKS

# Theory: Kubernetes Storage, Networking & Security

## Learning Objectives

By the end of this session, participants will be able to:

- Understand Kubernetes persistent storage concepts.
- Learn Amazon EBS and Amazon EFS integration with EKS.
- Understand Kubernetes networking architecture.
- Learn Ingress and service routing concepts.
- Understand Route53 integration with Kubernetes.
- Learn Kubernetes security best practices.
- Secure workloads running on Amazon EKS.

---

# 1. Kubernetes Storage Overview

Containers are ephemeral by default.

Problem:

When a Pod is deleted:
- Container data is lost.

Solution:

Persistent Storage

Benefits:

- Data persistence
- Shared storage
- Stateful applications
- Backup support

---

# 2. Kubernetes Storage Components

## Volume

Storage attached to Pods.

Examples:

- emptyDir
- hostPath
- Persistent Volumes

---

## Persistent Volume (PV)

Cluster storage resource.

Managed by:

- Administrator
- Cloud Provider

Characteristics:

- Independent lifecycle
- Reusable storage

---

## Persistent Volume Claim (PVC)

Request for storage.

Example:

Application requests:

10 GB Storage

Kubernetes binds PVC to PV.

---

# 3. Storage Classes

Storage Classes automate volume provisioning.

Benefits:

- Dynamic provisioning
- Standardized storage

Example:

gp3 Storage Class

---

# 4. Amazon EBS with EKS

Amazon Elastic Block Store (EBS)

Features:

- Block Storage
- High Performance
- Persistent Data

Use Cases:

- Databases
- Stateful Applications

Supported Modes:

ReadWriteOnce (RWO)

---

# 5. EBS CSI Driver

Container Storage Interface Driver.

Responsibilities:

- Dynamic volume creation
- Attach volumes
- Delete volumes

Architecture:

Pod
↓
PVC
↓
StorageClass
↓
EBS CSI Driver
↓
EBS Volume

---

# 6. Amazon EFS with EKS

Amazon Elastic File System (EFS)

Features:

- Shared File System
- Multi-AZ
- Highly Available

Use Cases:

- Shared Content
- Web Applications
- CMS Platforms

Supported Modes:

ReadWriteMany (RWX)

---

# 7. EFS CSI Driver

Allows Kubernetes Pods to mount EFS.

Benefits:

- Shared storage
- Dynamic provisioning
- Simplified management

---

# 8. Kubernetes Networking

Every Pod receives:

- Unique IP Address

Networking Components:

- Pods
- Services
- Ingress
- DNS

---

# 9. Kubernetes Service Types

## ClusterIP

Internal communication only.

---

## NodePort

Exposes application through node ports.

---

## LoadBalancer

Creates cloud load balancer.

AWS Integration:

Elastic Load Balancer

---

# 10. Ingress

Ingress provides:

- HTTP Routing
- HTTPS Routing
- Path-based Routing
- Host-based Routing

Benefits:

- Centralized access
- Reduced load balancers
- SSL termination

---

# 11. Ingress Controller

Ingress resources require controller.

Examples:

- AWS Load Balancer Controller
- NGINX Ingress Controller

Recommended:

AWS Load Balancer Controller

---

# 12. Route53 Integration

Amazon Route53 provides DNS management.

Workflow:

Route53
↓
Application Load Balancer
↓
Ingress
↓
Service
↓
Pods

Benefits:

- Friendly DNS Names
- Automated Routing

---

# 13. Kubernetes Security Overview

Security Layers:

- IAM
- RBAC
- Network Policies
- Secrets
- Security Groups

---

# 14. IAM Roles for Service Accounts (IRSA)

Provides AWS permissions directly to Pods.

Benefits:

- Least Privilege
- Improved Security

---

# 15. RBAC

Role-Based Access Control

Components:

- Roles
- ClusterRoles
- RoleBindings
- ClusterRoleBindings

---

# 16. Kubernetes Secrets

Store:

- Passwords
- Tokens
- Certificates

Best Practice:

Avoid hardcoded credentials.

---

# 17. Network Policies

Control Pod-to-Pod communication.

Benefits:

- Traffic isolation
- Security segmentation

---

# 18. Security Best Practices

- Enable IAM integration.
- Use IRSA.
- Use RBAC.
- Encrypt data at rest.
- Scan container images.
- Use private ECR repositories.
- Implement network policies.
- Rotate credentials regularly.

---

# Summary

Topics Covered:

✓ Persistent Volumes

✓ Persistent Volume Claims

✓ Storage Classes

✓ Amazon EBS

✓ Amazon EFS

✓ Kubernetes Networking

✓ Services

✓ Ingress

✓ Route53 Integration

✓ Kubernetes Security

✓ RBAC

✓ IRSA

✓ Network Policies

Next Session:
Advanced Kubernetes Monitoring and Observability
