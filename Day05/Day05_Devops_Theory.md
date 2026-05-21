# Day 05 – DevOps Theory
## Module 1 – DevOps & CI/CD Fundamentals
### Date: 22-May-2026 (Friday)


---

# AWS CodeDeploy

## Introduction

AWS CodeDeploy is a fully managed deployment service that automates software deployments to various compute services such as:
- Amazon EC2
- AWS Lambda
- Amazon ECS
- On-premises servers

It helps automate application deployments while minimizing downtime and reducing deployment risks.

---

# Benefits of AWS CodeDeploy

## Automated Deployments
Eliminates manual deployment processes.

## Reduced Downtime
Supports deployment strategies that minimize service interruption.

## Centralized Deployment Management
Manage deployments from a single platform.

## Rollback Capability
Automatically rollback failed deployments.

## Scalability
Deploy applications to a single instance or thousands of servers.

---

# AWS CodeDeploy Architecture

## Core Components

### 1. Application
A logical representation of the application being deployed.

---

### 2. Deployment Group
Defines:
- Target servers/resources
- Deployment configuration
- Deployment strategy

Examples:
- EC2 instances
- ECS services

---

### 3. Deployment Configuration
Defines how deployments occur.

Examples:
- One at a time
- Half at a time
- All at once

---

### 4. AppSpec File
A configuration file that tells CodeDeploy:
- Which files to copy
- Lifecycle hooks to run
- Deployment scripts

File types:
- appspec.yml (Linux)
- appspec.json (Windows)

---

### 5. Deployment Agent
A software agent installed on EC2 instances.

Responsibilities:
- Receives deployment instructions
- Downloads revisions
- Executes deployment scripts

---

# AWS CodeDeploy Workflow

1. Developer pushes updated code
2. Application revision uploaded to S3/GitHub
3. Deployment triggered
4. CodeDeploy sends instructions to instances
5. Deployment agent installs application
6. Validation checks are executed
7. Deployment status reported

---

# Deployment Strategies

## What are Deployment Strategies?

Deployment strategies define how application updates are released to users while minimizing downtime and risk.

---

# Common Deployment Strategies

## 1. In-Place Deployment

Application is stopped on current servers and updated directly.

### Advantages
- Simple implementation
- Lower infrastructure cost

### Disadvantages
- Downtime possible
- Rollback can be difficult

---

## 2. Blue/Green Deployment

Two identical environments are maintained:
- Blue = Current production
- Green = New version

Traffic is switched from blue to green after validation.

### Advantages
- Minimal downtime
- Easy rollback
- Safer deployments

### Disadvantages
- Higher infrastructure cost

---

## 3. Canary Deployment

New version is released to a small percentage of users first.

Traffic gradually increases if monitoring shows success.

### Advantages
- Reduced deployment risk
- Easier issue detection

### Disadvantages
- More complex monitoring

---

## 4. Rolling Deployment

Application updates happen in batches.

Example:
- 25% instances updated at a time

### Advantages
- Reduced downtime
- Controlled rollout

### Disadvantages
- Mixed application versions during deployment

---

# Blue/Green Deployment Architecture

```text
Users
   ↓
Load Balancer
   ↓
Blue Environment (Current Version)
Green Environment (New Version)

Traffic Switch → Green
```

---

# Canary Deployment Architecture

```text
100% Traffic
   ↓

90% → Old Version
10% → New Version

Gradually increase new version traffic
```

---

# AppSpec File Example

```yaml
version: 0.0
os: linux

files:
  - source: /
    destination: /var/www/html

hooks:
  BeforeInstall:
    - location: scripts/install_dependencies.sh

  ApplicationStart:
    - location: scripts/start_server.sh

  ValidateService:
    - location: scripts/validate_service.sh
```

---

# Monitoring Deployments

AWS services used for monitoring:
- Amazon CloudWatch
- AWS CloudTrail
- AWS CodeDeploy Console

Metrics monitored:
- Deployment success rate
- Instance health
- Application availability
- Error rates

---

# Best Practices

## Use Automated Rollbacks
Automatically restore previous version on failure.

## Monitor Deployments
Use CloudWatch alarms and dashboards.

## Use Immutable Infrastructure
Avoid modifying existing servers manually.

## Test Before Production
Validate deployments in staging environments.

## Use Small Deployment Batches
Reduce risk using canary or rolling deployments.

---

# AWS Resources Used

## AWS CodeDeploy
Automates software deployments.

## Amazon EC2
Hosts applications for deployment.

## Amazon ECS
Container orchestration service for deployments.

## Elastic Load Balancer (ELB)
Distributes traffic across environments.

## Auto Scaling
Automatically scales instances based on demand.

---

# Summary

In this session learners understood:
- AWS CodeDeploy architecture
- Deployment lifecycle
- AppSpec file structure
- Blue/Green deployments
- Canary deployments
- Deployment monitoring and rollback strategies

These concepts are critical for implementing reliable CI/CD deployment pipelines.
