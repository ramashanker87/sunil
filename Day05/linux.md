# Linux Commands – Basic Training for DevOps

## Purpose

This guide is designed for beginners learning Linux commands for DevOps work.

Linux is heavily used in DevOps for:

- Server management
- Application deployment
- Log checking
- File permissions
- Process monitoring
- Package installation
- Shell scripting
- Cloud server administration

---

# 1. Basic Linux Navigation Commands

## Check Current Directory

```bash
pwd
```

## List Files and Directories

```bash
ls
ls -l
ls -a
ls -lh
```

## Change Directory

```bash
cd /home/ubuntu
cd -
cd ~
cd ..
```

---

# 2. File and Directory Management

## Create a Directory

```bash
mkdir devops
mkdir -p projects/app/logs
```

## Create an Empty File

```bash
touch app.log
```

## Create File with Content

```bash
echo "Hello DevOps" > index.html
echo "New line added" >> index.html
```

## View File Content

```bash
cat index.html
less app.log
```

## Copy Files

```bash
cp index.html backup.html
cp -r devops devops-backup
```

## Move or Rename Files

```bash
mv oldname.txt newname.txt
mv index.html /tmp/
```

## Delete Files and Directories

```bash
rm file.txt
rm -r old-folder
rm -rf old-folder
```

> Be careful with `rm -rf`. It permanently deletes files.

---

# 3. File Viewing and Searching

## View First Lines

```bash
head app.log
head -n 20 app.log
```

## View Last Lines

```bash
tail app.log
tail -n 50 app.log
tail -f /var/log/syslog
```

## Search Inside File

```bash
grep "error" app.log
grep -i "error" app.log
grep -r "database" /var/www/html
```

## Find Files

```bash
find /home/ubuntu -name "app.log"
find /var/log -name "*.log"
```

---

# 4. File Permissions

## View Permissions

```bash
ls -l
```

## Permission Meaning

| Symbol | Meaning |
|---|---|
| r | Read |
| w | Write |
| x | Execute |

## Change File Permission

```bash
chmod +x deploy.sh
chmod 755 deploy.sh
```

## Change Owner

```bash
sudo chown ubuntu:ubuntu app.log
sudo chown -R ubuntu:ubuntu /var/www/html
```

---

# 5. User and System Information

```bash
whoami
hostname
cat /etc/os-release
uptime
df -h
du -sh /var/log
free -h
```

---

# 6. Process Management

## Show Running Processes

```bash
ps aux
```

## Search Process

```bash
ps aux | grep nginx
```

## Real-Time Process Monitor

```bash
top
```

If installed:

```bash
htop
```

## Kill Process

```bash
kill <PID>
kill -9 <PID>
```

---

# 7. Package Management on Ubuntu

## Update Package List

```bash
sudo apt update
```

## Upgrade Packages

```bash
sudo apt upgrade -y
```

## Install Package

```bash
sudo apt install nginx -y
```

## Remove Package

```bash
sudo apt remove nginx -y
```

## Check Package Version

```bash
nginx -v
```

---

# 8. Service Management with systemctl

## Start Service

```bash
sudo systemctl start nginx
```

## Stop Service

```bash
sudo systemctl stop nginx
```

## Restart Service

```bash
sudo systemctl restart nginx
```

## Enable Service on Boot

```bash
sudo systemctl enable nginx
```

## Check Service Status

```bash
sudo systemctl status nginx
```

## View Service Logs

```bash
journalctl -u nginx
journalctl -u nginx -f
```

---

# 9. Networking Commands

## Check IP Address

```bash
ip addr
hostname -I
```

## Test Internet Connectivity

```bash
ping google.com
```

## Check Open Ports

```bash
ss -tulnp
```

## Test HTTP Request

```bash
curl http://localhost
```

## Download File

```bash
wget https://example.com/file.zip
curl -O https://example.com/file.zip
```

---

# 10. Archive and Compression

## Create tar Archive

```bash
tar -cvf app.tar app/
```

## Extract tar Archive

```bash
tar -xvf app.tar
```

## Create gzip Archive

```bash
tar -czvf app.tar.gz app/
```

## Extract gzip Archive

