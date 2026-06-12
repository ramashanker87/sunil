# Day 16 ECS Fargate CloudFormation Lab Commands

## 1. Prerequisites

You need:

- AWS CLI configured
- Docker image already pushed to Amazon ECR
- IAM permissions for CloudFormation, ECS, EC2, ELB, IAM, and CloudWatch

Verify AWS login:

```bash
aws sts get-caller-identity --profile devops
```

Example ECR image URI:

```text
386757865964.dkr.ecr.us-east-1.amazonaws.com/rama-ecr:v2
```

---

## 2. Deploy the Stack

Replace the image URI and region as required.

```bash
aws cloudformation deploy \
  --stack-name sunil-ecs-fargate \
  --template-file sunil-ecs-cluster.yml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
      VpcId=vpc-0ca5b92e540035af6 \
      PublicSubnet1=subnet-02e4c0c0d48c6abe0 \
      PublicSubnet2=subnet-0fedff33455ac1bd6 \
      ECRImage=386757865964.dkr.ecr.us-east-1.amazonaws.com/sunil-ecs:v2 \
  --profile devops
```

---

## 3. Get the Application URL

```bash
aws cloudformation describe-stacks \
  --stack-name sunil-ecs-fargate \
  --query "Stacks[0].Outputs" \
  --profile devops
```

Open the `ApplicationURL` value in a browser.

---

## 4. Verify ECS Service

```bash
aws ecs list-clusters --region us-east-1 --profile devops
```

```bash
aws ecs list-services \
  --cluster rama-fargate-cluster \
  --region us-east-1 \
  --profile devops
```

```bash
aws ecs list-tasks \
  --cluster rama-fargate-cluster \
  --service-name Rama-service \
  --region us-east-1 \
  --profile devops
```

---

## 5. View Logs

```bash
aws logs describe-log-streams \
  --log-group-name /ecs/rama-fargate-cluster \
  --region us-east-1 \
  --profile devops
```

---

## 6. Scale the Service

```bash
aws ecs update-service \
  --cluster rama-fargate-cluster \
  --service Rama-service \
  --desired-count 2 \
  --region us-east-1 \
  --profile devops
```

---

## 7. Cleanup

```bash
aws cloudformation delete-stack \
  --stack-name rama-ecs-fargate \
  --region us-east-1 \
  --profile devops
```

Check deletion:

```bash
aws cloudformation describe-stacks \
  --stack-name rama-ecs-fargate \
  --region us-east-1 \
  --profile devops
```
