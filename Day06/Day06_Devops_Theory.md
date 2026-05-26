# Day 06 – DevOps Theory
## Module 1 – DevOps & CI/CD Fundamentals
### Date: 25-May-2026 (Monday)

---

# AWS CodePipeline

## Introduction

AWS CodePipeline is a fully managed Continuous Integration and Continuous Delivery (CI/CD) service that automates the build, test, and deployment phases of software release processes.

It helps development teams deliver software updates rapidly and reliably.

---

# Key Features of AWS CodePipeline

## Automated Workflow
Automates the entire software release process.

## Continuous Integration
Automatically integrates source code changes.

## Continuous Delivery
Automates deployments across environments.

## Integration with AWS Services
Works with:
- CodeBuild
- CodeDeploy
- Lambda
- ECS
- CloudFormation

## Third-Party Integration
Supports:
- GitHub
- Jenkins
- Bitbucket
- GitLab

---

# AWS CodePipeline Architecture

## Core Components

### 1. Source Stage
Fetches source code from repositories.

Supported sources:
- CodeCommit
- GitHub
- S3

---

### 2. Build Stage
Compiles and tests code using AWS CodeBuild.

Typical tasks:
- Install dependencies
- Run unit tests
- Create build artifacts

---

### 3. Deploy Stage
Deploys applications using:
- CodeDeploy
- ECS
- Lambda
- CloudFormation

---

### 4. Approval Stage (Optional)
Manual approval before deployment to production.

---

### 5. Notification Stage
Sends alerts and notifications using Amazon SNS.

---

# AWS CodePipeline Workflow

```text
Developer Commit
       ↓
Source Stage
       ↓
Build Stage (CodeBuild)
       ↓
Test Stage
       ↓
Deploy Stage (CodeDeploy)
       ↓
Production Environment
```

---

# CI/CD Orchestration

## What is CI/CD Orchestration?

CI/CD orchestration is the automated coordination of:
- Source control
- Builds
- Testing
- Deployments
- Monitoring

across the software delivery lifecycle.

---

# Continuous Integration (CI)

## Definition
Developers frequently merge code changes into a shared repository.

Automated builds and tests validate changes continuously.

---

# Benefits of Continuous Integration

- Faster bug detection
- Reduced integration issues
- Improved collaboration
- Higher software quality

---

# Continuous Delivery (CD)

## Definition
Applications are automatically prepared for deployment after successful testing.

Deployment may still require manual approval.

---

# Continuous Deployment

## Definition
Every validated change is automatically deployed to production without manual intervention.

---

# CI/CD Pipeline Stages

| Stage | Purpose |
|---|---|
| Source | Retrieve source code |
| Build | Compile and package |
| Test | Validate application |
| Deploy | Release application |
| Monitor | Track health and performance |

---

# AWS CodePipeline Stages Example

## Source Stage
GitHub repository triggers pipeline.

---

## Build Stage
CodeBuild:
- Compiles code
- Executes tests
- Generates artifacts

---

## Deploy Stage
CodeDeploy:
- Deploys application to EC2 or ECS
- Supports Blue/Green deployments

---

## Notification Stage
SNS sends:
- Success alerts
- Failure alerts
- Deployment notifications

---

# Amazon SNS Integration

## What is SNS?

Amazon Simple Notification Service (SNS) is a messaging service used for:
- Email alerts
- SMS notifications
- Event-driven communication

---

# SNS in CI/CD

SNS notifications can be triggered for:
- Build failures
- Deployment completion
- Pipeline success/failure
- Manual approvals

---

# Example CI/CD Pipeline Architecture

```text
GitHub
   ↓
CodePipeline
   ↓
CodeBuild
   ↓
CodeDeploy
   ↓
EC2 / ECS
   ↓
SNS Notifications
```

---

# Pipeline Monitoring

AWS services used:
- CloudWatch
- CloudTrail
- SNS
- CodePipeline Dashboard

Metrics monitored:
- Build success rate
- Deployment status
- Pipeline duration
- Failure trends

---

# Best Practices

## Automate Everything
Reduce manual intervention.

## Use Infrastructure as Code
Deploy consistent environments.

## Enable Notifications
Use SNS for alerts and approvals.

## Implement Rollbacks
Automatically recover from failures.

## Monitor Continuously
Use CloudWatch dashboards and alarms.

---

# AWS Resources Used

## AWS CodePipeline
Orchestrates CI/CD workflows.

## AWS CodeBuild
Compiles and tests applications.

## AWS CodeDeploy
Automates application deployments.

## Amazon SNS
Provides notifications and alerts.

---

# Summary

In this session learners understood:
- AWS CodePipeline architecture
- CI/CD orchestration concepts
- Pipeline stages and workflows
- Integration between CodeBuild and CodeDeploy
- SNS notifications in CI/CD

These concepts provide the foundation for implementing end-to-end DevOps automation pipelines.
