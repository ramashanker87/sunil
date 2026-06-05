# Day 12 — Terraform Modules and State Management
## Module 2 – Infrastructure as Code (IaC)
### Date: 02-Jun-2026 (Tuesday)

---

# Training Duration

Recommended duration: 4 hours

| Time | Topic |
|---|---|
| 00:00 – 00:30 | Recap of Terraform fundamentals |
| 00:30 – 01:15 | Terraform modules |
| 01:15 – 02:00 | Module structure and reusable design |
| 02:00 – 02:45 | Terraform state management |
| 02:45 – 03:30 | Remote state using S3 and DynamoDB |
| 03:30 – 04:00 | Terraform Cloud overview and Q&A |

---

# Learning Objectives

By the end of this session, participants will be able to:

- Understand Terraform modules
- Explain why modules are used
- Create reusable Terraform modules
- Use input variables and outputs in modules
- Understand Terraform state
- Explain local state and remote state
- Configure remote state using Amazon S3
- Use DynamoDB for state locking
- Understand Terraform Cloud basics
- Follow best practices for Terraform module and state management

---

# 1. Recap of Terraform Fundamentals

Terraform is an Infrastructure as Code tool used to define, provision, and manage infrastructure.

Terraform workflow:

```text
Write → Init → Validate → Plan → Apply → Manage → Destroy
```

Common commands:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

Terraform configuration files commonly include:

```text
provider.tf
main.tf
variables.tf
outputs.tf
terraform.tfvars
```

---

# 2. What are Terraform Modules?

A Terraform module is a reusable collection of Terraform configuration files.

A module usually contains:

- Resources
- Variables
- Outputs
- Provider-independent logic
- Reusable infrastructure patterns

A module helps avoid repeating the same Terraform code across multiple projects or environments.

---

# 3. Why Use Terraform Modules?

## Reusability

A module can be reused across multiple environments.

Example:

```text
dev
test
prod
```

can all use the same VPC module.

---

## Standardization

Modules help teams follow consistent infrastructure standards.

Example:

- Standard VPC CIDR structure
- Standard tagging
- Standard S3 bucket settings
- Standard security group rules

---

## Maintainability

Instead of editing duplicate code in many places, update the module once and reuse it.

---

## Scalability

Modules make it easier to manage large Terraform projects.

---

## Collaboration

Different teams can own different modules.

Example:

| Team | Module |
|---|---|
| Platform Team | VPC module |
| Security Team | IAM module |
| Application Team | EC2 module |

---

# 4. Types of Terraform Modules

## Root Module

The root module is the main Terraform working directory where commands are executed.

Example:

```text
terraform-day12/
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
└── terraform.tfvars
```

---

## Child Module

A child module is called by another module.

Example:

```text
terraform-day12/
├── main.tf
└── modules/
    └── s3_bucket/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## Published Modules

Modules can also come from:

- Terraform Registry
- GitHub
- Git repositories
- Private module registries
- Terraform Cloud private registry

---

# 5. Basic Module Structure

Recommended module structure:

```text
modules/
└── s3_bucket/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```

---

# 6. Calling a Module

Example:

```hcl
module "app_bucket" {
  source      = "./modules/s3_bucket"
  bucket_name = "my-demo-bucket"
  environment = "dev"
}
```

The `source` argument tells Terraform where the module is located.

---

# 7. Module Inputs

Modules use variables as inputs.

Example:

```hcl
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}
```

The root module passes values:

```hcl
module "app_bucket" {
  source      = "./modules/s3_bucket"
  bucket_name = "my-company-dev-app-bucket"
}
```

---

# 8. Module Outputs

Modules expose outputs to the root module.

Example:

```hcl
output "bucket_id" {
  value = aws_s3_bucket.this.id
}
```

The root module can access it:

```hcl
output "created_bucket_id" {
  value = module.app_bucket.bucket_id
}
```

---

# 9. Module Versioning

When using remote modules, pin versions.

Example:

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
}
```

Benefits of version pinning:

- Prevents accidental breaking changes
- Improves repeatability
- Supports controlled upgrades

---

# 10. Terraform State

Terraform state stores metadata about resources managed by Terraform.

Default state file:

```text
terraform.tfstate
```

Terraform state maps Terraform resources to real cloud resources.

Example:

```text
aws_s3_bucket.app_bucket → real AWS S3 bucket ID
```

---

# 11. Why Terraform State is Important

Terraform state is used to:

