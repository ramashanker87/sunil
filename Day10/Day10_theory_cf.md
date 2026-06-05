
# Day 10 — Infrastructure as Code (IaC)
## Module 2 – Advanced CloudFormation
### Date: 29-May-2026 (Friday)

# 4-Hour Training Plan

| Time | Topic |
|---|---|
| 09:00 – 10:00 | Advanced CloudFormation |
| 10:00 – 11:00 | Nested Stacks |
| 11:00 – 12:00 | StackSets |
| 12:00 – 13:00 | Architecture Discussion & Review |

---

# Learning Objectives

Participants will learn:

- Advanced CloudFormation concepts
- Modular Infrastructure as Code design
- Nested Stacks architecture
- StackSets deployment model
- Multi-environment provisioning concepts
- CloudFormation best practices

---

# Advanced CloudFormation

## What is CloudFormation?

AWS CloudFormation is an Infrastructure as Code (IaC) service that enables infrastructure provisioning using YAML or JSON templates.

Benefits:
- Automation
- Consistency
- Scalability
- Repeatability
- Version control

---

# CloudFormation Template Structure

```yaml
AWSTemplateFormatVersion: '2010-09-09'

Description: Sample Template

Parameters:
  EnvironmentName:
    Type: String

Resources:
  MyBucket:
    Type: AWS::S3::Bucket

Outputs:
  BucketName:
    Value: !Ref MyBucket
```

---

# CloudFormation Components

| Component | Purpose |
|---|---|
| Parameters | User inputs |
| Resources | Infrastructure resources |
| Outputs | Exported values |
| Conditions | Conditional deployment |
| Mappings | Static lookup values |

---

# Intrinsic Functions

| Function | Purpose |
|---|---|
| !Ref | Reference values |
| !Sub | Variable substitution |
| !Join | Concatenate strings |
| !GetAtt | Retrieve resource attributes |

---

# Change Sets

Change Sets allow previewing infrastructure changes before deployment.

Benefits:
- Safer deployments
- Better visibility
- Reduced risk

---

# Drift Detection

Drift occurs when resources are manually modified outside CloudFormation.

Drift detection helps:
- Maintain governance
- Identify inconsistencies
- Improve compliance

---

# Nested Stacks

## What are Nested Stacks?

Nested Stacks divide large templates into smaller reusable templates.

Example:
- Network Stack
- Security Stack
- Compute Stack
- Database Stack

---

# Benefits of Nested Stacks

- Reusability
- Scalability
- Easier troubleshooting
- Team collaboration

---

# Nested Stack Architecture

```text
Root Stack
│
├── Network Stack
├── Security Stack
├── Application Stack
└── Database Stack
```

---

# Parent Stack Example

```yaml
Resources:
  NetworkStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://s3.amazonaws.com/templates/network.yaml
```

---

# StackSets

## What are StackSets?

StackSets allow deploying CloudFormation stacks across:
- Multiple AWS accounts
- Multiple AWS regions

from a centralized administration account.

---

# StackSet Use Cases

- Enterprise governance
- Security baseline deployment
- Organization-wide logging
- Compliance enforcement

---

# StackSet Components

| Component | Description |
|---|---|
| StackSet | Central template |
| Stack Instance | Regional deployment |
| Admin Account | Controls deployment |
| Target Account | Receives deployment |

---

# Multi-Environment Provisioning Concepts

Environment Types:
- Development
- Testing
- Staging
- Production

---

# Environment Isolation

Each environment should have:
- Separate stacks
- Separate IAM permissions
- Separate parameters
- Separate naming conventions

---

# Best Practices

- Use modular templates
- Use parameters
- Store templates in S3
- Use Git version control
- Enable drift detection
- Use StackSets carefully

---

# Summary

This training covered:
- Advanced CloudFormation
- Nested Stacks
- StackSets
- Multi-environment provisioning concepts

