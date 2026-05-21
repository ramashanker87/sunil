# Day 04 – DevOps Theory
## Module 1 – DevOps & CI/CD Fundamentals
### Date: 21-May-2026 (Thursday)

---

# AWS CodeBuild Architecture

## Introduction
AWS CodeBuild is a fully managed continuous integration (CI) service that compiles source code, runs tests, and produces deployable software packages.

It eliminates the need to provision, manage, and scale build servers manually.

---


## Key Components of AWS CodeBuild

### 1. Source Provider
The source repository where application code is stored.

Supported sources include:
- AWS CodeCommit
- GitHub
- GitLab
- Bitbucket
- Amazon S3

---

### 2. Build Environment
A temporary environment created by CodeBuild to execute build commands.

Features:
- Managed Docker containers
- Custom runtime support
- Pre-installed tools and SDKs
- Linux and Windows environments

---

### 3. Buildspec File
A YAML configuration file named `buildspec.yml`.

It defines:
- Build phases
- Commands to execute
- Artifacts to store
- Environment variables

---

### 4. Build Phases
CodeBuild executes tasks in multiple phases:

| Phase | Purpose |
|---|---|
| install | Install dependencies |
| pre_build | Authentication/setup |
| build | Compile and test code |
| post_build | Final operations |
| artifacts | Upload build outputs |

---

### 5. Artifacts
Generated files after a successful build.

Examples:
- ZIP packages
- JAR/WAR files
- Docker images
- Reports/logs

Artifacts are typically stored in:
- Amazon S3
- CodePipeline

---

### 6. Logging & Monitoring
AWS CodeBuild integrates with:
- Amazon CloudWatch Logs
- CloudWatch Metrics
- AWS EventBridge

This helps monitor:
- Build success/failure
- Build duration
- Resource utilization

---

## AWS CodeBuild Workflow

1. Developer pushes code to repository
2. Build trigger starts CodeBuild
3. CodeBuild downloads source code
4. Build environment is provisioned
5. Commands from buildspec are executed
6. Artifacts are generated
7. Logs and reports are published

---

# Build Automation

## What is Build Automation?

Build automation is the process of automatically:
- Compiling source code
- Running tests
- Packaging applications
- Creating deployment artifacts

without manual intervention.

---

## Benefits of Build Automation

### Faster Development
Automated builds reduce manual tasks.

### Consistency
Ensures builds are repeatable and standardized.

### Error Reduction
Minimizes human mistakes during packaging and deployment.

### Continuous Integration
Enables rapid feedback for developers.

### Improved Productivity
Developers focus more on coding rather than build management.

---

## Build Automation Tools

Common tools:
- AWS CodeBuild
- Jenkins
- Maven
- Gradle
- GitHub Actions
- GitLab CI/CD

---

## Typical Automated Build Pipeline

```text
Code Commit → Build Trigger → Compile → Test → Package → Artifact Storage
```

---

## Build Automation Best Practices

### Use Version Control
Store all code and build configurations in Git.

### Keep Builds Fast
Optimize dependencies and avoid unnecessary steps.

### Automate Testing
Run unit and integration tests automatically.

### Store Artifacts Securely
Use Amazon S3 or artifact repositories.

### Monitor Builds
Use CloudWatch dashboards and alerts.

---

# AWS Resources Used

## AWS CodeBuild
Managed CI service for compiling and testing applications.

## Amazon S3
Stores source files and build artifacts.

## IAM
Controls permissions for CodeBuild and AWS resources.

## Amazon CloudWatch
Provides logs, monitoring, and metrics for builds.

---

# Summary

In this session, learners understood:
- AWS CodeBuild architecture
- CI/CD build workflows
- Build automation concepts
- Build phases and artifacts
- Monitoring builds using CloudWatch

These concepts form the foundation for implementing CI/CD pipelines in AWS.
