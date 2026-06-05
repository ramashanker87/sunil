# Day 09 – DevOps Lab
# Simple CloudFormation Lab

## Module 2 – Infrastructure as Code (IaC)
### Date: 28-May-2026 (Thursday)

---

# Lab Objective

In this lab you will:

- Create CloudFormation template
- Deploy EC2 using CloudFormation
- Create VPC resources
- Automate infrastructure deployment

This lab is simplified for beginners.

Estimated Time:

```text
1 Hour
```

---

# Architecture

```text
CloudFormation Template
           ↓
CloudFormation Stack
           ↓
VPC + EC2 + Security Group
```

---

# AWS Resources Used

| Resource | Purpose |
|---|---|
| CloudFormation | Infrastructure automation |
| EC2 | Application server |
| VPC | Network configuration |

---

# Prerequisites

Before starting:

- AWS Account
- EC2 Key Pair
- Basic AWS Console knowledge

Recommended Region:

```text
us-east-1
```

---

# Part 1 – Create CloudFormation Template

## Step 1 – Create Template File

Create file:

```text
simple-ec2-template.yaml
```

---

# Step 2 – Add CloudFormation Template

Paste:

```yaml
AWSTemplateFormatVersion: '2010-09-09'

Description: Simple EC2 Deployment using CloudFormation

Resources:

  MySecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Allow SSH and HTTP

      SecurityGroupIngress:

        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 0.0.0.0/0

        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0

  MyEC2Instance:
    Type: AWS::EC2::Instance

    Properties:
      ImageId: ami-0c02fb55956c7d316
      InstanceType: t2.micro
      KeyName: mykey

      SecurityGroups:
        - !Ref MySecurityGroup

      Tags:
        - Key: Name
          Value: Day09-CloudFormation-Server
```

IMPORTANT:

Replace:

```text
mykey
```

with your EC2 Key Pair name.

---

# Part 2 – Create CloudFormation Stack

## Step 3 – Open CloudFormation

Open:

```text
AWS Console → CloudFormation
```

Click:

```text
Create Stack
```

---

## Command to create cloudformation

    aws cloudformation create-stack \
    --stack-name rama-ec2-stack \
    --template-body file://rama-ec2-template.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile devops



# Part 3 – Validate Resources

## Step 8 – Verify EC2 Instance

Open:

```text
AWS Console → EC2
```

Verify instance created:

```text
Day09-CloudFormation-Server
```

---

# Step 9 – Connect to EC2

```bash
ssh -i mykey.pem ec2-user@<PUBLIC-IP>
```

---

# Step 10 – Install Apache

Run:

```bash
sudo yum update -y

sudo yum install httpd -y

sudo systemctl start httpd

sudo systemctl enable httpd
```

---

# Step 11 – Create Test Web Page

```bash
echo "<h1>CloudFormation Deployment Successful</h1>" | sudo tee /var/www/html/index.html
```

---

# Step 12 – Validate Deployment

Open browser:

```text
http://<PUBLIC-IP>
```

Expected:

```html
<h1>CloudFormation Deployment Successful</h1>
```

---

# Part 4 – Demonstrate Stack Management

## Step 13 – View Stack Resources

Open:

```text
CloudFormation → day09-ec2-stack → Resources
```

Observe:

- EC2 Instance
- Security Group

---

# Step 14 – Demonstrate Stack Outputs

Explain:

```text
CloudFormation manages all resources together as a stack.
```

---

# Step 15 – Delete Stack

Open:

```text
CloudFormation → day09-ec2-stack
```

Click:

```text
Delete
```

## Delete cloudformation command

    aws cloudformation delete-stack \
    --stack-name rama-ec2-stack \
    --profile devops

# Common Errors and Fixes

---

# Template Validation Error

Verify:

- YAML indentation correct
- No missing spaces
- Correct syntax

---

# Key Pair Error

Message:

```text
The key pair does not exist
```

Fix:

Replace:

```text
mykey
```

with your actual key pair name.

---

# EC2 Not Accessible

Verify:

- Security Group allows port 22
- Correct public IP used
- Correct key pair used

---

# Website Not Opening

Verify Apache:

```bash
sudo systemctl status httpd
```

Restart:

```bash
sudo systemctl restart httpd
```

---

# Stack Creation Failed

Open:

```text
CloudFormation → Stack → Events
```

Check failed resource.

---

# Useful Commands

## Check Apache Status

```bash
sudo systemctl status httpd
```

---

## Restart Apache

```bash
sudo systemctl restart httpd
```

---

## Delete Stack

```text
CloudFormation → Delete Stack
```

---

# Success Checklist

✅ CloudFormation stack created

✅ EC2 instance running

✅ Security Group created

✅ Apache installed

✅ Website accessible

---

# Cleanup

To avoid AWS charges:

- Delete CloudFormation stack
- Verify EC2 terminated

---

# Summary

In this lab you completed:

- CloudFormation template creation
- Automated EC2 deployment
- Security Group automation
- Infrastructure as Code implementation
- Stack management
