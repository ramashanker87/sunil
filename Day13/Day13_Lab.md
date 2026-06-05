# Day 13 Lab Guide — IaC Security and Automated Pipelines
## Module 2 – Infrastructure as Code (IaC)
### Date: 03-Jun-2026 (Wednesday)

---

# Lab Duration

Recommended duration: 4 hours

| Time | Lab Activity |
|---|---|
| 00:00 – 00:30 | Environment setup |
| 00:30 – 01:15 | Install security scanning tools |
| 01:15 – 02:00 | Scan insecure Terraform code |
| 02:00 – 02:45 | Fix IaC security issues |
| 02:45 – 03:30 | Build automated IaC pipeline |
| 03:30 – 04:00 | Security Hub review and cleanup |

---

# Lab Objectives

By the end of this lab, participants will be able to:

- Install IaC security scanning tools
- Scan Terraform code using tfsec and Checkov
- Identify common security issues
- Fix insecure Terraform configurations
- Build a secure automated IaC pipeline
- Understand Security Hub findings
- Apply IAM security best practices

---

# AWS Resources Used

- Security Hub
- CodePipeline
- IAM
- S3
- Terraform CLI

---

# Prerequisites

Participants should have:

- AWS account access
- Terraform CLI installed
- AWS CLI configured
- Git installed
- IAM permissions

Verify Terraform:

```bash
terraform version
```

Verify AWS CLI:

```bash
aws --version
```

Verify identity:

```bash
aws sts get-caller-identity
```

---

# Part 1 — Create Lab Directory

---

# Step 1 — Create Working Directory

```bash
mkdir terraform-security-lab
cd terraform-security-lab
```

---

# Step 2 — Initialize Git Repository

```bash
git init
```

---

# Part 2 — Create Insecure Terraform Configuration

---

# Step 1 — Create provider.tf

Create file:

```text
provider.tf
```

Add:

```hcl
provider "aws" {
  region = "us-east-1"
  profile ="devops"
}
```

---

# Step 2 — Create insecure main.tf

Create file:

```text
main.tf
```

Add:

```hcl
resource "aws_s3_bucket" "insecure_bucket" {
  bucket = "yourname-insecure-demo-bucket-20260603"

  tags = {
    Name = "InsecureBucket"
  }
}

resource "aws_security_group" "insecure_sg" {
  name        = "insecure-sg"
  description = "Open SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

This intentionally contains security issues.

---

# Part 3 — Install Security Scanning Tools

---

# Option 1 — Install tfsec

## macOS

```bash
brew install tfsec
```

## Linux

```bash
curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
```

Verify:

```bash
tfsec --version
```

---

# Option 2 — Install Checkov

Install using pip:

```bash
pip install checkov
```

Verify:

```bash
checkov --version
```

---

# Part 4 — Scan Terraform Code

---

# Step 1 — Run tfsec

```bash
tfsec .
```

Expected findings:
- Open security group
- Missing encryption
- Missing bucket protections

---

# Step 2 — Run Checkov

```bash
checkov -d .
```

Review findings carefully.

---

# Step 3 — Review Security Issues

Common findings:

| Issue | Risk |
|---|---|
| Open SSH access | Unauthorized access |
| Missing S3 encryption | Data exposure |
| Missing public access block | Public exposure |

---

# Part 5 — Fix Security Issues

---

# Step 1 — Secure the S3 Bucket

Update S3 configuration:

```hcl
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "yourname-secure-demo-bucket-20260603"

  tags = {
    Name = "SecureBucket"
  }
}

