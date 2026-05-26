# Day 7 – DevOps Lab
# Jenkins and GitHub Actions Deployment on AWS EC2

## Objective

In this lab, you will:

- Launch an EC2 application server
- Install Apache Web Server
- Launch a Jenkins server
- Install Jenkins on Amazon Linux 2023
- Deploy a website using Jenkins
- Deploy a website using GitHub Actions

This lab is designed for beginners and uses Amazon Linux 2023.

---

# Architecture

```text
GitHub
   ↓
Jenkins OR GitHub Actions
   ↓
AWS EC2 Application Server
   ↓
Apache Web Server
```

---

# Important Notes

This lab uses:

| Component | Value |
|---|---|
| OS | Amazon Linux 2023 |
| Application Server | Apache HTTP Server |
| Jenkins Java Version | Java 21 |
| Jenkins Port | 8080 |
| Web Server Port | 80 |
| EC2 User | ec2-user |

Jenkins currently requires Java 21 or newer. Do not use Java 17 for the latest Jenkins version.

Replace these values throughout the lab:

| Placeholder | Replace With |
|---|---|
| `<KEY-FILE>` | Your EC2 key file, for example `rama-ec2.pem` |
| `<APP-IP>` | Public IP of the application server |
| `<JENKINS-IP>` | Public IP of the Jenkins server |
| `<USERNAME>` | Your GitHub username |

---

# Part 1 – Create EC2 Application Server

## Step 1 – Launch Application EC2 Instance

Open:

```text
AWS Console → EC2 → Launch Instance
```

Use this configuration:

| Setting | Value |
|---|---|
| Name | app-server |
| AMI | Amazon Linux 2023 |
| Instance Type | t2.micro or t3.micro |
| Key Pair | Your existing key pair |
| Security Group | Allow SSH and HTTP |

Security Group inbound rules:

| Type | Port | Source |
|---|---|---|
| SSH | 22 | Your IP |
| HTTP | 80 | 0.0.0.0/0 |

Launch the instance.

---

## Step 2 – Connect to Application Server

From your local terminal:

```bash
chmod 400 <KEY-FILE>
ssh -i <KEY-FILE> ec2-user@<APP-IP>
```

Example:

```bash
chmod 400 rama-ec2.pem
ssh -i rama-ec2.pem ec2-user@18.209.32.250
```

---

## Step 3 – Install Apache Web Server

Run on the application server:

```bash
sudo dnf update -y
sudo dnf install -y httpd git
sudo systemctl enable httpd
sudo systemctl start httpd
sudo systemctl status httpd --no-pager
```

Expected status:

```text
active (running)
```

---

## Step 4 – Create Test Website

Run:

```bash
echo "<h1>Application Server Ready</h1>" | sudo tee /var/www/html/index.html
```

Open in browser:

```text
http://<APP-IP>
```

Expected output:

```html
<h1>Application Server Ready</h1>
```

---

# Part 2 – Jenkins Lab

## Step 5 – Launch Jenkins EC2 Instance

Create another EC2 instance.

Use this configuration:

| Setting | Value |
|---|---|
| Name | jenkins-server |
| AMI | Amazon Linux 2023 |
| Instance Type | t2.micro or t3.micro |
| Key Pair | Same key pair or another valid key |
| Security Group | Allow SSH and Jenkins port 8080 |

Security Group inbound rules:

| Type | Port | Source |
|---|---|---|
| SSH | 22 | Your IP |
| Custom TCP | 8080 | 0.0.0.0/0 |

Launch the instance.

---

## Step 6 – Connect to Jenkins Server

From your local terminal:

```bash
ssh -i <KEY-FILE> ec2-user@<JENKINS-IP>
```

Example:

```bash
ssh -i rama-ec2.pem ec2-user@54.224.211.20
```

---

## Step 7 – Install Jenkins on Amazon Linux 2023

Run these commands on the Jenkins server:

```bash
sudo dnf update -y
sudo dnf install -y wget git fontconfig java-21-amazon-corretto
```

Verify Java:

```bash
java -version
```

Expected output should show Java 21:

```text
openjdk version "21"
```

Add the Jenkins repository:

```bash
sudo wget -O /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/redhat-stable/jenkins.repo
```

Import the Jenkins key:

```bash
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
```

Install Jenkins:

```bash
sudo dnf install -y jenkins
```

