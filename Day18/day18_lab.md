# Day 18 – 10-Jun-2026 (Wednesday)
# Module 4 – Kubernetes with Amazon EKS

# Lab: EKS Provisioning & Networking Setup

## AWS Resources Used

- Amazon EKS
- Amazon VPC
- IAM
- CloudFormation

---

# Lab Objectives

Participants will:

- Provision EKS using CloudFormation.
- Configure networking resources.
- Verify cluster creation.
- Configure kubectl.
- Validate worker nodes.
- Test Kubernetes networking.
- Verify IAM integration.

---

# Lab 1: Review CloudFormation Template

``` 
unzip eks_day17_cloudformation.zip
chmod +x deploy-eks-day17.sh cleanup-eks-day17.sh
./deploy-eks-day17.sh
```

# Lab 5: Verify EKS Cluster

## List Clusters

```bash
aws eks list-clusters \
  --region us-east-1 \
  --profile devops
```

## Describe Cluster

```bash
aws eks describe-cluster \
  --name rama-eks-cluster \
  --region us-east-1 \
  --profile devops
```

## Verify Status

Expected:

```text
ACTIVE
```

---

# Lab 6: Configure kubectl

## Update kubeconfig

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name rama-eks-cluster \
  --profile devops
```

## Verify Nodes

```bash
kubectl get nodes
```

Expected:

```text
NAME                            STATUS   ROLES    AGE
ip-172-31-2-111.ec2.internal    Ready    <none>
ip-172-31-89-122.ec2.internal   Ready    <none>
```

---

# Lab 7: Explore Cluster Resources

## View Nodes

```bash
kubectl get nodes
```

## View Namespaces

```bash
kubectl get namespaces
```

## View All Pods

```bash
kubectl get pods -A
```

## View Node Groups

```bash
aws eks list-nodegroups \
  --cluster-name rama-eks-cluster \
  --region us-east-1 \
  --profile devops
```


## Check Application Logs

```bash
kubectl logs -n day17 deployment/rama-ecr-app
```

---

## Verify Service

```bash
kubectl get svc -n day17
```

## Verify Endpoints

```bash
kubectl get endpoints rama-ecr-service -n day17
```

Expected:

```text
172.31.x.x:8080
172.31.x.x:8080
```

## Verify Load Balancer

```bash
kubectl get svc rama-ecr-service -n day17
```

Wait until:

```text
EXTERNAL-IP / HOSTNAME is populated
```

---

# Lab 10: Test Internal Connectivity

## Launch Debug Pod

```bash
kubectl run debug --rm -it \
  --image=curlimages/curl \
  --restart=Never \
  -n day17 -- sh
```

## Test Pod Directly

```bash
curl -v http://172.31.13.20:8080
curl -v http://172.31.1.227:8080
```

Verify application response.

---

# Lab 11: Verify Node Group

```bash
aws eks describe-nodegroup \
  --cluster-name rama-eks-cluster \
  --nodegroup-name rama-eks-nodegroup \
  --region us-east-1 \
  --profile devops
```

Verify:

* Desired Size = 2
* Running Nodes = 2
* Instance Type = t3.medium
* Status = ACTIVE

---

## Disaster recovery and maintain

    kubectl get pods -n day17
    kubectl delete pod rama-ecr-app-87b74d478-d2pjc -n day17
    kubectl get pods -n day17

    If the pod is managed by a Deployment, ReplicaSet, StatefulSet, etc., 
    Kubernetes will automatically create a replacement pod.

# Lab 12: Scale Node Group

## Scale down a Deployment (stop all its pods)
    kubectl get deployment -n day17

    kubectl scale deployment <deployment-name> --replicas=0 -n <namespace>

    Example:
    
    kubectl scale deployment rama-ecr-app --replicas=0 -n day17
    
    To start it again:
    
    kubectl scale deployment rama-ecr-app --replicas=3 -n day17
## Increase Desired Capacity

```bash
aws eks update-nodegroup-config \
  --cluster-name rama-eks-cluster \
  --nodegroup-name rama-eks-nodegroup \
  --scaling-config minSize=1,maxSize=3,desiredSize=3 \
  --region us-east-1 \
  --profile devops
```

## Verify

```bash
kubectl get nodes -n day17
```

Observe the additional worker node joining the cluster.

---

# Lab 13: Verify Application Access

## Get Load Balancer URL

```bash
export APP_URL=$(kubectl get svc rama-ecr-service \
  -n day17 \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
```

## Display URL

```bash
echo http://$APP_URL
```

## Test Application

```bash
curl http://$APP_URL
```

Verify application response.

---

# Lab 14: CloudWatch Monitoring

Review:

* EKS Cluster Metrics
* Worker Node Metrics
* Load Balancer Metrics
* Control Plane Logs

Services:

```text
CloudWatch
Container Insights
EKS Monitoring
```

Verify:

* CPU Utilization
* Memory Utilization
* Network Throughput
* Pod Health

---

# Lab 15: Cleanup Resources

## Delete Kubernetes Resources

```bash
kubectl delete service rama-ecr-service -n day17
kubectl delete deployment rama-ecr-app -n day17
kubectl delete namespace day17
```

## Delete CloudFormation Stack

```bash
aws cloudformation delete-stack \
  --stack-name rama-eks-day17-stack \
  --region us-east-1 \
  --profile devops
```

## Wait for Stack Deletion

```bash
aws cloudformation wait stack-delete-complete \
  --stack-name rama-eks-day17-stack \
  --region us-east-1 \
  --profile devops
```

## Verify Deletion

```bash
aws cloudformation describe-stacks \
  --stack-name rama-eks-day17-stack
```

---

# Challenge Exercise

Using CloudFormation:

1. Create Amazon ECR Repository
2. Create EKS Cluster
3. Create IAM Roles
4. Create Managed Node Group
5. Configure kubectl
6. Deploy Application from ECR
7. Create LoadBalancer Service
8. Validate External Access

Document:

* CloudFormation Template
* Deployment Commands
* Screenshots
* Outputs

---

# Lab Deliverables

Submit:

* CloudFormation Stack Screenshot
* IAM Roles Screenshot
* EKS Cluster Screenshot
* Node Group Screenshot
* ECR Repository Screenshot
* `kubectl get nodes` Output
* `kubectl get pods -n day17` Output
* `kubectl get svc -n day17` Output
* Application Access Screenshot

---

# Expected Learning Outcomes

✓ Create Amazon EKS Using CloudFormation

✓ Configure IAM Roles for EKS

✓ Deploy Applications from Amazon ECR

✓ Configure kubectl Access

✓ Verify Worker Node Health

✓ Validate Kubernetes Networking

✓ Expose Applications Using LoadBalancer

✓ Manage EKS Infrastructure as Code

✓ Troubleshoot Pod and Service Connectivity
