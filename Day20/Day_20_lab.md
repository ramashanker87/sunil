# Day 20 Lab: Helm Charts and Scaling Strategies on Amazon EKS

## Training topics

- Helm charts
- Scaling strategies
- Helm deployments
- Autoscaling labs
- AWS resources: Helm, Amazon EKS, Auto Scaling

## Lab goal

In this lab, you will deploy a simple web application to Amazon EKS using a custom Helm chart, upgrade the release using Helm values, configure pod autoscaling with Kubernetes Horizontal Pod Autoscaler, and observe node scaling with AWS Auto Scaling through an EKS managed node group.

By the end of this lab, you will understand:

- How Helm packages Kubernetes manifests into reusable charts.
- How to install, upgrade, roll back, and uninstall Helm releases.
- How Horizontal Pod Autoscaler scales pods based on CPU usage.
- How EKS worker nodes are backed by AWS Auto Scaling groups.
- How Cluster Autoscaler can add or remove nodes when pods cannot be scheduled.

## Reference notes

- Helm installs charts as releases into Kubernetes namespaces.
- Amazon EKS supports Kubernetes autoscaling patterns such as Horizontal Pod Autoscaler for pods and Cluster Autoscaler or Karpenter for cluster compute.
- Metrics Server is required for CPU and memory based HPA metrics in EKS.
- EKS managed node groups use EC2 Auto Scaling groups behind the scenes.

## Prerequisites

You need the following installed and configured on your workstation or AWS CloudShell:

```bash
aws --version
kubectl version --client
helm version
eksctl version
```

You also need:

- An AWS account with permission to create EKS, IAM, EC2, CloudFormation, and Auto Scaling resources.
- AWS CLI configured with valid credentials.
- A default AWS Region selected.

Set environment variables used throughout the lab:

```bash
export AWS_REGION=eu-north-1
export CLUSTER_NAME=day20-eks-helm-scaling
export NODEGROUP_NAME=day20-managed-ng
export APP_NAME=day20-web
export NAMESPACE=day20
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
```

Check your AWS identity:

```bash
aws sts get-caller-identity
```

Explanation:

This confirms that the AWS CLI is authenticated and shows which AWS account will be charged for resources created in this lab.

---

## Part 1: Create an Amazon EKS cluster

Create an EKS cluster with one managed node group.

```bash
export AWS_REGION=us-east-1
export CLUSTER_NAME=sunil
eksctl create cluster \
  --name $CLUSTER_NAME \
  --region $AWS_REGION \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 4 \
  --nodegroup-name $NODEGROUP_NAME \
  --managed
```

Explanation:

This command creates:

- An EKS control plane.
- A managed node group.
- EC2 worker nodes.
- An Auto Scaling group behind the managed node group.
- IAM roles and networking resources required by EKS.

Verify cluster access:

```bash
aws eks update-kubeconfig \
  --region $AWS_REGION \
  --name $CLUSTER_NAME

kubectl get nodes
```

Expected result:

You should see two worker nodes in `Ready` state.

---

## Part 2: Create a namespace

```bash
kubectl create namespace $NAMESPACE
kubectl get namespace $NAMESPACE
```

Explanation:

A namespace keeps all Day 20 resources grouped separately from other workloads in the cluster.

---

## Part 3: Create a simple application

Create a working directory:

```bash
mkdir -p day20-lab/app
cd day20-lab
```

Create a simple Python Flask application:

```bash
cat > app/app.py <<'EOF'
from flask import Flask
import socket
import os

app = Flask(__name__)

@app.route("/")
def home():
    pod_name = socket.gethostname()
    version = os.getenv("APP_VERSION", "v1")
    return f"Hello from Day 20 Helm lab! Version={version}, Pod={pod_name}\n"

@app.route("/cpu")
def cpu():
    total = 0
    for i in range(5000000):
        total += i * i
    return f"CPU load generated: {total}\n"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
EOF
```

Create a Python requirements file:

```bash
cat > app/requirements.txt <<'EOF'
flask==3.0.3
EOF
```

Create a Dockerfile:

