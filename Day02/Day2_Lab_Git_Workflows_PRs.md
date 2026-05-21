# Lab.md — Day 2 Git Workflows & Pull Requests

# Day 2 — Git Workflows, Pull Requests & Branch Protection

## Lab Duration
**2 Hours**

---

# Lab Objectives

By the end of this lab, learners will be able to:

- Create Git workflows
- Work with feature branches
- Create pull requests
- Merge code changes
- Configure branch protection rules
- Collaborate using GitHub

---

# Prerequisites

- Git installed
- GitHub account
- VS Code or terminal
- Internet connection

---

# Part 1: Repository Setup

## Clone Existing Repository

```bash
git clone https://github.com/USERNAME/devops-git-lab.git
```

Navigate to repository:

```bash
cd devops-git-lab
```

---

# Part 2: Feature Branch Workflow

## Step 1: Create Feature Branch

```bash
git checkout -b feature-login
```

Verify branch:

```bash
git branch
```

---

## Step 2: Create New File

```bash
echo "Login module" > login.txt
```

---

## Step 3: Add and Commit Changes

```bash
git add login.txt
git commit -m "Added login feature"
```

---

## Step 4: Push Feature Branch

```bash
git push origin feature-login
```

---

# Part 3: Pull Request Workflow

## Step 1: Open GitHub Repository

Navigate to repository in GitHub.

---

## Step 2: Create Pull Request

1. Click "Compare & pull request"
2. Select:
   - Base branch: main
   - Compare branch: feature-login
3. Add title and description
4. Click "Create Pull Request"

---

# Pull Request Best Practices

- Use meaningful titles
- Add detailed descriptions
- Include screenshots if required
- Request reviewers

---

# Part 4: Merge Pull Request

## Step 1: Review Pull Request

Review:
- Code changes
- Commit history
- File modifications

---

## Step 2: Merge Pull Request

Select merge strategy:

- Merge commit
- Squash merge
- Rebase merge

Click:

```text
Merge Pull Request
```

---

# Part 5: Merge Strategies Practice

## Create New Branch

```bash
git checkout -b feature-dashboard
```

---

## Add New File

```bash
echo "Dashboard module" > dashboard.txt
```

---

## Commit Changes

```bash
git add dashboard.txt
git commit -m "Added dashboard feature"
```

---

## Push Branch

```bash
git push origin feature-dashboard
```

---

# Part 6: Rebase Practice

## Update Main Branch

```bash
git checkout main
git pull origin main
```

---

## Switch to Feature Branch

```bash
git checkout feature-dashboard
```

---

## Rebase Feature Branch

```bash
git rebase main
```

---

# Part 7: Branch Protection Rules

## Configure Branch Protection

Navigate:

```text
Repository → Settings → Branches
```

---

## Create Branch Protection Rule

Protect:

```text
main
```

---

# Enable Rules

Enable:

- Require pull request before merging
- Require approvals
- Require status checks
- Restrict force pushes

---

# Branch Protection Benefits

- Prevent accidental changes
- Enforce code reviews
- Improve security
- Maintain code quality

---

# Part 8: Simulate Merge Conflict

## Create Conflict Branch

```bash
git checkout -b feature-conflict
```

---

## Modify Same File

Edit README.md

Commit changes:

```bash
git add README.md
git commit -m "Updated README in feature branch"
```

---

## Switch to Main

```bash
git checkout main
```

Modify same README.md differently.

Commit:

```bash
git add README.md
git commit -m "Updated README in main branch"
```

---

## Merge Conflict

```bash
git merge feature-conflict
```

---

# Resolve Conflict

1. Open conflicting file
2. Remove conflict markers
3. Save file
4. Commit resolution

```bash
git add README.md
git commit -m "Resolved merge conflict"
```

---

# Validation Checklist

| Task | Status |
|---|---|
| Feature branch created | ✅ |
| Pull request created | ✅ |
| Pull request merged | ✅ |
| Rebase completed | ✅ |
| Branch protection configured | ✅ |
| Merge conflict resolved | ✅ |

---

# Common Git Commands

| Command | Purpose |
|---|---|
| git checkout -b branch-name | Create branch |
| git add . | Stage changes |
| git commit -m "msg" | Commit changes |
| git push origin branch | Push branch |
| git pull | Pull latest changes |
| git merge | Merge branch |
| git rebase | Rebase branch |
| git branch | View branches |

---

# Lab Assignment

## Create Following Branches

```text
feature-authentication
feature-profile
feature-notifications
```

Each branch should:

- Create one file
- Commit changes
- Push to GitHub
- Create pull request
- Merge into main branch

---

# Expected Repository Structure

```text
devops-git-lab/
├── README.md
├── login.txt
├── dashboard.txt
├── authentication.txt
├── profile.txt
└── notifications.txt
```

---

# Summary

In this lab, you practiced:

- Git workflows
- Feature branching
- Pull requests
- Merge strategies
- Rebase operations
- Branch protection rules
- Merge conflict resolution

---
