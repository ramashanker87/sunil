# Day 7 – DevOps Theory

## Module 1 – DevOps & CI/CD Fundamentals
### Date: 26-May-2026 (Tuesday)

---

# Topics Covered

- Jenkins
- GitHub Actions
- CI/CD Pipelines
- GitHub Actions Integration with AWS
- AWS EC2 Deployments
- DevOps Automation

---

# 1. Introduction to CI/CD

CI/CD stands for:

- Continuous Integration
- Continuous Delivery
- Continuous Deployment

CI/CD automates software development workflows including:

- Code integration
- Testing
- Building
- Deployment
- Monitoring

---

# Benefits of CI/CD

- Faster releases
- Reduced manual work
- Early bug detection
- Improved software quality
- Reliable deployments
- Better collaboration

---

# Continuous Integration (CI)

Continuous Integration means developers frequently push code changes to a shared repository.

Each code change automatically triggers:

- Build process
- Unit testing
- Code validation
- Security scanning

---

# Continuous Delivery (CD)

Continuous Delivery ensures software is always ready for deployment.

Deployment may still require manual approval.

---

# Continuous Deployment

Continuous Deployment automatically deploys changes to production after successful testing.

---

# 2. Jenkins

## What is Jenkins?

Jenkins is an open-source automation server used for CI/CD pipelines.

Jenkins automates:

- Code builds
- Testing
- Packaging
- Deployments
- Infrastructure automation

---

# Jenkins Architecture

Jenkins contains:

- Controller
- Agents
- Jobs
- Pipelines
- Plugins

---

# Jenkins Controller

The controller manages:

- Jobs
- Users
- Plugins
- Build scheduling

---

# Jenkins Agents

Agents execute build and deployment tasks.

They distribute workload across multiple systems.

---

# Jenkins Pipelines

Jenkins pipelines automate workflows.

Pipeline stages commonly include:

```text
Checkout → Build → Test → Deploy
```

---

# Jenkinsfile Example

```groovy
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                sh 'echo Building Application'
            }
        }

        stage('Test') {
            steps {
                sh 'echo Running Tests'
            }
        }

        stage('Deploy') {
            steps {
                sh 'echo Deploying Application'
            }
        }
    }
}
```

---

# Jenkins Plugins

Popular plugins:

| Plugin | Purpose |
|---|---|
| Git Plugin | Git integration |
| Pipeline Plugin | Pipeline support |
| SSH Plugin | Remote deployment |
| Docker Plugin | Docker integration |
| AWS Plugin | AWS integration |

---

# Jenkins Integration with AWS

Jenkins can integrate with:

- EC2
- ECS
- ECR
- S3
- CodeDeploy
- CloudFormation

---

# 3. GitHub Actions

## What is GitHub Actions?

GitHub Actions is GitHub's built-in CI/CD platform.

It automates workflows directly from GitHub repositories.

---

# GitHub Actions Features

- Automated builds
- Automated testing
- Deployment automation
- Docker integration
- AWS integration
- Secret management

---

# Workflow File Location

Workflow files are stored in:

```text
.github/workflows/
```

---

# GitHub Actions Concepts

| Concept | Description |
|---|---|
| Workflow | Automation process |
| Job | Group of steps |
| Step | Individual task |
| Runner | Machine executing workflow |
| Action | Reusable automation component |

---

# Workflow Example

```yaml
name: CI Pipeline

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Build
        run: echo "Building application"

      - name: Test
        run: echo "Running tests"
```

---

# GitHub Actions Runners

Types:

- GitHub-hosted runners
- Self-hosted runners

---

# GitHub Actions Secrets

Secrets securely store sensitive data:

- SSH keys
- AWS credentials
- API tokens

Secrets are encrypted and hidden in workflow logs.

---

# GitHub Actions with AWS

GitHub Actions integrates with AWS services:

- EC2
- ECS
- ECR
- S3
- Lambda
- CodeDeploy

---

# GitHub Actions Deployment Flow

Typical deployment flow:

```text
Developer Pushes Code
        ↓
GitHub Actions Workflow Triggered
        ↓
Build & Test
        ↓
Deploy to AWS EC2
```

---

# 4. GitHub Actions vs Jenkins

| Feature | Jenkins | GitHub Actions |
|---|---|---|
| Hosting | Self-managed | GitHub-managed |
| Configuration | Jenkinsfile | YAML |
| Plugin ecosystem | Large | Marketplace Actions |
| Setup effort | Medium | Easy |
| Cloud-native support | Good | Excellent |
| GitHub integration | Plugin-based | Native |

---

# 5. AWS EC2 in CI/CD

EC2 instances are commonly used as deployment targets.

Applications deployed to EC2 may include:

- Web applications
- APIs
- Docker containers
- Backend services

---

# CI/CD Deployment Process to EC2

Typical process:

1. Developer pushes code
2. CI pipeline starts
3. Tests execute
4. Application builds
5. SSH deployment to EC2
6. Service restart
7. Validation

---

# 6. SSH-Based Deployment

CI/CD tools commonly deploy using SSH.

Example deployment command:

```bash
scp index.html ec2-user@<EC2-IP>:/tmp/
```

Remote deployment:

```bash
ssh ec2-user@<EC2-IP>
```

---

# 7. Best Practices

## Jenkins Best Practices

- Use pipelines as code
- Secure credentials
- Use agents
- Keep plugins updated

---

## GitHub Actions Best Practices

- Store secrets securely
- Use reusable workflows
- Use branch protection
- Use environment approvals

---

## AWS Deployment Best Practices

- Restrict SSH access
- Use IAM roles
- Use staging environments
- Enable monitoring
- Use rollback strategies

---

# 8. Summary

In this module you learned:

- CI/CD fundamentals
- Jenkins pipelines
- GitHub Actions workflows
- AWS EC2 deployment automation
- CI/CD best practices
