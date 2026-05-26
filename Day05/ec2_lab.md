# EC2 Blue/Green Deployment Lab Guide

# Day 05 – DevOps Lab

## Module 1 – DevOps & CI/CD Fundamentals
### Date: 22-May-2026 (Friday)

---

# Your 4 EC2 Instances

| Instance Name | Purpose |
|---|---|
| blue-1 | Blue Environment |
| blue-2 | Blue Environment |
| green-1 | Green Environment |
| green-2 | Green Environment |

---

# STEP 1 — Launch ALL 4 EC2 Instances

While creating EACH instance:

## Use

| Setting | Value |
|---|---|
| AMI | Amazon Linux 2 |
| Type | t2.micro |
| Key Pair | rama-ec2.pem |
| Public IP | ENABLE |
| Security Group | Allow 22 and 80 |

---

# STEP 2 — Verify ALL EC2 Have Public IP

Go:

```text
EC2 → Instances
```

Verify EACH instance has:

```text
Public IPv4 address
```

---

# STEP 3 — SSH INTO blue-1

```bash
chmod 400 rama-ec2.pem
blue-1
ssh -i rama-ec2.pem ec2-user@34.228.55.11    
blue-2
ssh -i rama-ec2.pem ec2-user@3.93.171.13 
green-1    
ssh -i rama-ec2.pem ec2-user@34.234.64.136   
green-2
ssh -i rama-ec2.pem ec2-user@34.228.69.115   

```

---

# STEP 4 — INSTALL APACHE ON blue-1

```bash
sudo yum update -y
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
```

---

# STEP 5 — TEST APACHE ON blue-1

```bash
echo "<h1>BLUE-1 SERVER</h1>" | sudo tee /var/www/html/index.html
```

Verify:

```bash
curl localhost
```

Check service:

```bash
sudo systemctl status httpd
```

Expected:

```text
active (running)
```

---

# STEP 6 — INSTALL CODEDEPLOY AGENT ON blue-1

```bash
sudo yum install ruby wget -y

cd /home/ec2-user

wget https://aws-codedeploy-eu-north-1.s3.eu-north-1.amazonaws.com/latest/install

chmod +x ./install

sudo ./install auto

sudo service codedeploy-agent start
```

Verify:

```bash
sudo service codedeploy-agent status
```

Expected:

```text
The AWS CodeDeploy agent is running
```

---

# STEP 7 — TEST blue-1 IN BROWSER

Open:

```text
http://<BLUE-1-PUBLIC-IP>
```

Expected:

```text
BLUE-1 SERVER
```

---

# STEP 8 — REPEAT SAME FOR blue-2

```bash
ssh -i rama-ec2.pem ec2-user@<BLUE-2-PUBLIC-IP>
```

Install Apache:

```bash
sudo yum update -y
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
```

Create page:

```bash
echo "<h1>BLUE-2 SERVER</h1>" | sudo tee /var/www/html/index.html
```

Test:

```bash
curl localhost
```

Install CodeDeploy:

```bash
sudo yum install ruby wget -y

cd /home/ec2-user

wget https://aws-codedeploy-eu-north-1.s3.eu-north-1.amazonaws.com/latest/install

chmod +x ./install

sudo ./install auto

sudo service codedeploy-agent start
```

Verify:

```bash
sudo service codedeploy-agent status
```

Browser:

```text
http://<BLUE-2-PUBLIC-IP>
```

Expected:

```text
BLUE-2 SERVER
```

---

# STEP 9 — REPEAT SAME FOR green-1

```bash
ssh -i rama-ec2.pem ec2-user@<GREEN-1-PUBLIC-IP>
```

Install Apache:

```bash
sudo yum update -y
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
```

Create page:

```bash
echo "<h1>GREEN-1 SERVER</h1>" | sudo tee /var/www/html/index.html
```

Test:

```bash
curl localhost
```

Install CodeDeploy:

```bash
sudo yum install ruby wget -y

cd /home/ec2-user

wget https://aws-codedeploy-eu-north-1.s3.eu-north-1.amazonaws.com/latest/install

chmod +x ./install

sudo ./install auto

sudo service codedeploy-agent start
```

Verify:

```bash
sudo service codedeploy-agent status
```

Browser:

```text
http://<GREEN-1-PUBLIC-IP>
```

Expected:

```text
GREEN-1 SERVER
```

---

# STEP 10 — REPEAT SAME FOR green-2

```bash
ssh -i rama-ec2.pem ec2-user@<GREEN-2-PUBLIC-IP>
```

Install Apache:

```bash
sudo yum update -y
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
```

Create page:

```bash
echo "<h1>GREEN-2 SERVER</h1>" | sudo tee /var/www/html/index.html
```

Test:

```bash
curl localhost
```

Install CodeDeploy:

```bash
sudo yum install ruby wget -y

cd /home/ec2-user

wget https://aws-codedeploy-eu-north-1.s3.eu-north-1.amazonaws.com/latest/install

chmod +x ./install

sudo ./install auto

sudo service codedeploy-agent start
```

Verify:

```bash
sudo service codedeploy-agent status
```

Browser:

```text
http://<GREEN-2-PUBLIC-IP>
```

Expected:

```text
GREEN-2 SERVER
```

---

# AFTER ALL 4 ARE DONE

Verify ALL 4:

| Check | Expected |
|---|---|
| Browser works | YES |
| curl localhost works | YES |
| httpd running | YES |
| codedeploy-agent running | YES |

---

# NEXT STEPS

1. Create IAM Roles
2. Attach Roles to ALL 4 EC2
3. Create Target Groups
4. Register Blue/Green instances
5. Create ALB
6. Create CodeDeploy Application
7. Deploy ZIP from S3

---

# FINAL VERIFICATION COMMANDS

Run on EACH EC2:

```bash
sudo systemctl status httpd
```

AND

```bash
sudo service codedeploy-agent status
```

Both MUST show:

```text
active (running)
```