- Track created resources
- Detect differences between desired and actual infrastructure
- Build dependency graphs
- Determine what to create, update, or delete
- Store resource metadata

Without state, Terraform cannot reliably manage existing infrastructure.

---

# 12. Local State

By default, Terraform stores state locally:

```text
terraform.tfstate
```

Local state is simple but not ideal for teams.

Limitations:

- Not shared with team members
- Easy to lose
- No locking
- Can cause conflicts
- May contain sensitive data

---

# 13. Remote State

Remote state stores Terraform state in a shared backend.

Common remote backends:

- Amazon S3
- Terraform Cloud
- Azure Storage
- Google Cloud Storage
- Consul

For AWS teams, a common backend is:

- S3 for storing state
- DynamoDB for state locking

---

# 14. Remote State with S3

S3 stores the Terraform state file centrally.

Benefits:

- Durable storage
- Centralized state
- Versioning support
- Encryption support
- Team collaboration

Example backend:

```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}
```

---

# 15. State Locking with DynamoDB

DynamoDB can be used to lock Terraform state during operations.

This prevents two users from applying changes at the same time.

Example backend with locking:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

---

# 16. Terraform State Locking

State locking prevents concurrent writes.

Example problem without locking:

1. User A runs `terraform apply`
2. User B runs `terraform apply`
3. Both update the same state file
4. State may become corrupted or inconsistent

With locking:

- User A gets the lock
- User B must wait
- State remains consistent

---

# 17. Terraform Cloud

Terraform Cloud is HashiCorp's managed platform for Terraform workflows.

It provides:

- Remote state management
- Remote runs
- Workspace management
- Team access control
- Policy as code
- Run history
- Private module registry
- VCS integration

---

# 18. Terraform Cloud Workspaces

A workspace stores:

- Terraform state
- Variables
- Run history
- Configuration settings

Example workspace strategy:

```text
app-dev
app-test
app-prod
```

---

# 19. Terraform Cloud vs S3 Backend

| Feature | S3 + DynamoDB | Terraform Cloud |
|---|---|---|
| State storage | Yes | Yes |
| State locking | DynamoDB | Built-in |
| Remote execution | No | Yes |
| UI dashboard | Limited | Yes |
| Team access controls | IAM based | Built-in |
| VCS integration | External | Built-in |

---

# 20. State Management Best Practices

## Use Remote State for Teams

Avoid local state for shared environments.

## Enable S3 Versioning

Protect state history.

## Enable Encryption

Protect state file contents.

## Use DynamoDB Locking

Prevent concurrent changes.

## Separate State by Environment

Use separate state files:

```text
dev/terraform.tfstate
test/terraform.tfstate
prod/terraform.tfstate
```

## Restrict Access

Only authorized users should access state.

## Do Not Edit State Manually

Manual state editing can break Terraform management.

---

# 21. Module Best Practices

## Keep Modules Focused

Each module should have a clear purpose.

Examples:

- VPC module
- S3 module
- EC2 module
- IAM module

## Use Clear Inputs

Variables should have descriptions and types.

## Use Useful Outputs

Expose values that other modules may need.

## Avoid Hardcoding

Use variables for names, CIDR ranges, tags, and configuration.

## Add README Documentation

Explain how to use the module.

## Version Modules

Pin remote module versions.

---

# 22. Example Module Design

Example project:

```text
terraform-day12/
├── backend.tf
├── provider.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── modules/
    ├── s3_bucket/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── dynamodb_table/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

# 23. Common Mistakes

| Mistake | Impact |
|---|---|
| Using local state in teams | State conflicts |
| Not enabling S3 versioning | Harder recovery |
| No state locking | Concurrent apply issues |
| Hardcoding values | Poor reusability |
| Large monolithic configuration | Hard maintenance |
| No module documentation | Difficult reuse |
| Not pinning module versions | Unplanned changes |

---

# 24. Day 12 Summary

In this session, participants learned:

- What Terraform modules are
- Why modules are useful
- How root and child modules work
- How variables and outputs are used in modules
- What Terraform state is
- Why remote state is important
- How S3 and DynamoDB support state management
- What Terraform Cloud provides
- Best practices for modules and state

---

# Review Questions

1. What is a Terraform module?
2. What is the difference between root and child modules?
3. Why should Terraform state be stored remotely?
4. Why is DynamoDB used with S3 backend?
5. What is state locking?
6. What are the benefits of Terraform Cloud?
7. Why should modules be versioned?
