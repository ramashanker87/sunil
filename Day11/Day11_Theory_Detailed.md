# Day 11 — Terraform Fundamentals and Architecture
## Module 2 – Infrastructure as Code (IaC)
### Date: 01-June-2026 (Monday)

---

# Training Duration

Recommended duration: 4 hours


---

# Learning Objectives

By the end of this session, participants will be able to:

- Understand Terraform fundamentals
- Explain Terraform architecture
- Install and configure Terraform CLI
- Understand the Terraform workflow
- Write basic Terraform configuration files
- Use Terraform providers and resources
- Work with variables and outputs
- Understand Terraform state management
- Provision AWS resources using Terraform
- Follow Terraform best practices

---

# 1. Introduction to Infrastructure as Code

Infrastructure as Code, or IaC, is the practice of managing infrastructure through code instead of manual console operations.

With IaC, teams can define infrastructure such as:

- Virtual machines
- Networks
- Security groups
- IAM roles
- Storage buckets
- Load balancers

using configuration files.

---

# Why Infrastructure as Code?

## Automation

Infrastructure can be created automatically without manual steps.

## Repeatability

The same configuration can be deployed multiple times.

## Consistency

Reduces human error and environment mismatch.

## Version Control

Infrastructure code can be stored in Git.

## Collaboration

Teams can review infrastructure changes using pull requests.

## Auditability

Changes can be tracked over time.

---

# 2. What is Terraform?

Terraform is an open-source Infrastructure as Code tool created by HashiCorp.

Terraform allows users to:

- Define infrastructure using configuration files
- Provision infrastructure across cloud providers
- Manage infrastructure lifecycle
- Track infrastructure state
- Automate cloud deployments

Terraform supports many platforms, including:

- AWS
- Microsoft Azure
- Google Cloud
- Kubernetes
- VMware
- GitHub
- Datadog

---

# 3. Terraform Language

Terraform uses HashiCorp Configuration Language, known as HCL.

HCL is designed to be:

- Human-readable
- Declarative
- Easy to understand
- Suitable for infrastructure definitions

Example:

```hcl
resource "aws_s3_bucket" "demo" {
  bucket = "my-demo-terraform-bucket"
}
```

This configuration tells Terraform what infrastructure should exist.

---

# 4. Terraform Architecture

Terraform architecture has four major parts:

1. Terraform CLI
2. Terraform Core
3. Providers
4. State file

---

# Terraform CLI

Terraform CLI is the command-line tool used by engineers.

Common commands include:

```bash
terraform init
terraform validate
terraform plan
terraform apply
terraform destroy
```

---

# Terraform Core

Terraform Core is responsible for:

- Reading configuration files
- Building dependency graphs
- Comparing desired state with current state
- Creating execution plans
- Managing resource lifecycle

---

# Terraform Providers

Providers are plugins that allow Terraform to communicate with platforms.

For AWS, Terraform uses the AWS provider.

Example:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

The provider allows Terraform to create AWS resources such as:

- EC2 instances
- VPCs
- S3 buckets
- IAM roles
- Security groups

---

# Terraform State

Terraform stores resource information in a state file.

Default state file:

```text
terraform.tfstate
```

Terraform state helps Terraform understand:

- What resources it manages
- Resource IDs
- Dependencies
- Current infrastructure configuration

---

# 5. Terraform Workflow

Terraform follows a standard workflow:

```text
Write → Init → Validate → Plan → Apply → Manage → Destroy
```

---

# Step 1 — Write

Create Terraform configuration files.

Common files:

```text
main.tf
provider.tf
variables.tf
outputs.tf
terraform.tfvars
```

---

# Step 2 — Init

Initialize the Terraform project.

```bash
terraform init
```

This downloads required provider plugins.

---

# Step 3 — Validate

Validate configuration syntax.

```bash
terraform validate
```

---

# Step 4 — Plan

Preview changes before applying.

```bash
terraform plan
```

Terraform shows what it will create, update, or delete.

---

# Step 5 — Apply

Create infrastructure.

```bash
terraform apply
```

---

# Step 6 — Destroy

Delete infrastructure.

