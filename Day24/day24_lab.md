# Day 24 Lab – Monitoring and Production Readiness on AWS

## Module 7 and 8 – Monitoring and Production Readiness

**Date:** 18-Jun-2026, Thursday  
**Estimated Duration:** 3–4 hours  
**Level:** Beginner to Intermediate  
**AWS CLI Profile:** `devops`

---

## 1. Lab Overview

This lab creates a small production-readiness environment from scratch in a clean AWS account.

You will create:

- A Python Flask application
- A Docker image for the Python app
- An Amazon ECR repository
- An Amazon ECS Fargate service
- AWS X-Ray tracing
- Basic OpenTelemetry/X-Ray instrumentation
- CloudWatch centralized application logs
- Amazon OpenSearch Service domain for centralized logging discussion
- Amazon Managed Grafana workspace for observability discussion
- Multi-Region DR simulation resources
- Route53 health check review
- Global Accelerator review
- AWS Cost Explorer reports
- FinOps recommendations
- Full cleanup

> Note: Some managed services such as OpenSearch and Grafana may take several minutes to create and may incur cost. Cleanup is mandatory.

---

## 2. Topics Covered

### Theory

- AWS X-Ray
- OpenTelemetry
- Centralized logging
- Multi-Region Disaster Recovery
- Route53 failover concepts
- AWS Global Accelerator concepts
- FinOps and cost optimization

### Hands-on Lab

- Create a Python Docker application
- Push image to Amazon ECR
- Deploy application on ECS Fargate
- Enable CloudWatch logs
- Enable X-Ray tracing
- Create OpenSearch domain
- Create Grafana workspace
- Simulate DR using two AWS regions
- Review Route53 and Global Accelerator
- Generate Cost Explorer reports
- Clean up all resources

---

## 3. AWS Resources Created

This lab creates resources from scratch:

- ECR repository
- ECS cluster
- ECS task definition
- ECS service
- Application Load Balancer
- Target group
- Security groups
- CloudWatch log group
- IAM roles
- X-Ray permissions
- OpenSearch domain
- Grafana workspace
- DR S3 buckets in two regions
- Optional Route53 health check
- Optional Global Accelerator
- Cost Explorer reports

---

## 4. Prerequisites

Before starting, make sure you have:

- AWS CLI installed
- Docker installed
- IAM user or role configured with AWS CLI profile `devops`
- Permissions for:
  - IAM
  - ECR
  - ECS
  - EC2
  - ELBv2
  - CloudWatch Logs
  - X-Ray
  - OpenSearch
  - Grafana
  - S3
  - Route53
  - Global Accelerator
  - Cost Explorer

Verify AWS CLI profile:

```bash
aws sts get-caller-identity --profile devops
```

Expected output includes:

```text
Account
Arn
UserId
```

---

## 5. Environment Variables

Run these commands first.

```bash
export AWS_PROFILE=devops
export AWS_REGION=us-east-1
export DR_REGION=us-west-2

export APP_NAME=day24-python-observability
export ECR_REPO_NAME=day24-python-observability
export ECS_CLUSTER_NAME=day24-observability-cluster
export ECS_SERVICE_NAME=day24-python-service
export ECS_TASK_FAMILY=day24-python-task
export LOG_GROUP_NAME=/ecs/day24-python-observability

export OPENSEARCH_DOMAIN_NAME=day24-logs
export GRAFANA_WORKSPACE_NAME=day24-grafana

export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --profile $AWS_PROFILE --query Account --output text)
export IMAGE_TAG=v1
export ECR_IMAGE_URI=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:$IMAGE_TAG
```

Verify:

```bash
echo $AWS_ACCOUNT_ID
echo $ECR_IMAGE_URI
```

---

# Part 1 – Create the Python Application

## Step 1: Create Project Folder

```bash
mkdir -p day24-python-app
cd day24-python-app
```

### Explanation

This folder contains the Python application source code and Dockerfile.

---

## Step 2: Create Python Flask App

```bash
cat > app.py <<'EOF'
from flask import Flask, request
import os
import time
import logging

from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.ext.flask.middleware import XRayMiddleware

app = Flask(__name__)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

xray_recorder.configure(service="day24-python-observability")
XRayMiddleware(app, xray_recorder)


@app.route("/")
def home():
    logger.info("Home endpoint called")
    return {
        "message": "Hello from Day 24 Python Observability App",
        "version": "v1",
        "region": os.environ.get("AWS_REGION", "unknown")
    }


@app.route("/health")
def health():
    # Keep this endpoint very small and always return HTTP 200 for ALB health checks.
    return {"status": "healthy"}, 200


@app.route("/slow")
def slow():
    logger.info("Slow endpoint called")
    time.sleep(2)
    return {"message": "Slow request completed"}


@app.route("/error")
def error():
    logger.error("Error endpoint called")
    return {"error": "Simulated application error"}, 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
EOF
```

