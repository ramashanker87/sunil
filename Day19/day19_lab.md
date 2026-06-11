# Day 19 Lab: Persistent Storage on Amazon EKS with EBS, EFS, Route 53, and ECR

## Goal

Create a simple Python web application, build it as a Docker image, push it to Amazon ECR, deploy it on Amazon EKS, and test persistent storage using Amazon EBS and Amazon EFS.

This lab also demonstrates how persistent data can remain available even if the EKS cluster is deleted, as long as the backing EBS volume or EFS file system is retained.

## Topics Covered

- Persistent storage in Kubernetes
- Amazon EBS for block storage
- Amazon EFS for shared file storage
- Amazon ECR for Docker image registry
- Amazon EKS for Kubernetes workloads
- Route 53 DNS record for application access
- Retaining data when a cluster is deleted

## Important Storage Concept

| Storage | Kubernetes access mode | Best use case | Survives EKS cluster deletion? |
|---|---|---|---|
| EBS | ReadWriteOnce | Single-Pod or single-node stateful app | Yes, if volume is retained |
| EFS | ReadWriteMany | Shared data across Pods and nodes | Yes, if file system is retained |

EBS is Availability Zone scoped. EFS is regional and can be mounted by multiple Pods.

---

## Prerequisites

Install these tools:

```bash
aws --version
kubectl version --client
docker --version
jq --version
```

You need AWS permissions for EKS, IAM, EC2, ECR, EBS, EFS, and Route 53.

Set variables:

```bash
export AWS_REGION=us-east-1
export ACCOUNT_ID=$(aws sts get-caller-identity --profile devops --query Account --output text)
export CLUSTER_NAME=rama-day19-persistence-eks
export ECR_REPO=rama-day19-python-app
export APP_NAME=rama-day19-app
export NAMESPACE=rama-day19
```

Explanation:

- `AWS_REGION` decides where resources are created.
- `ACCOUNT_ID` is required for the ECR image URI.
- `CLUSTER_NAME` identifies the EKS cluster.
- `NAMESPACE` keeps lab resources separated inside Kubernetes.

---

# Part 1: Create and Push Python Docker App to ECR

## Step 1: Create a simple Python application

```bash
mkdir -p day19-python-app
cd day19-python-app
```

Create `app.py`:

```bash
cat > app.py <<'PYAPP'
from flask import Flask, jsonify, request
from pathlib import Path
from datetime import datetime

app = Flask(__name__)

EBS_FILE = Path('/data/ebs/messages.txt')
EFS_FILE = Path('/data/efs/messages.txt')


def append_message(path: Path, message: str):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('a') as file:
        file.write(f'{datetime.utcnow().isoformat()}Z - {message}\n')


def read_messages(path: Path):
    if not path.exists():
        return []
    return path.read_text().splitlines()


@app.route('/')
def home():
    return jsonify({
        'message': 'Day 19 persistent storage lab',
        'write_ebs': '/write?target=ebs&message=hello-ebs',
        'write_efs': '/write?target=efs&message=hello-efs',
        'read': '/read'
    })


@app.route('/write', methods=['GET', 'POST'])
def write():
    target = request.args.get('target', 'efs')
    message = request.args.get('message', 'default-message')

    if target == 'ebs':
        append_message(EBS_FILE, message)
    elif target == 'efs':
        append_message(EFS_FILE, message)
    else:
        return jsonify({'error': 'target must be ebs or efs'}), 400

    return jsonify({'status': 'written', 'target': target, 'message': message})


@app.route('/read')
def read():
    return jsonify({
        'ebs_messages': read_messages(EBS_FILE),
        'efs_messages': read_messages(EFS_FILE)
    })


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
PYAPP
```

Create `requirements.txt`:

```bash
cat > requirements.txt <<'REQ'
flask==3.0.3
REQ
```

Create `Dockerfile`:

```bash
cat > Dockerfile <<'DOCKER'
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 8080
CMD ["python", "app.py"]
DOCKER
```

Explanation:

- The app writes EBS data to `/data/ebs/messages.txt`.
- The app writes EFS data to `/data/efs/messages.txt`.
- These paths will be mounted from Kubernetes PersistentVolumeClaims.