```bash
terraform destroy
```

---

# 6. Terraform Files

## provider.tf

Defines cloud provider configuration.

```hcl
provider "aws" {
  region = "us-east-1"
}
```

---

## main.tf

Defines infrastructure resources.

```hcl
resource "aws_instance" "web" {
  ami           = "ami-1234567890abcdef0"
  instance_type = "t2.micro"
}
```

---

## variables.tf

Defines reusable variables.

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
```

---

## outputs.tf

Displays useful information after deployment.

```hcl
output "instance_id" {
  value = aws_instance.web.id
}
```

---

## terraform.tfvars

Stores variable values.

```hcl
instance_type = "t2.micro"
environment   = "dev"
```

---

# 7. Terraform Resources

A Terraform resource represents an infrastructure object.

Example resources:

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
```

```hcl
resource "aws_s3_bucket" "demo" {
  bucket = "my-terraform-demo-bucket"
}
```

```hcl
resource "aws_instance" "web" {
  ami           = "ami-1234567890abcdef0"
  instance_type = "t2.micro"
}
```

---

# 8. Terraform Variables

Variables make Terraform code flexible.

Example:

```hcl
variable "environment" {
  type        = string
  description = "Deployment environment"
  default     = "dev"
}
```

Usage:

```hcl
tags = {
  Environment = var.environment
}
```

---

# 9. Terraform Outputs

Outputs show important information after deployment.

Example:

```hcl
output "bucket_name" {
  value = aws_s3_bucket.demo.bucket
}
```

---

# 10. Terraform State Management

Terraform state is critical.

State should be protected because it may contain:

- Resource IDs
- Infrastructure metadata
- Sensitive values

For team environments, use remote state storage such as:

- Amazon S3
- DynamoDB state locking

---

# 11. Local State vs Remote State

## Local State

Stored on local machine:

```text
terraform.tfstate
```

Suitable for learning and small demos.

## Remote State

Stored in shared backend such as S3.

Benefits:

- Team collaboration
- Centralized state
- State locking
- Improved safety

---

# 12. Terraform and AWS IAM

Terraform requires AWS permissions to create resources.

For training labs, permissions may include:

- EC2 create/read/delete permissions
- VPC create/read/delete permissions
- S3 create/read/delete permissions
- IAM role and policy permissions

Production environments should follow least privilege access.

---

# 13. Terraform Best Practices

## Use Version Control

Store Terraform files in Git.

## Use Variables

Avoid hardcoded values.

## Use Outputs

Expose useful deployment values.

## Use Remote State

Use S3 backend for shared environments.

## Use Modules

Organize reusable infrastructure.

## Use Least Privilege IAM

Grant only required permissions.

## Separate Environments

Use separate folders or workspaces for dev, test, and prod.

## Review Plans Before Apply

Always check:

```bash
terraform plan
```

before running:

```bash
terraform apply
```

---

# 14. Common Terraform Commands

| Command | Purpose |
|---|---|
| terraform version | Check Terraform version |
| terraform init | Initialize working directory |
| terraform fmt | Format Terraform files |
| terraform validate | Validate configuration |
| terraform plan | Preview changes |
| terraform apply | Apply changes |
| terraform output | Show outputs |
| terraform state list | List resources in state |
| terraform destroy | Destroy resources |

---

# 15. Terraform Directory Structure

Recommended basic structure:

```text
terraform-day11/
├── provider.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── terraform.tfvars
```

Recommended environment structure:

```text
terraform-project/
├── dev/
├── test/
├── prod/
└── modules/
```

---

# 16. Day 11 Summary

In this theory session, participants learned:

- What Terraform is
- Why Terraform is used
- Terraform architecture
- Terraform workflow
- Providers and resources
- Variables and outputs
- Terraform state
- AWS IAM requirements
- Terraform best practices

---

# Review Questions

1. What is Terraform?
2. What is a Terraform provider?
3. Why is Terraform state important?
4. What is the purpose of `terraform plan`?
5. What is the difference between local and remote state?
6. Why should variables be used in Terraform?
7. How does Terraform help with Infrastructure as Code?
