# Day 20 – 12-Jun-2026 (Friday)
# Module 4 – Kubernetes with Amazon EKS

# Theory: Helm Charts & Kubernetes Scaling Strategies

## Learning Objectives

By the end of this session, participants will be able to:

- Understand Helm architecture and components.
- Learn Helm chart structure.
- Deploy applications using Helm.
- Manage Helm releases.
- Understand Kubernetes scaling concepts.
- Learn Horizontal Pod Autoscaler (HPA).
- Understand Cluster Autoscaler.
- Implement scaling strategies in Amazon EKS.

---

# 1. Introduction to Helm

Helm is the package manager for Kubernetes.

Similar To:

- apt for Ubuntu
- yum for RHEL
- npm for Node.js

Benefits:

- Simplified deployments
- Reusable templates
- Version control
- Easy upgrades and rollbacks

---

# 2. Why Helm?

Without Helm:

- Large YAML files
- Manual updates
- Configuration duplication

With Helm:

- Parameterized deployments
- Centralized management
- Reusable charts

---

# 3. Helm Architecture

Components:

Helm CLI
↓
Kubernetes API Server
↓
Cluster Resources

Key Concepts:

- Chart
- Release
- Repository
- Values File

---

# 4. Helm Chart Structure

Example:

mychart/
├── Chart.yaml
├── values.yaml
├── charts/
└── templates/

Files:

### Chart.yaml

Metadata file.

Contains:

- Name
- Version
- Description

---

### values.yaml

Default configuration values.

Example:

replicaCount: 2

image:
  repository: nginx

---

### templates/

Contains Kubernetes manifests.

Examples:

- deployment.yaml
- service.yaml
- ingress.yaml

---

# 5. Helm Lifecycle Commands

Install:

```bash
helm install myapp ./chart
```

Upgrade:

```bash
helm upgrade myapp ./chart
```

Rollback:

```bash
helm rollback myapp 1
```

Uninstall:

```bash
helm uninstall myapp
```

---

# 6. Helm Repositories

Public Repositories:

- Bitnami
- Artifact Hub

Example:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```

---

# 7. Kubernetes Scaling Concepts

Scaling ensures:

- High availability
- Performance
- Cost optimization

Types:

- Horizontal Scaling
- Vertical Scaling
- Cluster Scaling

---

# 8. Horizontal Scaling

Add more Pods.

Example:

2 Pods → 5 Pods

Managed by:

Horizontal Pod Autoscaler (HPA)

---

# 9. Vertical Scaling

Increase resources.

Example:

CPU:

500m → 1000m

Memory:

512Mi → 1Gi

---

# 10. Horizontal Pod Autoscaler (HPA)

Automatically adjusts Pod count.

Metrics:

- CPU Utilization
- Memory Utilization
- Custom Metrics

Example:

Target CPU:

70%

---

# 11. Metrics Server

Required for HPA.

Provides:

- CPU Metrics
- Memory Metrics

Commands:

```bash
kubectl top pods
kubectl top nodes
```

---

# 12. Cluster Autoscaler

Scales worker nodes.

Functions:

- Add Nodes
- Remove Nodes

Benefits:

- Cost savings
- Automatic scaling

---

# 13. Scaling Architecture

User Traffic
↓
Ingress
↓
Pods
↓
HPA
↓
Cluster Autoscaler
↓
Worker Nodes

---

# 14. Amazon EKS Scaling

Components:

- HPA
- Cluster Autoscaler
- Managed Node Groups

Benefits:

- Elastic infrastructure
- Automated capacity management

---

# 15. Helm Best Practices

- Use values.yaml
- Store charts in Git
- Use semantic versioning
- Validate templates
- Use separate environments

---

# 16. Scaling Best Practices

- Define resource requests.
- Define resource limits.
- Monitor utilization.
- Avoid overprovisioning.
- Test autoscaling regularly.

---

# Summary

Topics Covered:

✓ Helm Architecture

✓ Helm Charts

✓ Helm Repositories

✓ Helm Releases

✓ Horizontal Scaling

✓ Vertical Scaling

✓ HPA

✓ Metrics Server

✓ Cluster Autoscaler

✓ Amazon EKS Scaling

Next Session:
Kubernetes Monitoring and Observability