```bash
tar -xzvf app.tar.gz
```

## Zip Files

```bash
sudo apt install zip unzip -y
zip -r app.zip app/
unzip app.zip
```

---

# 11. Git Commands for DevOps

## Check Git Version

```bash
git --version
```

## Configure Git

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## Clone Repository

```bash
git clone https://github.com/user/repo.git
```

## Check Status

```bash
git status
```

## Add Files

```bash
git add .
```

## Commit Changes

```bash
git commit -m "Initial commit"
```

## Push Changes

```bash
git push origin main
```

## Pull Latest Code

```bash
git pull origin main
```

---

# 12. DevOps Deployment Practice

## Install Nginx

```bash
sudo apt update
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
```

## Create Web Page

```bash
echo "<h1>Hello from DevOps Linux Training</h1>" | sudo tee /var/www/html/index.html
```

## Test Locally

```bash
curl http://localhost
```

## Check Nginx Status

```bash
sudo systemctl status nginx
```

## View Nginx Logs

```bash
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

---

# 13. Shell Script Basics

## Create Script

```bash
nano deploy.sh
```

Add this script:

```bash
#!/bin/bash

echo "Starting deployment"

sudo apt update
sudo apt install nginx -y

echo "<h1>Deployed using shell script</h1>" | sudo tee /var/www/html/index.html

sudo systemctl restart nginx

echo "Deployment completed"
```

## Give Execute Permission

```bash
chmod +x deploy.sh
```

## Run Script

```bash
./deploy.sh
```

---

# 14. Environment Variables

```bash
APP_NAME=devops-app
echo $APP_NAME

export ENVIRONMENT=dev
env
```

---

# 15. Useful DevOps Command Combinations

## Check Disk and Memory

```bash
df -h && free -h
```

## Find Large Files

```bash
sudo find / -type f -size +100M
```

## Check Failed Services

```bash
systemctl --failed
```

## Restart Web Server and Check Status

```bash
sudo systemctl restart nginx && sudo systemctl status nginx
```

## Search Error Logs

```bash
sudo grep -i error /var/log/nginx/error.log
```

---

# 16. Practice Exercises

## Exercise 1 – Directory Practice

```bash
mkdir devops-training
cd devops-training
touch file1.txt file2.txt
ls -l
```

## Exercise 2 – File Content Practice

```bash
echo "Linux is important for DevOps" > notes.txt
cat notes.txt
```

## Exercise 3 – Permission Practice

```bash
touch script.sh
chmod +x script.sh
ls -l script.sh
```

## Exercise 4 – Service Practice

```bash
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl status nginx
```

## Exercise 5 – Log Practice

Terminal 1:

```bash
sudo tail -f /var/log/nginx/access.log
```

Terminal 2:

```bash
curl http://localhost
```

Observe the log update.

---

# 17. Important Commands Summary

| Command | Purpose |
|---|---|
| pwd | Show current directory |
| ls | List files |
| cd | Change directory |
| mkdir | Create directory |
| touch | Create file |
| cat | View file |
| cp | Copy file |
| mv | Move or rename file |
| rm | Delete file |
| chmod | Change permission |
| chown | Change owner |
| grep | Search text |
| find | Find files |
| ps | Show processes |
| kill | Stop process |
| systemctl | Manage services |
| journalctl | View service logs |
| apt | Package manager |
| git | Version control |
| curl | Test HTTP requests |
| wget | Download files |
| tar | Archive files |

---

# 18. DevOps Best Practices

- Always check current directory before deleting files
- Avoid using `rm -rf` carelessly
- Use `sudo` only when required
- Check logs during deployment
- Automate repeated tasks with shell scripts
- Keep application files organized
- Use Git for version control
- Monitor services after restart
- Secure SSH access
- Keep packages updated

---

# Summary

In this Linux training guide, you learned:

- Basic Linux navigation
- File and directory management
- Permissions
- Process management
- Package installation
- Service management
- Networking commands
- Git basics
- Shell scripting
- DevOps deployment practice

These commands are essential for DevOps engineers working with Linux servers, AWS EC2, Jenkins, Docker, Kubernetes, and CI/CD pipelines.
