# Day 11 Lab Guide — AWS Infrastructure Provisioning with Terraform
## Module 2 – Infrastructure as Code (IaC)
### Date: 1-june-2026 (Monday)

---

# Lab Duration

Recommended duration: 4 hours

---

# Lab Objectives

By the end of this lab, participants will be able to:

- Install Terraform CLI
- Verify Terraform installation
- Configure AWS CLI credentials
- Create Terraform project structure
- Configure the AWS provider
- Create an S3 bucket using Terraform
- Create a VPC using Terraform
- Create a subnet and security group
- Launch an EC2 instance using Terraform
- Use variables and outputs
- Destroy resources safely

---

# AWS Resources Used

- Terraform CLI
- AWS CLI
- IAM
- S3
- VPC
- Subnet
- Internet Gateway
- Route Table
- Security Group
- EC2

---

# Important Notes Before Starting

## Unique Resource Names

S3 bucket names must be globally unique.

Replace:

```text
rama-day11-terraform-demo-bucket
```

with a unique name, for example:

```text
yourname-day11-terraform-demo-bucket-20260520
```

## AWS Region

This lab uses:

```text
us-east-1
```

You can change the region if required.

---

# Part 1 — First-Time Setup

---

# Step 1 — Install Terraform CLI


## Linux Ubuntu/Debian

```bash
sudo apt-get update
sudo apt-get install -y gnupg software-properties-common curl

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt-get update
sudo apt-get install terraform
```

Verify:

```bash
terraform version
```

---

# Step 2 — Install AWS CLI

Verify if AWS CLI is already installed:

```bash
aws --version
```

If not installed, install AWS CLI v2.

After installation, verify:

```bash
aws --version
```

---

# Step 3 — Create IAM User or Role for Terraform

For a training lab, the IAM identity should have permissions to create:

- EC2
- VPC
- S3
- IAM read access

Example managed policies for training only:

```text
AmazonEC2FullAccess
AmazonS3FullAccess
IAMReadOnlyAccess
```

For production, always use least privilege permissions.

---

# Step 4 — Configure AWS CLI


Verify identity:

```bash
aws sts get-caller-identity --profile devops
```

---

# Step 5 — Create Lab Directory

```bash
mkdir terraform-day11-lab
cd terraform-day11-lab
```

---

# Part 2 — Terraform Project Setup

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
  profile = "devops"
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
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "day11-terraform"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the main VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.10.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
```

---

# Step 3 — Create terraform.tfvars

Create file:

```text
terraform.tfvars
```

Add and update the bucket name:

```hcl
aws_region          = "us-east-1"
environment         = "dev"
project_name        = "day11-terraform"
bucket_name         = "yourname-day11-terraform-demo-bucket-20260520"
vpc_cidr            = "10.10.0.0/16"
public_subnet_cidr  = "10.10.1.0/24"
instance_type       = "t2.micro"
```

---

# Part 3 — Create S3 Bucket

---

# Step 1 — Create main.tf

Create file:

```text
main.tf
```

Add:

```hcl
resource "aws_s3_bucket" "lab_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "${var.project_name}-${var.environment}-bucket"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "lab_bucket_versioning" {
  bucket = aws_s3_bucket.lab_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
```

---

# Step 2 — Initialize Terraform

```bash
terraform init
```

---

# Step 3 — Format Terraform Files

```bash
terraform fmt
```

---

# Step 4 — Validate Terraform Configuration

```bash
terraform validate
```

---

# Step 5 — Review Terraform Plan

```bash
terraform plan
```

---

# Step 6 — Apply Terraform Configuration

```bash
terraform apply
```

When prompted, type:

```text
yes
```

---

# Step 7 — Verify S3 Bucket

Use AWS CLI:

```bash
aws s3 ls --profile devops
```

Check bucket versioning:

```bash
aws s3api get-bucket-versioning \
--bucket yourname-day11-terraform-demo-bucket-20260520
```

---

# Part 4 — Create VPC, Subnet, Internet Gateway, Route Table, Security Group, and EC2

---

# Step 1 — Add Networking Resources to main.tf

Append the following to `main.tf`:

```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-subnet"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
```

---

# Step 2 — Add Security Group

Append to `main.tf`:

```hcl
resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-${var.environment}-web-sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH - training only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-web-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

Security note: In production, never allow SSH from `0.0.0.0/0`. Restrict it to trusted IP ranges.

---

# Step 3 — Add Latest Amazon Linux AMI Data Source

Append to `main.tf`:

```hcl
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
```

---

# Step 4 — Add EC2 Instance

Append to `main.tf`:

```hcl
resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd
              systemctl enable httpd
              systemctl start httpd
              echo "<h1>Hello from Terraform Day 11 Lab</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
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
output "s3_bucket_name" {
  description = "Created S3 bucket name"
  value       = aws_s3_bucket.lab_bucket.bucket
}

output "vpc_id" {
  description = "Created VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Created public subnet ID"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "Created security group ID"
  value       = aws_security_group.web_sg.id
}

output "ec2_instance_id" {
  description = "Created EC2 instance ID"
  value       = aws_instance.web.id
}

output "ec2_public_ip" {
  description = "Public IP address of EC2 instance"
  value       = aws_instance.web.public_ip
}

output "website_url" {
  description = "HTTP URL for web server"
  value       = "http://${aws_instance.web.public_ip}"
}
```

---

# Step 6 — Format and Validate

```bash
terraform fmt
```

```bash
terraform validate
```

---

# Step 7 — Review Plan

```bash
terraform plan
```

---

# Step 8 — Apply Changes

```bash
terraform apply
```

Type:

```text
yes
```

---

# Step 9 — View Outputs

```bash
terraform output
```

---

# Step 10 — Test Web Server

Copy the `website_url` output and open it in a browser.

Or use curl:

```bash
curl $(terraform output -raw website_url)
```

Expected output:

```html
<h1>Hello from Terraform Day 11 Lab</h1>
```

---

# Part 5 — Terraform State Commands

---

# List Resources in State

```bash
terraform state list
```

---

# Show EC2 Instance State

```bash
terraform state show aws_instance.web
```

---

# Show S3 Bucket State

```bash
terraform state show aws_s3_bucket.lab_bucket
```

---

# Part 6 — Optional Remote State Setup with S3

This section is optional for training.

---

# Step 1 — Create Backend S3 Bucket Manually

Use a unique bucket name:

```bash
aws s3 mb s3://yourname-terraform-state-day11-20260520
```

Enable versioning:

```bash
aws s3api put-bucket-versioning \
--bucket yourname-terraform-state-day11-20260520 \
--versioning-configuration Status=Enabled
```

---

# Step 2 — Create backend.tf

Create file:

```text
backend.tf
```

Add:

```hcl
terraform {
  backend "s3" {
    bucket = "yourname-terraform-state-day11-20260520"
    key    = "day11/terraform.tfstate"
    region = "us-east-1"
  }
}
```

---

# Step 3 — Reinitialize Terraform

```bash
terraform init
```

When prompted to migrate state, answer:

```text
yes
```

---

# Part 7 — Cleanup

To avoid AWS charges, destroy all resources after the lab.

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

# Step 2 — Verify Resources Are Deleted

Check EC2:

```bash
aws ec2 describe-instances \
--filters "Name=tag:ManagedBy,Values=Terraform"
```

Check S3:

```bash
aws s3 ls
```

---

# Troubleshooting

| Problem | Possible Cause | Solution |
|---|---|---|
| terraform command not found | Terraform not installed or PATH missing | Reinstall Terraform or fix PATH |
| aws command not found | AWS CLI not installed | Install AWS CLI |
| InvalidClientTokenId | Incorrect AWS credentials | Run aws configure again |
| AccessDenied | Missing IAM permissions | Update IAM policy |
| BucketAlreadyExists | S3 bucket name is not unique | Use a globally unique bucket name |
| Invalid AMI ID | Region mismatch or old AMI | Use AMI data source from this lab |
| Instance not reachable | Security group or subnet issue | Check public IP, route table, and security group |
| Provider download failed | Internet/proxy issue | Check network access |

---

# Lab Review Questions

1. What is the purpose of `terraform init`?
2. Why should you run `terraform plan` before `terraform apply`?
3. What is stored in Terraform state?
4. Why must S3 bucket names be globally unique?
5. What is the purpose of a VPC?
6. What is the role of a security group?
7. Why should SSH access not be open to everyone in production?

---

# Expected Outcomes

After completing this lab, participants will have created:

- S3 bucket with versioning
- VPC
- Public subnet
- Internet Gateway
- Route Table
- Security Group
- EC2 instance running Apache web server

Participants will also understand:

- Terraform CLI workflow
- AWS provider setup
- Variables and outputs
- Terraform state
- Resource cleanup

---

# End of Lab

Congratulations! You have completed Day 11 AWS infrastructure provisioning with Terraform.
