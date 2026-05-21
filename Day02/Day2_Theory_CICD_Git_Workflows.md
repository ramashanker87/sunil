# Theory.md — Day 2 CI/CD Fundamentals

# Day 2 — CI/CD Concepts, Git Workflows & Merge/Rebase Strategies

## Duration
**1.5 Hours Theory Session**

---

# Agenda

| Time | Topic |
|------|------|
| 00:00 – 00:20 | CI/CD Concepts |
| 00:20 – 00:45 | Git Workflows |
| 00:45 – 01:05 | Merge Strategies |
| 01:05 – 01:20 | Rebase Strategies |
| 01:20 – 01:30 | Summary & Q/A |

---

# 1. Introduction to CI/CD

## What is CI/CD?

CI/CD stands for:

- Continuous Integration (CI)
- Continuous Delivery (CD)
- Continuous Deployment

CI/CD is a modern software delivery practice that automates:

- Code integration
- Testing
- Build process
- Deployment

---

# Continuous Integration (CI)

## Definition

Continuous Integration is the process where developers frequently merge code changes into a shared repository.

Each code change triggers:

- Automated build
- Automated testing
- Code validation

---

# CI Workflow

```text
Developer Commit
        |
        v
Git Repository
        |
        v
Automated Build
        |
        v
Automated Testing
        |
        v
Validation Report
```

---

# Benefits of Continuous Integration

- Faster bug detection
- Reduced integration issues
- Improved code quality
- Faster development cycles
- Automated validation

---

# Continuous Delivery (CD)

## Definition

Continuous Delivery ensures software is always ready for deployment.

Applications automatically:

- Build
- Test
- Package
- Prepare for release

Deployment requires manual approval.

---

# Continuous Deployment

## Definition

Continuous Deployment automatically deploys code to production after successful testing.

No manual approval is required.

---

# CI vs Continuous Delivery vs Continuous Deployment

| Feature | CI | Continuous Delivery | Continuous Deployment |
|---|---|---|---|
| Automated Build | Yes | Yes | Yes |
| Automated Testing | Yes | Yes | Yes |
| Production Deployment | No | Manual Approval | Automatic |

---

# CI/CD Pipeline

```text
Code → Build → Test → Package → Deploy → Monitor
```

---

# Benefits of CI/CD

## Technical Benefits

- Faster releases
- Reduced deployment failures
- Automated testing
- Consistent deployments

## Business Benefits

- Faster time to market
- Improved customer satisfaction
- Reduced downtime

---

# Popular CI/CD Tools

| Tool | Purpose |
|---|---|
| GitHub Actions | CI/CD automation |
| Jenkins | Build automation |
| GitLab CI | CI/CD pipelines |
| AWS CodePipeline | Deployment orchestration |
| AWS CodeBuild | Build service |
| AWS CodeDeploy | Deployment automation |

---

# 2. Git Workflows

## What is a Git Workflow?

A Git workflow defines how developers:

- Create branches
- Commit code
- Merge changes
- Collaborate with teams

---

# Common Git Workflows

| Workflow | Description |
|---|---|
| Centralized Workflow | Single main branch |
| Feature Branch Workflow | Separate branch per feature |
| Gitflow Workflow | Structured branching strategy |
| Forking Workflow | External contributor model |
| Trunk-Based Development | Short-lived feature branches |

---

# Feature Branch Workflow

## Workflow Steps

1. Create feature branch
2. Develop feature
3. Commit changes
4. Create pull request
5. Review code
6. Merge into main branch

---

# Feature Branch Workflow Diagram

```text
main
 |
 +---- feature-login
 |
 +---- feature-payment
 |
 +---- feature-dashboard
```

---

# Gitflow Workflow

## Main Branches

| Branch | Purpose |
|---|---|
| main/master | Production code |
| develop | Integration branch |
| feature | New features |
| release | Release preparation |
| hotfix | Emergency fixes |

---

# Gitflow Diagram

```text
main
  |
  +---------------------+
                        |
develop ----------------+---------
     |                  |
     +-- feature-login  |
     +-- feature-api    |
                        |
release ----------------+
                        |
hotfix -----------------+
```

---

# Trunk-Based Development

## Characteristics

- Developers commit frequently
- Small feature branches
- Faster integration
- Frequent releases

---

# Best Practices for Git Workflows

- Use meaningful branch names
- Commit small changes
- Write clear commit messages
- Use pull requests
- Perform code reviews

---

# 3. Merge Strategies

## What is Merge?

Merge combines changes from one branch into another.

---

# Git Merge Example

```bash
git checkout main
git merge feature-login
```

---

# Merge Types

| Merge Type | Description |
|---|---|
| Fast-Forward Merge | Direct branch movement |
| Three-Way Merge | Creates merge commit |
| Squash Merge | Combines commits |
| Recursive Merge | Default Git strategy |

---

# Fast-Forward Merge

```text
A---B---C main
         \
          D---E feature
```

After merge:

```text
A---B---C---D---E main
```

---

# Three-Way Merge

Creates a dedicated merge commit.

```text
A---B---C main
     \     \
      D---E M
```

---

# Squash Merge

Combines all feature commits into one commit.

Benefits:

- Cleaner history
- Easier rollback
- Simplified commit logs

---

# Merge Conflicts

## Causes

- Same file modified
- Same lines updated
- Concurrent changes

---

# Conflict Example

```text
<<<<<<< HEAD
Current branch code
=======
Incoming branch code
>>>>>>> feature-login
```

---

# Conflict Resolution Steps

1. Open conflicting file
2. Edit required changes
3. Remove conflict markers
4. Save file
5. Commit changes

---

# 4. Rebase Strategies

## What is Rebase?

Rebase moves feature branch commits on top of another branch.

---

# Rebase Example

```bash
git checkout feature-login
git rebase main
```

---

# Merge vs Rebase

| Merge | Rebase |
|---|---|
| Preserves history | Creates linear history |
| Creates merge commit | No merge commit |
| Easier for teams | Cleaner history |

---

# Rebase Workflow

```text
Before Rebase:

main:     A---B---C
               \
feature:        D---E

After Rebase:

main:     A---B---C
                   \
feature:            D'---E'
```

---

# Advantages of Rebase

- Cleaner commit history
- Linear project history
- Easier troubleshooting

---

# Rebase Best Practices

- Avoid rebasing shared branches
- Rebase local branches only
- Pull latest changes before rebasing

---

# AWS Resources Overview

| Service | Purpose |
|---|---|
| GitHub | Source code management |
| CodeCommit | AWS Git repository |
| IAM | Access management |

---

# Real-World CI/CD Example

1. Developer pushes code to GitHub
2. GitHub Actions pipeline starts
3. Automated build executes
4. Tests run automatically
5. Deployment pipeline triggers
6. Application deploys successfully

---

# Key Takeaways

## CI/CD
- Automates software delivery
- Improves deployment reliability

## Git Workflows
- Standardizes team collaboration

## Merge/Rebase
- Helps integrate code effectively

---

# Interview Questions

1. What is CI/CD?
2. Difference between CI and CD?
3. What is Gitflow workflow?
4. Difference between Merge and Rebase?
5. What are merge conflicts?
6. Explain branch protection.

---

# Summary

In this session, we covered:

- CI/CD fundamentals
- Git workflows
- Merge strategies
- Rebase strategies
- Branching best practices
- AWS DevOps services overview

---
