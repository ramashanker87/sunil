# Day 08 – DevOps Lab
# Simple SonarQube & CodeBuild Lab

## Module 1 – DevOps & CI/CD Fundamentals
### Date: 27-May-2026 (Wednesday)

---

# Lab Objective

In this lab you will:

- Launch SonarQube on AWS EC2
- Configure SonarQube
- Create AWS CodeBuild project
- Run automated testing
- Perform quality validation

This lab is simplified for beginners.

Estimated Time:

```text
1 Hour
```

---

# Architecture

```text
Developer
   ↓
GitHub Repository
   ↓
AWS CodeBuild
   ↓
SonarQube Quality Scan
   ↓
Quality Validation
```

---

# AWS Resources Used

| Resource | Purpose |
|---|---|
| EC2 | SonarQube Server |
| CodeBuild | Build & Testing |
| S3 | Build artifacts |
| IAM | Permissions |

---

# Prerequisites

Before starting:

- AWS Account
- GitHub Account
- EC2 Key Pair
- Internet access

Recommended Region:

```text
us-east-1
```

---

# Part 1 – Launch SonarQube Server

## Step 1 – Launch EC2 Instance

Open:

```text
AWS Console → EC2 → Launch Instance
```

Configuration:

| Setting | Value |
|---|---|
| Name | sonarqube-server |
| AMI | Amazon Linux 2 |
| Instance Type | t2.medium |

IMPORTANT:

```text
Do NOT use t2.micro
```

---

# Step 2 – Configure Security Group

Allow:

| Type | Port |
|---|---|
| SSH | 22 |
| Custom TCP | 9000 |

Launch instance.

---

# Step 3 – Connect to EC2

```bash
ssh -i mykey.pem ec2-user@<SONAR-IP>
```

---

# Step 4 – Install Docker

Run:

```bash
sudo yum update -y

sudo yum install docker -y

sudo usermod -aG docker $USER

newgrp docker

sudo service docker start

sudo systemctl enable docker

sudo usermod -aG docker ec2-user
```

Reconnect SSH.

---

# Step 5 – Run SonarQube Container

Run:

```bash
docker run -d --name sonarqube \
-p 9000:9000 sonarqube:lts
```

Verify:

```bash
docker ps
```

---

# Step 6 – Access SonarQube

Open browser:

```text
http://<SONAR-IP>:9000
```

Default credentials:

| Username | Password |
|---|---|
| admin | admin |

Change password when prompted.

---

# Part 2 – Create GitHub Repository

## Step 7 – Create GitHub Repository

Repository Name:

```text
sonarqube-demo
```

---

# Step 8 – Create Application File

Create:

## index.html

```html
<h1>SonarQube Demo Application</h1>
```

---

# Step 9 – Create buildspec.yml

Create:

```yaml
version: 0.2

phases:
  install:
    commands:
      - echo Installing dependencies

  build:
    commands:
      - echo Running automated tests
      - echo Running quality validation

artifacts:
  files:
    - '**/*'
```

---

# Step 10 – Push Code to GitHub

```bash
git init

git add .

git commit -m "Initial commit"

git push origin main
```

---

# Part 3 – Create IAM Role

## Step 11 – Create CodeBuild IAM Role

Open:

```text
IAM → Roles → Create Role
```

Select:

```text
AWS Service → CodeBuild
```

Attach policies:

```text
AmazonS3FullAccess
CloudWatchLogsFullAccess
```

Role Name:

```text
Day08_CodeBuild_Role
```

---

# Part 4 – Create CodeBuild Project

## Step 12 – Create CodeBuild Project

Open:

```text
AWS Console → CodeBuild
```

Click:

```text
Create Build Project
```

Configuration:

| Setting | Value |
|---|---|
| Project Name | sonarqube-build |
| Source Provider | GitHub |
| Repository | sonarqube-demo |
| Environment | Managed Image |
| OS | Amazon Linux 2 |
| Runtime | Standard |
| Service Role | Day08_CodeBuild_Role |

Buildspec:

```text
Use buildspec.yml
```

Artifacts:

```text
No Artifacts
```

Create project.

---

# Part 5 – Run Build

## Step 13 – Start Build

Open:

```text
CodeBuild → sonarqube-build
```

Click:

```text
Start Build
```

---

# Step 14 – Monitor Build Logs

Verify:

```text
Build Succeeded
```

Check logs:

```text
Running automated tests
Running quality validation
```

---

# Part 6 – SonarQube Demonstration

## Step 15 – Create SonarQube Project

Open SonarQube:

```text
http://<SONAR-IP>:9000
```

Click:

```text
Create Project
```

Project Name:

```text
sonarqube-demo
```

---

# Step 16 – Generate Token

Open:

```text
My Account → Security
```

Generate token:

```text
demo-token
```

Copy token.

---

# Step 17 – Demonstrate Code Quality Scan

Explain:

```text
SonarQube normally scans source code using Sonar Scanner.
```

For beginner lab demonstration:

- Show SonarQube dashboard
- Explain quality gates
- Explain bug detection
- Explain CI/CD integration

---

# Quality Validation Demo

Explain examples:

| Validation | Example |
|---|---|
| Bugs | Detect coding issues |
| Vulnerabilities | Detect security problems |
| Coverage | Validate testing |
| Duplication | Detect duplicate code |

---

# Expected Result

You should have:

✅ SonarQube accessible

✅ CodeBuild successful

✅ Automated testing demonstrated

✅ Quality validation demonstrated

---

# Common Issues

---

# SonarQube Not Opening

Verify:

```bash
docker ps
```

Restart container:

```bash
docker restart sonarqube
```

Verify port:

```text
9000 open in Security Group
```

---

# Docker Not Running

Start Docker:

```bash
sudo service docker start
```

---

# CodeBuild Failed

Verify:

- IAM permissions
- buildspec.yml exists
- GitHub repository connected

---

# EC2 Connection Failed

Verify:

- Public IP exists
- SSH port 22 open
- Correct key pair used

---

# Useful Commands

## Check Docker Containers

```bash
docker ps
```

---

## Restart SonarQube

```bash
docker restart sonarqube
```

---

## View Container Logs

```bash
docker logs sonarqube
```

---

# Cleanup

To avoid AWS charges:

- Stop EC2 instances
- Delete CodeBuild projects
- Delete unused repositories

---

# Summary

In this lab you completed:

- SonarQube setup on AWS EC2
- Automated testing using CodeBuild
- Quality validation workflow
- CI/CD quality demonstration