## Step 2: Create ECR repository and push image

Create an ECR repository:

```bash
aws ecr create-repository \
  --repository-name ${ECR_REPO} \
  --region ${AWS_REGION} \
  --profile devops
```

Login Docker to ECR:

```bash
aws ecr get-login-password --region ${AWS_REGION} --profile devops \
  | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
```

Build, tag, and push:

```bash
docker build -t ${ECR_REPO}:v1 .
```
## Verify running docker container

```bash 
docker run --name rama-python-app -p 8080:8080 rama-day19-python-app:v1
```

## Push image to ECR
```bash
docker tag ${ECR_REPO}:v1 ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:v1
docker push ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:v1
```

Return to parent directory:

```bash
cd ..
```

Explanation:

- ECR is a private container registry.
- EKS nodes pull the application image from ECR.

---

# Part 2: Create EKS Cluster

## Step 3: Create IAM roles for EKS

Create the EKS cluster role trust policy:

```bash
cat > eks-cluster-trust-policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"Service": "eks.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
```

Create cluster role and attach policy:

```bash
aws iam create-role \
  --role-name Day19EksClusterRole \
  --assume-role-policy-document file://eks-cluster-trust-policy.json \
  --profile devops

aws iam attach-role-policy \
  --role-name Day19EksClusterRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy \
  --profile devops
```

Create the node role trust policy:

```bash
cat > eks-node-trust-policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
```

Create node role and attach policies:

```bash
aws iam create-role \
  --role-name Day19EksNodeRole \
  --assume-role-policy-document file://eks-node-trust-policy.json \
  --profile devops

aws iam attach-role-policy \
  --role-name Day19EksNodeRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy \
  --profile devops

aws iam attach-role-policy \
  --role-name Day19EksNodeRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly \
  --profile devops

aws iam attach-role-policy \
  --role-name Day19EksNodeRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
  --profile devops
```

Export role ARNs:

```bash
export CLUSTER_ROLE_ARN=$(aws iam get-role --role-name Day19EksClusterRole --query Role.Arn --profile devops --output text)
export NODE_ROLE_ARN=$(aws iam get-role --role-name Day19EksNodeRole --query Role.Arn --profile devops --output text)
```

Explanation:

- The cluster role lets EKS manage the Kubernetes control plane.
- The node role lets EC2 worker nodes join the cluster and pull images from ECR.

## Step 4: Create VPC and public subnets

Create VPC:

```bash
export VPC_ID=$(aws ec2 create-vpc \
  --cidr-block 10.90.0.0/16 \
  --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=day19-eks-vpc}]' \
  --query Vpc.VpcId \
  --profile devops \
  --output text)

aws ec2 modify-vpc-attribute --vpc-id ${VPC_ID} --enable-dns-hostnames '{"Value":true}' --profile devops
aws ec2 modify-vpc-attribute --vpc-id ${VPC_ID} --enable-dns-support '{"Value":true}' --profile devops
```

Get two Availability Zones:

```bash
export AZ1=$(aws ec2 describe-availability-zones --region ${AWS_REGION} --query 'AvailabilityZones[0].ZoneName' --profile devops --output text)
export AZ2=$(aws ec2 describe-availability-zones --region ${AWS_REGION} --query 'AvailabilityZones[1].ZoneName' --profile devops --output text)
```

Create subnets:

```bash
export SUBNET1_ID=$(aws ec2 create-subnet \
  --vpc-id ${VPC_ID} \
  --cidr-block 10.90.1.0/24 \
  --availability-zone ${AZ1} \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=day19-public-subnet-1}]' \
  --query Subnet.SubnetId \
  --profile devops \
  --output text)

export SUBNET2_ID=$(aws ec2 create-subnet \
  --vpc-id ${VPC_ID} \
  --cidr-block 10.90.2.0/24 \
  --availability-zone ${AZ2} \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=day19-public-subnet-2}]' \
  --query Subnet.SubnetId \
  --profile devops \
  --output text)

aws ec2 modify-subnet-attribute --subnet-id ${SUBNET1_ID} --map-public-ip-on-launch --profile devops
aws ec2 modify-subnet-attribute --subnet-id ${SUBNET2_ID} --map-public-ip-on-launch --profile devops
```