### Explanation

This app has four routes:

- `/` returns application information
- `/health` is used by the load balancer health check
- `/slow` simulates a slow request
- `/error` simulates an application error

The app also includes basic AWS X-Ray instrumentation.

---

## Step 3: Create Requirements File

```bash
cat > requirements.txt <<'EOF'
flask==3.0.3
aws-xray-sdk==2.14.0
gunicorn==22.0.0
EOF
```

### Explanation

The application uses Flask for the web server and AWS X-Ray SDK for tracing.

---

## Step 4: Create Dockerfile

```bash
cat > Dockerfile <<'EOF'
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--timeout", "30", "app:app"]
EOF
```

### Explanation

This Dockerfile builds a small Python container image.

---

## Step 5: Test App Locally

```bash
docker build -t $APP_NAME:$IMAGE_TAG .
docker run --rm -p 5000:5000 $APP_NAME:$IMAGE_TAG
```

Open another terminal and test:

```bash
curl http://localhost:5000/
curl http://localhost:5000/health
curl http://localhost:5000/slow
curl http://localhost:5000/error
```

Stop the container with:

```bash
CTRL+C
```

### Explanation

This confirms the app works before deploying to AWS.

---

# Part 2 – Create Amazon ECR Repository

## Step 6: Create ECR Repository

```bash
aws ecr create-repository   --repository-name $ECR_REPO_NAME   --image-scanning-configuration scanOnPush=true   --encryption-configuration encryptionType=AES256   --region $AWS_REGION   --profile $AWS_PROFILE
```

### Explanation

Amazon ECR stores Docker images privately in AWS.

---

## Step 7: Authenticate Docker to ECR

```bash
aws ecr get-login-password   --region $AWS_REGION   --profile $AWS_PROFILE | docker login   --username AWS   --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

Expected output:

```text
Login Succeeded
```

---

## Step 8: Tag and Push Image

```bash
docker tag $APP_NAME:$IMAGE_TAG $ECR_IMAGE_URI
docker push $ECR_IMAGE_URI
```

### Explanation

This uploads the Python Docker image to ECR.

---

## Step 9: Verify Image in ECR

```bash
aws ecr describe-images   --repository-name $ECR_REPO_NAME   --region $AWS_REGION   --profile $AWS_PROFILE   --query 'imageDetails[*].{Tags:imageTags,Digest:imageDigest,PushedAt:imagePushedAt}'   --output table
```

---

# Part 3 – Create IAM Roles

## Step 10: Create ECS Task Execution Role Trust Policy

```bash
cat > ecs-task-execution-trust-policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
```

---

## Step 11: Create ECS Task Execution Role

```bash
aws iam create-role   --role-name day24EcsTaskExecutionRole   --assume-role-policy-document file://ecs-task-execution-trust-policy.json   --profile $AWS_PROFILE
```

Attach required policy:

```bash
aws iam attach-role-policy   --role-name day24EcsTaskExecutionRole   --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy   --profile $AWS_PROFILE
```

### Explanation

This role allows ECS to pull images from ECR and write logs to CloudWatch.

---

## Step 12: Create ECS Application Task Role

```bash
aws iam create-role   --role-name day24EcsAppTaskRole   --assume-role-policy-document file://ecs-task-execution-trust-policy.json   --profile $AWS_PROFILE
```

Attach X-Ray write permissions:

```bash
aws iam attach-role-policy   --role-name day24EcsAppTaskRole   --policy-arn arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess   --profile $AWS_PROFILE
```

### Explanation

This role allows the app and X-Ray daemon to send traces to AWS X-Ray.

---

# Part 4 – Create Networking Resources

## Step 13: Get Default VPC

```bash
export VPC_ID=$(aws ec2 describe-vpcs   --filters Name=isDefault,Values=true   --region $AWS_REGION   --profile $AWS_PROFILE   --query 'Vpcs[0].VpcId'   --output text)

echo $VPC_ID
```

### Explanation

This lab uses the default VPC to keep the setup simple.

---

## Step 14: Get Public Subnets

Use two available subnets from the default VPC. Keep two formats:

- `SUBNET_IDS_SPACE` for commands such as `create-load-balancer`
- `SUBNET_IDS_COMMA` for ECS `awsvpcConfiguration`

```bash
export SUBNET_IDS_SPACE=$(aws ec2 describe-subnets \
  --filters Name=vpc-id,Values=$VPC_ID \
            Name=availability-zone,Values=us-east-1a,us-east-1b \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --query 'join(`,`, Subnets[*].SubnetId)' \
  --output text)

export SUBNET_IDS_COMMA=$(echo "$SUBNET_IDS_SPACE" | tr '\t ' ',,' | sed 's/,,*/,/g; s/^,//; s/,$//')

