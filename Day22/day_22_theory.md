# Day 22 – 16-Jun-2026 (Tuesday)
# Module 5 & 6 – GitOps, Progressive Delivery & DevSecOps

# Theory: Flux CD, Progressive Delivery & DevSecOps Fundamentals

## Learning Objectives

By the end of this session, participants will be able to:

- Explain GitOps and how Flux CD implements it.
- Understand Flux CD architecture and core controllers.
- Compare Flux CD and Argo CD.
- Explain Progressive Delivery strategies.
- Understand Canary and Blue-Green deployments.
- Describe DevSecOps principles and benefits.
- Explain Kubernetes secrets management.
- Understand AWS Secrets Manager and AWS KMS integration.
- Apply security best practices in Amazon EKS.

---

# 1. What is GitOps?

GitOps is an operational model where Git becomes the single source of truth for infrastructure and application deployments.

Instead of manually deploying applications:

```text
Developer → kubectl apply → Kubernetes
```

We use GitOps:

```text
Developer
    ↓
Git Repository
    ↓
Flux CD
    ↓
Amazon EKS
```

Benefits:

- Version control for infrastructure
- Automated deployments
- Easy rollback
- Audit trail of all changes
- Reduced manual errors

---

# 2. What is Flux CD?

Flux CD is a Kubernetes-native GitOps Continuous Delivery tool.

It continuously monitors a Git repository and ensures that the Kubernetes cluster matches the desired state stored in Git.

Think of Flux as an automated operator that constantly asks:

> "Does the cluster match what is defined in Git?"

If not, Flux automatically corrects the cluster.

---

# 3. Why Do Organizations Use Flux CD?

Traditional deployments often involve:

- Manual kubectl commands
- Human errors
- Configuration drift
- Lack of visibility

Flux solves these problems by:

- Automating deployments
- Continuously reconciling changes
- Maintaining consistency
- Providing auditability through Git history

Key Benefits:

- Git-driven deployments
- Lightweight architecture
- Kubernetes-native design
- Automatic drift correction
- Easy integration with Helm and Kustomize

---

# 4. Flux CD Architecture

Flux consists of multiple controllers that work together.

```text
Git Repository
      |
      v
Source Controller
      |
      v
Kustomize Controller
      |
      v
Kubernetes Cluster
```

Additional controllers support Helm deployments, notifications, and image automation.

---

# 5. Source Controller

The Source Controller is responsible for:

- Connecting to Git repositories
- Downloading manifests
- Detecting changes
- Providing source artifacts to other controllers

Supported Sources:

- GitHub
- GitLab
- Bitbucket
- AWS CodeCommit
- OCI Repositories

Think of it as the "Git watcher" inside Flux.

---

# 6. Kustomize Controller

The Kustomize Controller:

- Reads Kubernetes manifests
- Applies configurations
- Reconciles cluster state
- Detects drift

Example:

Git defines:

```yaml
replicas: 3
```

If someone manually changes it to:

```yaml
replicas: 1
```

Flux detects the drift and restores it back to:

```yaml
replicas: 3
```

---

# 7. Helm Controller

Many Kubernetes applications are deployed using Helm charts.

The Helm Controller:

- Installs Helm charts
- Upgrades releases
- Rolls back failed releases
- Maintains desired chart versions

Examples:

- NGINX Ingress
- Prometheus
- Grafana
- Argo CD

---

# 8. Flux CD Workflow

A typical GitOps workflow looks like this:

```text
Developer
    ↓
Git Commit
    ↓
Git Repository
    ↓
Flux CD
    ↓
Amazon EKS
    ↓
Application Running
```

Process:

1. Developer updates YAML files.
2. Changes are committed to Git.
3. Flux detects the change.
4. Flux applies changes to EKS.
5. Cluster state matches Git.

---

# 9. Flux CD vs Argo CD

Both Flux CD and Argo CD are CNCF GitOps tools.

| Feature | Flux CD | Argo CD |
|----------|----------|----------|
| GitOps Support | Yes | Yes |
| Helm Support | Yes | Yes |
| Kubernetes Native | Strong | Strong |
| Web UI | Limited | Rich UI |
| Resource Usage | Lightweight | Higher |
| Learning Curve | Moderate | Easy |
| Enterprise Adoption | High | Very High |

General Guidance:

Choose Flux CD when:

- You prefer lightweight Kubernetes-native controllers.
- You want minimal operational overhead.

Choose Argo CD when:

- You need a rich graphical UI.
- Developers require self-service deployments.

---

# 10. What is Progressive Delivery?

Progressive Delivery is a deployment strategy that reduces deployment risk by gradually releasing changes.

Instead of exposing a new version to all users immediately, traffic is shifted gradually.

Benefits:

- Reduced deployment risk
- Faster issue detection
- Controlled rollout process
- Improved customer experience

---

# 11. Canary Deployments

A Canary deployment releases a new version to a small percentage of users first.

Example:

```text
Version 1 = 90%
Version 2 = 10%
```

After monitoring:

```text
Version 1 = 50%
Version 2 = 50%
```

Eventually:

```text
Version 2 = 100%
```

Advantages:

- Early detection of issues
- Reduced blast radius
- Safer production releases

Tools:

- Flagger
- Argo Rollouts
- Service Meshes

---

# 12. Blue-Green Deployments

Blue-Green deployment uses two identical environments.

```text
Blue  = Current Production
Green = New Version
```

Deployment Process:

1. Deploy new version to Green.
2. Test Green environment.
3. Switch traffic from Blue to Green.
4. Keep Blue available for rollback.

Benefits:

- Near-zero downtime
- Fast rollback
- Reduced deployment risk

---

# 13. Feature Flags

Feature Flags allow teams to enable or disable features without redeploying applications.

Example:

```text
Feature Enabled = True
Feature Enabled = False
```

Benefits:

- Safer releases
- A/B testing
- Faster experimentation

---

# 14. What is DevSecOps?

DevSecOps stands for:

```text
Development + Security + Operations
```

The goal is to integrate security throughout the software lifecycle rather than treating it as a final step.

Traditional Model:

```text
Develop → Deploy → Secure
```

DevSecOps Model:

```text
Develop → Secure → Deploy
```

---

# 15. DevSecOps Principles

### Shift Security Left

Security checks happen earlier in development.

Benefits:

- Faster vulnerability detection
- Lower remediation costs
- Improved compliance

### Automation

Security controls should be automated whenever possible.

Examples:

- Image scanning
- Secret scanning
- Vulnerability scanning
- Policy validation

### Continuous Monitoring

Security is continuously monitored after deployment.

---

# 16. Kubernetes Security Considerations

Areas that require protection:

- Container images
- Secrets
- Network traffic
- User access
- Cluster configuration

Security Risks:

- Hardcoded passwords
- Excessive privileges
- Untrusted images
- Open network access

---

# 17. Secrets Management

Sensitive information should never be stored directly in Git.

Examples:

- Passwords
- API Keys
- Tokens
- Certificates

Bad Example:

```yaml
password: MyPassword123
```

Recommended Options:

- Kubernetes Secrets
- AWS Secrets Manager

---

# 18. AWS Secrets Manager

AWS Secrets Manager provides centralized secret storage.

Features:

- Encryption
- Rotation
- Access control
- Auditing

Common Use Cases:

- Database passwords
- API tokens
- Application credentials

Benefits:

- No secrets stored in Git
- Centralized management
- Enhanced security

---

# 19. AWS KMS (Key Management Service)

AWS KMS manages encryption keys.

Purpose:

- Protect sensitive data
- Encrypt secrets
- Meet compliance requirements

AWS Services Using KMS:

- Secrets Manager
- EBS
- EFS
- S3
- RDS

Relationship:

```text
KMS Key
    ↓
Secrets Manager
    ↓
Application Secrets
```

---

# 20. Amazon EKS Security Best Practices

Recommended Controls:

### Use IAM Roles for Service Accounts (IRSA)

Provides secure AWS access without storing credentials.

### Enable KMS Encryption

Protect Kubernetes secrets at rest.

### Use Private ECR Repositories

Store container images securely.

### Implement RBAC

Control user permissions.

### Rotate Credentials

Regularly update secrets and access keys.

### Enable Logging and Auditing

Monitor cluster activity and security events.

---

# 21. Secure GitOps Workflow

A secure deployment pipeline looks like this:

```text
Developer
    ↓
Git Repository
    ↓
Flux CD
    ↓
AWS Secrets Manager
    ↓
Amazon EKS
    ↓
Application
```

Advantages:

- Automated deployments
- Secure secret management
- Auditability
- Drift detection
- Consistent environments

---

# Real-World Example

Developer updates application version:

```text
v1 → v2
```

Process:

1. Code committed to Git.
2. Flux detects change.
3. New image deployed.
4. Secrets retrieved securely.
5. Application updated.
6. Health checks validated.
7. Traffic shifted gradually using Canary deployment.

Result:

- Secure deployment
- Reduced downtime
- Faster rollback if issues occur

---

# Summary

Topics Covered:

✓ GitOps Fundamentals

✓ Flux CD Architecture

✓ Source Controller

✓ Kustomize Controller

✓ Helm Controller

✓ Flux CD Workflow

✓ Flux CD vs Argo CD

✓ Progressive Delivery

✓ Canary Deployments

✓ Blue-Green Deployments

✓ Feature Flags

✓ DevSecOps Principles

✓ AWS Secrets Manager

✓ AWS KMS

✓ Kubernetes Security

✓ Amazon EKS Best Practices

✓ Secure GitOps Workflows

---

# Key Takeaways

- Git is the source of truth in GitOps.
- Flux continuously reconciles Kubernetes state with Git.
- Progressive Delivery reduces deployment risk.
- DevSecOps integrates security into every phase.
- Secrets should never be stored in Git repositories.
- AWS Secrets Manager and KMS provide secure secret management.
- Secure GitOps improves automation, compliance, and operational reliability.

---

# Next Session

Advanced DevSecOps, Policy Enforcement, Security Monitoring, GuardDuty, Security Hub, and CloudWatch.