Create internet gateway and route table:

```bash
export IGW_ID=$(aws ec2 create-internet-gateway \
  --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=day19-igw}]' \
  --query InternetGateway.InternetGatewayId \
  --profile devops \
  --output text)

aws ec2 attach-internet-gateway --internet-gateway-id ${IGW_ID} --vpc-id ${VPC_ID} --profile devops

export RTB_ID=$(aws ec2 create-route-table \
  --vpc-id ${VPC_ID} \
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=day19-public-rtb}]' \
  --query RouteTable.RouteTableId \
  --profile devops \
  --output text)

aws ec2 create-route \
  --route-table-id ${RTB_ID} \
  --destination-cidr-block 0.0.0.0/0 \
  --profile devops \
  --gateway-id ${IGW_ID}

aws ec2 associate-route-table --route-table-id ${RTB_ID} --subnet-id ${SUBNET1_ID} --profile devops
aws ec2 associate-route-table --route-table-id ${RTB_ID} --subnet-id ${SUBNET2_ID} --profile devops
```

Tag subnets for Kubernetes load balancers:

```bash
aws ec2 create-tags \
  --resources ${SUBNET1_ID} ${SUBNET2_ID} \
  --profile devops \
  --tags Key=kubernetes.io/cluster/${CLUSTER_NAME},Value=shared Key=kubernetes.io/role/elb,Value=1
```

Explanation:

- EKS needs VPC subnets for control plane networking and worker nodes.
- Subnet tags help Kubernetes create AWS load balancers.

## Step 5: Create EKS cluster and node group

Create the cluster:

```bash
aws eks create-cluster \
  --region ${AWS_REGION} \
  --name ${CLUSTER_NAME} \
  --role-arn ${CLUSTER_ROLE_ARN} \
  --resources-vpc-config subnetIds=${SUBNET1_ID},${SUBNET2_ID},endpointPublicAccess=true,endpointPrivateAccess=false \
  --profile devops
```

Wait for it:

```bash
aws eks wait cluster-active \
  --region ${AWS_REGION} \
  --name ${CLUSTER_NAME} \
  --profile devops
```

Configure `kubectl`:

```bash
aws eks update-kubeconfig \
  --region ${AWS_REGION} \
  --name ${CLUSTER_NAME} \
  --profile devops
```

Create managed node group:

```bash
aws eks create-nodegroup \
  --region ${AWS_REGION} \
  --cluster-name ${CLUSTER_NAME} \
  --nodegroup-name day19-ng \
  --node-role ${NODE_ROLE_ARN} \
  --subnets ${SUBNET1_ID} ${SUBNET2_ID} \
  --instance-types t3.medium \
  --scaling-config minSize=2,maxSize=3,desiredSize=2 \
  --disk-size 20 \
  --profile devops
```

Wait and verify:

```bash
aws eks wait nodegroup-active \
  --region ${AWS_REGION} \
  --cluster-name ${CLUSTER_NAME} \
  --nodegroup-name day19-ng \
  --profile devops

kubectl get nodes
```

Explanation:

- Managed node groups create EC2 worker nodes for the cluster.
- Pods run on the worker nodes.

---

# Part 3: Configure EBS Persistent Storage

## Step 6: Install EBS CSI driver

Create IAM role for EBS CSI driver using EKS Pod Identity:

```bash
cat > ebs-csi-trust-policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"Service": "pods.eks.amazonaws.com"},
      "Action": ["sts:AssumeRole", "sts:TagSession"]
    }
  ]
}
EOF

aws iam create-role \
  --role-name Day19EbsCsiRole \
  --assume-role-policy-document file://ebs-csi-trust-policy.json \
  --profile devops

aws iam attach-role-policy \
  --role-name Day19EbsCsiRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --profile devops

export EBS_CSI_ROLE_ARN=$(aws iam get-role --role-name Day19EbsCsiRole --query Role.Arn --profile devops --output text)
```

Install Pod Identity Agent and EBS CSI add-ons:

```bash
aws eks create-addon \
  --cluster-name ${CLUSTER_NAME} \
  --addon-name eks-pod-identity-agent \
  --region ${AWS_REGION} \
  --profile devops

aws eks create-addon \
  --cluster-name ${CLUSTER_NAME} \
  --addon-name aws-ebs-csi-driver \
  --region ${AWS_REGION} \
  --profile devops
```

Associate IAM role with EBS CSI service account:

```bash
aws eks create-pod-identity-association \
  --cluster-name ${CLUSTER_NAME} \
  --namespace kube-system \
  --service-account ebs-csi-controller-sa \
  --role-arn ${EBS_CSI_ROLE_ARN} \
  --region ${AWS_REGION} \
  --profile devops
```

Verify:

```bash
kubectl get pods -n kube-system | grep ebs
```

Explanation:

- The EBS CSI driver allows Kubernetes to create and attach EBS volumes.
- Pod Identity gives the CSI controller AWS permissions.

## Step 7: Create EBS StorageClass and PVC

```bash
cat > ebs-storage.yaml <<'EOF'
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-retain-sc
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Retain
parameters:
  type: gp3
  encrypted: "true"
---
apiVersion: v1
kind: Namespace
metadata:
  name: rama-day19
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ebs-data
  namespace: rama-day19
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: ebs-retain-sc
  resources:
    requests:
      storage: 5Gi
EOF

kubectl apply -f ebs-storage.yaml
kubectl get pvc -n ${NAMESPACE}
```

Explanation:

- `ReadWriteOnce` means the volume can be mounted by one node at a time.
- `reclaimPolicy: Retain` tells Kubernetes not to delete the backing EBS volume when the PV is deleted.
- `WaitForFirstConsumer` waits until a Pod is scheduled before creating the EBS volume in the correct Availability Zone.

---

# Part 4: Configure EFS Persistent Storage

## Step 8: Create EFS file system and mount targets

Get cluster security group:

```bash
export NODE_SG_ID=$(aws eks describe-cluster \
  --name ${CLUSTER_NAME} \
  --region ${AWS_REGION} \
  --query 'cluster.resourcesVpcConfig.clusterSecurityGroupId' \
  --profile devops \
  --output text)
```

Create EFS security group:

```bash
export EFS_SG_ID=$(aws ec2 create-security-group \
  --group-name rama-day19-efs-sg \
  --description "Allow NFS from EKS" \
  --vpc-id ${VPC_ID} \
  --query GroupId \
  --profile devops \
  --output text)

aws ec2 authorize-security-group-ingress \
  --group-id ${EFS_SG_ID} \
  --protocol tcp \
  --port 2049 \
  --profile devops \
  --source-group ${NODE_SG_ID}
```

Create EFS file system:

```bash
export EFS_ID=$(aws efs create-file-system \
  --creation-token day19-efs-${CLUSTER_NAME} \
  --performance-mode generalPurpose \
  --throughput-mode elastic \
  --encrypted \
  --tags Key=Name,Value=day19-efs \
  --query FileSystemId \
  --profile devops \
  --output text)
```

Create mount targets:

```bash
aws efs create-mount-target \
  --file-system-id ${EFS_ID} \
  --subnet-id ${SUBNET1_ID} \
  --profile devops \
  --security-groups ${EFS_SG_ID}

aws efs create-mount-target \
  --file-system-id ${EFS_ID} \
  --subnet-id ${SUBNET2_ID} \
  --profile devops \
  --security-groups ${EFS_SG_ID}
```

Check mount target status:

```bash
aws efs describe-mount-targets \
  --file-system-id ${EFS_ID} \
  --query 'MountTargets[*].[MountTargetId,LifeCycleState,SubnetId]' \
  --profile devops \
  --output table
```

Explanation:

- EFS requires mount targets in VPC subnets.
- Worker nodes mount EFS through NFS port 2049.

## Step 9: Install EFS CSI driver

Create IAM role for EFS CSI driver:

```bash
cat > efs-csi-trust-policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"Service": "pods.eks.amazonaws.com"},
      "Action": ["sts:AssumeRole", "sts:TagSession"]
    }
  ]
}
EOF

aws iam create-role \
  --role-name Day19EfsCsiRole \
  --profile devops \
  --assume-role-policy-document file://efs-csi-trust-policy.json

aws iam attach-role-policy \
  --role-name Day19EfsCsiRole \
  --profile devops \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy

export EFS_CSI_ROLE_ARN=$(aws iam get-role --role-name Day19EfsCsiRole --query Role.Arn --profile devops --output text)
```

Install EFS CSI add-on:

```bash
aws eks create-addon \
  --cluster-name ${CLUSTER_NAME} \
  --addon-name aws-efs-csi-driver \
  --profile devops \
  --region ${AWS_REGION}
```

Associate role with EFS CSI service account:

```bash
aws eks create-pod-identity-association \
  --cluster-name ${CLUSTER_NAME} \
  --namespace kube-system \
  --service-account efs-csi-controller-sa \
  --role-arn ${EFS_CSI_ROLE_ARN} \
  --profile devops \
  --region ${AWS_REGION}
```

Verify:

```bash
kubectl get pods -n kube-system | grep efs
```

Explanation:

- The EFS CSI driver mounts Amazon EFS into Kubernetes Pods.
- EFS supports `ReadWriteMany`, so multiple Pods can use the same file system.

## Step 10: Create EFS StorageClass and PVC

```bash
cat > efs-storage.yaml <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: ${EFS_ID}
  directoryPerms: "700"
  basePath: "/day19"
reclaimPolicy: Retain
volumeBindingMode: Immediate
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: efs-data
  namespace: rama-day19
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: efs-sc
  resources:
    requests:
      storage: 5Gi
EOF

kubectl apply -f efs-storage.yaml
kubectl get pvc -n ${NAMESPACE}
```

Explanation:

- `ReadWriteMany` allows shared access.
- `provisioningMode: efs-ap` creates EFS Access Points dynamically.
- `reclaimPolicy: Retain` helps keep the data after Kubernetes objects are deleted.

---

# Part 5: Deploy Application with EBS and EFS Volumes

## Step 11: Deploy the app

```bash
cat > app-deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${APP_NAME}
  namespace: ${NAMESPACE}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${APP_NAME}
  template:
    metadata:
      labels:
        app: ${APP_NAME}
    spec:
      containers:
        - name: ${APP_NAME}
          image: ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:v1
          imagePullPolicy: Always
          ports:
            - containerPort: 8080
          volumeMounts:
            - name: ebs-volume
              mountPath: /data/ebs
            - name: efs-volume
              mountPath: /data/efs
      volumes:
        - name: ebs-volume
          persistentVolumeClaim:
            claimName: ebs-data
        - name: efs-volume
          persistentVolumeClaim:
            claimName: efs-data
---
apiVersion: v1
kind: Service
metadata:
  name: ${APP_NAME}-svc
  namespace: ${NAMESPACE}
spec:
  type: LoadBalancer
  selector:
    app: ${APP_NAME}
  ports:
    - port: 80
      targetPort: 8080
EOF

kubectl apply -f app-deployment.yaml
```

Wait for the Pod and service:

```bash
kubectl get pods -n ${NAMESPACE}
kubectl get svc -n ${NAMESPACE}
```

Get load balancer DNS:

```bash
export LB_DNS=$(kubectl get svc ${APP_NAME}-svc -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo ${LB_DNS}
```

Test writes:

```bash
curl http://${LB_DNS}/
curl -X POST "http://${LB_DNS}/write?target=ebs&message=hello-ebs"
curl -X POST "http://${LB_DNS}/write?target=efs&message=hello-efs"
curl http://${LB_DNS}/read
```

Explanation:

- The same container mounts both EBS and EFS.
- Data written to `/data/ebs` goes to EBS.
- Data written to `/data/efs` goes to EFS.

## Step 12: Test persistence after Pod deletion

Delete the Pod:

```bash
kubectl delete pod -n ${NAMESPACE} -l app=${APP_NAME}
```

Wait for the Deployment to recreate it:

```bash
kubectl get pods -n ${NAMESPACE}
```

Read data again:

```bash
curl http://${LB_DNS}/read
```

