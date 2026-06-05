# Day 12 Lab Guide — Terraform Modules and Remote State Management
## Module 2 – Infrastructure as Code (IaC)
### Date: 02-Jun-2026 (Tuesday)

---

# Lab Duration

Recommended duration: 4 hours

---

# Lab Objectives

By the end of this lab, participants will be able to:

- Create reusable Terraform modules
- Build an S3 bucket module
- Build a DynamoDB table module
- Call modules from a root Terraform configuration
- Create a remote backend using S3
- Enable Terraform state locking using DynamoDB
- Reinitialize Terraform with remote state
- Understand Terraform Cloud workspace usage
- Clean up Terraform-managed resources safely

---

# AWS Resources Used

- S3
- DynamoDB
- Terraform CLI
- Terraform Cloud

---

# Prerequisites

Participants should have:

- AWS account access
- AWS CLI installed
- Terraform CLI installed
- IAM permissions for S3 and DynamoDB
- Basic Terraform knowledge from Day 11

Verify AWS CLI:

```bash
aws --version
```

Verify Terraform:

```bash
terraform version
```

Verify AWS identity:

```bash
aws sts get-caller-identity
```

---

# Required IAM Permissions

For this lab, the IAM user or role should be able to manage:

- S3 buckets
- S3 bucket versioning
- S3 bucket encryption
- DynamoDB tables
- Terraform backend access

Example training permissions:

```text
AmazonS3FullAccess
AmazonDynamoDBFullAccess
```

For production, use least privilege policies.

---

# Important Naming Note

S3 bucket names must be globally unique.

Replace all example bucket names with your own unique name.

Example:

```text
yourname-day12-tf-state-20260602
```

---

# Part 1 — Create Lab Folder Structure

---

# Step 1 — Create Project Directory

```bash
mkdir terraform-day12-lab
cd terraform-day12-lab
```

---

# Step 2 — Create Folder Structure

```bash
mkdir -p modules/s3_bucket
mkdir -p modules/dynamodb_table
```

Final structure:

```text
terraform-day12-lab/
├── modules/
│   ├── s3_bucket/
│   └── dynamodb_table/
```

---

# Part 2 — Create S3 Bucket Module

---

# Step 1 — Create S3 Module main.tf

Create file:

```text
modules/s3_bucket/main.tf
```

Add:

```hcl
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = merge(
    var.tags,
    {
      Name      = var.bucket_name
      ManagedBy = "Terraform"
    }
  )
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

---

# Step 2 — Create S3 Module variables.tf

Create file:

```text
modules/s3_bucket/variables.tf
```

Add:

```hcl
variable "bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the bucket"
  type        = map(string)
  default     = {}
}
```

---

# Step 3 — Create S3 Module outputs.tf

Create file:

```text
modules/s3_bucket/outputs.tf
```

Add:

```hcl
output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}
```

---

# Part 3 — Create DynamoDB Table Module

---

# Step 1 — Create DynamoDB Module main.tf

Create file:

```text
modules/dynamodb_table/main.tf
```

Add:

```hcl
resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(
    var.tags,
    {
      Name      = var.table_name
      ManagedBy = "Terraform"
    }
  )
}
```

---

# Step 2 — Create DynamoDB Module variables.tf

Create file:

```text
modules/dynamodb_table/variables.tf
```

Add:

```hcl
variable "table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the DynamoDB table"
  type        = map(string)
  default     = {}
}
```

---

# Step 3 — Create DynamoDB Module outputs.tf

Create file:

```text
modules/dynamodb_table/outputs.tf
```

Add:

```hcl
output "table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.this.name
}

output "table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.this.arn
}
```

---

# Part 4 — Create Root Terraform Configuration

---

# Step 1 — Create provider.tf

Create file:

```text
provider.tf
```

Add:

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}
```

---

# Step 2 — Create variables.tf

Create file:

```text
variables.tf
```

Add:

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS Profile"
  type        = string
  default     = "devops"
}
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "day12-terraform"
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform remote state"
  type        = string
}

variable "lock_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
}
```

---

# Step 3 — Create terraform.tfvars

Create file:

```text
terraform.tfvars
```

Add and update names to unique values:

```hcl
aws_region        = "us-east-1"
aws_profile        = "devops"
environment       = "dev"
project_name      = "day12-terraform"
state_bucket_name = "yourname-day12-tf-state-20260602"
lock_table_name   = "day12-terraform-locks"
```

---

# Step 4 — Create main.tf

Create file:

```text
main.tf
```

Add:

```hcl
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = "training"
  }
}

module "remote_state_bucket" {
  source = "./modules/s3_bucket"

  bucket_name        = var.state_bucket_name
  versioning_enabled = true
  tags               = local.common_tags
}

module "terraform_lock_table" {
  source = "./modules/dynamodb_table"

  table_name = var.lock_table_name
  tags       = local.common_tags
}
```

---

# Step 5 — Create outputs.tf

Create file:

```text
outputs.tf
```

Add:

```hcl
output "state_bucket_name" {
  description = "Terraform remote state bucket name"
  value       = module.remote_state_bucket.bucket_name
}

output "state_bucket_arn" {
  description = "Terraform remote state bucket ARN"
  value       = module.remote_state_bucket.bucket_arn
}

output "lock_table_name" {
  description = "Terraform lock table name"
  value       = module.terraform_lock_table.table_name
}

