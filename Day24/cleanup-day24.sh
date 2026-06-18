#!/usr/bin/env bash
set +e

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

export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --profile "$AWS_PROFILE" --query Account --output text)

export PRIMARY_BUCKET=day24-primary-$AWS_ACCOUNT_ID-$AWS_REGION
export DR_BUCKET=day24-dr-$AWS_ACCOUNT_ID-$DR_REGION

echo "Cleaning Day 24 resources from account: $AWS_ACCOUNT_ID"

echo "Getting ARNs and IDs..."

export ALB_ARN=$(aws elbv2 describe-load-balancers \
  --names day24-python-alb \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" \
  --query 'LoadBalancers[0].LoadBalancerArn' \
  --output text 2>/dev/null)

export TARGET_GROUP_ARN=$(aws elbv2 describe-target-groups \
  --names day24-python-tg \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text 2>/dev/null)

export ALB_SG_ID=$(aws ec2 describe-security-groups \
  --filters Name=group-name,Values=day24-alb-sg \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" \
  --query 'SecurityGroups[0].GroupId' \
  --output text 2>/dev/null)

export ECS_SG_ID=$(aws ec2 describe-security-groups \
  --filters Name=group-name,Values=day24-ecs-sg \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" \
  --query 'SecurityGroups[0].GroupId' \
  --output text 2>/dev/null)

echo "Stopping ECS service..."
aws ecs update-service \
  --cluster "$ECS_CLUSTER_NAME" \
  --service "$ECS_SERVICE_NAME" \
  --desired-count 0 \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE"

aws ecs delete-service \
  --cluster "$ECS_CLUSTER_NAME" \
  --service "$ECS_SERVICE_NAME" \
  --force \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE"

echo "Deleting ECS cluster..."
aws ecs delete-cluster \
  --cluster "$ECS_CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE"

echo "Deleting ALB listener and load balancer..."
if [ "$ALB_ARN" != "None" ] && [ -n "$ALB_ARN" ]; then
  LISTENER_ARN=$(aws elbv2 describe-listeners \
    --load-balancer-arn "$ALB_ARN" \
    --region "$AWS_REGION" \
    --profile "$AWS_PROFILE" \
    --query 'Listeners[0].ListenerArn' \
    --output text 2>/dev/null)

  if [ "$LISTENER_ARN" != "None" ] && [ -n "$LISTENER_ARN" ]; then
    aws elbv2 delete-listener \
      --listener-arn "$LISTENER_ARN" \
      --region "$AWS_REGION" \
      --profile "$AWS_PROFILE"
  fi

  aws elbv2 delete-load-balancer \
    --load-balancer-arn "$ALB_ARN" \
    --region "$AWS_REGION" \
    --profile "$AWS_PROFILE"
fi

echo "Waiting before deleting target group..."
sleep 30

if [ "$TARGET_GROUP_ARN" != "None" ] && [ -n "$TARGET_GROUP_ARN" ]; then
  aws elbv2 delete-target-group \
    --target-group-arn "$TARGET_GROUP_ARN" \
    --region "$AWS_REGION" \
    --profile "$AWS_PROFILE"
fi

echo "Deleting security groups..."
if [ "$ECS_SG_ID" != "None" ] && [ -n "$ECS_SG_ID" ]; then
  aws ec2 delete-security-group \
    --group-id "$ECS_SG_ID" \
    --region "$AWS_REGION" \
    --profile "$AWS_PROFILE"
fi

if [ "$ALB_SG_ID" != "None" ] && [ -n "$ALB_SG_ID" ]; then
  aws ec2 delete-security-group \
    --group-id "$ALB_SG_ID" \
    --region "$AWS_REGION" \
    --profile "$AWS_PROFILE"
fi

echo "Deleting CloudWatch log group..."
aws logs delete-log-group \
  --log-group-name "$LOG_GROUP_NAME" \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE"

echo "Deleting ECR repository..."
aws ecr delete-repository \
  --repository-name "$ECR_REPO_NAME" \
  --force \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE"

echo "Deleting OpenSearch domain..."
aws opensearch delete-domain \
  --domain-name "$OPENSEARCH_DOMAIN_NAME" \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE"

echo "Deleting Grafana workspaces matching name..."
GRAFANA_IDS=$(aws grafana list-workspaces \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" \
  --query "workspaces[?name=='$GRAFANA_WORKSPACE_NAME'].id" \
  --output text 2>/dev/null)

for ID in $GRAFANA_IDS; do
  aws grafana delete-workspace \
    --workspace-id "$ID" \
    --region "$AWS_REGION" \
    --profile "$AWS_PROFILE"
done

echo "Emptying and deleting S3 buckets..."
aws s3 rm "s3://$PRIMARY_BUCKET" --recursive \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE"

aws s3api delete-bucket \
  --bucket "$PRIMARY_BUCKET" \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE"

aws s3 rm "s3://$DR_BUCKET" --recursive \
  --region "$DR_REGION" \
  --profile "$AWS_PROFILE"

aws s3api delete-bucket \
  --bucket "$DR_BUCKET" \
  --region "$DR_REGION" \
  --profile "$AWS_PROFILE"

echo "Deleting IAM roles..."
aws iam detach-role-policy \
  --role-name day24EcsTaskExecutionRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy \
  --profile "$AWS_PROFILE"

aws iam detach-role-policy \
  --role-name day24EcsAppTaskRole \
  --policy-arn arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess \
  --profile "$AWS_PROFILE"

aws iam delete-role \
  --role-name day24EcsTaskExecutionRole \
  --profile "$AWS_PROFILE"

aws iam delete-role \
  --role-name day24EcsAppTaskRole \
  --profile "$AWS_PROFILE"

echo "Disabling and deleting Global Accelerator if present..."
ACCELERATOR_ARN=$(aws globalaccelerator list-accelerators \
  --profile "$AWS_PROFILE" \
  --query "Accelerators[?Name=='day24-accelerator'].AcceleratorArn" \
  --output text 2>/dev/null)

if [ -n "$ACCELERATOR_ARN" ] && [ "$ACCELERATOR_ARN" != "None" ]; then
  aws globalaccelerator update-accelerator \
    --accelerator-arn "$ACCELERATOR_ARN" \
    --enabled false \
    --profile "$AWS_PROFILE"

  sleep 30

  aws globalaccelerator delete-accelerator \
    --accelerator-arn "$ACCELERATOR_ARN" \
    --profile "$AWS_PROFILE"
fi

echo "Cleanup completed."