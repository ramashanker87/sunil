# Day 08 – DevOps Theory
# Testing Automation, Quality Gates & SonarQube

## Module 1 – DevOps & CI/CD Fundamentals
### Date: 27-May-2026 (Wednesday)

---

# Learning Objectives

In this session you will learn:

- What is testing automation
- What are quality gates
- What is SonarQube
- Why code quality matters
- How DevOps teams automate validation
- How SonarQube integrates with CI/CD

---

# What is Testing Automation?

Testing automation means:

```text
Automatically testing applications using tools and scripts.
```

Instead of manually checking applications every time, automated tools verify:

- Code quality
- Functionality
- Bugs
- Security issues
- Performance issues

---

# Why Testing Automation is Important

Benefits:

| Benefit | Description |
|---|---|
| Faster Delivery | Tests run automatically |
| Better Quality | Fewer production bugs |
| Continuous Validation | Every code change gets tested |
| Reduced Manual Work | Less human effort |
| Faster Feedback | Developers get instant results |

---

# Types of Automated Testing

| Testing Type | Purpose |
|---|---|
| Unit Testing | Tests individual functions |
| Integration Testing | Tests system integration |
| Functional Testing | Tests application behavior |
| Security Testing | Detects vulnerabilities |
| Performance Testing | Tests scalability |

---

# What are Quality Gates?

A Quality Gate is:

```text
A checkpoint that validates whether code quality standards are met.
```

If quality rules fail:

```text
Deployment can be stopped automatically.
```

---

# Examples of Quality Gates

| Quality Rule | Example |
|---|---|
| Code Coverage | Must be greater than 80% |
| Bugs | No critical bugs |
| Vulnerabilities | No high severity issues |
| Duplicated Code | Less than 5% |
| Maintainability | Must pass rating |

---

# Benefits of Quality Gates

- Prevents bad code deployment
- Improves maintainability
- Reduces production failures
- Improves security
- Standardizes development quality

---

# What is SonarQube?

SonarQube is:

```text
A code quality and security analysis platform.
```

It scans source code and identifies:

- Bugs
- Security vulnerabilities
- Code smells
- Duplicated code
- Maintainability issues

---

# SonarQube Features

| Feature | Purpose |
|---|---|
| Static Code Analysis | Reviews source code |
| Security Scanning | Finds vulnerabilities |
| Code Coverage | Measures testing |
| Quality Gates | Blocks bad code |
| CI/CD Integration | Integrates with pipelines |

---

# SonarQube Workflow

```text
Developer Pushes Code
          ↓
CI/CD Pipeline Starts
          ↓
SonarQube Scans Code
          ↓
Quality Gate Validation
          ↓
Pass OR Fail
          ↓
Deployment Decision
```

---

# SonarQube Components

| Component | Purpose |
|---|---|
| SonarQube Server | Analysis platform |
| Sonar Scanner | Scans source code |
| Database | Stores reports |
| Dashboard | Displays code quality |

---

# Common Code Issues Detected

SonarQube can detect:

- Unused variables
- Duplicate code
- Hardcoded passwords
- Security vulnerabilities
- Complex code
- Memory issues

---

# What is Static Code Analysis?

Static analysis means:

```text
Analyzing source code without running the application.
```

This helps detect issues early during development.

---

# SonarQube and CI/CD

SonarQube integrates with:

- Jenkins
- GitHub Actions
- AWS CodeBuild
- GitLab CI/CD
- Azure DevOps

---

# AWS Services Used with SonarQube

| AWS Service | Purpose |
|---|---|
| EC2 | Hosting SonarQube |
| CodeBuild | Automated testing |
| S3 | Artifact storage |
| IAM | Permissions management |

---

# What is Code Coverage?

Code coverage measures:

```text
How much application code is tested.
```

Example:

```text
80% coverage means 80% of code is tested.
```

---

# Quality Gate Example

Example policy:

| Rule | Condition |
|---|---|
| Bugs | 0 Critical Bugs |
| Vulnerabilities | 0 High Severity |
| Coverage | > 80% |
| Duplications | < 5% |

---

# Benefits of SonarQube in DevOps

- Continuous quality validation
- Early bug detection
- Security improvement
- Better maintainability
- Automated governance

---

# Real-World Example

Without SonarQube:

```text
Developer → Deploy → Production Bug
```

With SonarQube:

```text
Developer → SonarQube Scan → Quality Gate → Safe Deployment
```

---

# Best Practices

- Scan every code commit
- Enforce quality gates
- Use automated testing
- Monitor vulnerabilities
- Review code coverage regularly

---

# Summary

In this session you learned:

- Testing automation concepts
- Quality gates
- SonarQube architecture
- Static code analysis
- CI/CD quality validation
- AWS services used with SonarQube
