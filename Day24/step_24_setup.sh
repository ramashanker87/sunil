#!/usr/bin/env bash
set -e

export AWS_PROFILE=devops
export AWS_REGION=us-east-1

export APP_NAME=day24-python-observability
export ECR_REPO_NAME=day24-python-observability
export ECS_CLUSTER_NAME=day24-observability-cluster
export ECS_SERVICE_NAME=day24-python-service
export ECS_TASK_FAMILY=day24-python-task
export LOG_GROUP_NAME=/ecs/day24-python-observability

export IMAGE_TAG=v1
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --profile "$AWS_PROFILE" --query Account --output text)
export ECR_IMAGE_URI=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:$IMAGE_TAG

echo "Account: $AWS_ACCOUNT_ID"
echo "Image: $ECR_IMAGE_URI"

mkdir -p day24-python-app
cd day24-python-app

cat > app.py <<'EOF'
from flask import Flask
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
    }, 200

@app.route("/health")
def health():
    return {"status": "healthy"}, 200

@app.route("/slow")
def slow():
    time.sleep(2)
    return {"message": "Slow request completed"}, 200

@app.route("/error")
def error():
    return {"error": "Simulated application error"}, 500
EOF

cat > requirements.txt <<'EOF'
flask==3.0.3
aws-xray-sdk==2.14.0
gunicorn==22.0.0
EOF

cat > Dockerfile <<'EOF'
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--timeout", "30", "app:app"]
EOF

echo "Building Docker image..."
docker build -t "$APP_NAME:$IMAGE_TAG" .

echo "Creating ECR repo if missing..."
aws ecr describe-repositories \
  --repository-names "$ECR_REPO_NAME" \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" >/dev/null 2>&1 || \
aws ecr create-repository \
  --repository-name "$ECR_REPO_NAME" \
  --image-scanning-configuration scanOnPush=true \
  --encryption-configuration encryptionType=AES256 \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE"

echo "Logging in to ECR..."
aws ecr get-login-password \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" | docker login \
  --username AWS \
  --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

docker tag "$APP_NAME:$IMAGE_TAG" "$ECR_IMAGE_URI"
docker push "$ECR_IMAGE_URI"

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

echo "Creating IAM roles if missing..."
aws iam get-role --role-name day24EcsTaskExecutionRole --profile "$AWS_PROFILE" >/dev/null 2>&1 || \
aws iam create-role \
  --role-name day24EcsTaskExecutionRole \
  --assume-role-policy-document file://ecs-task-execution-trust-policy.json \
  --profile "$AWS_PROFILE"

aws iam attach-role-policy \
  --role-name day24EcsTaskExecutionRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy \
  --profile "$AWS_PROFILE" || true

aws iam get-role --role-name day24EcsAppTaskRole --profile "$AWS_PROFILE" >/dev/null 2>&1 || \
aws iam create-role \
  --role-name day24EcsAppTaskRole \
  --assume-role-policy-document file://ecs-task-execution-trust-policy.json \
  --profile "$AWS_PROFILE"

aws iam attach-role-policy \
  --role-name day24EcsAppTaskRole \
  --policy-arn arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess \
  --profile "$AWS_PROFILE" || true

echo "Waiting for IAM role propagation..."
sleep 20

export EXECUTION_ROLE_ARN=arn:aws:iam::$AWS_ACCOUNT_ID:role/day24EcsTaskExecutionRole
export TASK_ROLE_ARN=arn:aws:iam::$AWS_ACCOUNT_ID:role/day24EcsAppTaskRole