Configure Jenkins to use Java 21:

```bash
sudo mkdir -p /etc/systemd/system/jenkins.service.d
sudo tee /etc/systemd/system/jenkins.service.d/override.conf > /dev/null <<'EOT'
[Service]
Environment="JENKINS_JAVA_CMD=/usr/lib/jvm/java-21-amazon-corretto/bin/java"
EOT
```

Reload systemd:

```bash
sudo systemctl daemon-reload
```

Enable and start Jenkins:

```bash
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins --no-pager
```

Expected status:

```text
active (running)
```

---

## Step 8 – Access Jenkins

Open in browser:

```text
http://<JENKINS-IP>:8080
```

Get the initial Jenkins admin password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

In Jenkins UI:

```text
Install Suggested Plugins
```

Then create your Jenkins admin user.

---

## Step 9 – Install Jenkins SSH Agent Plugin

Open Jenkins:

```text
Manage Jenkins → Plugins → Available Plugins
```

Search for and install:

```text
SSH Agent
```

Restart Jenkins if requested.

---

## Step 10 – Allow Jenkins to Deploy to Application Server

Jenkins needs SSH access to the application server.

On your local machine, open your EC2 private key file:

```bash
cat <KEY-FILE>
```

Copy the full private key content, including:

```text
-----BEGIN RSA PRIVATE KEY-----
...
-----END RSA PRIVATE KEY-----
```

or:

```text
-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----
```

---

## Step 11 – Add Jenkins SSH Credentials

Open Jenkins:

```text
Manage Jenkins → Credentials → System → Global credentials → Add Credentials
```

Use this configuration:

| Field | Value |
|---|---|
| Kind | SSH Username with private key |
| ID | ec2-key |
| Username | ec2-user |
| Private Key | Enter directly |
| Key | Paste your EC2 private key |

Save the credential.

---

## Step 12 – Create GitHub Repository for Jenkins

Create a GitHub repository named:

```text
jenkins-demo
```

Create a file named `index.html`:

```html
<h1>Deployed using Jenkins</h1>
```

Push the file to GitHub.

Example local commands:

```bash
mkdir jenkins-demo
cd jenkins-demo
printf '<h1>Deployed using Jenkins</h1>\n' > index.html
git init
git add index.html
git commit -m "Initial Jenkins deployment page"
git branch -M main
git remote add origin https://github.com/<USERNAME>/jenkins-demo.git
git push -u origin main
```

---

## Step 13 – Create Jenkins Pipeline

Open Jenkins:

```text
New Item → Pipeline
```

Name:

```text
jenkins-deploy
```

Select:

```text
Pipeline
```

Click:

```text
OK
```

---

## Step 14 – Add Jenkins Pipeline Script

Paste this pipeline script.

Replace:

- `<USERNAME>` with your GitHub username
- `<APP-IP>` with your application server public IP

```groovy
pipeline {
    agent any

    stages {
        stage('Clone GitHub Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/<USERNAME>/jenkins-demo.git'
            }
        }

        stage('Deploy to Application Server') {
            steps {
                sshagent(['ec2-key']) {
                    sh '''
                    scp -o StrictHostKeyChecking=no index.html ec2-user@<APP-IP>:/tmp/index.html

                    ssh -o StrictHostKeyChecking=no ec2-user@<APP-IP> "sudo cp /tmp/index.html /var/www/html/index.html && sudo systemctl restart httpd"
                    '''
                }
            }
        }
    }
}
```

Click:

```text
Save
```

---

## Step 15 – Run Jenkins Pipeline

Click:

```text
Build Now
```

Open:

```text
Console Output
```

The build should finish successfully.

---

## Step 16 – Validate Jenkins Deployment

Open in browser:

```text
http://<APP-IP>
```

Expected output:

```html
<h1>Deployed using Jenkins</h1>
```

---

# Part 3 – GitHub Actions Lab

## Step 17 – Create GitHub Repository for GitHub Actions

Create another GitHub repository named:

```text
github-actions-demo
```

Create a file named `index.html`:

```html
<h1>Deployed using GitHub Actions</h1>
```

---

## Step 18 – Add GitHub Actions Secrets

Open your GitHub repository:

```text
Repository → Settings → Secrets and variables → Actions → New repository secret
```

Add these secrets:

| Secret | Value |
|---|---|
| EC2_HOST | Application server public IP |
| EC2_USER | ec2-user |
| EC2_SSH_KEY | Full private key content from your `.pem` file |

Important: `EC2_HOST` should be the application server public IP, not the Jenkins server IP.

---

## Step 19 – Create GitHub Actions Workflow

Create this file in the repository:

```text
.github/workflows/deploy.yml
```

Paste:

```yaml
name: Deploy to EC2

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Configure SSH
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.EC2_SSH_KEY }}" > ~/.ssh/ec2_key
          chmod 600 ~/.ssh/ec2_key
          ssh-keyscan -H ${{ secrets.EC2_HOST }} >> ~/.ssh/known_hosts

      - name: Deploy to EC2 Apache Server
        run: |
          scp -i ~/.ssh/ec2_key index.html ${{ secrets.EC2_USER }}@${{ secrets.EC2_HOST }}:/tmp/index.html

          ssh -i ~/.ssh/ec2_key ${{ secrets.EC2_USER }}@${{ secrets.EC2_HOST }} "sudo cp /tmp/index.html /var/www/html/index.html && sudo systemctl restart httpd"
```

---

## Step 20 – Push GitHub Actions Code

Run from your local repository:

```bash
git add .
git commit -m "Add GitHub Actions deployment"
git push origin main
```

---

## Step 21 – Validate GitHub Actions Deployment

Open:

```text
GitHub Repository → Actions
```

Check that the workflow completed successfully.

Then open in browser:

```text
http://<APP-IP>
```

Expected output:

```html
<h1>Deployed using GitHub Actions</h1>
```

---

# Common Issues and Fixes

## Jenkins Fails to Start

Check logs:

```bash
sudo journalctl -u jenkins.service --no-pager -n 100
```

If you see this error:

```text
Running with Java 17, which is older than the minimum required version Java 21
```

Install Java 21 and restart Jenkins:

```bash
sudo dnf install -y java-21-amazon-corretto fontconfig
sudo systemctl daemon-reload
sudo systemctl reset-failed jenkins
sudo systemctl restart jenkins
sudo systemctl status jenkins --no-pager
```

---

## Jenkins Not Opening in Browser

Check Jenkins status:

```bash
sudo systemctl status jenkins --no-pager
```

Check that port 8080 is listening:

```bash
sudo ss -tulnp | grep 8080
```

Verify the Jenkins server security group allows inbound TCP port 8080.

---

## Apache Website Not Opening

Run on the application server:

```bash
sudo systemctl status httpd --no-pager
sudo systemctl restart httpd
```

Verify the application server security group allows inbound HTTP port 80.

---

## SSH Permission Denied From Local Machine

Run:

```bash
chmod 400 <KEY-FILE>
```

Then reconnect:

```bash
ssh -i <KEY-FILE> ec2-user@<APP-IP>
```

---

## Jenkins Pipeline SSH Permission Denied

Check:

- Jenkins credential ID is exactly `ec2-key`
- Jenkins credential username is `ec2-user`
- The private key is the correct key for the application server
- Application server security group allows SSH port 22 from the Jenkins server

For better security, allow SSH from the Jenkins server security group instead of `0.0.0.0/0`.

---

## GitHub Actions SSH Failed

Check GitHub secrets:

- `EC2_HOST` is the application server public IP
- `EC2_USER` is `ec2-user`
- `EC2_SSH_KEY` contains the full private key
- Application server security group allows SSH port 22 from GitHub Actions runner IPs or temporarily from `0.0.0.0/0` for lab testing

---

# Success Checklist

- [ ] Application EC2 instance launched
- [ ] Apache installed and running
- [ ] Jenkins EC2 instance launched
- [ ] Java 21 installed on Jenkins server
- [ ] Jenkins installed and running
- [ ] Jenkins accessible on port 8080
- [ ] Jenkins SSH Agent plugin installed
- [ ] Jenkins credentials added
- [ ] Jenkins pipeline deployed website successfully
- [ ] GitHub Actions workflow deployed website successfully
- [ ] Website accessible using application server public IP

---

# Final Result

At the end of this lab, your deployment flow should work like this:

```text
Developer pushes code to GitHub
        ↓
Jenkins Pipeline OR GitHub Actions Workflow runs
        ↓
index.html is copied to EC2 Application Server
        ↓
Apache serves the updated website
```