```bash
cat > app/Dockerfile <<'EOF'
FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .
EXPOSE 8080

CMD ["python", "app.py"]
EOF
```

Explanation:

This application exposes:

- `/` for a normal web response.
- `/cpu` to generate CPU load for autoscaling tests.

---

## Part 4: Build and push the container image to Amazon ECR

Create an ECR repository:

```bash
aws ecr create-repository \
  --repository-name $APP_NAME \
  --region $AWS_REGION
```

If the repository already exists, continue with the next command.

Authenticate Docker to ECR:

```bash
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin \
  $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

Build and push the image:

```bash
docker build -t $APP_NAME:v1 ./app

docker tag $APP_NAME:v1 \
  $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$APP_NAME:v1

docker push $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$APP_NAME:v1
```

Store the image URI:

```bash
export IMAGE_URI=$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$APP_NAME:v1
echo $IMAGE_URI
```

Explanation:

EKS worker nodes can pull application images from Amazon ECR when the node IAM role has the required ECR read permissions. Managed EKS node groups created by `eksctl` usually include these permissions.

---

## Part 5: Create a custom Helm chart

Create a Helm chart:

```bash
helm create $APP_NAME
```

Remove the default templates that are not needed:

```bash
rm -f $APP_NAME/templates/ingress.yaml
rm -f $APP_NAME/templates/hpa.yaml
rm -f $APP_NAME/templates/serviceaccount.yaml
rm -f $APP_NAME/templates/tests/test-connection.yaml
```

Replace `values.yaml`:

```bash
cat > $APP_NAME/values.yaml <<EOF
replicaCount: 2

image:
  repository: $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$APP_NAME
  tag: v1
  pullPolicy: IfNotPresent

service:
  type: LoadBalancer
  port: 80
  targetPort: 8080

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 300m
    memory: 256Mi