echo "$SUBNET_IDS_SPACE"
echo "$SUBNET_IDS_COMMA"
```

Do not pass comma-separated subnet IDs to `create-load-balancer`. That command needs subnet IDs separated by spaces.

---

## Step 15: Create Security Group for Load Balancer

```bash
export ALB_SG_ID=$(aws ec2 create-security-group   --group-name day24-alb-sg   --description "Day 24 ALB security group"   --vpc-id $VPC_ID   --region $AWS_REGION   --profile $AWS_PROFILE   --query GroupId   --output text)

echo $ALB_SG_ID
```

Allow HTTP traffic:

```bash
aws ec2 authorize-security-group-ingress   --group-id $ALB_SG_ID   --protocol tcp   --port 80   --cidr 0.0.0.0/0   --region $AWS_REGION   --profile $AWS_PROFILE
```

---

## Step 16: Create Security Group for ECS Tasks

```bash
export ECS_SG_ID=$(aws ec2 create-security-group   --group-name day24-ecs-sg   --description "Day 24 ECS service security group"   --vpc-id $VPC_ID   --region $AWS_REGION   --profile $AWS_PROFILE   --query GroupId   --output text)

echo $ECS_SG_ID
```

Allow ALB to reach ECS tasks on port 5000:

```bash
aws ec2 authorize-security-group-ingress   --group-id $ECS_SG_ID   --protocol tcp   --port 5000   --source-group $ALB_SG_ID   --region $AWS_REGION   --profile $AWS_PROFILE
```

---

# Part 5 – Create CloudWatch Log Group

## Step 17: Create Log Group

```bash
aws logs create-log-group   --log-group-name $LOG_GROUP_NAME   --region $AWS_REGION   --profile $AWS_PROFILE
```

Set retention:

```bash
aws logs put-retention-policy   --log-group-name $LOG_GROUP_NAME   --retention-in-days 7   --region $AWS_REGION   --profile $AWS_PROFILE
```

### Explanation

Centralized logs from ECS containers will be stored in CloudWatch Logs.

---

# Part 6 – Create ECS Fargate Service

## Step 18: Create ECS Cluster

```bash
aws ecs create-cluster   --cluster-name $ECS_CLUSTER_NAME   --region $AWS_REGION   --profile $AWS_PROFILE
```

---

## Step 19: Create Application Load Balancer

```bash
export ALB_ARN=$(aws elbv2 create-load-balancer   --name day24-python-alb   --subnets ${SUBNET_IDS//,/ }   --security-groups $ALB_SG_ID   --scheme internet-facing   --type application   --region $AWS_REGION   --profile $AWS_PROFILE   --query 'LoadBalancers[0].LoadBalancerArn'   --output text)

echo $ALB_ARN
```

Get ALB DNS name:

```bash
export ALB_DNS=$(aws elbv2 describe-load-balancers   --load-balancer-arns $ALB_ARN   --region $AWS_REGION   --profile $AWS_PROFILE   --query 'LoadBalancers[0].DNSName'   --output text)

echo $ALB_DNS
```

---

## Step 20: Create Target Group

```bash
export TARGET_GROUP_ARN=$(aws elbv2 create-target-group \
  --name day24-python-tg \
  --protocol HTTP \
  --port 5000 \
  --vpc-id $VPC_ID \
  --target-type ip \
  --health-check-enabled \
  --health-check-protocol HTTP \
  --health-check-port traffic-port \
  --health-check-path /health \
  --matcher HttpCode=200 \
  --healthy-threshold-count 2 \
  --unhealthy-threshold-count 3 \
  --health-check-interval-seconds 30 \
  --health-check-timeout-seconds 5 \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text)

echo $TARGET_GROUP_ARN
```

---

## Step 21: Create Listener

```bash
aws elbv2 create-listener   --load-balancer-arn $ALB_ARN   --protocol HTTP   --port 80   --default-actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN   --region $AWS_REGION   --profile $AWS_PROFILE
```

---

## Step 22: Register ECS Task Definition

```bash
export EXECUTION_ROLE_ARN=arn:aws:iam::$AWS_ACCOUNT_ID:role/day24EcsTaskExecutionRole
export TASK_ROLE_ARN=arn:aws:iam::$AWS_ACCOUNT_ID:role/day24EcsAppTaskRole
```

Create task definition:

```bash
cat > task-definition.json <<EOF
{
  "family": "$ECS_TASK_FAMILY",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "$EXECUTION_ROLE_ARN",
  "taskRoleArn": "$TASK_ROLE_ARN",
  "containerDefinitions": [
    {
      "name": "$APP_NAME",
      "image": "$ECR_IMAGE_URI",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 5000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "AWS_REGION",
          "value": "$AWS_REGION"
        },
        {
          "name": "AWS_XRAY_DAEMON_ADDRESS",
          "value": "127.0.0.1:2000"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "$LOG_GROUP_NAME",
          "awslogs-region": "$AWS_REGION",
          "awslogs-stream-prefix": "app"
        }
      }
    },
    {
      "name": "xray-daemon",
      "image": "public.ecr.aws/xray/aws-xray-daemon:latest",
      "essential": false,
      "portMappings": [
        {
          "containerPort": 2000,
          "protocol": "udp"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "$LOG_GROUP_NAME",
          "awslogs-region": "$AWS_REGION",
          "awslogs-stream-prefix": "xray"
        }
      }
    }
  ]
}
EOF
```

Register task definition:

```bash
aws ecs register-task-definition   --cli-input-json file://task-definition.json   --region $AWS_REGION   --profile $AWS_PROFILE
```

### Explanation

This task definition runs two containers:

- Python Flask app
- X-Ray daemon sidecar

The app sends traces to the local X-Ray daemon, and the daemon sends traces to AWS X-Ray.

---

## Step 23: Create ECS Service

```bash
aws ecs create-service \
  --cluster $ECS_CLUSTER_NAME \
  --service-name $ECS_SERVICE_NAME \
  --task-definition $ECS_TASK_FAMILY \
  --desired-count 2 \
  --launch-type FARGATE \
  --health-check-grace-period-seconds 120 \
  --network-configuration "awsvpcConfiguration={subnets=[$SUBNET_IDS_COMMA],securityGroups=[$ECS_SG_ID],assignPublicIp=ENABLED}" \
  --load-balancers "targetGroupArn=$TARGET_GROUP_ARN,containerName=$APP_NAME,containerPort=5000" \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

