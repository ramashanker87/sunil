# Day 23 – 17-Jun-2026 (Wednesday)
# Module 6 & 7 – DevSecOps, Monitoring & Observability

# Theory: Security Automation, Monitoring & Logging

## Learning Objectives

By the end of this session, participants will be able to:

- Understand security automation concepts.
- Learn AWS-native security services.
- Understand continuous security monitoring.
- Learn security event management.
- Understand observability principles.
- Learn monitoring and logging architecture.
- Implement CloudWatch dashboards.
- Improve operational visibility and compliance.

---

# 1. Introduction to Security Automation

Security Automation uses tools and processes to automatically:

- Detect threats
- Respond to incidents
- Enforce policies
- Reduce manual effort

Benefits:

- Faster detection
- Reduced risk
- Improved compliance
- Consistent security controls

---

# 2. Why Security Automation?

Traditional Challenges:

- Manual reviews
- Delayed responses
- Human errors
- Large attack surface

Automation Benefits:

- Continuous monitoring
- Faster remediation
- Scalable security operations

---

# 3. DevSecOps and Automation

DevSecOps integrates security into:

- Development
- CI/CD
- Deployment
- Operations

Workflow:

Code
↓
Build
↓
Security Scan
↓
Deploy
↓
Monitor

---

# 4. Security Automation Lifecycle

Identify
↓
Monitor
↓
Detect
↓
Respond
↓
Recover
↓
Improve

---

# 5. Amazon GuardDuty Overview

GuardDuty is AWS's intelligent threat detection service.

Features:

- Threat detection
- Continuous monitoring
- Machine learning analysis

Monitors:

- AWS Accounts
- EKS Clusters
- EC2 Instances
- IAM Activity

---

# 6. GuardDuty Findings

Examples:

- Unauthorized Access
- Suspicious API Calls
- Credential Compromise
- Crypto Mining Activity

Severity Levels:

- Low
- Medium
- High

---

# 7. Amazon Security Hub

Security Hub provides:

- Centralized security management
- Compliance reporting
- Security findings aggregation

Integrates With:

- GuardDuty
- Inspector
- IAM Access Analyzer
- Third-party tools

---

# 8. Security Hub Architecture

Security Services
↓
Security Hub
↓
Central Dashboard
↓
Security Team

Benefits:

- Unified visibility
- Compliance tracking
- Prioritized findings

---

# 9. Security Standards

Security Hub supports:

- AWS Foundational Security Best Practices
- CIS AWS Foundations Benchmark
- PCI DSS

---

# 10. Introduction to Monitoring

Monitoring helps organizations:

- Detect issues
- Improve performance
- Maintain availability

Key Areas:

- Infrastructure
- Applications
- Security
- User Experience

---

# 11. Observability Pillars

Three Pillars:

### Metrics

Examples:

- CPU
- Memory
- Network

---

### Logs

Examples:

- Application Logs
- System Logs
- Audit Logs

---

### Traces

Examples:

- Request Flow
- Service Dependencies

---

# 12. Amazon CloudWatch

CloudWatch provides:

- Metrics
- Logs
- Dashboards
- Alarms

Monitors:

- EC2
- EKS
- Lambda
- Applications

---

# 13. CloudWatch Metrics

Examples:

- CPU Utilization
- Memory Usage
- Request Count
- Error Rate

---

# 14. CloudWatch Logs

Centralized logging service.

Sources:

- EKS
- EC2
- Containers
- Applications

Benefits:

- Searchable logs
- Retention policies
- Auditing

---

# 15. CloudWatch Dashboards

Dashboards provide:

- Visual monitoring
- Operational insights
- Executive reporting

Widgets:

- Graphs
- Numbers
- Tables

---

# 16. CloudWatch Alarms

Trigger actions when thresholds exceed limits.

Examples:

CPU > 80%

Memory > 75%

Error Rate > 5%

---

# 17. Monitoring Kubernetes

Monitor:

- Nodes
- Pods
- Services
- Deployments

Tools:

- CloudWatch Container Insights
- Prometheus
- Grafana

---

# 18. Security Monitoring Best Practices

- Enable GuardDuty.
- Enable Security Hub.
- Centralize logs.
- Create dashboards.
- Configure alerts.
- Review findings regularly.

---

# 19. Logging Best Practices

- Use structured logs.
- Retain logs appropriately.
- Encrypt logs.
- Monitor critical events.
- Automate alerting.

---

# Summary

Topics Covered:

✓ Security Automation

✓ DevSecOps Monitoring

✓ Amazon GuardDuty

✓ Amazon Security Hub

✓ CloudWatch Metrics

✓ CloudWatch Logs

✓ Dashboards

✓ Alarms

✓ Security Monitoring

✓ Observability Principles

Next Session:
Advanced Compliance, Governance and Security Operations