env:
  APP_VERSION: v1

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 50
EOF
```

Replace the Deployment template:

```bash
cat > $APP_NAME/templates/deployment.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "day20-web.fullname" . }}
  labels:
    {{- include "day20-web.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "day20-web.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "day20-web.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .Values.service.targetPort }}
              protocol: TCP
          env:
            - name: APP_VERSION
              value: {{ .Values.env.APP_VERSION | quote }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
EOF
```

Replace the Service template:

```bash
cat > $APP_NAME/templates/service.yaml <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: {{ include "day20-web.fullname" . }}
  labels:
    {{- include "day20-web.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
      protocol: TCP
      name: http
  selector:
    {{- include "day20-web.selectorLabels" . | nindent 4 }}
EOF
```

Create the HPA template:

```bash
cat > $APP_NAME/templates/hpa.yaml <<'EOF'
{{- if .Values.autoscaling.enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "day20-web.fullname" . }}
  labels:
    {{- include "day20-web.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "day20-web.fullname" . }}
  minReplicas: {{ .Values.autoscaling.minReplicas }}
  maxReplicas: {{ .Values.autoscaling.maxReplicas }}
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ .Values.autoscaling.targetCPUUtilizationPercentage }}
{{- end }}
EOF
```

Explanation:

The chart now contains three important Kubernetes resources:

- Deployment: runs the Flask pods.
- Service: exposes the pods through an AWS Load Balancer.
- HorizontalPodAutoscaler: scales pod replicas based on CPU usage.

---

## Part 6: Validate the Helm chart

Check the chart syntax:

```bash
helm lint ./$APP_NAME
```

Render the Kubernetes YAML locally:

```bash
helm template $APP_NAME ./$APP_NAME \
  --namespace $NAMESPACE
```

Explanation:

`helm lint` checks chart structure and common problems. `helm template` renders the final Kubernetes manifests without deploying them.

---

## Part 7: Install the application using Helm

```bash
helm install $APP_NAME ./$APP_NAME \
  --namespace $NAMESPACE
```

Check the release:

```bash
helm list --namespace $NAMESPACE
helm status $APP_NAME --namespace $NAMESPACE
```

Check Kubernetes resources:

```bash
kubectl get deployment,service,pods,hpa -n $NAMESPACE
```

Wait for the load balancer hostname:

```bash
kubectl get service -n $NAMESPACE -w
```

In another terminal, store the external load balancer address:

```bash
export LB_HOST=$(kubectl get svc $APP_NAME -n $NAMESPACE \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo $LB_HOST
```

Test the app:

```bash
curl http://$LB_HOST/
```

Explanation:

Helm installed the application as a release. The service type `LoadBalancer` causes AWS to provision an external load balancer for the app.

---

## Part 8: Upgrade the Helm release

Update the application version value without rebuilding the image:

```bash
helm upgrade $APP_NAME ./$APP_NAME \
  --namespace $NAMESPACE \
  --set env.APP_VERSION=v2 \
  --set replicaCount=3
```

Check rollout status:

```bash
kubectl rollout status deployment/$APP_NAME -n $NAMESPACE
kubectl get pods -n $NAMESPACE
curl http://$LB_HOST/
```

View Helm release history:

```bash
helm history $APP_NAME --namespace $NAMESPACE
```

Explanation:

`helm upgrade` changes the release by applying new rendered manifests. Here, the app version environment variable changes to `v2`, and the desired replica count changes to three.

---

## Part 9: Roll back the Helm release

Roll back to revision 1:

```bash
helm rollback $APP_NAME 1 --namespace $NAMESPACE
```

Verify rollback:

```bash
helm history $APP_NAME --namespace $NAMESPACE
kubectl get deployment $APP_NAME -n $NAMESPACE
curl http://$LB_HOST/
```

Explanation:

Helm stores release revisions. Rollback is useful when a deployment causes application errors and you need to return to a previous known-good release.

---

## Part 10: Install Metrics Server

Install Metrics Server:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

Wait for it to become available:

```bash
kubectl rollout status deployment/metrics-server -n kube-system
```

Check node and pod metrics:

```bash
kubectl top nodes
kubectl top pods -n $NAMESPACE
```

Explanation:

Horizontal Pod Autoscaler needs resource metrics. Metrics Server collects CPU and memory metrics from kubelets and exposes them through the Kubernetes Metrics API.

---

## Part 11: Test Horizontal Pod Autoscaling

Check the current HPA:

```bash
kubectl get hpa -n $NAMESPACE
```

Generate load:

```bash
kubectl run load-generator \
  --rm -i --tty \
  --image=busybox:1.36 \
  --restart=Never \
  --namespace $NAMESPACE \
  -- /bin/sh
```

Inside the BusyBox shell, run:

```bash
while true; do wget -q -O- http://$APP_NAME.$NAMESPACE.svc.cluster.local/cpu; done
```

Open another terminal and watch the HPA:

```bash
kubectl get hpa -n $NAMESPACE -w
```

Watch the pods:

```bash
kubectl get pods -n $NAMESPACE -w
```

Stop the load generator with `Ctrl+C`.

Explanation:

The `/cpu` endpoint creates CPU pressure. When average CPU usage exceeds the configured target, HPA increases the number of pod replicas up to `maxReplicas`.

---

## Part 12: Manual scaling strategies

Scale the deployment manually with kubectl:

```bash
kubectl scale deployment $APP_NAME \
  --replicas=5 \
  -n $NAMESPACE

kubectl get pods -n $NAMESPACE
```

Scale using Helm values:

```bash
helm upgrade $APP_NAME ./$APP_NAME \
  --namespace $NAMESPACE \
  --set replicaCount=4
```

Explanation:

There are two common scaling approaches:

- Manual scaling: useful for quick tests or emergency changes.
- Declarative scaling through Helm: preferred for repeatable deployments because the desired state is stored in chart values.

Important note:

When HPA is enabled, it controls the replica count. Manual replica changes may be overwritten by HPA decisions.

---

## Part 13: Understand AWS Auto Scaling behind EKS nodes

Find the Auto Scaling group created for the EKS managed node group:

```bash
aws eks describe-nodegroup \
  --cluster-name $CLUSTER_NAME \
  --nodegroup-name $NODEGROUP_NAME \
  --region $AWS_REGION \
  --query 'nodegroup.resources.autoScalingGroups[*].name' \
  --output text
```

Save it:

```bash
export ASG_NAME=$(aws eks describe-nodegroup \
  --cluster-name $CLUSTER_NAME \
  --nodegroup-name $NODEGROUP_NAME \
  --region $AWS_REGION \
  --query 'nodegroup.resources.autoScalingGroups[0].name' \
  --output text)

echo $ASG_NAME
```

Describe the ASG:

```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names $ASG_NAME \
  --region $AWS_REGION \
  --query 'AutoScalingGroups[0].{Min:MinSize,Desired:DesiredCapacity,Max:MaxSize,Instances:Instances[*].InstanceId}'
```

Explanation:

EKS schedules pods onto Kubernetes nodes. Those nodes are EC2 instances. In a managed node group, EC2 instances are managed by an AWS Auto Scaling group.

---

## Part 14: Install Cluster Autoscaler with Helm

Cluster Autoscaler adds nodes when pods are unschedulable and removes nodes when they are underutilized.

Add the Helm repo:

```bash
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm repo update
```

Create an IAM policy file for Cluster Autoscaler:

```bash
cat > cluster-autoscaler-policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeScalingActivities",
        "autoscaling:DescribeTags",
        "ec2:DescribeImages",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplateVersions",
        "ec2:GetInstanceTypesFromInstanceRequirements",
        "eks:DescribeNodegroup"
      ],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup"
      ],
      "Resource": ["*"],
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/k8s.io/cluster-autoscaler/enabled": "true",
          "aws:ResourceTag/k8s.io/cluster-autoscaler/day20-eks-helm-scaling": "owned"
        }
      }
    }
  ]
}
EOF
```

Create the IAM policy:

```bash
aws iam create-policy \
  --policy-name Day20ClusterAutoscalerPolicy \
  --policy-document file://cluster-autoscaler-policy.json