---

## Step 24: Wait for ECS Service Stability

```bash
aws ecs wait services-stable   --cluster $ECS_CLUSTER_NAME   --services $ECS_SERVICE_NAME   --region $AWS_REGION   --profile $AWS_PROFILE
```

Verify service:

```bash
aws ecs describe-services   --cluster $ECS_CLUSTER_NAME   --services $ECS_SERVICE_NAME   --region $AWS_REGION   --profile $AWS_PROFILE   --query 'services[0].{Status:status,Running:runningCount,Desired:desiredCount}'
```

---


If the service is not stable or tasks stop with `Task failed ELB health checks`, inspect the target group and stopped task reason:

```bash
aws elbv2 describe-target-health \
  --target-group-arn $TARGET_GROUP_ARN \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --query 'TargetHealthDescriptions[*].{Target:Target.Id,Port:Target.Port,State:TargetHealth.State,Reason:TargetHealth.Reason,Description:TargetHealth.Description}' \
  --output table

aws ecs list-tasks \
  --cluster $ECS_CLUSTER_NAME \
  --desired-status STOPPED \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --query 'taskArns[0:5]' \
  --output text
```

The expected healthy target is port `5000` with state `healthy`.

## Step 25: Test Application Through ALB

```bash
echo http://$ALB_DNS
curl http://$ALB_DNS/
curl http://$ALB_DNS/health
curl http://$ALB_DNS/slow
curl http://$ALB_DNS/error
```

### Explanation

These requests generate logs and traces.

---

# Part 7 – Centralized Logging with CloudWatch Logs

## Step 26: View Log Streams

```bash
aws logs describe-log-streams   --log-group-name $LOG_GROUP_NAME   --region $AWS_REGION   --profile $AWS_PROFILE   --order-by LastEventTime   --descending   --max-items 5
```

---

## Step 27: Read Application Logs

Replace `<LOG_STREAM_NAME>` with a stream name from the previous command.

```bash
aws logs get-log-events   --log-group-name $LOG_GROUP_NAME   --log-stream-name <LOG_STREAM_NAME>   --region $AWS_REGION   --profile $AWS_PROFILE   --limit 20
```

### Explanation

This confirms centralized logging is working.

---

# Part 8 – AWS X-Ray

## Step 28: Query X-Ray Service Graph

```bash
export START_TIME=$(date -u -d "30 minutes ago" +%Y-%m-%dT%H:%M:%SZ)
export END_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)

aws xray get-service-graph   --start-time $START_TIME   --end-time $END_TIME   --region $AWS_REGION   --profile $AWS_PROFILE
```

---

## Step 29: Query X-Ray Trace Summaries

```bash
aws xray get-trace-summaries   --start-time $START_TIME   --end-time $END_TIME   --region $AWS_REGION   --profile $AWS_PROFILE
```

### Explanation

X-Ray helps identify request paths, latency, and errors.

---

# Part 9 – OpenTelemetry Explanation and Optional Collector Config

## Step 30: Create Example OpenTelemetry Collector Config

