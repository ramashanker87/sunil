# Day 16 – 08-Jun-2026 (Monday)
# Module 3 – Containerization & Registry Management

# Lab: ECS Cluster & AWS Fargate Deployment

## Lab Objectives

Participants will:

- Create ECS cluster.
- Create Task Definition.
- Deploy container on Fargate.
- Configure ALB.
- Verify service availability.
- Monitor application using CloudWatch.

---

# AWS Resources Used

- Amazon ECS
- AWS Fargate
- Amazon ECR
- Application Load Balancer
- CloudWatch
- IAM

---

# Lab 1: Verify Container Image

Verify image exists in ECR:

```bash
aws ecr list-images --repository-name sunil-ecr --region us-east-1 --profile devops
```

Record:
- Repository URI
- Image Tag

---

# Lab 2: Create ECS Cluster

AWS Console:

ECS → Clusters → Create Cluster

Configuration:

Cluster Name:
training-cluster

Infrastructure:
AWS Fargate

Create Cluster

Verify Cluster Status:
Active

---

# Lab 3: Create Task Definition

ECS → Task Definitions → Create

Configuration:

Task Definition Name:
sunil-task

Launch Type:
Fargate

CPU:
0.25 vCPU

Memory:
0.5 GB

Container:

Name:
sunil-app

Image:
ACCOUNT_ID.dkr.ecr.eu-north-1.amazonaws.com/hello-ecr:v2

Port:
8080

Create Task Definition

---

# Lab 4: Create Security Group

Inbound Rules:

HTTP
Port 80

Custom TCP
Port 8080

Source:
0.0.0.0/0

Record Security Group ID.

---

# Lab 5: Create Application Load Balancer

EC2 → Load Balancers

Type:
Application Load Balancer

Name:
training-alb

Scheme:
Internet-facing

Listener:
HTTP 80

Target Type:
IP:

Create Load Balancer

Record DNS Name.

---

# Lab 6: Create ECS Service

Cluster:
training-cluster

Create Service

Configuration:

Launch Type:
Fargate

Task Definition:
hello-task

Desired Tasks:
1

Networking:

Assign Public IP:
Enabled

Security Group:
Created Earlier

Load Balancing:

Application Load Balancer

Target Group:
Create New

Create Service

---

# Lab 7: Verify Deployment

ECS → Services

Verify:

- Running Tasks = 1
- Service Status = Active

---

# Lab 8: Test Application

Open:

http://ALB-DNS-NAME

Expected:

Hello from Docker and Amazon ECR!

---

# Lab 9: View Running Tasks

ECS → Cluster → Tasks

Record:

- Task ARN
- Task Status
- Task IP Address

---

# Lab 10: Monitor Using CloudWatch

CloudWatch → Metrics

View:

- CPU Utilization
- Memory Utilization

Create Dashboard:

Name:
ecs-training-dashboard

Add:
- CPU Graph
- Memory Graph

---

# Lab 11: View Application Logs

CloudWatch → Log Groups

Locate:

/ecs/hello-task

Review:
- Startup Logs
- Request Logs
- Errors

---

# Lab 12: Scale Service

Update Service

Desired Tasks:

1 → 2

Verify:

Two tasks running.

Refresh application.

Observe Load Balancing.

---

# Lab 13: Configure Auto Scaling

ECS Service → Auto Scaling

Minimum:
1

Maximum:
4

Target CPU:
70%

Save Configuration

---

# Lab 14: Cleanup Resources

Delete:

- ECS Service
- ECS Cluster
- ALB
- Target Group
- Security Group

Verify no charges remain.

---

# Challenge Exercise

Deploy:

1. Custom Docker image
2. Push image to ECR
3. Create ECS Task Definition
4. Deploy using Fargate
5. Configure ALB
6. Enable CloudWatch Logs

Document:

- Screenshots
- Task Definition
- Service Details
- Monitoring Dashboard

---

# Lab Deliverables

Submit:

- ECS Cluster Screenshot
- Task Definition Screenshot
- Running Service Screenshot
- ALB URL Screenshot
- CloudWatch Dashboard Screenshot
- Scaling Demonstration Screenshot

---

# Expected Learning Outcomes

✓ Create ECS Clusters

✓ Create Task Definitions

✓ Deploy Containers using Fargate

✓ Configure Load Balancers

✓ Monitor with CloudWatch

✓ Scale ECS Services

✓ Deploy Production-Ready Container Workloads