```

Create an IAM service account for Cluster Autoscaler:

```bash
eksctl create iamserviceaccount \
  --cluster $CLUSTER_NAME \
  --namespace kube-system \
  --name cluster-autoscaler \
  --attach-policy-arn arn:aws:iam::$ACCOUNT_ID:policy/Day20ClusterAutoscalerPolicy \
  --approve \
  --region $AWS_REGION
```

Install Cluster Autoscaler using Helm:

```bash
helm upgrade --install cluster-autoscaler autoscaler/cluster-autoscaler \
  --namespace kube-system \
  --set autoDiscovery.clusterName=$CLUSTER_NAME \
  --set awsRegion=$AWS_REGION \
  --set rbac.serviceAccount.create=false \
  --set rbac.serviceAccount.name=cluster-autoscaler
```

Check the Cluster Autoscaler pod:

```bash
kubectl get pods -n kube-system | grep cluster-autoscaler
kubectl logs -n kube-system deployment/cluster-autoscaler --tail=50
```

Explanation:

Cluster Autoscaler needs IAM permissions to inspect and modify the EC2 Auto Scaling group. The Helm chart installs Cluster Autoscaler into the cluster, and the IAM service account gives it AWS permissions through IAM Roles for Service Accounts.

---

## Part 15: Test node autoscaling

Create a workload that needs more CPU than the current nodes can provide:

```bash
cat > scale-test.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scale-test
  namespace: day20
spec:
  replicas: 10
  selector:
    matchLabels:
      app: scale-test
  template:
    metadata:
      labels:
        app: scale-test
    spec:
      containers:
        - name: pause
          image: registry.k8s.io/pause:3.9
          resources:
            requests:
              cpu: "700m"
              memory: "128Mi"
EOF

kubectl apply -f scale-test.yaml
```

Watch pods:

```bash
kubectl get pods -n $NAMESPACE -w
```

In another terminal, watch nodes:

```bash
kubectl get nodes -w
```

Check Auto Scaling group desired capacity:

```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names $ASG_NAME \
  --region $AWS_REGION \
  --query 'AutoScalingGroups[0].{Min:MinSize,Desired:DesiredCapacity,Max:MaxSize}'