```bash
cat > otel-collector-config.yaml <<'EOF'
receivers:
  otlp:
    protocols:
      grpc:
      http:

processors:
  batch:

exporters:
  awsxray:
  awscloudwatchlogs:
    log_group_name: /ecs/day24-otel-example
    log_stream_name: otel-stream
    region: us-east-1

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [awsxray]
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [awscloudwatchlogs]
EOF
```

### Explanation

This file is for learning purposes. It shows how OpenTelemetry can receive telemetry and export it to AWS X-Ray and CloudWatch Logs.

---

# Part 10 – Amazon OpenSearch for Centralized Logging

## Step 31: Create OpenSearch Domain

```bash
aws opensearch create-domain   --domain-name $OPENSEARCH_DOMAIN_NAME   --engine-version OpenSearch_2.11   --cluster-config InstanceType=t3.small.search,InstanceCount=1   --ebs-options EBSEnabled=true,VolumeSize=10,VolumeType=gp3   --node-to-node-encryption-options Enabled=true   --encryption-at-rest-options Enabled=true   --domain-endpoint-options EnforceHTTPS=true   --region $AWS_REGION   --profile $AWS_PROFILE
```

### Explanation

OpenSearch can be used for centralized search and analysis of application logs.

---

## Step 32: Check OpenSearch Domain Status

```bash
aws opensearch describe-domain   --domain-name $OPENSEARCH_DOMAIN_NAME   --region $AWS_REGION   --profile $AWS_PROFILE   --query 'DomainStatus.{DomainName:DomainName,Processing:Processing,Endpoint:Endpoint,Created:Created}'
```

Wait until `Processing` becomes `false`.

---

## Step 33: Discuss Log Flow

A common centralized logging flow is:

```text
Application Logs
  -> CloudWatch Logs
  -> Subscription Filter or Firehose
  -> OpenSearch
  -> Dashboard/Search
```

### Student Task

Write a short explanation of how application logs can be sent from CloudWatch Logs to OpenSearch.

---

# Part 11 – Amazon Managed Grafana

## Step 34: Create Grafana Workspace

```bash
aws grafana create-workspace   --account-access-type CURRENT_ACCOUNT   --authentication-providers AWS_SSO   --permission-type SERVICE_MANAGED   --workspace-name $GRAFANA_WORKSPACE_NAME   --region $AWS_REGION   --profile $AWS_PROFILE
```

### Explanation

Grafana is used to visualize logs, metrics, and traces.

---

## Step 35: List Grafana Workspaces

```bash
aws grafana list-workspaces   --region $AWS_REGION   --profile $AWS_PROFILE
```

Record the workspace ID:

```bash
export GRAFANA_WORKSPACE_ID=<WORKSPACE_ID>
```

---

## Step 36: Describe Grafana Workspace

```bash
aws grafana describe-workspace   --workspace-id $GRAFANA_WORKSPACE_ID   --region $AWS_REGION   --profile $AWS_PROFILE
```

### Student Task

Write which AWS services could be visualized in Grafana.

Examples:

- CloudWatch metrics
- CloudWatch logs
- X-Ray traces
- OpenSearch logs

---

# Part 12 – Multi-Region DR Simulation

## Step 37: Create Primary Region S3 Bucket

S3 bucket names must be globally unique.

```bash
export PRIMARY_BUCKET=day24-primary-$AWS_ACCOUNT_ID-$AWS_REGION
export DR_BUCKET=day24-dr-$AWS_ACCOUNT_ID-$DR_REGION
```

Create primary bucket:

```bash
aws s3api create-bucket   --bucket $PRIMARY_BUCKET   --region $AWS_REGION   --profile $AWS_PROFILE
```

Enable versioning:

```bash
aws s3api put-bucket-versioning   --bucket $PRIMARY_BUCKET   --versioning-configuration Status=Enabled   --profile $AWS_PROFILE
```

---

## Step 38: Create DR Region S3 Bucket

```bash
aws s3api create-bucket   --bucket $DR_BUCKET   --region $DR_REGION   --create-bucket-configuration LocationConstraint=$DR_REGION   --profile $AWS_PROFILE
```

Enable versioning:

```bash
aws s3api put-bucket-versioning   --bucket $DR_BUCKET   --versioning-configuration Status=Enabled   --profile $AWS_PROFILE
```

---

## Step 39: Upload Sample Data to Primary Bucket

```bash
echo "Day 24 DR test file" > dr-test.txt

aws s3 cp dr-test.txt s3://$PRIMARY_BUCKET/   --region $AWS_REGION   --profile $AWS_PROFILE
```

Verify:

```bash
aws s3 ls s3://$PRIMARY_BUCKET/   --region $AWS_REGION   --profile $AWS_PROFILE
```

---

## Step 40: Simulate Manual DR Copy

```bash
aws s3 cp s3://$PRIMARY_BUCKET/dr-test.txt s3://$DR_BUCKET/dr-test.txt   --source-region $AWS_REGION   --region $DR_REGION   --profile $AWS_PROFILE
```

