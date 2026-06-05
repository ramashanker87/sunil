# Day 09 – DevOps Theory
# Infrastructure as Code (IaC) & CloudFormation Basics

## Module 2 – Infrastructure as Code (IaC)
### Date: 28-May-2026 (Thursday)

---

# Learning Objectives

In this session you will learn:

- What is Infrastructure as Code (IaC)
- Benefits of IaC
- CloudFormation basics
- CloudFormation templates
- AWS resource automation
- Real-world DevOps infrastructure management

---

# What is Infrastructure as Code (IaC)?

Infrastructure as Code means:

```text
Managing infrastructure using code instead of manual configuration.
```

Instead of manually creating servers, networks, and services:

```text
Infrastructure is created automatically using templates.
```

---

# Traditional Infrastructure Management

Old method:

```text
Login → Create Server → Configure Manually
```

Problems:

- Time consuming
- Human errors
- Inconsistent environments
- Difficult to scale

---

# Infrastructure as Code Approach

IaC method:

```text
Write Template → Execute → Infrastructure Created Automatically
```

Benefits:

- Faster deployment
- Consistent environments
- Easy automation
- Version control support
- Repeatable infrastructure

---

# Benefits of IaC

| Benefit | Description |
|---|---|
| Automation | Infrastructure created automatically |
| Consistency | Same setup every time |
| Scalability | Easy to scale environments |
| Faster Deployment | Infrastructure in minutes |
| Version Control | Templates stored in Git |
| Reduced Errors | Less manual mistakes |

---

# What is AWS CloudFormation?

CloudFormation is:

```text
AWS service used to automate infrastructure deployment.
```

Using CloudFormation templates, AWS resources can be created automatically.

---

# CloudFormation Features

| Feature | Purpose |
|---|---|
| Template-Based | Infrastructure defined as code |
| Automated Deployment | Creates resources automatically |
| Stack Management | Manages grouped resources |
| Dependency Handling | Creates resources in correct order |
| Rollback Support | Automatically rolls back failures |

---

# What is a CloudFormation Template?

A template is:

```text
A YAML or JSON file describing AWS infrastructure.
```

Example resources:

- EC2
- VPC
- Security Groups
- S3
- IAM Roles

---

# CloudFormation Workflow

```text
Template File
      ↓
CloudFormation Stack
      ↓
AWS Resources Created
```

---

# CloudFormation Stack

A Stack is:

```text
A collection of AWS resources managed together.
```

Example:

```text
One stack can create:
- VPC
- EC2
- Security Group
- IAM Role
```

---

# YAML vs JSON Templates

CloudFormation supports:

- YAML
- JSON

YAML is easier to read.

Example:

```yaml
Resources:
  MyEC2:
    Type: AWS::EC2::Instance
```

---

# Common CloudFormation Sections

| Section | Purpose |
|---|---|
| AWSTemplateFormatVersion | Template version |
| Description | Template description |
| Resources | AWS resources |
| Outputs | Display output values |

---

# Example EC2 Template

```yaml
Resources:
  MyEC2:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: t2.micro
```

---

# What is a VPC?

VPC means:

```text
Virtual Private Cloud
```

It is a private network inside AWS.

---

# Why VPC is Important

VPC provides:

- Network isolation
- Security
- Custom IP ranges
- Public and private subnets
- Routing control

---

# CloudFormation Supported Resources

CloudFormation can create:

- EC2
- VPC
- S3
- IAM
- Lambda
- RDS
- Load Balancers

---

# Real-World DevOps Usage

DevOps teams use IaC for:

- Environment provisioning
- CI/CD automation
- Disaster recovery
- Infrastructure standardization
- Multi-environment deployments

---

# CloudFormation Advantages

- AWS native service
- Free service
- Easy automation
- Git integration
- Infrastructure versioning

---

# CloudFormation Rollback

If deployment fails:

```text
CloudFormation automatically removes failed resources.
```

This helps maintain clean environments.

---

# Best Practices

- Store templates in Git
- Use reusable templates
- Use parameters
- Enable rollback
- Use least privilege IAM

---

# Summary

In this session you learned:

- Infrastructure as Code concepts
- Benefits of IaC
- CloudFormation basics
- CloudFormation templates
- AWS infrastructure automation
- EC2 and VPC automation
