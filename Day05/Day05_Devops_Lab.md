# Day 05 – DevOps Lab

## Module 1 – DevOps & CI/CD Fundamentals
### Date: 22-May-2026 (Friday)

# Lab Guide – Blue/Green & Canary Deployments on AWS

---

# Lab 1 – Blue/Green Deployments using AWS CodeDeploy

## Objective

Learn how to perform Blue/Green deployments using:

- AWS EC2
- AWS CodeDeploy
- Application Load Balancer (ALB)
- Amazon S3

---

# Architecture Overview

```text
                Users
                   |
                   v
        Application Load Balancer
              /              \
             /                \
   Blue Environment      Green Environment
   (Current Version)     (New Version)
```

---

# Prerequisites

Ensure you have:

- AWS Account
- IAM User with Admin/DevOps permissions
- EC2 Key Pair
- S3 Bucket
- AWS CLI installed (optional)
- Internet-enabled EC2 instances

---

# Step 1 – Launch EC2 Instances

## Create 4 EC2 Instances

| Environment | Number of Instances |
|---|---|
| Blue | 2 |
| Green | 2 |

## EC2 Configuration

### AMI
- Amazon Linux 2

### Instance Type
- t2.micro

### Security Group

Allow:

| Type | Port |
|---|---|
| SSH | 22 |
| HTTP | 80 |

## Launch using AWS Console

1. Open EC2 Console
2. Click Launch Instance
3. Configure:
   - Name
   - Amazon Linux 2
   - t2.micro
4. Select Key Pair
5. Configure Security Group
6. Launch instance

Repeat until 4 instances are created.

---

# Step 2 – Install Apache Web Server

SSH into each EC2 instance.

## Connect to EC2

```bash
ssh -i sunil.pem ec2-user@18.208.216.246
```

## Install Apache

```bash
sudo yum update -y
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
```

## Test Apache

```bash
echo "<h1>Blue Server-1</h1>" | sudo tee /var/www/html/index.html
echo "<h1>Blue Server-2</h1>" | sudo tee /var/www/html/index.html
echo "<h1>green Server-3</h1>" | sudo tee /var/www/html/index.html
echo "<h1>green Server-4</h1>" | sudo tee /var/www/html/index.html
```

Open browser:

```text
http://<EC2-PUBLIC-IP>
```

---

# Step 3 – Install CodeDeploy Agent

Run on ALL EC2 instances.

## Install Required Packages

```bash
sudo yum update -y
sudo yum install ruby wget -y
```

## Download CodeDeploy Agent

```bash
cd /home/ec2-user

wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
```

## Give Execute Permission

```bash
chmod +x ./install
```

## Install Agent

```bash
sudo ./install auto
```

## Verify Agent Status

```bash
sudo service codedeploy-agent status
```

Expected output:

```text
The AWS CodeDeploy agent is running
```

---

# Step 4 – Create IAM Role for EC2

## Create Role

1. Open IAM Console
2. Click Roles
3. Click Create Role

## Select Trusted Entity

- AWS Service
- EC2

## Attach Policies

Attach:

```text
AmazonEC2RoleforAWSCodeDeploy
AmazonS3ReadOnlyAccess
```

## Attach Role to EC2

1. Go to EC2
2. Select instances
3. Actions → Security → Modify IAM Role
4. Attach created role

---

# Step 5 – Create Application Files

Create local folder:

```bash
mkdir sample-app
cd sample-app
```

## Create Directory Structure

```text
sample-app/
 ├── appspec.yml
 ├── index.html
 └── scripts/
      ├── install.sh
      └── start_server.sh
```

---

# Step 6 – Create Application Files

## Create index.html

```bash
nano index.html
```

Add:

```html
<h1>Blue/Green Deployment Success</h1>
```

## Create install.sh

```bash
mkdir scripts
nano scripts/install.sh
```

Add:

```bash
#!/bin/bash
yum install httpd -y
systemctl start httpd
systemctl enable httpd
```

## Create start_server.sh

```bash
nano scripts/start_server.sh
```

Add:

```bash
#!/bin/bash
systemctl restart httpd
```

## Give Execute Permissions

```bash
chmod +x scripts/install.sh
chmod +x scripts/start_server.sh
```

---

# Step 7 – Create appspec.yml

```bash
nano appspec.yml
```

Add:

```yaml
version: 0.0
os: linux

files:
  - source: /
    destination: /var/www/html

hooks:
  BeforeInstall:
    - location: scripts/install.sh
      timeout: 300
      runas: root

  ApplicationStart:
    - location: scripts/start_server.sh
      timeout: 300
      runas: root
```

---

# Step 8 – Package Application

Install zip if needed:

```bash
sudo yum install zip -y
```

## Create ZIP File

```bash
zip -r sample-app.zip .
```

Verify:

```bash
ls
```

Expected:

```text
sample-app.zip
```

---

# Step 9 – Upload Package to S3

## Create S3 Bucket

1. Open S3 Console
2. Create bucket:
   - Unique bucket name
3. Keep defaults
4. Create bucket

## Upload ZIP

Upload:

```text
sample-app.zip
```

---

# Step 10 – Create CodeDeploy Application

## Open CodeDeploy Console

1. AWS Console
2. Search:
   - CodeDeploy

## Create Application

| Field | Value |
|---|---|
| Application Name | DevOpsTrainingApp |
| Compute Platform | EC2/On-Premises |

Click:

```text
Create Application
```

---

# Step 11 – Create Deployment Group

## Configuration

| Setting | Value |
|---|---|
| Deployment Group Name | BlueGreenDG |
| Service Role | CodeDeployServiceRole |
| Deployment Type | Blue/Green |
| Environment Configuration | EC2 Instances |

## Add EC2 Tags

| Key | Value |
|---|---|
| Environment | Blue |

---

# Step 12 – Create Load Balancer

## Create Application Load Balancer

1. Open EC2 Console
2. Load Balancers
3. Create ALB

## Configure

| Setting | Value |
|---|---|
| Scheme | Internet-facing |
| Listener | HTTP:80 |

## Create Target Groups

Create:

- blue-target-group
- green-target-group

Attach respective EC2 instances.

---

# Step 13 – Start Deployment

## Create Deployment

1. Open CodeDeploy
2. Select application
3. Click:
   - Create Deployment

## Deployment Settings

| Setting | Value |
|---|---|
| Revision Type | My application is stored in Amazon S3 |
| Bucket | Your S3 bucket |
| Bundle Type | ZIP |

---

# Step 14 – Monitor Deployment

Open:

```text
CodeDeploy → Deployments
```

Monitor:

- Lifecycle events
- Deployment status
- Traffic shifting

---

# Step 15 – Validate Blue/Green Deployment

Open ALB DNS:

```text
http://<ALB-DNS-NAME>
```

Verify:

- Application loads successfully
- Traffic shifts to Green
- No downtime occurs

---

# Step 16 – Rollback Deployment (Optional)

If deployment fails:

1. Open Deployment
2. Click:
   - Stop and Rollback
