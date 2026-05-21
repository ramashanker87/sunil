# Theory.md — Day 3 AWS CodeCommit & Repository Management

# Day 3 — AWS CodeCommit and Repository Management

## Duration
**1.5 Hours Theory Session**

---

# Agenda

| Time | Topic |
|------|------|
| 00:00 – 00:20 | Introduction to AWS CodeCommit |
| 00:20 – 00:40 | Repository Management Concepts |
| 00:40 – 01:00 | CodeCommit Architecture & Security |
| 01:00 – 01:15 | IAM Integration & Access Control |
| 01:15 – 01:25 | Monitoring with CloudWatch Logs |
| 01:25 – 01:30 | Summary & Q/A |

---

# 1. Introduction to AWS CodeCommit

## What is AWS CodeCommit?

AWS CodeCommit is a fully managed source control service provided by AWS.

It helps teams:

- Store source code securely
- Manage Git repositories
- Collaborate with developers
- Integrate with CI/CD pipelines

---

# Features of AWS CodeCommit

| Feature | Description |
|---|---|
| Fully Managed | No infrastructure management |
| Secure | Integrated with IAM |
| Scalable | Supports large repositories |
| Highly Available | Built on AWS infrastructure |
| Git Compatible | Works with standard Git commands |

---

# Why Use CodeCommit?

## Benefits

- Secure private repositories
- Encryption at rest and in transit
- Easy AWS integration
- No Git server maintenance
- Supports CI/CD automation

---

# AWS CodeCommit Architecture

```text
+-------------------+
|    Developers     |
+-------------------+
          |
          v
+-------------------+
|    Git Client     |
+-------------------+
          |
          v
+-------------------+
| AWS CodeCommit    |
+-------------------+
          |
          v
+-------------------+
| IAM Authentication|
+-------------------+
          |
          v
+-------------------+
| CloudWatch Logs   |
+-------------------+
```

---

# CodeCommit Components

| Component | Purpose |
|---|---|
| Repository | Stores source code |
| Branch | Parallel development |
| Commit | Snapshot of changes |
| Pull Request | Code review process |
| IAM | Authentication & authorization |

---

# Repository Management

## What is Repository Management?

Repository management involves:

- Creating repositories
- Managing branches
- Access control
- Version management
- Repository monitoring

---

# Git Repository Structure

```text
Repository
├── Branches
├── Commits
├── Tags
├── Pull Requests
└── Files
```

---

# Creating Repositories

Repositories can be created using:

- AWS Management Console
- AWS CLI
- SDK/API
- CloudFormation

---

# AWS CLI Example

## Create Repository

```bash
aws codecommit create-repository \
--repository-name DevOpsRepo \
--repository-description "DevOps Training Repository"
```

---

# Cloning CodeCommit Repository

```bash
git clone https://git-codecommit.us-east-1.amazonaws.com/v1/repos/DevOpsRepo
```

---

# Branch Management

## Common Branch Types

| Branch | Purpose |
|---|---|
| main/master | Production code |
| develop | Integration branch |
| feature | New feature development |
| hotfix | Emergency fixes |

---

# Repository Best Practices

- Use meaningful repository names
- Apply branch protection
- Use pull requests
- Follow commit standards
- Enable monitoring

---

# Pull Requests in CodeCommit

## Purpose

Pull Requests are used for:

- Code review
- Collaboration
- Quality checks
- Merge approvals

---

# Pull Request Workflow

```text
Developer Branch
       |
       v
Push Changes
       |
       v
Create Pull Request
       |
       v
Code Review
       |
       v
Approval
       |
       v
Merge to Main
```

---

# IAM Integration

## What is IAM?

IAM (Identity and Access Management) controls:

- User authentication
- Permissions
- Access policies

---

# IAM Authentication Methods

| Method | Description |
|---|---|
| IAM User | AWS account-based access |
| HTTPS Git Credentials | Git authentication |
| SSH Keys | Secure shell authentication |

---

# Sample IAM Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codecommit:*"
      ],
      "Resource": "*"
    }
  ]
}
```

---

# Repository Security

## Security Best Practices

- Use least privilege access
- Enable MFA
- Use encryption
- Restrict branch deletion
- Enable logging

---

# CloudWatch Logs Integration

## Why CloudWatch?

CloudWatch helps monitor:

- Repository activity
- API calls
- User access
- Errors and failures

---

# Monitoring Workflow

```text
CodeCommit Activity
         |
         v
CloudTrail Events
         |
         v
CloudWatch Logs
         |
         v
Monitoring Dashboard
```

---

# Common Repository Operations

| Operation | Command |
|---|---|
| Clone | git clone |
| Pull | git pull |
| Push | git push |
| Commit | git commit |
| Branch | git branch |
| Merge | git merge |

---

# AWS Services Used

| Service | Purpose |
|---|---|
| CodeCommit | Source code repository |
| IAM | Access management |
| CloudWatch Logs | Monitoring |
| CloudTrail | Audit logging |

---

# Real-World Example

## DevOps Workflow

1. Developer pushes code to CodeCommit
2. Repository triggers CI/CD pipeline
3. Build process starts
4. Automated testing runs
5. Deployment pipeline executes
6. Logs monitored in CloudWatch

---

# Advantages of CodeCommit

- Fully managed Git service
- Secure repository storage
- AWS ecosystem integration
- High availability
- Easy scalability

---

# Limitations

- AWS-specific service
- Smaller ecosystem than GitHub
- Requires AWS knowledge

---

# Best Practices Summary

- Use branch strategies
- Protect main branch
- Review pull requests
- Enable monitoring
- Follow IAM least privilege

---

# Interview Questions

1. What is AWS CodeCommit?
2. Difference between GitHub and CodeCommit?
3. What is repository management?
4. How does IAM integrate with CodeCommit?
5. What is the purpose of CloudWatch Logs?
6. Explain pull request workflow.

---

# Summary

In this session, we covered:

- AWS CodeCommit fundamentals
- Repository management
- Branching concepts
- Pull requests
- IAM authentication
- Monitoring with CloudWatch Logs

These concepts are essential for secure and scalable DevOps repository management.

---