Expected result:

- EBS messages should still exist.
- EFS messages should still exist.

Explanation:

- Pods are temporary.
- PersistentVolumes are separate from Pods.
- A new Pod can reconnect to the same PVC.

---

# Part 6: Add Route 53 DNS

## Step 13: Create DNS record

Skip this section if you do not have a Route 53 hosted zone.

Set your hosted zone and DNS name:

```bash
export HOSTED_ZONE_ID=Z1234567890EXAMPLE
export RECORD_NAME=day19.example.com
```

Create a CNAME record pointing to the load balancer:

```bash
cat > route53-change.json <<EOF
{
  "Comment": "Day 19 EKS lab DNS record",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${RECORD_NAME}",
        "Type": "CNAME",
        "TTL": 60,
        "ResourceRecords": [
          {"Value": "${LB_DNS}"}
        ]
      }
    }
  ]
}
EOF

aws route53 change-resource-record-sets \
  --hosted-zone-id ${HOSTED_ZONE_ID} \
  --change-batch file://route53-change.json
```

Test:

```bash
curl http://${RECORD_NAME}/read
```

Explanation:

- Route 53 gives the application a readable DNS name.
- The DNS record points to the Kubernetes LoadBalancer DNS name.

---

# Part 7: Keep Data Even if EKS Cluster Is Gone

## Step 14: Record persistent storage IDs

Write final data:

```bash
curl -X POST "http://${LB_DNS}/write?target=efs&message=before-cluster-delete"
curl -X POST "http://${LB_DNS}/write?target=ebs&message=before-cluster-delete"
curl http://${LB_DNS}/read
```

Record Kubernetes PVs:

```bash
kubectl get pv
kubectl describe pv
```

Record EFS ID:

```bash
echo ${EFS_ID}
aws efs describe-file-systems --file-system-id ${EFS_ID}
```

Record EBS volume ID from the PV:

```bash
kubectl get pv -o json | jq -r '.items[] | select(.spec.csi.driver=="ebs.csi.aws.com") | .spec.csi.volumeHandle'
```

Explanation:

- EFS exists outside Kubernetes.
- EBS volume IDs can be found from PersistentVolume details.
- Data survives only if you do not delete the EBS volume or EFS file system.

## Step 15: Delete workload, then cluster

Delete the app:

```bash
kubectl delete -f app-deployment.yaml
```

Optional cluster deletion:

```bash
aws eks delete-nodegroup \
  --cluster-name ${CLUSTER_NAME} \
  --nodegroup-name day19-ng \
  --region ${AWS_REGION}

aws eks wait nodegroup-deleted \
  --cluster-name ${CLUSTER_NAME} \
  --nodegroup-name day19-ng \
  --region ${AWS_REGION}

aws eks delete-cluster \
  --name ${CLUSTER_NAME} \
  --region ${AWS_REGION}
```

Expected result:

- EKS cluster is deleted.
- EFS file system still exists.
- EBS volume can remain because the StorageClass used `Retain`.

## Step 16: Reuse EFS from a new EKS cluster

After creating a new EKS cluster and installing the EFS CSI driver again, reuse the existing EFS file system ID:

```bash
export EFS_ID=fs-xxxxxxxxxxxxxxxxx
```

Create a static PV and PVC:

```bash
cat > existing-efs-pv-pvc.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: day19
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: existing-efs-pv
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: existing-efs-sc
  csi:
    driver: efs.csi.aws.com
    volumeHandle: ${EFS_ID}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: efs-data
  namespace: day19
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: existing-efs-sc
  resources:
    requests:
      storage: 5Gi
EOF

kubectl apply -f existing-efs-pv-pvc.yaml
```

Explanation:

- This lets a new cluster mount the same EFS file system.
- Data can be recovered even after the original EKS cluster is gone.

---

# Cleanup

Delete Kubernetes objects:

```bash
kubectl delete -f app-deployment.yaml --ignore-not-found
kubectl delete -f efs-storage.yaml --ignore-not-found
kubectl delete -f ebs-storage.yaml --ignore-not-found
```

Delete EKS node group and cluster:

```bash
aws eks delete-nodegroup \
  --cluster-name ${CLUSTER_NAME} \
  --nodegroup-name day19-ng \
  --region ${AWS_REGION}

aws eks wait nodegroup-deleted \
  --cluster-name ${CLUSTER_NAME} \
  --nodegroup-name day19-ng \
  --region ${AWS_REGION}

aws eks delete-cluster \
  --name ${CLUSTER_NAME} \
  --region ${AWS_REGION}
```

Delete ECR repository:

```bash
aws ecr delete-repository \
  --repository-name ${ECR_REPO} \
  --force \
  --region ${AWS_REGION}
```

Delete EFS only when data is no longer required:

```bash
aws efs describe-mount-targets \
  --file-system-id ${EFS_ID} \
  --query 'MountTargets[*].MountTargetId' \
  --output text

aws efs delete-mount-target --mount-target-id mt-xxxxxxxxxxxxxxxxx
aws efs delete-mount-target --mount-target-id mt-yyyyyyyyyyyyyyyyy

aws efs delete-file-system --file-system-id ${EFS_ID}
```

Delete IAM roles:

```bash
aws iam detach-role-policy --role-name Day19EksClusterRole --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
aws iam delete-role --role-name Day19EksClusterRole

aws iam detach-role-policy --role-name Day19EksNodeRole --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
aws iam detach-role-policy --role-name Day19EksNodeRole --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
aws iam detach-role-policy --role-name Day19EksNodeRole --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
aws iam delete-role --role-name Day19EksNodeRole

aws iam detach-role-policy --role-name Day19EbsCsiRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy
aws iam delete-role --role-name Day19EbsCsiRole

aws iam detach-role-policy --role-name Day19EfsCsiRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy
aws iam delete-role --role-name Day19EfsCsiRole
```

Delete VPC resources after load balancers and ENIs are gone:

```bash
aws ec2 delete-security-group --group-id ${EFS_SG_ID}
aws ec2 detach-internet-gateway --internet-gateway-id ${IGW_ID} --vpc-id ${VPC_ID}
aws ec2 delete-internet-gateway --internet-gateway-id ${IGW_ID}
aws ec2 delete-subnet --subnet-id ${SUBNET1_ID}
aws ec2 delete-subnet --subnet-id ${SUBNET2_ID}
aws ec2 delete-route-table --route-table-id ${RTB_ID}
aws ec2 delete-vpc --vpc-id ${VPC_ID}
```

---

# Troubleshooting

## Pod is Pending

```bash
kubectl describe pod -n ${NAMESPACE} -l app=${APP_NAME}
kubectl get pvc -n ${NAMESPACE}
kubectl describe pvc ebs-data -n ${NAMESPACE}
kubectl describe pvc efs-data -n ${NAMESPACE}
```

Possible causes:

- CSI driver is not running.
- Pod Identity association is missing.
- EFS mount target is not available.
- Security group does not allow TCP 2049.

## ImagePullBackOff

```bash
kubectl describe pod -n ${NAMESPACE} -l app=${APP_NAME}
aws ecr describe-images --repository-name ${ECR_REPO} --region ${AWS_REGION}
```

Possible causes:

- Image was not pushed.
- Image URI is wrong.
- Node IAM role cannot pull from ECR.

## LoadBalancer DNS is empty

```bash
kubectl describe svc ${APP_NAME}-svc -n ${NAMESPACE}
```

Possible causes:

- Subnet tags are missing.
- AWS load balancer creation is still in progress.
- IAM permissions are insufficient.

---

# Key Learning Points

- EBS is persistent block storage for single-node access.
- EFS is persistent shared file storage for multi-node access.
- PVCs allow applications to request storage without knowing the AWS storage details.
- `Retain` is important when storage must survive Kubernetes object deletion.
- Deleting an EKS cluster does not automatically delete external AWS storage if it is retained.
- Route 53 provides a friendly DNS name for the application endpoint.

---

# References

- Amazon EKS cluster creation: https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html
- Amazon EKS managed node groups: https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html
- Amazon EBS CSI driver for EKS: https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html
- Amazon EFS CSI driver for EKS: https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html
- Push Docker image to Amazon ECR: https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html
