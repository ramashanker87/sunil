
# Day 06 – DevOps Lab
# Beginner-Friendly AWS CI/CD Pipeline Lab

## Objective

Build a complete CI/CD pipeline using:

- AWS CodeCommit
- AWS CodePipeline
- AWS CodeBuild
- AWS CodeDeploy
- Amazon EC2

This lab is simplified for:
- Beginners
- AWS Console users
- 1-hour classroom labs
- Smooth successful deployment

---

# Final Architecture

```text
Developer
   ↓
AWS CodeCommit
   ↓
AWS CodePipeline
   ↓
AWS CodeBuild
   ↓
AWS CodeDeploy
   ↓
EC2 Web Server
```

---

# Expected Result

After successful deployment:

```text
http://EC2-PUBLIC-IP
```

Displays:

```html
<h1>CI/CD Pipeline Deployment Successful</h1>
```

---

# Prerequisites

Before starting:

- AWS Account
- Git installed locally
- SSH Key Pair
- Internet connection

Recommended Region:

```text
us-east-1
```

---

# Step 1 – Launch EC2 Instance

Open:

```text
AWS Console → EC2 → Launch Instance
```

Configuration:

| Setting | Value |
|---|---|
| Name | rama-day06-lab |
| AMI | Amazon Linux 2 |
| Instance Type | t2.micro |
| Key Pair | Existing key pair |
| Security Group | Allow SSH + HTTP |

Security Group Rules:

| Type | Port |
|---|---|
| SSH | 22 |
| HTTP | 80 |

Launch instance.

---

# Step 2 – Create EC2 IAM Role

Open:

```text
IAM → Roles → Create Role
```

Select:

```text
AWS Service → EC2
```

Attach policy:

```text
AmazonS3ReadOnlyAccess
```

Role name:

```text
EC2_Pipe_Rama_Role
```

Attach role to EC2:

```text
EC2 → Instance → Actions → Security → Modify IAM Role
```

Select:

```text
Rama_EC2_CodeDeploy_Role
```

---

# Step 3 – Connect to EC2

```bash
ssh -i rama-ec2.pem ec2-user@<PUBLIC-IP>
```

---

# Step 4 – Install Apache Web Server

Run:

```bash
sudo yum update -y

sudo yum install httpd -y

sudo systemctl start httpd

sudo systemctl enable httpd
```

Test:

```bash
echo "<h1>Server Running</h1>" | sudo tee /var/www/html/index.html
```

Open browser:

```text
http://EC2-PUBLIC-IP
```

---

# Step 5 – Install CodeDeploy Agent

Run:

```bash
sudo yum install ruby wget -y

cd /home/ec2-user

wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install

chmod +x install

sudo ./install auto
```

Start agent:

```bash
sudo service codedeploy-agent restart
```

Verify:

```bash
sudo service codedeploy-agent status
```

Expected:

```text
The AWS CodeDeploy agent is running
```

Verify IAM credentials:

```bash
sudo yum install curl -y
curl http://54.198.227.76/latest/meta-data/iam/security-credentials/
```

Should return:

```text
Rama_EC2_CodeDeploy_Role
```

---

# Step 6 – Create CodeCommit Repository

Open:

```text
AWS Console → CodeCommit
```

Create repository:

| Setting | Value |
|---|---|
| Repository Name | sample-app-repo-rama |

---

# Step 7 – Create Application Files

Create folder:

```text
sample-app
```

Inside create these files.

---

## index.html

```html
<h1>CI/CD Pipeline Deployment Successful</h1>
```

---

## buildspec.yml

```yaml
version: 0.2

phases:
  build:
    commands:
      - echo "Build successful"

artifacts:
  files:
    - '**/*'
```

---

## appspec.yml

IMPORTANT:

```yaml
version: 0.0
os: linux

files:
  - source: /
    destination: /var/www/html
    overwrite: true
```

The line below prevents deployment failure:

```yaml
overwrite: true
```

---

# Step 8 – Push Code to CodeCommit

Clone repository:

```bash
git clone https://git-codecommit.us-east-1.amazonaws.com/v1/repos/sample-app-repo-rama
```

Copy files into repository folder.

Run:

```bash
aws sts get-caller-identity --profile devops
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true
export AWS_PROFILE=devops

git add .
git commit -m "Initial commit"
git push origin master
```

---

# Step 9 – Create IAM Roles

## A. CodeBuild Role

Open:

```text
IAM → Roles → Create Role
```

Select:

```text
AWS Service → CodeBuild
```

Attach:

```text
AmazonS3FullAccess
CloudWatchLogsFullAccess
```

Role Name:

```text
Rama_CodeBuild_Role
```

---

## B. CodeDeploy Role

Select:

```text
AWS Service → CodeDeploy
```

Attach:

```text
AWSCodeDeployRole
```

Role Name:

```text
Rama_CodeDeploy_Role
```

---

## C. CodePipeline Role

Select:

```text
AWS Service → CodePipeline
```

Attach ALL:

```text
AWSCodePipelineFullAccess
AWSCodeCommitReadOnly
AWSCodeBuildDeveloperAccess
AWSCodeDeployDeployerAccess
AmazonS3FullAccess
```

Role Name:

```text
Rama_CodePipeline_Role
```

IMPORTANT:

Without these permissions the pipeline fails.

---

# Step 10 – Create CodeBuild Project