resource "aws_s3_bucket_versioning" "secure_bucket_versioning" {
  bucket = aws_s3_bucket.secure_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "secure_bucket_encryption" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "secure_bucket_public_block" {
  bucket = aws_s3_bucket.secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

---

# Step 2 — Secure the Security Group

Update ingress rules:

```hcl
resource "aws_security_group" "secure_sg" {
  name        = "secure-sg"
  description = "Restricted SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_PUBLIC_IP/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

Replace:

```text
YOUR_PUBLIC_IP/32
```

with your own public IP.

---

# Step 3 — Run Security Scans Again

Run:

```bash
tfsec .
```

and:

```bash
checkov -d .
```

Verify that findings are reduced or resolved.

---

# Part 6 — Terraform Validation Workflow

---

# Step 1 — Format Terraform Files

```bash
terraform fmt
```

---

# Step 2 — Validate Configuration

```bash
terraform validate
```

---

# Step 3 — Generate Terraform Plan

```bash
terraform plan
```

---

# Part 7 — Simulate Automated IaC Pipeline 

---

# Pipeline Stages

Example pipeline:

```text
Code Commit Push
   ↓
Terraform fmt
   ↓
Terraform validate
   ↓
tfsec scan
   ↓
Terraform plan
   ↓
Terraform apply
```

---

# Step 1 — Create Pipeline Script

Create file:

```text
pipeline.sh
```

Add:

```bash
#!/bin/bash

echo "Formatting Terraform files..."
terraform fmt -recursive

echo "Validating Terraform..."
terraform validate

echo "Running tfsec..."
tfsec .

echo "Initialize Terraform..."
terraform init

echo "Generating Terraform plan..."
terraform plan
```

---

# Step 2 — Make Script Executable

```bash
chmod +x pipeline.sh
```

---

# Step 3 — Run Pipeline Script

```bash
./pipeline.sh
```

Review pipeline results.

---

# Part 8 — Deploy Secure Terraform Resources

---

# Step 1 — Initialize Terraform

```bash
terraform init
```

---

# Step 2 — Apply Configuration

```bash
terraform apply
```

Type:

```text
yes
```

---

# Step 3 — Verify Resources

Check S3 buckets:

```bash
aws s3 ls --profile devops
```

Check security groups:

```bash
aws ec2 describe-security-groups --profile devops
```

---

# Part 9 — AWS Security Hub Overview

---

# Step 1 — Open Security Hub

Navigate to:

```text
AWS Console → Security Hub
```

---

# Step 2 — Enable Security Hub

If not enabled:
- Enable Security Hub
- Enable default standards

---

# Step 3 — Review Findings

Review findings from:
- IAM
- S3
- EC2
- Security Groups

---

# Step 4 — Review Security Score

Security Hub provides:
- Security score
- Compliance findings
- Recommendations

---

# Part 10 — IAM Security Best Practices

---

# Avoid Wildcard Permissions

Avoid:

```json
"Action": "*"
```

---

# Use Least Privilege

Grant only required permissions.

---

# Rotate Credentials

Regularly rotate:
- Access keys
- Secrets

---

# Use MFA

Enable MFA for administrators.

---

# Part 11 — Optional AWS CodePipeline Discussion

---

# Example Pipeline Architecture

```text
GitHub
   ↓
CodePipeline
   ↓
CodeBuild
   ↓
Terraform Validate
   ↓
tfsec Scan
   ↓
Checkov Scan
   ↓
Terraform Plan
   ↓
Manual Approval
   ↓
Terraform Apply
```

---

# Example buildspec.yml  :assignment

```yaml
version: 0.2

phases:
  install:
    commands:
      - terraform --version

  build:
    commands:
      - terraform init
      - terraform fmt -check
      - terraform validate
      - tfsec .
      - checkov -d .
      - terraform plan
```

---

# Part 12 — Cleanup

---

# Step 1 — Destroy Terraform Resources

```bash
terraform destroy
```

Type:

```text
yes
```

---

# Step 2 — Verify Cleanup

Check S3:

```bash
aws s3 ls
```

Check Security Groups:

```bash
aws ec2 describe-security-groups
```

---

# Troubleshooting Guide

| Problem | Possible Cause | Solution |
|---|---|---|
| tfsec command not found | tfsec not installed | Install tfsec |
| checkov command not found | Checkov not installed | Install Checkov |
| BucketAlreadyExists | Bucket name not unique | Use unique bucket name |
| AccessDenied | Missing IAM permissions | Update IAM policies |
| Terraform validation failed | Invalid syntax | Check Terraform files |
| Security findings still appear | Configuration incomplete | Review findings carefully |

---

# Review Questions

1. What is Policy as Code?
2. Why should Terraform code be scanned?
3. What does tfsec detect?
4. Why is open SSH access dangerous?
5. What is Security Hub used for?
6. Why are manual approvals important?
7. Why should S3 buckets be encrypted?
8. What is Shift Left security?

---

# Expected Outcomes

After completing this lab, participants will have:

- Installed IaC scanning tools
- Scanned insecure Terraform code
- Fixed security vulnerabilities
- Created secure Terraform resources
- Simulated an automated IaC pipeline
- Reviewed Security Hub findings
- Applied secure IAM practices

---

# End of Lab

Congratulations! You have completed Day 13 IaC Security and Automated Pipeline Labs.
