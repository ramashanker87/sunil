# Day 21 – 15-Jun-2026 (Monday)
# Module 5 – GitOps & Advanced Deployment

# Theory: GitOps Principles & ArgoCD Architecture

## Learning Objectives

By the end of this session, participants will be able to:

- Understand GitOps principles and workflows.
- Learn GitOps architecture and benefits.
- Understand ArgoCD components and architecture.
- Learn declarative deployment methodologies.
- Understand Continuous Delivery using GitOps.
- Integrate ArgoCD with Amazon EKS.
- Implement automated deployment strategies.

---

# 1. Introduction to GitOps

GitOps is an operational framework that uses Git as the single source of truth for infrastructure and application deployments.

Core Idea:

Git Repository
↓
Desired State
↓
Automation Tool
↓
Kubernetes Cluster

---

# 2. Why GitOps?

Traditional Deployment Challenges:

- Manual deployments
- Configuration drift
- Limited auditability
- Human errors

GitOps Benefits:

- Declarative deployments
- Version control
- Audit trails
- Automated recovery
- Consistent environments

---

# 3. GitOps Principles

### Declarative Configuration

Infrastructure and applications are defined using code.

Examples:

- YAML
- Helm Charts
- Kustomize

---

### Version Controlled

All changes are stored in Git.

Benefits:

- Rollback capability
- Change tracking
- Collaboration

---

### Automated Deployment

Changes pushed to Git automatically deploy to clusters.

---

### Continuous Reconciliation

GitOps tools continuously compare:

Desired State
vs
Actual State

Drift is automatically corrected.

---

# 4. GitOps Workflow

Developer
↓
Git Commit
↓
Git Repository
↓
ArgoCD
↓
EKS Cluster

Workflow:

1. Developer updates YAML.
2. Commit pushed to Git.
3. ArgoCD detects changes.
4. ArgoCD synchronizes cluster.
5. Application updated.

---

# 5. GitOps Benefits

- Faster deployments
- Improved reliability
- Easier auditing
- Better security
- Simplified disaster recovery

---

# 6. What is ArgoCD?

ArgoCD is a declarative GitOps Continuous Delivery tool for Kubernetes.

Functions:

- Application deployment
- Synchronization
- Rollback
- Drift detection

---

# 7. ArgoCD Architecture

Components:

ArgoCD API Server
↓
Repository Server
↓
Application Controller
↓
Redis
↓
Kubernetes Cluster

---

# 8. ArgoCD Components

## API Server

Provides:

- UI
- CLI access
- API endpoints

---

## Repository Server

Responsibilities:

- Git access
- Manifest generation
- Repository synchronization

---

## Application Controller

Responsibilities:

- State comparison
- Synchronization
- Health monitoring

---

## Redis

Stores:

- Application state
- Session data

---

# 9. ArgoCD Application Model

Application

Contains:

- Git Repository
- Target Cluster
- Namespace
- Sync Policy

Example:

Git Repository:
github.com/company/app-config

Namespace:
production

---

# 10. Sync Strategies

### Manual Sync

Administrator initiates deployment.

---

### Automatic Sync

Changes deployed automatically.

Benefits:

- Fully automated GitOps

---

# 11. Drift Detection

ArgoCD continuously compares:

Git State
vs
Cluster State

If drift occurs:

ArgoCD flags or corrects drift.

---

# 12. ArgoCD Rollback

Rollback Methods:

- Git Revert
- Application History Rollback

Benefits:

- Rapid recovery
- Controlled releases

---

# 13. ArgoCD with Amazon EKS

Architecture:

Git Repository
↓
ArgoCD
↓
Amazon EKS
↓
Applications

AWS Services:

- EKS
- IAM
- ECR
- Route53

---

# 14. Security Best Practices

- Use IAM Roles.
- Restrict ArgoCD access.
- Use RBAC.
- Store secrets securely.
- Enable audit logging.
- Use private repositories.

---

# 15. GitOps Best Practices

- Keep manifests small.
- Use Git branches properly.
- Separate environments.
- Use automated validation.
- Review pull requests.

---

# Summary

Topics Covered:

✓ GitOps Principles

✓ Declarative Deployments

✓ Continuous Reconciliation

✓ ArgoCD Architecture

✓ ArgoCD Components

✓ Sync Strategies

✓ Drift Detection

✓ Rollback Strategies

✓ ArgoCD on EKS

✓ GitOps Best Practices

Next Session:
Advanced GitOps Workflows and Multi-Cluster Management
