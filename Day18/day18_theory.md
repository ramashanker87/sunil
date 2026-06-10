# Day 18 – 10-Jun-2026 (Wednesday)
# Module 4 – Kubernetes with Amazon EKS

# Theory: EKS Setup & Cluster Management

## Learning Objectives

By the end of this session, participants will be able to:

- Understand Amazon EKS setup requirements.
- Learn EKS cluster architecture.
- Understand VPC networking for EKS.
- Configure IAM roles and permissions.
- Learn EKS cluster management concepts.
- Understand node groups and scaling.
- Manage Kubernetes clusters using AWS services.
- Automate EKS provisioning using CloudFormation.

---

# 1. Introduction to Amazon EKS

Amazon Elastic Kubernetes Service (EKS) is a managed Kubernetes service.

AWS manages:

- Kubernetes Control Plane
- API Server
- etcd
- Scheduler
- Controller Manager

Customers manage:

- Worker Nodes
- Applications
- Networking Policies

Benefits:

- High Availability
- Scalability
- Security
- Managed Control Plane

---

# 2. EKS Architecture

Developer
↓
kubectl
↓
EKS Control Plane
↓
Worker Nodes
↓
Pods

AWS Services:

- EKS
- EC2
- IAM
- VPC
- CloudFormation
- CloudWatch

---

# 3. EKS Prerequisites

Before creating an EKS cluster:

Required Components:

- AWS Account
- IAM Permissions
- VPC
- Subnets
- Security Groups
- kubectl
- AWS CLI

---

# 4. VPC Requirements for EKS

Amazon EKS requires:

- VPC
- Multiple Availability Zones
- Public Subnets
- Private Subnets

Recommended Architecture:

VPC
├── Public Subnet AZ-A
├── Public Subnet AZ-B
├── Private Subnet AZ-A
└── Private Subnet AZ-B

Benefits:

- High Availability
- Fault Tolerance

---

# 5. IAM Roles in EKS

## Cluster Role

Permissions required by EKS Control Plane.

Example Policies:

- AmazonEKSClusterPolicy

---

## Node Role

Permissions required by Worker Nodes.

Example Policies:

- AmazonEKSWorkerNodePolicy
- AmazonEC2ContainerRegistryReadOnly
- AmazonEKS_CNI_Policy

---

# 6. Node Groups

Node Groups provide:

- Worker Node Management
- Scaling
- Updates

Types:

### Managed Node Groups

AWS manages:

- Provisioning
- Updates
- Health Monitoring

### Self-Managed Nodes

Customer manages EC2 instances.

---

# 7. EKS Cluster Lifecycle

Plan
↓
Provision
↓
Configure
↓
Deploy Workloads
↓
Monitor
↓
Scale
↓
Upgrade
↓
Retire

---

# 8. Cluster Networking

Networking Components:

- VPC
- Subnets
- Route Tables
- NAT Gateway
- Security Groups

Each Pod receives:

- Unique IP Address

Using AWS VPC CNI Plugin.

---

# 9. Security Groups

Security Groups control:

- API Access
- Worker Node Access
- Application Traffic

Best Practices:

- Least Privilege
- Restrict Public Access
- Separate Application Security Groups

---

# 10. EKS Authentication

Authentication Methods:

- IAM Users
- IAM Roles
- IAM Identity Center

Authorization:

- Kubernetes RBAC

---

# 11. Cluster Management Tasks

Common Administrative Tasks:

- Node Monitoring
- Cluster Upgrades
- Scaling Node Groups
- Backup Strategies
- Security Auditing

Useful Commands:

```bash
kubectl get nodes
kubectl get pods -A
kubectl top nodes
```

---

# 12. CloudFormation for EKS

Benefits:

- Infrastructure as Code
- Repeatable Deployments
- Version Control
- Automation

Resources Created:

- VPC
- IAM Roles
- EKS Cluster
- Node Groups

---

# 13. Monitoring and Logging

AWS Services:

- CloudWatch Logs
- CloudWatch Metrics
- Container Insights

Monitor:

- CPU Usage
- Memory Usage
- Node Health
- Cluster Events

---

# 14. Scaling EKS Clusters

Methods:

### Manual Scaling

Adjust Node Count

### Auto Scaling

Cluster Autoscaler

Benefits:

- Cost Optimization
- High Availability

---

# Summary

Topics Covered:

✓ EKS Architecture

✓ VPC Networking

✓ IAM Roles

✓ Node Groups

✓ Cluster Lifecycle

✓ Security Groups

✓ Authentication

✓ CloudFormation Automation

✓ Monitoring and Logging

✓ Cluster Scaling

Next Session:
Advanced Kubernetes Networking and Ingress Controllers
