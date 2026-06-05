# Day 13 — Policy as Code and IaC Security
## Module 2 – Infrastructure as Code (IaC)
### Date: 03-Jun-2026 (Wednesday)

---

# Training Duration

Recommended duration: 4 hours

| Time | Topic |
|---|---|
| 00:00 – 00:30 | Introduction to IaC Security |
| 00:30 – 01:15 | Policy as Code Concepts |
| 01:15 – 02:00 | Terraform and CloudFormation Security |
| 02:00 – 02:45 | Security Scanning Tools |
| 02:45 – 03:30 | Automated IaC Pipelines |
| 03:30 – 04:00 | Security Best Practices and Q&A |

---

# Learning Objectives

By the end of this session, participants will be able to:

- Understand Infrastructure as Code security risks
- Explain Policy as Code concepts
- Identify common Terraform and CloudFormation security issues
- Understand security scanning tools
- Implement secure Infrastructure as Code practices
- Understand automated IaC pipelines
- Integrate security checks into CI/CD pipelines
- Use AWS Security Hub concepts
- Understand IAM security best practices
- Understand secure deployment workflows

---

# 1. Introduction to IaC Security

Infrastructure as Code improves automation and consistency, but insecure IaC can create large-scale security risks.

Common risks include:

- Open security groups
- Public S3 buckets
- Hardcoded secrets
- Excessive IAM permissions
- Unencrypted storage
- Missing logging
- Weak network segmentation

A single insecure template can deploy insecure infrastructure repeatedly.

---

# 2. Why IaC Security Matters

## Fast Deployments

Infrastructure is deployed quickly.

If templates are insecure, vulnerabilities spread rapidly.

---

## Repeatable Risks

IaC makes infrastructure repeatable.

Unfortunately, insecure infrastructure also becomes repeatable.

---

## Compliance Requirements

Organizations must meet standards such as:

- ISO 27001
- SOC 2
- PCI DSS
- HIPAA
- GDPR

Security controls must be embedded in infrastructure code.

---

# 3. Shift Left Security

Shift Left means moving security earlier in the development lifecycle.

Instead of finding problems after deployment:

```text
Developer → Scan → Fix → Deploy
```

Benefits:

- Faster remediation
- Lower cost
- Reduced production risk
- Better compliance

---

# 4. What is Policy as Code?

Policy as Code allows security and compliance rules to be written as code.

Policies automatically validate infrastructure configurations.

Example policies:

- S3 buckets must not be public
- Encryption must be enabled
- IAM roles must follow least privilege
- Logging must be enabled
- Security groups must not allow SSH from everywhere

---

# 5. Benefits of Policy as Code

## Automation

Security checks happen automatically.

## Consistency

Policies are applied uniformly.

## Auditability

Policies are version controlled.

## Scalability

Policies can be enforced across many projects.

---

# 6. Policy as Code Tools

Common tools include:

| Tool | Purpose |
|---|---|
| Open Policy Agent (OPA) | General policy engine |
| Sentinel | HashiCorp policy framework |
| Checkov | IaC security scanning |
| tfsec | Terraform security scanning |
| Terrascan | IaC compliance scanning |
| AWS Config Rules | AWS compliance rules |

---

# 7. Common IaC Security Problems

## Public S3 Buckets

Example insecure configuration:

```hcl
acl = "public-read"
```

---

## Open Security Groups

Dangerous rule:

```text
0.0.0.0/0 on port 22
```

---

## Hardcoded Secrets

Never store:

- Passwords
- Access keys
- Tokens

inside Terraform or CloudFormation files.

Use:

- AWS Secrets Manager
- AWS Systems Manager Parameter Store

---

## Excessive IAM Permissions

Avoid:

```json
"Action": "*"
```

Use least privilege permissions.

---

## Missing Encryption

Resources should use encryption:

- S3 encryption
- EBS encryption
- RDS encryption

---

# 8. IAM Security Best Practices

## Principle of Least Privilege

Grant only required permissions.

---

## Avoid Wildcards

Avoid:

```json
"Resource": "*"
```

unless necessary.

---

## Use Roles Instead of Long-Term Keys

Prefer IAM roles over access keys.

---

## Enable MFA

Enable multi-factor authentication for administrators.

---

# 9. Terraform Security Best Practices

## Use Remote State

Protect state files using:

- S3 backend
- Encryption
- State locking

---

## Avoid Sensitive Values in Code

Use sensitive variables.

Example:

