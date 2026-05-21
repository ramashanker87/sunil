# Theory.md — Introduction to DevOps, CALMS Framework, Agile & SDLC Basics

# DevOps Fundamentals Training

# 1. Introduction to DevOps

## What is DevOps?

DevOps is a software engineering culture and practice that combines:

- Development (Dev)
- Operations (Ops)

The primary goal of DevOps is:

- Faster software delivery
- Better collaboration
- Automation
- Continuous improvement
- Reliable deployments

---

# Traditional IT Model

## Traditional Workflow

```text
Development Team → Testing Team → Operations Team → Production
```

## Challenges

- Communication gaps
- Slow deployments
- Manual infrastructure management
- High downtime
- Long release cycles

---

# DevOps Model

## Modern Workflow

```text
Plan → Code → Build → Test → Release → Deploy → Monitor
                  ↑_______________________________|
                     Continuous Feedback Loop
```

---

# DevOps Lifecycle

```text
+------------+
|    PLAN    |
+------------+
       |
       v
+------------+
|    CODE    |
+------------+
       |
       v
+------------+
|    BUILD   |
+------------+
       |
       v
+------------+
|    TEST    |
+------------+
       |
       v
+------------+
|   RELEASE  |
+------------+
       |
       v
+------------+
|   DEPLOY   |
+------------+
       |
       v
+------------+
|   MONITOR  |
+------------+
```

---

# Benefits of DevOps

## Technical Benefits

- Faster deployments
- Reduced failures
- Automated testing
- Infrastructure automation
- Improved monitoring

## Business Benefits

- Faster time to market
- Improved customer satisfaction
- Better product quality
- Reduced operational cost

---

# Key DevOps Practices

| Practice | Description |
|---|---|
| Continuous Integration | Frequent code integration |
| Continuous Delivery | Automated deployments |
| Infrastructure as Code | Infrastructure managed through code |
| Monitoring | Real-time system monitoring |
| Automation | Reduced manual tasks |

---

# 2. CALMS Framework

## What is CALMS?

CALMS is a DevOps maturity framework.

| Letter | Meaning |
|---|---|
| C | Culture |
| A | Automation |
| L | Lean |
| M | Measurement |
| S | Sharing |

---

# CALMS Diagram

```text
+--------------------------------+
|            CALMS               |
+--------------------------------+
| C → Culture                    |
| A → Automation                 |
| L → Lean                       |
| M → Measurement                |
| S → Sharing                    |
+--------------------------------+
```

---

## Culture

### Focus Areas

- Collaboration
- Team ownership
- Shared responsibility
- Communication

### Example

Developers and Operations teams work together during deployment.

---

## Automation

### What Can Be Automated?

- Build process
- Testing
- Deployment
- Infrastructure provisioning
- Monitoring

### Common Tools

- Jenkins
- GitHub Actions
- Terraform
- Ansible

---

## Lean

### Lean Principles

- Remove waste
- Improve efficiency
- Deliver faster
- Continuous improvement

### Examples of Waste

- Manual approvals
- Waiting time
- Repetitive tasks

---

## Measurement

### Important Metrics

- Deployment frequency
- Failure rate
- Mean Time to Recovery (MTTR)
- Lead time

### Monitoring Tools

- CloudWatch
- Prometheus
- Grafana

---

## Sharing

### Importance

- Knowledge sharing
- Team collaboration
- Documentation
- Transparency

---

# CALMS Summary

| Component | Goal |
|---|---|
| Culture | Collaboration |
| Automation | Speed |
| Lean | Efficiency |
| Measurement | Improvement |
| Sharing | Knowledge Transfer |

---

# 3. Agile Basics

## What is Agile?

Agile is a software development methodology focused on:

- Iterative development
- Customer collaboration
- Frequent delivery
- Continuous feedback

---

# Agile Workflow

```text
Backlog → Sprint Planning → Development → Testing → Review → Release
```

---

# Agile Principles

## Core Principles

- Deliver software frequently
- Accept changing requirements
- Encourage teamwork
- Continuous improvement

---

# Scrum Framework

| Component | Description |
|---|---|
| Product Owner | Defines requirements |
| Scrum Master | Facilitates process |
| Development Team | Builds software |
| Sprint | Short iteration cycle |
| Backlog | List of tasks |

---

# Sprint Lifecycle

```text
Product Backlog
       |
       v
Sprint Planning
       |
       v
Development
       |
       v
Testing
       |
       v
Sprint Review
       |
       v
Retrospective
```

---

# Agile vs Waterfall

| Waterfall | Agile |
|---|---|
| Sequential | Iterative |
| Late testing | Continuous testing |
| Fixed requirements | Flexible requirements |
| Slow delivery | Faster delivery |

---

# 4. SDLC Basics

## What is SDLC?

SDLC stands for:

**Software Development Life Cycle**

It defines the process used to build software systems.

---

# SDLC Phases

| Phase | Description |
|---|---|
| Requirement Gathering | Business requirements |
| Planning | Resource & timeline planning |
| Design | System architecture |
| Development | Coding |
| Testing | Validation |
| Deployment | Release to production |
| Maintenance | Bug fixes & updates |

---

# SDLC Diagram

```text
+---------------+
| Requirements  |
+---------------+
        |
        v
+---------------+
|   Planning    |
+---------------+
        |
        v
+---------------+
|    Design     |
+---------------+
        |
        v
+---------------+
| Development   |
+---------------+
        |
        v
+---------------+
|    Testing    |
+---------------+
        |
        v
+---------------+
|  Deployment   |
+---------------+
        |
        v
+---------------+
| Maintenance   |
+---------------+
```

---

# Relationship Between DevOps, Agile & SDLC

| Concept | Purpose |
|---|---|
| SDLC | Software development process |
| Agile | Development methodology |
| DevOps | Automation & operations integration |

---

# Real-World DevOps Example

## Example Workflow

1. Developer pushes code to GitHub
2. CI pipeline triggers automatically
3. Automated tests execute
4. Docker image is built
5. Deployment to cloud environment
6. Monitoring enabled using dashboards

---

# Key Takeaways

## DevOps
- Improves collaboration
- Accelerates delivery
- Enables automation

## CALMS
- Defines DevOps maturity

## Agile
- Supports iterative development

## SDLC
- Defines software delivery stages

---

# Quick Questions

1. What is DevOps?
2. What is CI/CD?
3. Explain CALMS framework.
4. Difference between Agile and Waterfall?
5. What are SDLC phases?
6. What is a Sprint?

---

# Summary

In this session, we covered:

- Introduction to DevOps
- DevOps lifecycle
- CALMS framework
- Agile fundamentals
- SDLC basics
- Relationship between Agile, SDLC, and DevOps

These concepts form the foundation for CI/CD, Cloud Engineering, Automation, and Kubernetes.

---