Open:

```text
AWS Console → CodeBuild
```

Create project:

| Setting | Value |
|---|---|
| Project Name | sample-build-rama |
| Source Provider | AWS CodeCommit |
| Repository | sample-app-repo-rama |
| Environment | Managed Image |
| OS | Amazon Linux 2 |
| Runtime | Standard |
| Service Role | Rama_CodeBuild_Role |

Buildspec:

```text
Use buildspec.yml
```

Artifacts:

```text
No artifacts
```

Create project.

---

# Step 11 – Create CodeDeploy Application

Open:

```text
AWS Console → CodeDeploy
```

Create application:

| Setting | Value |
|---|---|
| Application Name | sample-app-rama |
| Compute Platform | EC2/On-Premises |

---

# Step 12 – Create Deployment Group

Configuration:

| Setting | Value |
|---|---|
| Deployment Group | sample-deployment-group-rama |
| Service Role | Rama_CodeDeploy_Role |
| Deployment Type | In-place |

Environment Configuration:

```text
Amazon EC2 Instances
```

Tag configuration:

| Key | Value |
|---|---|
| Name | rama-day06-lab |

Deployment Config:

```text
CodeDeployDefault.AllAtOnce
```

Load Balancer:

```text
Disable Load Balancer
```

Create deployment group.

---

# Step 13 – Create Pipeline

Open:

```text
AWS Console → CodePipeline
```

Select:

```text
Build Custom Pipeline
```

---

## Pipeline Settings

| Setting | Value |
|---|---|
| Pipeline Name | sample-pipeline-rama |
| Service Role | Existing Role |
| Role | Rama_CodePipeline_Role |

---

## Source Stage

| Setting | Value                |
|---|----------------------|
| Source Provider | AWS CodeCommit       |
| Repository | sample-app-repo-rama |
| Branch | master               |

---

## Build Stage

| Setting | Value |
|---|---|
| Provider | AWS CodeBuild |
| Build Project | sample-build-rama |

---

## Deploy Stage

| Setting | Value |
|---|---|
| Provider | AWS CodeDeploy |
| Application | sample-app-rama |
| Deployment Group | sample-deployment-group-rama |

Create pipeline.

---

# Step 14 – Run Pipeline

Pipeline starts automatically.

Stages:

```text
Source → Build → Deploy
```

All stages should become green.

---

## Verify any Error in deploy.
    
    sudo grep -i -A10 -B10 "Install\|UnknownError\|error\|failed" /var/log/aws/codedeploy-agent/codedeploy-agent.log

# Step 15 – Validate Deployment

Open:

```text
http://EC2-PUBLIC-IP
```

Expected:

```html
<h1>CI/CD Pipeline Deployment Successful</h1>
```

---

# Common Errors and Fixes

---

## Error: codecommit:GetBranch AccessDenied

Fix:

Attach to CodePipeline role:

```text
AWSCodeCommitReadOnly
```

---

## Error: s3:PutObject AccessDenied

Fix:

Attach:

```text
AmazonS3FullAccess
```

to:

```text
Rama_CodePipeline_Role
```

---

## Error: codebuild:StartBuild AccessDenied

Fix:

Attach:

```text
AWSCodeBuildDeveloperAccess
```

---

## Error: codedeploy:CreateDeployment AccessDenied

Fix:

Attach:

```text
AWSCodeDeployDeployerAccess
```

---

## Error: Missing credentials

Message:

```text
Missing credentials - please check if this instance was started with an IAM instance profile
```

Fix:

Attach EC2 IAM role:

```text
Rama_EC2_CodeDeploy_Role
```

Restart agent:

```bash
sudo service codedeploy-agent restart
```

---

## Error: CodeDeploy agent not running

Fix:

```bash
sudo service codedeploy-agent restart

sudo service codedeploy-agent status
```

---

## Error: File already exists

Message:

```text
specified file already exists at this location
```

Fix:

Add:

```yaml
overwrite: true
```

inside:

```yaml
appspec.yml
```

---

## Error: HEALTH_CONSTRAINTS

Usually caused by:
- CodeDeploy agent stopped
- Wrong EC2 tag
- Missing IAM role
- Existing files conflict

Quick fix:

```bash
sudo rm -rf /var/www/html/*

sudo service codedeploy-agent restart

sudo systemctl restart httpd
```

---

# Useful Commands

## Check CodeDeploy Logs

```bash
sudo tail -n 100 /var/log/aws/codedeploy-agent/codedeploy-agent.log
sudo grep -i -A10 -B10 "Install\|UnknownError\|error\|failed" /var/log/aws/codedeploy-agent/codedeploy-agent.log
```

---

## Restart CodeDeploy Agent

```bash
sudo service codedeploy-agent restart
```

---

## Check Apache

```bash
sudo systemctl status httpd
```

---

# Success Checklist

✅ EC2 running  
✅ CodeDeploy agent running  
✅ IAM roles attached  
✅ Pipeline stages green  
✅ Website accessible  

---

# AWS Services Used

| Service | Purpose |
|---|---|
| CodeCommit | Source Repository |
| CodePipeline | CI/CD Workflow |
| CodeBuild | Build Process |
| CodeDeploy | Deploy to EC2 |
| EC2 | Web Server |

---

# Final Result

You successfully created a beginner-friendly AWS CI/CD pipeline using AWS native DevOps services.