export VPC_ID=$(aws ec2 describe-vpcs \
  --filters Name=isDefault,Values=true \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" \
  --query 'Vpcs[0].VpcId' \
  --output text)

export SUBNET_1A=$(aws ec2 describe-subnets \
  --filters Name=vpc-id,Values="$VPC_ID" \
            Name=availability-zone,Values=us-east-1a \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" \
  --query 'Subnets[0].SubnetId' \
  --output text)

export SUBNET_1B=$(aws ec2 describe-subnets \
  --filters Name=vpc-id,Values="$VPC_ID" \
            Name=availability-zone,Values=us-east-1b \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" \
  --query 'Subnets[0].SubnetId' \
  --output text)

export SUBNET_IDS_SPACE="$SUBNET_1A $SUBNET_1B"
export SUBNET_IDS_COMMA="$SUBNET_1A,$SUBNET_1B"

echo "VPC: $VPC_ID"
echo "ALB subnets: $SUBNET_IDS_SPACE"
echo "ECS subnets: $SUBNET_IDS_COMMA"

echo "Creating security groups if missing..."
export ALB_SG_ID=$(aws ec2 describe-security-groups \
  --filters Name=group-name,Values=day24-alb-sg Name=vpc-id,Values="$VPC_ID" \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" \
  --query 'SecurityGroups[0].GroupId' \
  --output text 2>/dev/null)

if [ "$ALB_SG_ID" = "None" ] || [ -z "$ALB_SG_ID" ]; then
  export ALB_SG_ID=$(aws ec2 create-security-group \
    --group-name day24-alb-sg \
    --description "Day 24 ALB security group" \
    --vpc-id "$VPC_ID" \
    --region "$AWS_REGION" \
    --profile "$AWS_PROFILE" \
    --query GroupId \
    --output text)
fi

aws ec2 authorize-security-group-ingress \
  --group-id "$ALB_SG_ID" \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0 \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" || true

export ECS_SG_ID=$(aws ec2 describe-security-groups \
  --filters Name=group-name,Values=day24-ecs-sg Name=vpc-id,Values="$VPC_ID" \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" \
  --query 'SecurityGroups[0].GroupId' \
  --output text 2>/dev/null)

if [ "$ECS_SG_ID" = "None" ] || [ -z "$ECS_SG_ID" ]; then
  export ECS_SG_ID=$(aws ec2 create-security-group \
    --group-name day24-ecs-sg \
    --description "Day 24 ECS service security group" \
    --vpc-id "$VPC_ID" \
    --region "$AWS_REGION" \
    --profile "$AWS_PROFILE" \
    --query GroupId \
    --output text)
fi

aws ec2 authorize-security-group-ingress \
  --group-id "$ECS_SG_ID" \
  --protocol tcp \
  --port 5000 \
  --source-group "$ALB_SG_ID" \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" || true

echo "Creating log group if missing..."
aws logs create-log-group \
  --log-group-name "$LOG_GROUP_NAME" \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" 2>/dev/null || true

aws logs put-retention-policy \
  --log-group-name "$LOG_GROUP_NAME" \
  --retention-in-days 7 \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE"

echo "Creating ECS cluster..."
aws ecs create-cluster \
  --cluster-name "$ECS_CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" >/dev/null

echo "Creating ALB if missing..."
export ALB_ARN=$(aws elbv2 describe-load-balancers \
  --names day24-python-alb \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" \
  --query 'LoadBalancers[0].LoadBalancerArn' \
  --output text 2>/dev/null)

if [ "$ALB_ARN" = "None" ] || [ -z "$ALB_ARN" ]; then
  export ALB_ARN=$(aws elbv2 create-load-balancer \
    --name day24-python-alb \
    --subnets $SUBNET_IDS_SPACE \
    --security-groups "$ALB_SG_ID" \
    --scheme internet-facing \
    --type application \
    --region "$AWS_REGION" \
    --profile "$AWS_PROFILE" \
    --query 'LoadBalancers[0].LoadBalancerArn' \
    --output text)
fi

aws elbv2 wait load-balancer-available \
  --load-balancer-arns "$ALB_ARN" \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE"

export ALB_DNS=$(aws elbv2 describe-load-balancers \
  --load-balancer-arns "$ALB_ARN" \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" \
  --query 'LoadBalancers[0].DNSName' \
  --output text)

echo "ALB DNS: $ALB_DNS"

echo "Creating target group if missing..."
export TARGET_GROUP_ARN=$(aws elbv2 describe-target-groups \
  --names day24-python-tg \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text 2>/dev/null)

if [ "$TARGET_GROUP_ARN" = "None" ] || [ -z "$TARGET_GROUP_ARN" ]; then
  export TARGET_GROUP_ARN=$(aws elbv2 create-target-group \
    --name day24-python-tg \
    --protocol HTTP \
    --port 5000 \
    --vpc-id "$VPC_ID" \
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
    --region "$AWS_REGION" \
    --profile "$AWS_PROFILE" \
    --query 'TargetGroups[0].TargetGroupArn' \
    --output text)
else
  aws elbv2 modify-target-group \
    --target-group-arn "$TARGET_GROUP_ARN" \
    --health-check-enabled \
    --health-check-protocol HTTP \
    --health-check-port traffic-port \
    --health-check-path /health \
    --matcher HttpCode=200 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3 \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 5 \
    --region "$AWS_REGION" \
    --profile "$AWS_PROFILE"
fi

echo "Creating listener if missing..."
LISTENER_ARN=$(aws elbv2 describe-listeners \
  --load-balancer-arn "$ALB_ARN" \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" \
  --query 'Listeners[?Port==`80`].ListenerArn | [0]' \
  --output text 2>/dev/null)

if [ "$LISTENER_ARN" = "None" ] || [ -z "$LISTENER_ARN" ]; then
  aws elbv2 create-listener \
    --load-balancer-arn "$ALB_ARN" \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn="$TARGET_GROUP_ARN" \
    --region "$AWS_REGION" \
    --profile "$AWS_PROFILE"
else
  aws elbv2 modify-listener \
    --listener-arn "$LISTENER_ARN" \
    --default-actions Type=forward,TargetGroupArn="$TARGET_GROUP_ARN" \
    --region "$AWS_REGION" \
    --profile "$AWS_PROFILE"
fi

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

echo "Registering task definition..."
aws ecs register-task-definition \
  --cli-input-json file://task-definition.json \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" >/dev/null

echo "Creating or updating ECS service..."
SERVICE_STATUS=$(aws ecs describe-services \
  --cluster "$ECS_CLUSTER_NAME" \
  --services "$ECS_SERVICE_NAME" \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" \
  --query 'services[0].status' \
  --output text 2>/dev/null)

if [ "$SERVICE_STATUS" = "ACTIVE" ]; then
  aws ecs update-service \
    --cluster "$ECS_CLUSTER_NAME" \
    --service "$ECS_SERVICE_NAME" \
    --task-definition "$ECS_TASK_FAMILY" \
    --desired-count 2 \
    --health-check-grace-period-seconds 180 \
    --force-new-deployment \
    --region "$AWS_REGION" \
    --profile "$AWS_PROFILE"
else
  aws ecs create-service \
    --cluster "$ECS_CLUSTER_NAME" \
    --service-name "$ECS_SERVICE_NAME" \
    --task-definition "$ECS_TASK_FAMILY" \
    --desired-count 2 \
    --launch-type FARGATE \
    --health-check-grace-period-seconds 180 \
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNET_IDS_COMMA],securityGroups=[$ECS_SG_ID],assignPublicIp=ENABLED}" \
    --load-balancers "targetGroupArn=$TARGET_GROUP_ARN,containerName=$APP_NAME,containerPort=5000" \
    --region "$AWS_REGION" \
    --profile "$AWS_PROFILE"
fi

echo "Waiting for service stability..."
aws ecs wait services-stable \
  --cluster "$ECS_CLUSTER_NAME" \
  --services "$ECS_SERVICE_NAME" \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE"

echo "Service status:"
aws ecs describe-services \
  --cluster "$ECS_CLUSTER_NAME" \
  --services "$ECS_SERVICE_NAME" \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" \
  --query 'services[0].{Status:status,Running:runningCount,Desired:desiredCount,LoadBalancers:loadBalancers}' \
  --output table

echo "Target health:"
aws elbv2 describe-target-health \
  --target-group-arn "$TARGET_GROUP_ARN" \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" \
  --query 'TargetHealthDescriptions[*].{Target:Target.Id,Port:Target.Port,State:TargetHealth.State,Reason:TargetHealth.Reason,Description:TargetHealth.Description}' \
  --output table

echo "Testing ALB:"
echo "http://$ALB_DNS"

curl -i "http://$ALB_DNS/"
echo
curl -i "http://$ALB_DNS/health"
echo

echo "Done. ALB URL: http://$ALB_DNS"