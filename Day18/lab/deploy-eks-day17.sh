#!/usr/bin/env bash
set -euo pipefail

export AWS_REGION=us-east-1
export AWS_PROFILE=devops
export STACK_NAME=sunil-eks-day17-stack
export CLUSTER_NAME=sunil-eks-cluster

echo "Finding default VPC..."
export VPC_ID=$(aws ec2 describe-vpcs \
  --filters Name=isDefault,Values=true \
  --query 'Vpcs[0].VpcId' \
  --output text \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE")

echo "Finding subnets in us-east-1a and us-east-1b..."
export SUBNET_IDS=$(aws ec2 describe-subnets \
  --filters \
    Name=vpc-id,Values="$VPC_ID" \
    Name=availability-zone,Values=us-east-1a,us-east-1b \
  --query 'Subnets[*].SubnetId' \
  --output text \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" | tr '\t' ',')

echo "VPC_ID=$VPC_ID"
echo "SUBNET_IDS=$SUBNET_IDS"

echo "Creating CloudFormation stack..."
aws cloudformation deploy \
  --stack-name "$STACK_NAME" \
  --template-file eks-day17-cloudformation.yml \
  --capabilities CAPABILITY_NAMED_IAM \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" \
  --parameter-overrides \
    VpcId="$VPC_ID" \
    SubnetIds="$SUBNET_IDS" \
    CreateEcrRepository=false

echo "Updating kubeconfig..."
aws eks update-kubeconfig \
  --region "$AWS_REGION" \
  --name "$CLUSTER_NAME" \
  --profile "$AWS_PROFILE"

echo "Waiting for nodes..."
kubectl get nodes

echo "Deploying app and service..."
kubectl apply -f k8s-deployment.yml
kubectl apply -f k8s-service.yml

echo "Waiting for deployment rollout..."
kubectl rollout status deployment/sunil-ecr-app -n day17

echo "Service:"
kubectl get svc sunil-ecr-service -n day17

echo "When EXTERNAL-IP/hostname appears, test with:"
echo "curl http://$(kubectl get svc sunil-ecr-service -n day17 -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
