# Day 04 – DevOps Lab
## Module 1 – DevOps & CI/CD Fundamentals
### Date: 21-May-2026 (Thursday)

## AWS CodeCommit + CodeBuild + S3 CI/CD Pipeline

---

# 🚀 Objective
Create a complete CI/CD pipeline using:

- AWS CodeCommit (Source)
- AWS CodeBuild (Build)
- Amazon S3 (Artifacts)
- CloudWatch (Logs)

---

# 🧠 Architecture

```
Developer
   ↓
AWS CodeCommit
   ↓
AWS CodeBuild
   ↓
buildspec.yml execution
   ↓
S3 (ZIP Artifact Output)
   ↓
CloudWatch Logs
```

---

# STEP 1 – Create CodeCommit Repository

    - Repository name: devops-training-repo

     aws codecommit create-repository \
      --repository-name devops-training-repo-rama \
      --repository-description "DevOps Training Repository" --profile devops

---

    aws sts get-caller-identity --profile devops
    git config --global credential.helper '!aws codecommit credential-helper $@'
    git config --global credential.UseHttpPath true
    export AWS_PROFILE=devops

# STEP 2 – Clone Repository

    git clone https://git-codecommit.us-east-1.amazonaws.com/v1/repos/devops-training-repo-rama
    cd devops-training-repo-rama

---

# STEP 3 – Create Project Files

## index.html
<h1>DevOps CodeCommit + CodeBuild Success</h1>

## buildspec.yml

```
version: 0.2

phases:
  install:
    commands:
      - echo Installing dependencies

  pre_build:
    commands:
      - echo Preparing build environment

  build:
    commands:
      - echo Build started
      - mkdir -p output
      - cp index.html output/

  post_build:
    commands:
      - echo Build completed successfully

artifacts:
  files:
    - '**/*'
  base-directory: output 
```

---

# STEP 4 – Push Code

``` 
git add .
git commit -m "initial commit"
git push origin master
```


---

#  STEP 5 – Create S3 Bucket

    - devops-training-build-artifacts-rama

---


#  STEP 7 – CodeBuild Project
    project name: devops-build-rama
    Source: CodeCommit
    repository: devops-training-repo-rama
    Branch: master
    Operating system: ubuntu
    image: latest
    image version:latest
    Buildspec : use a buildspec file
    Artifacts :S3
    Bucket Name: devops-training-build-artifacts-rama
    Name: output
    Path: (empty)
    Artifacts packaging: zip
    Logs: cloudwatch
---


# STEP 8 – Run Build

    Click Start build

---

# STEP 9 – Verify Output

    S3 will contain:
    - output.zip

---

# 🎯 FINAL FLOW

    CodeCommit → CodeBuild → output/ → ZIP → S3