```hcl
variable "db_password" {
  sensitive = true
}
```

---

## Use Version Pinning

Pin provider versions:

```hcl
version = "~> 5.0"
```

---

## Scan Terraform Code

Use tools such as:

- tfsec
- Checkov
- Terrascan

---

# 10. CloudFormation Security Best Practices

## Use IAM Least Privilege

CloudFormation execution roles should be restricted.

---

## Enable Drift Detection

Monitor configuration drift.

---

## Secure S3 Template Storage

Protect template buckets using:

- Encryption
- Access policies
- Versioning

---

## Validate Templates

Use:

```bash
aws cloudformation validate-template
```

before deployment.

---

# 11. Security Scanning Tools

## tfsec

tfsec scans Terraform code for security problems.

Example:

```bash
tfsec .
```

---

## Checkov

Checkov scans Terraform, CloudFormation, Kubernetes, and more.

Example:

```bash
checkov -d .
```

---

## Terrascan

Terrascan detects compliance and security issues.

Example:

```bash
terrascan scan
```

---

# 12. Security Hub

AWS Security Hub centralizes security findings.

Security Hub aggregates findings from:

- GuardDuty
- Inspector
- IAM Access Analyzer
- Macie
- Partner tools

---

# Security Hub Benefits

- Centralized visibility
- Compliance reporting
- Security score
- Continuous monitoring

---

# 13. Automated IaC Pipelines

Infrastructure pipelines automate:

- Validation
- Security scanning
- Testing
- Deployment

Example workflow:

```text
Code Commit
    ↓
Terraform Validate
    ↓
Security Scan
    ↓
Terraform Plan
    ↓
Approval
    ↓
Terraform Apply
```

---

# 14. CI/CD for Infrastructure

CI/CD tools commonly used:

| Tool | Purpose |
|---|---|
| AWS CodePipeline | AWS CI/CD orchestration |
| GitHub Actions | CI/CD automation |
| Jenkins | Automation server |
| GitLab CI | Pipeline automation |

---

# 15. AWS CodePipeline Overview

AWS CodePipeline automates deployment workflows.

Pipeline stages may include:

- Source
- Build
- Test
- Security Scan
- Approval
- Deploy

---

# 16. Example Secure Terraform Pipeline

```text
Git Push
   ↓
CodePipeline Trigger
   ↓
Terraform fmt
   ↓
Terraform validate
   ↓
tfsec / Checkov Scan
   ↓
Terraform plan
   ↓
Manual approval
   ↓
Terraform apply
```

---

# 17. Security Gates in Pipelines

A security gate blocks deployments if security issues are found.

Example conditions:

- Public S3 bucket detected
- Unencrypted resources detected
- Critical vulnerability detected

---

# 18. Manual Approvals

Sensitive deployments should require manual approval.

Examples:

- Production deployments
- IAM permission changes
- Network changes

---

# 19. Secure Secrets Management

Never store secrets in:

- Terraform code
- Git repositories
- CloudFormation templates

Use:

- AWS Secrets Manager
- AWS Systems Manager Parameter Store

---

# 20. Infrastructure Compliance

Infrastructure compliance can be automated using:

- Policy as Code
- Security scanning
- AWS Config Rules
- Security Hub
- CI/CD gates

---

# 21. Logging and Auditing

Enable logging for infrastructure operations.

Examples:

- CloudTrail
- S3 access logging
- VPC Flow Logs
- CloudWatch Logs

---

# 22. Incident Prevention

Secure IaC helps prevent:

- Public exposure
- Privilege escalation
- Data leaks
- Compliance violations

---

# 23. Best Practices Summary

## Shift Security Left

Scan infrastructure before deployment.

## Use Policy as Code

Automate compliance rules.

## Scan Every Commit

Integrate scanning into pipelines.

## Use Least Privilege

Restrict IAM permissions.

## Protect State Files

Encrypt and secure Terraform state.

## Enable Logging

Monitor infrastructure activity.

---

# 24. Day 13 Summary

Participants learned:

- IaC security concepts
- Policy as Code
- Terraform and CloudFormation security
- Security scanning tools
- Secure CI/CD pipelines
- Security Hub concepts
- IAM security practices

---

# Review Questions

1. What is Policy as Code?
2. Why is IaC security important?
3. What is Shift Left security?
4. What tools can scan Terraform code?
5. Why should SSH not be open to the internet?
6. What is Security Hub used for?
7. Why are manual approvals important?
8. Why should secrets never be hardcoded?