output "lock_table_arn" {
  description = "Terraform lock table ARN"
  value       = module.terraform_lock_table.table_arn
}
```

---

# Part 5 — Deploy Backend Infrastructure Locally

The S3 backend bucket and DynamoDB lock table must exist before Terraform can use them as a backend.

For this first step, Terraform uses local state.

---

# Step 1 — Initialize Terraform

```bash
terraform init
```

---

# Step 2 — Format Terraform Files

```bash
terraform fmt -recursive
```

---

# Step 3 — Validate Configuration

```bash
terraform validate
```

---

# Step 4 — Preview Plan

```bash
terraform plan
```

---

# Step 5 — Apply Configuration

```bash
terraform apply
```

Type:

```text
yes
```

---

# Step 6 — Verify Created Resources

Check S3:

```bash
aws s3 ls
```

Check DynamoDB:

```bash
aws dynamodb list-tables
```

Check Terraform outputs:

```bash
terraform output
```

---

# Part 6 — Configure Remote State Backend

---

# Step 1 — Create backend.tf

Create file:

```text
backend.tf
```

Add this content and replace bucket/table names:

```hcl
terraform {
  backend "s3" {
    bucket         = "yourname-day12-tf-state-20260602"
    key            = "day12/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "day12-terraform-locks"
    encrypt        = true
  }
}
```

Important: backend values cannot use normal Terraform variables.

---

# Step 2 — Reinitialize Terraform

```bash
terraform init
```

Terraform asks whether to migrate local state to S3.

Type:

```text
yes
```

---

# Step 3 — Verify State File in S3

```bash
aws s3 ls s3://yourname-day12-tf-state-20260602/day12/dev/
```

Expected:

```text
terraform.tfstate
```

---

# Step 4 — Run Plan Again

```bash
terraform plan
```

Expected result:

```text
No changes. Your infrastructure matches the configuration.
```

---

# Part 7 — Test State Locking

---

# Step 1 — Start a Terraform Apply

Run:

```bash
terraform apply
```

Do not approve immediately.

---

# Step 2 — Open a Second Terminal

In the same project directory, run:

```bash
terraform plan
```

Terraform should wait for or report a state lock.

This demonstrates DynamoDB state locking.

---

# Step 3 — Cancel or Complete the First Apply

In the first terminal, type:

```text
no
```

or approve if required.

---

# Part 8 — Using Terraform Cloud

This section is for demonstration or optional practice.

---

# Terraform Cloud Concepts

Terraform Cloud provides:

- Remote state
- Remote execution
- Workspaces
- Team access control
- Run history
- Policy as code
- Private module registry

---

# Step 1 — Create Terraform Cloud Account

Create or use an existing Terraform Cloud account.

---

# Step 2 — Create an Organization

Example:

```text
training-org
```

---

# Step 3 — Create a Workspace

Example workspace name:

```text
day12-dev
```

Workspace types:

- Version control workflow
- CLI-driven workflow
- API-driven workflow

For training, CLI-driven workflow is simple.

---

# Step 4 — Login from Terraform CLI

```bash
terraform login
```

Follow browser authentication steps.

---

# Step 5 — Configure Terraform Cloud Backend

Alternative backend example:

```hcl
terraform {
  cloud {
    organization = "training-org"

    workspaces {
      name = "day12-dev"
    }
  }
}
```

Note: Do not use both S3 backend and Terraform Cloud backend in the same active configuration.

---

# Part 9 — Cleanup

Important: If backend infrastructure is stored in the same remote backend, cleanup requires care.

For training, remove `backend.tf` only if instructed by the trainer.

---

# Option A — Standard Cleanup

Run:

```bash
terraform destroy
```

Type:

```text
yes
```

This destroys:

- S3 bucket
- DynamoDB table

However, if the state is stored inside the same S3 bucket being destroyed, cleanup may fail or become unsafe.

---

# Option B — Recommended Training Cleanup

1. Keep the backend resources for future labs.
2. Or create a separate permanent backend bucket manually.
3. Destroy only non-backend lab resources.

---

# Option C — Manual Cleanup

If needed, remove S3 objects first:

```bash
aws s3 rm s3://yourname-day12-tf-state-20260602 --recursive
```

Delete bucket:

```bash
aws s3 rb s3://yourname-day12-tf-state-20260602 --force
```

Delete DynamoDB table:

```bash
aws dynamodb delete-table \
--table-name day12-terraform-locks
```

---

# Troubleshooting Guide

| Problem | Possible Cause | Solution |
|---|---|---|
| BucketAlreadyExists | S3 bucket name not unique | Use a unique bucket name |
| AccessDenied | Missing IAM permissions | Update IAM permissions |
| Backend initialization failed | Wrong bucket or region | Check backend.tf |
| State lock error | Another Terraform operation is running | Wait or unlock carefully |
| DynamoDB lock table error | Table missing or wrong key | Ensure LockID string key exists |
| Variables not accepted in backend | Terraform limitation | Hardcode backend values or use backend config file |
| Destroy fails for backend bucket | State is stored in same bucket | Use careful manual cleanup |

---

# Useful Commands

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
terraform output
terraform state list
terraform destroy
```

AWS verification commands:

```bash
aws s3 ls
aws dynamodb list-tables
aws sts get-caller-identity
```

---

# Lab Review Questions

1. What is a Terraform module?
2. Why do we use modules?
3. What is Terraform state?
4. Why is remote state useful?
5. Why is DynamoDB used with S3 backend?
6. What happens during `terraform init` after adding backend.tf?
7. Why should backend resources be handled carefully during cleanup?
8. What are Terraform Cloud workspaces?

---

# Expected Outcomes

After completing this lab, participants will have:

- Created an S3 Terraform module
- Created a DynamoDB Terraform module
- Used modules from a root configuration
- Created S3 remote state storage
- Created DynamoDB state locking
- Migrated local state to remote state
- Reviewed Terraform Cloud concepts

---

# End of Lab

Congratulations! You have completed Day 12 Terraform modules and remote state management lab.