Verify DR bucket:

```bash
aws s3 ls s3://$DR_BUCKET/   --region $DR_REGION   --profile $AWS_PROFILE
```

### Explanation

This simulates copying critical data from a primary region to a DR region.

---

## Step 41: DR Assessment

Answer these questions:

1. What is the primary region?
2. What is the DR region?
3. What data was copied?
4. What is the Recovery Point Objective, or RPO?
5. What is the Recovery Time Objective, or RTO?
6. What would happen if the primary region became unavailable?
7. What should be automated in a production DR solution?

---

# Part 13 – Route53 Failover Review

## Step 42: List Hosted Zones

```bash
aws route53 list-hosted-zones   --profile $AWS_PROFILE
```

### Explanation

Route53 hosted zones contain DNS records for domains.

---

## Step 43: Create Optional Route53 Health Check

```bash
cat > health-check.json <<EOF
{
  "CallerReference": "day24-health-check-$(date +%s)",
  "HealthCheckConfig": {
    "IPAddress": "8.8.8.8",
    "Port": 53,
    "Type": "TCP",
    "ResourcePath": "/",
    "RequestInterval": 30,
    "FailureThreshold": 3
  }
}
EOF
```

Create health check:

```bash
aws route53 create-health-check   --caller-reference day24-health-check-$(date +%s)   --health-check-config file://health-check.json   --profile $AWS_PROFILE
```

List health checks:

```bash
aws route53 list-health-checks   --profile $AWS_PROFILE
```

### Explanation

Health checks can be used with failover DNS records.

---

# Part 14 – AWS Global Accelerator Review

## Step 44: Create Optional Global Accelerator

```bash
aws globalaccelerator create-accelerator   --name day24-accelerator   --enabled   --profile $AWS_PROFILE
```

List accelerators:

```bash
aws globalaccelerator list-accelerators   --profile $AWS_PROFILE
```

Record the accelerator ARN:

```bash
export ACCELERATOR_ARN=<ACCELERATOR_ARN>
```

---

## Step 45: Describe Accelerator

```bash
aws globalaccelerator describe-accelerator   --accelerator-arn $ACCELERATOR_ARN   --profile $AWS_PROFILE
```

### Explanation

Global Accelerator provides static anycast IPs and routes traffic to healthy endpoints.

---

# Part 15 – Cost Explorer and FinOps

## Step 46: Enable Cost Explorer

Cost Explorer is usually enabled from the AWS Console.

Check monthly cost:

```bash
aws ce get-cost-and-usage   --time-period Start=2026-06-01,End=2026-06-18   --granularity MONTHLY   --metrics UnblendedCost   --profile $AWS_PROFILE
```

---

## Step 47: Get Cost by Service

```bash
aws ce get-cost-and-usage   --time-period Start=2026-06-01,End=2026-06-18   --granularity MONTHLY   --metrics UnblendedCost   --group-by Type=DIMENSION,Key=SERVICE   --profile $AWS_PROFILE
```

---

## Step 48: FinOps Analysis

Identify at least five cost optimization actions:

Examples:

1. Delete unused OpenSearch domains.
2. Stop or remove idle compute resources.
3. Use log retention policies.
4. Right-size ECS task CPU and memory.
5. Use Savings Plans for stable workloads.
6. Remove unused load balancers.
7. Use lifecycle policies for S3.
8. Review NAT Gateway usage.
9. Reduce unnecessary cross-region data transfer.
10. Delete unused ECR images.

---

# Part 16 – Validation Checklist

Run these commands and save the output.

## AWS Identity

```bash
aws sts get-caller-identity --profile $AWS_PROFILE
```

## ECR Image

```bash
aws ecr describe-images   --repository-name $ECR_REPO_NAME   --region $AWS_REGION   --profile $AWS_PROFILE
```

## ECS Service

```bash
aws ecs describe-services   --cluster $ECS_CLUSTER_NAME   --services $ECS_SERVICE_NAME   --region $AWS_REGION   --profile $AWS_PROFILE
```

## Application URL

```bash
curl http://$ALB_DNS/
```

## CloudWatch Logs

```bash
aws logs describe-log-streams   --log-group-name $LOG_GROUP_NAME   --region $AWS_REGION   --profile $AWS_PROFILE
```

## X-Ray

```bash
aws xray get-trace-summaries   --start-time $START_TIME   --end-time $END_TIME   --region $AWS_REGION   --profile $AWS_PROFILE
```

## OpenSearch

```bash
aws opensearch describe-domain   --domain-name $OPENSEARCH_DOMAIN_NAME   --region $AWS_REGION   --profile $AWS_PROFILE
```

## Grafana

```bash
aws grafana list-workspaces   --region $AWS_REGION   --profile $AWS_PROFILE
```

## S3 DR Buckets