```

Explanation:

If pods remain pending because there is not enough node capacity, Cluster Autoscaler should increase the desired capacity of the node group's Auto Scaling group, up to the configured maximum size.

---

## Part 16: Scale down test

Delete the scale test deployment:

```bash
kubectl delete deployment scale-test -n $NAMESPACE
```

Watch pods and nodes:

```bash
kubectl get pods -n $NAMESPACE
kubectl get nodes
```

Check Cluster Autoscaler logs:

```bash
kubectl logs -n kube-system deployment/cluster-autoscaler --tail=100
```

Explanation:

After the extra workload is removed, Cluster Autoscaler can later reduce unused nodes. Scale-down may not happen immediately because Cluster Autoscaler waits to confirm that nodes are safely removable.

---

## Part 17: Useful Helm commands

List releases:

```bash
helm list --all-namespaces
```

Show release values:

```bash
helm get values $APP_NAME -n $NAMESPACE
```

Show rendered manifests from a release:

```bash
helm get manifest $APP_NAME -n $NAMESPACE
```

Show release history:

```bash
helm history $APP_NAME -n $NAMESPACE
```

Uninstall a release:

```bash
helm uninstall $APP_NAME -n $NAMESPACE
```

Explanation:

These commands are commonly used when troubleshooting Helm deployments.

---

## Part 18: Cleanup

Delete the app release:

```bash
helm uninstall $APP_NAME -n $NAMESPACE
```

Delete Cluster Autoscaler:

```bash
helm uninstall cluster-autoscaler -n kube-system
```

Delete the namespace:

```bash
kubectl delete namespace $NAMESPACE
```

Delete the ECR repository:

```bash
aws ecr delete-repository \
  --repository-name $APP_NAME \
  --region $AWS_REGION \
  --force
```

Delete the EKS cluster:

```bash
eksctl delete cluster \
  --name $CLUSTER_NAME \
  --region $AWS_REGION
```

Optional: delete the IAM policy if it is no longer attached:

```bash
aws iam delete-policy \
  --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/Day20ClusterAutoscalerPolicy
```

Explanation:

EKS clusters, load balancers, EC2 nodes, and ECR repositories can create AWS charges. Always clean up lab resources when finished.

---

## Troubleshooting

### Helm install fails with chart template error

Run:

```bash
helm lint ./$APP_NAME
helm template $APP_NAME ./$APP_NAME --namespace $NAMESPACE
```

Check the rendered YAML and fix indentation or missing values.

### Pods cannot pull image

Run:

```bash
kubectl describe pod -n $NAMESPACE
```

Check for `ImagePullBackOff`. Confirm the ECR image URI is correct and the node IAM role can pull from ECR.

### HPA shows unknown metrics

Run:

```bash
kubectl get deployment metrics-server -n kube-system
kubectl top pods -n $NAMESPACE
```

If `kubectl top` does not work, Metrics Server is not ready or cannot collect metrics.

### Cluster Autoscaler does not add nodes

Check:

```bash
kubectl get pods -n $NAMESPACE
kubectl describe pod <pending-pod-name> -n $NAMESPACE
kubectl logs -n kube-system deployment/cluster-autoscaler --tail=100
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $ASG_NAME --region $AWS_REGION
```

Common causes:

- Node group maximum size is too low.
- Pods are pending for reasons other than compute shortage.
- Cluster Autoscaler IAM permissions are missing.
- Auto Scaling group tags are incorrect.

---

## Review questions

1. What problem does Helm solve in Kubernetes deployments?
2. What is the difference between `helm install` and `helm upgrade`?
3. Why does HPA require Metrics Server?
4. What is the difference between pod autoscaling and node autoscaling?
5. Why does EKS managed node group use an Auto Scaling group?
6. What happens when HPA creates more pods than the current nodes can schedule?
7. Why should production Helm values be stored in version control?

## Summary

In this lab, you created an EKS cluster, built and pushed a Python container image to ECR, packaged the app as a Helm chart, deployed it to EKS, upgraded and rolled back the release, configured HPA, and tested node scaling through AWS Auto Scaling and Cluster Autoscaler.