```bash
aws s3 ls s3://$PRIMARY_BUCKET/ --profile $AWS_PROFILE
aws s3 ls s3://$DR_BUCKET/ --profile $AWS_PROFILE
```

---

# Part 17 – Troubleshooting

## ECS task failed ELB health checks

Most failures in this lab are caused by one of these issues:

1. Subnets were passed as one comma-separated value to the ALB. Use `SUBNET_IDS_SPACE` for the ALB and `SUBNET_IDS_COMMA` for ECS.
2. The target group health check must use `/health` on traffic port `5000`.
3. The ECS task security group must allow inbound TCP `5000` from the ALB security group.
4. The ECS service should have a short health-check grace period while the Flask/Gunicorn app starts.
5. The container name and port in the ECS service load balancer config must exactly match the task definition: `$APP_NAME` and `5000`.

Quick check:

```bash
aws elbv2 describe-target-health \
  --target-group-arn $TARGET_GROUP_ARN \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --output table

aws ecs describe-services \
  --cluster $ECS_CLUSTER_NAME \
  --services $ECS_SERVICE_NAME \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --query 'services[0].events[0:5]' \
  --output table
```

If the target health reason is `Target.Timeout`, check the ECS security group and whether the app is listening on `0.0.0.0:5000`. If it is `Target.ResponseCodeMismatch`, check that `/health` returns HTTP `200`.


## Docker Push Fails

Check ECR login:

```bash
aws ecr get-login-password   --region $AWS_REGION   --profile $AWS_PROFILE | docker login   --username AWS   --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

## ECS Tasks Are Not Running

```bash
aws ecs describe-services   --cluster $ECS_CLUSTER_NAME   --services $ECS_SERVICE_NAME   --region $AWS_REGION   --profile $AWS_PROFILE
```

Check stopped task reason:

```bash
aws ecs list-tasks   --cluster $ECS_CLUSTER_NAME   --desired-status STOPPED   --region $AWS_REGION   --profile $AWS_PROFILE
```

## ALB Not Working

```bash
aws elbv2 describe-target-health   --target-group-arn $TARGET_GROUP_ARN   --region $AWS_REGION   --profile $AWS_PROFILE
```

## No X-Ray Traces

Generate traffic:

```bash
for i in {1..10}; do curl http://$ALB_DNS/; done
for i in {1..3}; do curl http://$ALB_DNS/slow; done
for i in {1..3}; do curl http://$ALB_DNS/error; done
```

Then query X-Ray again.

## Cost Explorer Error

Cost Explorer may need to be enabled first in the AWS Billing Console.

---

# Part 18 – Cleanup

> Important: Run cleanup to avoid unwanted AWS charges.

## Step 49: Delete ECS Service

```bash
aws ecs update-service   --cluster $ECS_CLUSTER_NAME   --service $ECS_SERVICE_NAME   --desired-count 0   --region $AWS_REGION   --profile $AWS_PROFILE
```

```bash
aws ecs delete-service   --cluster $ECS_CLUSTER_NAME   --service $ECS_SERVICE_NAME   --force   --region $AWS_REGION   --profile $AWS_PROFILE
```

---

## Step 50: Delete ECS Cluster

```bash
aws ecs delete-cluster   --cluster $ECS_CLUSTER_NAME   --region $AWS_REGION   --profile $AWS_PROFILE
```

---

## Step 51: Delete Load Balancer

Get listener ARN:

```bash
export LISTENER_ARN=$(aws elbv2 describe-listeners   --load-balancer-arn $ALB_ARN   --region $AWS_REGION   --profile $AWS_PROFILE   --query 'Listeners[0].ListenerArn'   --output text)
```

Delete listener:

```bash
aws elbv2 delete-listener   --listener-arn $LISTENER_ARN   --region $AWS_REGION   --profile $AWS_PROFILE
```

Delete load balancer:

```bash
aws elbv2 delete-load-balancer   --load-balancer-arn $ALB_ARN   --region $AWS_REGION   --profile $AWS_PROFILE
```

Wait a few minutes before deleting the target group.

```bash
aws elbv2 delete-target-group   --target-group-arn $TARGET_GROUP_ARN   --region $AWS_REGION   --profile $AWS_PROFILE
```

---

## Step 52: Delete Security Groups

```bash
aws ec2 delete-security-group   --group-id $ECS_SG_ID   --region $AWS_REGION   --profile $AWS_PROFILE
```

```bash
aws ec2 delete-security-group   --group-id $ALB_SG_ID   --region $AWS_REGION   --profile $AWS_PROFILE
```

---

## Step 53: Delete CloudWatch Log Group

```bash
aws logs delete-log-group   --log-group-name $LOG_GROUP_NAME   --region $AWS_REGION   --profile $AWS_PROFILE
```

---

## Step 54: Delete ECR Repository

```bash
aws ecr delete-repository   --repository-name $ECR_REPO_NAME   --force   --region $AWS_REGION   --profile $AWS_PROFILE
```

---

## Step 55: Delete OpenSearch Domain

```bash
aws opensearch delete-domain   --domain-name $OPENSEARCH_DOMAIN_NAME   --region $AWS_REGION   --profile $AWS_PROFILE
```

---

## Step 56: Delete Grafana Workspace

```bash
aws grafana delete-workspace   --workspace-id $GRAFANA_WORKSPACE_ID   --region $AWS_REGION   --profile $AWS_PROFILE
```

---

## Step 57: Delete S3 Buckets

Delete objects:

```bash
aws s3 rm s3://$PRIMARY_BUCKET --recursive   --region $AWS_REGION   --profile $AWS_PROFILE
```

```bash
aws s3 rm s3://$DR_BUCKET --recursive   --region $DR_REGION   --profile $AWS_PROFILE
```

Delete buckets:

```bash
aws s3api delete-bucket   --bucket $PRIMARY_BUCKET   --region $AWS_REGION   --profile $AWS_PROFILE
```

```bash
aws s3api delete-bucket   --bucket $DR_BUCKET   --region $DR_REGION   --profile $AWS_PROFILE
```

---

## Step 58: Delete IAM Roles

Detach policies:

```bash
aws iam detach-role-policy   --role-name day24EcsTaskExecutionRole   --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy   --profile $AWS_PROFILE
```

```bash
aws iam detach-role-policy   --role-name day24EcsAppTaskRole   --policy-arn arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess   --profile $AWS_PROFILE
```

Delete roles:

```bash
aws iam delete-role   --role-name day24EcsTaskExecutionRole   --profile $AWS_PROFILE
```

```bash
aws iam delete-role   --role-name day24EcsAppTaskRole   --profile $AWS_PROFILE
```

---

## Step 59: Delete Optional Route53 Health Check

List health checks:

```bash
aws route53 list-health-checks   --profile $AWS_PROFILE
```

Delete selected health check:

```bash
aws route53 delete-health-check   --health-check-id <HEALTH_CHECK_ID>   --profile $AWS_PROFILE
```

---

## Step 60: Delete Optional Global Accelerator

Disable accelerator first:

```bash
aws globalaccelerator update-accelerator   --accelerator-arn $ACCELERATOR_ARN   --enabled false   --profile $AWS_PROFILE
```

Delete accelerator:

```bash
aws globalaccelerator delete-accelerator   --accelerator-arn $ACCELERATOR_ARN   --profile $AWS_PROFILE
```

---

# Part 19 – Lab Deliverables

Submit the following:

1. AWS identity output.
2. Docker image build screenshot or CLI output.
3. ECR image push confirmation.
4. ECS service running output.
5. Application ALB URL output.
6. CloudWatch log stream output.
7. X-Ray trace summary output.
8. OpenSearch domain status output.
9. Grafana workspace output.
10. Primary and DR S3 bucket outputs.
11. Route53 health check output, if created.
12. Global Accelerator output, if created.
13. Cost Explorer service cost output.
14. DR assessment answers.
15. Five FinOps recommendations.
16. Cleanup verification output.

---

# Part 20 – Evaluation Rubric – 100 Marks

| Area | Marks |
|---|---:|
| Environment setup and AWS CLI profile validation | 5 |
| Python app created and tested locally | 10 |
| Docker image built successfully | 10 |
| ECR repository created and image pushed | 10 |
| IAM roles created correctly | 8 |
| ECS Fargate service deployed successfully | 12 |
| Application accessible through ALB | 8 |
| CloudWatch centralized logging verified | 8 |
| X-Ray traces generated and reviewed | 8 |
| OpenTelemetry concept explained | 4 |
| OpenSearch domain created and log flow explained | 5 |
| Grafana workspace created or reviewed | 4 |
| DR simulation completed using two regions | 5 |
| Cost Explorer and FinOps recommendations completed | 3 |
| Cleanup completed properly | 0 mandatory pass requirement |

> Cleanup is mandatory. If cleanup is not completed, the submission should not be considered complete even if the technical score is high.

---

# Expected Learning Outcomes

After completing this lab, students should be able to:

- Explain why observability is important in production systems.
- Build and deploy a Python containerized application.
- Use CloudWatch Logs for centralized logging.
- Use AWS X-Ray for distributed tracing.
- Explain the purpose of OpenTelemetry.
- Understand how OpenSearch can support centralized log search.
- Understand how Grafana supports dashboards.
- Explain basic multi-region DR concepts.
- Explain Route53 failover and health checks.
- Explain AWS Global Accelerator use cases.
- Use Cost Explorer for basic cost analysis.
- Recommend simple FinOps improvements.
- Clean up AWS resources safely.