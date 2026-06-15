# Day 21 Lab - GitOps with ArgoCD on Amazon EKS using AWS CodeCommit and Amazon ECR

## Module: Kubernetes with Amazon EKS

## Topics Covered

- GitOps principles
- ArgoCD architecture
- ArgoCD installation on Amazon EKS
- AWS CodeCommit repository setup
- Amazon ECR image repository setup
- Docker image build, tag, and push to ECR
- Kubernetes manifest management through CodeCommit
- ArgoCD application deployment from CodeCommit
- Application sync, drift detection, and self-healing
- IAM, AWS CLI, kubectl, and ArgoCD CLI validation
- Cleanup of AWS and Kubernetes resources

---

## Lab Objectives

By the end of this lab, you will be able to:

- Explain GitOps principles.
- Install ArgoCD on an existing Amazon EKS cluster.
- Create and use an AWS CodeCommit repository for Kubernetes manifests.
- Create and use an Amazon ECR repository for container images.
- Build and push a Docker image to Amazon ECR.
- Store Kubernetes manifests in AWS CodeCommit.
- Deploy an application to EKS using ArgoCD.
- Sync application changes from Git to Kubernetes.
- Test ArgoCD drift detection and self-healing.
- Review IAM identity, EKS cluster role, Kubernetes RBAC, and ArgoCD resources.
- Clean up all lab resources.

---

## AWS Resources Used

- Amazon EKS
- AWS CodeCommit
- Amazon ECR
- IAM
- AWS CLI
- ArgoCD
- ArgoCD CLI
- kubectl
- Docker
- Kubernetes Deployments
- Kubernetes Services
- Kubernetes Namespaces

---

## Lab Environment Variables

Run these commands before starting the lab.

```bash
export AWS_REGION=us-east-1
export AWS_PROFILE=devops
export CLUSTER_NAME=sunil-day21-eks-cluster
export ARGOCD_NAMESPACE=argocd
export APP_NAMESPACE=sunil-day21
export APP_NAME=sunil-day21-nginx
export CODECOMMIT_REPO_NAME=sunil-day21-gitops-app
export ECR_REPO_NAME=sunil-day21-nginx
export IMAGE_TAG=v1
export NODEGROUP_NAME=sunil-day21-managed-ng
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --profile $AWS_PROFILE --query Account --output text)
export ECR_IMAGE_URI=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:$IMAGE_TAG

```

Description:

- `AWS_REGION` is the region where your AWS resources are created.
- `AWS_PROFILE` is the AWS CLI profile used for authentication.
- `CLUSTER_NAME` is the existing EKS cluster name.
- `ARGOCD_NAMESPACE` is the namespace where ArgoCD will be installed.
- `APP_NAMESPACE` is the namespace where the application will run.
- `APP_NAME` is the Kubernetes application name.
- `CODECOMMIT_REPO_NAME` is the AWS CodeCommit repository name.
- `ECR_REPO_NAME` is the Amazon ECR repository name.
- `IMAGE_TAG` is the Docker image version.
- `AWS_ACCOUNT_ID` is automatically detected from AWS STS.
- `ECR_IMAGE_URI` is the full image URI used by Kubernetes.

---

# Part 1: Validate AWS and EKS Access

## Step 1: Verify AWS CLI Identity

```bash
aws sts get-caller-identity \
  --profile $AWS_PROFILE
```

Description:

This confirms that your AWS CLI is configured and using the correct AWS account.

Expected output includes:

```text
Account
Arn
UserId
```

---

## Step 2: Verify the EKS Cluster
```bash
export VPC_ID=$(aws ec2 describe-vpcs \
  --filters Name=isDefault,Values=true \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --query 'Vpcs[0].VpcId' \
  --output text)
```
```bash
echo $VPC_ID
```

```bash
export SUBNET_IDS=$(aws ec2 describe-subnets \
  --filters Name=vpc-id,Values=$VPC_ID \
            Name=availability-zone,Values=us-east-1a,us-east-1b \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --query 'join(`,`, Subnets[*].SubnetId)' \
  --output text)
```
```bash
echo $SUBNET_IDS
```
```bash
eksctl create cluster \
  --name $CLUSTER_NAME \
  --region $AWS_REGION \
  --vpc-public-subnets $SUBNET_IDS \
  --nodes 1 \
  --nodes-min 1 \
  --nodes-max 4 \
  --nodegroup-name $NODEGROUP_NAME \
  --managed \
  --profile $AWS_PROFILE
```


```bash
aws eks describe-cluster \
  --name $CLUSTER_NAME \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --query 'cluster.{Name:name,Status:status,Version:version,Endpoint:endpoint}' \
  --output table
```

Description:

This checks whether the EKS cluster exists and is active.

Expected result:

```text
Status: ACTIVE
```

---

## Step 3: Configure kubectl for EKS

```bash
aws eks update-kubeconfig \
  --region $AWS_REGION \
  --name $CLUSTER_NAME \
  --profile $AWS_PROFILE
```

Description:

This updates your local kubeconfig file so `kubectl` can connect to the EKS cluster.

---

## Step 4: Verify Kubernetes Nodes

```bash
kubectl get nodes
```

Description:

This confirms that EKS worker nodes are registered and ready.

Expected result:

```text
STATUS: Ready
```

---

## Step 5: Verify Current Kubernetes Context

```bash
kubectl config current-context
```

Description:

This shows which Kubernetes cluster `kubectl` is currently connected to.

---

# Part 2: Create Kubernetes Namespaces

## Step 6: Create the ArgoCD Namespace

```bash
kubectl create namespace $ARGOCD_NAMESPACE \
  --dry-run=client \
  -o yaml | kubectl apply -f -
```

Description:

This creates the namespace where ArgoCD components will run. The command is idempotent, so it can be safely re-run.

Verify:

```bash
kubectl get namespace $ARGOCD_NAMESPACE
```

---

## Step 7: Create the Application Namespace

```bash
kubectl create namespace $APP_NAMESPACE \
  --dry-run=client \
  -o yaml | kubectl apply -f -
```

Description:

This creates the namespace where the sample application will be deployed.

Verify:

```bash
kubectl get namespace $APP_NAMESPACE
```

---

# Part 3: Create an Amazon ECR Repository

## Step 8: Create the ECR Repository

```bash
aws ecr create-repository \
  --repository-name $ECR_REPO_NAME \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --image-scanning-configuration scanOnPush=true \
  --encryption-configuration encryptionType=AES256
```

Description:

This creates an Amazon ECR repository to store the Docker image used by the Kubernetes application.

If the repository already exists, you can continue to the next step.

---

## Step 9: Verify the ECR Repository

```bash
aws ecr describe-repositories \
  --repository-names $ECR_REPO_NAME \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --query 'repositories[0].{RepositoryName:repositoryName,RepositoryUri:repositoryUri}' \
  --output table
```

Description:

This confirms that the ECR repository exists and displays its repository URI.

---

## Step 10: Authenticate Docker to Amazon ECR

```bash
aws ecr get-login-password \
  --region $AWS_REGION \
  --profile $AWS_PROFILE | docker login \
  --username AWS \
  --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

Description:

This logs Docker in to Amazon ECR using your AWS CLI credentials.

Expected result:

```text
Login Succeeded
```

---

# Part 4: Build and Push the Application Image to ECR

## Step 11: Create a Local Application Folder

```bash
mkdir -p day21-ecr-app
cd day21-ecr-app
```

Description:

This creates a working folder for the sample application source code.

---

## Step 12: Create a Simple HTML Page

```bash
cat > index.html <<'EOF_HTML'
<!DOCTYPE html>
<html>
<head>
  <title>Day 21 GitOps Demo</title>
</head>
<body>
  <h1>Day 21 GitOps Demo</h1>
  <p>Application deployed to Amazon EKS using ArgoCD, AWS CodeCommit, and Amazon ECR.</p>
</body>
</html>
EOF_HTML
```

Description:

This creates a simple web page served by nginx.

---

## Step 13: Create a Dockerfile

```bash
cat > Dockerfile <<'EOF_DOCKER'
FROM nginx:1.25-alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
EOF_DOCKER
```

Description:

This Dockerfile creates a custom nginx image containing the sample web page.

---

## Step 14: Build the Docker Image

```bash
docker build -t $ECR_REPO_NAME:$IMAGE_TAG .
```

Description:

This builds the local Docker image.

---

## Step 15: Tag the Image for ECR

```bash
docker tag $ECR_REPO_NAME:$IMAGE_TAG $ECR_IMAGE_URI
```

Description:

This tags the local Docker image with the full ECR image URI.

---

## Step 16: Push the Image to ECR

```bash
docker push $ECR_IMAGE_URI
```

Description:

This uploads the Docker image to Amazon ECR.

---

## Step 17: Verify the Image in ECR

```bash
aws ecr describe-images \
  --repository-name $ECR_REPO_NAME \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --query 'imageDetails[*].{Tags:imageTags,ImageDigest:imageDigest,PushedAt:imagePushedAt}' \
  --output table
```

Description:

This verifies that the Docker image was pushed successfully.

Return to the parent folder:

```bash
cd ..
```

---

# Part 5: Create an AWS CodeCommit Repository

## Step 18: Create the CodeCommit Repository

```bash
aws codecommit create-repository \
  --repository-name $CODECOMMIT_REPO_NAME \
  --repository-description " sunil Day 21 GitOps app manifests for ArgoCD on EKS" \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

Description:

This creates a CodeCommit repository that will store Kubernetes manifests used by ArgoCD.

If the repository already exists, continue to the next step.

---

## Step 19: Get the CodeCommit Clone URL

```bash
export CODECOMMIT_CLONE_URL=$(aws codecommit get-repository \
  --repository-name $CODECOMMIT_REPO_NAME \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --query 'repositoryMetadata.cloneUrlHttp' \
  --output text)

echo $CODECOMMIT_CLONE_URL
```

Description:

This retrieves the HTTPS clone URL for the CodeCommit repository.

---

## Step 20: Configure Git to Use AWS CodeCommit Credential Helper

```bash
git config --global credential.helper '!aws codecommit credential-helper $@ --profile '$AWS_PROFILE
git config --global credential.UseHttpPath true
```

Description:

This allows Git to authenticate to CodeCommit using your AWS CLI profile.

---

## Step 21: Clone the CodeCommit Repository

```bash
git clone $CODECOMMIT_CLONE_URL
cd $CODECOMMIT_REPO_NAME
```

Description:

This clones the empty CodeCommit repository to your local machine.

---

# Part 6: Create Kubernetes Manifests for GitOps

## Step 22: Create the Manifest Directory

```bash
mkdir -p manifests
```

Description:

This creates a directory where Kubernetes YAML files will be stored.

---

## Step 23: Create the Kubernetes Deployment Manifest

```bash
cat > manifests/deployment.yaml <<EOF_DEPLOY
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $APP_NAME
  namespace: $APP_NAMESPACE
  labels:
    app: $APP_NAME
spec:
  replicas: 2
  selector:
    matchLabels:
      app: $APP_NAME
  template:
    metadata:
      labels:
        app: $APP_NAME
    spec:
      containers:
      - name: $APP_NAME
        image: $ECR_IMAGE_URI
        imagePullPolicy: Always
        ports:
        - containerPort: 80
EOF_DEPLOY
```

Description:

This creates a Kubernetes Deployment that pulls the application image from Amazon ECR.

---

## Step 24: Create the Kubernetes Service Manifest

```bash
cat > manifests/service.yaml <<EOF_SERVICE
apiVersion: v1
kind: Service
metadata:
  name: $APP_NAME
  namespace: $APP_NAMESPACE
  labels:
    app: $APP_NAME
spec:
  type: ClusterIP
  selector:
    app: $APP_NAME
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
EOF_SERVICE
```

Description:

This creates a Kubernetes ClusterIP service for the nginx application.

---

## Step 25: Review the Manifest Files

```bash
cat manifests/deployment.yaml
cat manifests/service.yaml
```

Description:

This lets you verify the namespace, app name, and ECR image URI before committing to Git.

---

## Step 26: Commit and Push the Manifests to CodeCommit

```bash
git status
git add manifests/
git commit -m "Add Day 21 GitOps manifests using ECR image"
git branch -M main
git push -u origin main
```

Description:

This stores the Kubernetes desired state in CodeCommit. ArgoCD will use this Git repository as the source of truth.

---

## Step 27: Verify the Commit in CodeCommit

```bash
aws codecommit get-branch \
  --repository-name $CODECOMMIT_REPO_NAME \
  --branch-name main \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

Description:

This confirms that the `main` branch exists in CodeCommit.

---

# Part 7: Install ArgoCD on Amazon EKS

## Step 28: Install ArgoCD

```bash
kubectl apply -n $ARGOCD_NAMESPACE \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Description:

This installs ArgoCD into the EKS cluster.

Resources created include:

- Deployments
- StatefulSets
- Services
- ConfigMaps
- Secrets
- ServiceAccounts
- Roles
- RoleBindings
- ClusterRoles
- ClusterRoleBindings
- Custom Resource Definitions

---

## Step 29: Wait for ArgoCD Pods to Become Ready

```bash
kubectl wait --for=condition=Ready pods \
  --all \
  -n $ARGOCD_NAMESPACE \
  --timeout=300s
```

Description:

This waits until all ArgoCD pods are ready.

---

## Step 30: Verify ArgoCD Pods

```bash
kubectl get pods -n $ARGOCD_NAMESPACE
```

Description:

This lists ArgoCD pods and their status.

Expected pods include:

```text
argocd-application-controller
argocd-applicationset-controller
argocd-dex-server
argocd-notifications-controller
argocd-redis
argocd-repo-server
argocd-server
```

Expected status:

```text
Running
```

---

## Step 31: Verify ArgoCD Services

```bash
kubectl get svc -n $ARGOCD_NAMESPACE
```

Description:

This lists services created for ArgoCD.

Important service:

```text
argocd-server
```

---

# Part 8: Access the ArgoCD UI

## Step 32: Port Forward the ArgoCD Server

Run this command in a separate terminal and keep it running.

```bash
kubectl port-forward svc/argocd-server \
  -n $ARGOCD_NAMESPACE \
  8080:443
```

Description:

This forwards your local port `8080` to the ArgoCD server service on port `443`.

Open this URL in your browser:

```text
https://localhost:8080
```

Note:

The browser may show a self-signed certificate warning. Accept the warning for lab use.

---

## Optional Step 33: Expose ArgoCD Using an AWS Load Balancer

```bash
kubectl patch svc argocd-server \
  -n $ARGOCD_NAMESPACE \
  -p '{"spec": {"type": "LoadBalancer"}}'
```

Description:

This exposes ArgoCD using an AWS Load Balancer.

Verify the Load Balancer hostname:

```bash
kubectl get svc argocd-server -n $ARGOCD_NAMESPACE
```

Get only the hostname:

```bash
kubectl get svc argocd-server \
  -n $ARGOCD_NAMESPACE \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
echo
```

Open in browser:

```text
https://<load-balancer-hostname>
```

Important:

For production, use Ingress, TLS certificates, SSO, and restricted network access instead of exposing ArgoCD publicly.

---

# Part 9: Get ArgoCD Admin Password and Install CLI

## Step 34: Retrieve the Initial Admin Password

```bash
export ARGOCD_ADMIN_PASSWORD=$(kubectl -n $ARGOCD_NAMESPACE get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d)

echo $ARGOCD_ADMIN_PASSWORD
```

Description:

This retrieves the initial password for the ArgoCD `admin` user.

Username:

```text
admin
```

---

## Step 35: Install the ArgoCD CLI on Linux

```bash
curl -sSL -o argocd-linux-amd64 \
  https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
```

Description:

This downloads and installs the ArgoCD CLI.

Verify:

```bash
argocd version --client
```

---

## Step 36: Login to ArgoCD CLI Using Port Forward

Make sure the port-forward command from Step 32 is still running.

```bash
argocd login localhost:9090 \
  --username admin \
  --password $ARGOCD_ADMIN_PASSWORD \
  --insecure
```

Description:

This logs the ArgoCD CLI into the local ArgoCD API server.

---

# Part 10: Configure ArgoCD Access to AWS CodeCommit

ArgoCD needs permission to read the CodeCommit repository. For this lab, use an HTTPS username and password generated from IAM Git credentials for CodeCommit.

## Step 37: Create IAM Git Credentials for CodeCommit

Description:

In the AWS Console, open IAM and create HTTPS Git credentials for the IAM user used in this lab.

Record these values:

```text
CODECOMMIT_USERNAME=<IAM Git credential username>
CODECOMMIT_PASSWORD=<IAM Git credential password>
```

Export them locally:

```bash
export CODECOMMIT_USERNAME='<your-codecommit-git-username>'
export CODECOMMIT_PASSWORD='<your-codecommit-git-password>'
```

``` 
aws iam create-service-specific-credential \
  --user-name ac \
  --service-name codecommit.amazonaws.com \
  --profile devops
```

```
export CODECOMMIT_USERNAME="ac-at-386757865964"
export CODECOMMIT_PASSWORD="pLICuZZc8o0SEhz7sN4CAoDOsDLoB96csEEhaCyQX70ZNiYAN7WkziQPWiI="
```
Description:

ArgoCD will use these credentials to clone the CodeCommit repository over HTTPS.

---

## Step 38: Add the CodeCommit Repository to ArgoCD

```bash
argocd repo add $CODECOMMIT_CLONE_URL \
  --username $CODECOMMIT_USERNAME \
  --password $CODECOMMIT_PASSWORD
```

Description:

This registers your AWS CodeCommit repository with ArgoCD.

Verify:

```bash
argocd repo list
```

---

# Part 11: Deploy the Application with ArgoCD CLI

## Step 39: Create the ArgoCD Application

```bash
argocd app create $APP_NAME \
  --repo $CODECOMMIT_CLONE_URL \
  --revision main \
  --path manifests \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace $APP_NAMESPACE
```

Description:

This creates an ArgoCD Application that points to the Kubernetes manifests stored in AWS CodeCommit.

Command options:

- `--repo` points to the CodeCommit Git repository.
- `--revision` points to the Git branch.
- `--path` points to the manifest folder.
- `--dest-server` points to the Kubernetes API server inside the cluster.
- `--dest-namespace` tells ArgoCD where to deploy the app.

---

## Step 40: Sync the ArgoCD Application

```bash
argocd app sync $APP_NAME
```

Description:

This applies the Kubernetes manifests from CodeCommit to the EKS cluster.

---

## Step 41: Check ArgoCD Application Status

```bash
argocd app get $APP_NAME
```

Description:

This shows sync status, health status, repository, target revision, and deployed Kubernetes resources.

Expected result:

```text
Sync Status: Synced
Health Status: Healthy
```

---

# Part 12: Deploy the Application Using ArgoCD YAML

Use this method if you prefer to create the ArgoCD Application as Kubernetes YAML instead of CLI flags.

## Step 42: Create the ArgoCD Application YAML

```bash
cat > day21-argocd-app.yaml <<EOF_ARGOAPP
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: $APP_NAME
  namespace: $ARGOCD_NAMESPACE
spec:
  project: default
  source:
    repoURL: $CODECOMMIT_CLONE_URL
    targetRevision: main
    path: manifests
  destination:
    server: https://kubernetes.default.svc
    namespace: $APP_NAMESPACE
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF_ARGOAPP
```

Description:

This defines an ArgoCD Application custom resource that uses CodeCommit as the Git source.

---

## Step 43: Apply the ArgoCD Application YAML

```bash
kubectl apply -f day21-argocd-app.yaml
```

Description:

This creates or updates the ArgoCD Application in the `argocd` namespace.

Verify:

```bash
kubectl get applications -n $ARGOCD_NAMESPACE
argocd app list
```

Note:

If you already created the application using Step 39, you do not need to apply this YAML again unless you want to manage the ArgoCD Application declaratively.

---

# Part 13: Verify the Application Deployment

## Step 44: Check Application Pods

```bash
kubectl get pods -n $APP_NAMESPACE
```

Description:

This confirms that the application pods are running.

Expected result:

```text
Running
```

---

## Step 45: Check the Application Service

```bash
kubectl get svc -n $APP_NAMESPACE
```

Description:

This confirms that the Kubernetes service was created.

---

## Step 46: Check All Application Resources

```bash
kubectl get all -n $APP_NAMESPACE
```

Description:

This lists all pods, services, deployments, and replica sets in the application namespace.

---

## Step 47: Describe the Deployment

```bash
kubectl describe deployment $APP_NAME -n $APP_NAMESPACE
```

Description:

This confirms the ECR image URI and deployment status.

---

# Part 14: Access the Application

## Step 48: Port Forward the Application Service

```bash
kubectl port-forward svc/$APP_NAME \
  -n $APP_NAMESPACE \
  8081:80
```

Description:

This forwards local port `8081` to the application service on port `80`.

Open in browser:

```text
http://localhost:8081
```

Expected result:

You should see the Day 21 GitOps demo web page.

---

# Part 15: Test GitOps Drift Detection

## Step 49: Manually Scale the Deployment

```bash
kubectl scale deployment $APP_NAME \
  --replicas=1 \
  -n $APP_NAMESPACE
```

Description:

This manually changes the live Kubernetes state outside Git.

---

## Step 50: Check ArgoCD Drift Status

```bash
argocd app get $APP_NAME
```

Description:

This checks whether ArgoCD detects that the live cluster state is different from Git.

Expected result if auto-sync is not enabled:

```text
OutOfSync
```

Note:

If `selfHeal` is enabled, ArgoCD may automatically restore the replica count to the value stored in Git.

---

## Step 51: Restore the Desired State from Git

```bash
argocd app sync $APP_NAME
```

Description:

This manually syncs the application and restores the Kubernetes state from CodeCommit.

Verify:

```bash
kubectl get deployment $APP_NAME -n $APP_NAMESPACE
```

---

# Part 16: Update the Application Through CodeCommit

## Step 52: Update the HTML Page

Move back to the application image folder.

```bash
cd ../day21-ecr-app
```

Update the page:

```bash
cat > index.html <<'EOF_HTML_UPDATE'
<!DOCTYPE html>
<html>
<head>
  <title>Day 21 GitOps Demo v2</title>
</head>
<body>
  <h1>Day 21 GitOps Demo v2</h1>
  <p>This version was built, pushed to ECR, committed to CodeCommit, and synced by ArgoCD.</p>
</body>
</html>
EOF_HTML_UPDATE
```

Description:

This changes the application content so a new image version can be built.

---

## Step 53: Build and Push a New ECR Image Version

```bash
export IMAGE_TAG=v2
export ECR_IMAGE_URI=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:$IMAGE_TAG

docker build -t $ECR_REPO_NAME:$IMAGE_TAG .
docker tag $ECR_REPO_NAME:$IMAGE_TAG $ECR_IMAGE_URI
docker push $ECR_IMAGE_URI
```


Description:

This builds and pushes version `v2` of the application image to Amazon ECR.

---

## Step 54: Update the Kubernetes Manifest in CodeCommit

```bash
cd ../$CODECOMMIT_REPO_NAME
sed -i "s|image: .*|image: $ECR_IMAGE_URI|" manifests/deployment.yaml
```

Description:

This updates the Deployment manifest to use the new ECR image tag.

Review the change:

```bash
git diff
```

---

## Step 55: Commit and Push the Manifest Update

```bash
git add manifests/deployment.yaml
git commit -m "Update Day 21 app image to v2"
git push
```

Description:

This updates the desired state in CodeCommit.

---

## Step 56: Refresh and Sync the ArgoCD Application

```bash
argocd app refresh $APP_NAME
argocd app sync $APP_NAME
```

Description:

This tells ArgoCD to refresh repository state and apply the new image version to EKS.

---

## Step 57: Verify the New Image Version

```bash
kubectl describe deployment $APP_NAME -n $APP_NAMESPACE | grep Image
```

Description:

This confirms that the Deployment is using the new ECR image tag.

---

## Step 58: Access the Updated Application

```bash
kubectl port-forward svc/$APP_NAME \
  -n $APP_NAMESPACE \
  8081:80
```

Open:

```text
http://localhost:8081
```

Description:

This confirms that the updated application is running in EKS.

---

# Part 17: Enable Automated Sync, Prune, and Self-Heal

## Step 59: Enable Auto-Sync

```bash
argocd app set $APP_NAME \
  --sync-policy automated \
  --auto-prune \
  --self-heal
```

Description:

This enables automatic synchronization, automatic pruning, and self-healing.

---

## Step 60: Verify Sync Policy

```bash
argocd app get $APP_NAME
```

Description:

This confirms that the application has automated sync enabled.

Look for:

```text
Sync Policy: Automated
```

---

# Part 18: IAM and Kubernetes RBAC Review

## Step 61: Review AWS Caller Identity

```bash
aws sts get-caller-identity \
  --profile $AWS_PROFILE
```

Description:

This confirms the IAM identity used for AWS operations in this lab.

---

## Step 62: Review EKS Cluster IAM Role

```bash
aws eks describe-cluster \
  --name $CLUSTER_NAME \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --query 'cluster.roleArn' \
  --output text
```

Description:

This shows the IAM role used by the EKS control plane.

---

## Step 63: Review ArgoCD Service Accounts

```bash
kubectl get serviceaccount -n $ARGOCD_NAMESPACE
```

Description:

This lists Kubernetes service accounts used by ArgoCD components.

---

## Step 64: Review ArgoCD Cluster Roles

```bash
kubectl get clusterrole | grep argocd
```

Description:

This shows ArgoCD Kubernetes cluster roles.

---

## Step 65: Review ArgoCD Cluster Role Bindings

```bash
kubectl get clusterrolebinding | grep argocd
```

Description:

This shows which service accounts are bound to ArgoCD cluster roles.

---

# Part 19: Troubleshooting Commands

## ArgoCD Pods Are Not Running

```bash
kubectl get pods -n $ARGOCD_NAMESPACE
kubectl describe pod <pod-name> -n $ARGOCD_NAMESPACE
kubectl logs <pod-name> -n $ARGOCD_NAMESPACE
```

Description:

Use these commands to inspect pod status, events, and logs.

Common causes:

- Image pull issue
- Insufficient node capacity
- Kubernetes API issue
- Network or DNS issue

---

## Cannot Access the ArgoCD UI

```bash
kubectl get svc -n $ARGOCD_NAMESPACE
kubectl describe svc argocd-server -n $ARGOCD_NAMESPACE
kubectl port-forward svc/argocd-server -n $ARGOCD_NAMESPACE 8080:443
```

Description:

Use these commands to verify the ArgoCD server service and port-forwarding.

---

## ArgoCD CLI Login Failed

```bash
echo $ARGOCD_ADMIN_PASSWORD
argocd login localhost:8080 \
  --username admin \
  --password $ARGOCD_ADMIN_PASSWORD \
  --insecure
```

Description:

Use these commands to confirm the password and retry CLI login.

---

## CodeCommit Git Push Failed

```bash
aws sts get-caller-identity --profile $AWS_PROFILE
git config --global credential.helper
git config --global credential.UseHttpPath
aws codecommit get-repository \
  --repository-name $CODECOMMIT_REPO_NAME \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

Description:

Use these commands to verify AWS credentials, Git credential helper settings, and repository existence.

---

## ArgoCD Cannot Read CodeCommit Repository

```bash
argocd repo list
argocd repo get $CODECOMMIT_CLONE_URL
```

Description:

Use these commands to verify that ArgoCD has the correct CodeCommit repository URL and credentials.

Fix by re-adding the repository:

```bash
argocd repo rm $CODECOMMIT_CLONE_URL
argocd repo add $CODECOMMIT_CLONE_URL \
  --username $CODECOMMIT_USERNAME \
  --password $CODECOMMIT_PASSWORD
```

---

## ECR Image Pull Failed

```bash
kubectl describe pod <pod-name> -n $APP_NAMESPACE
aws ecr describe-images \
  --repository-name $ECR_REPO_NAME \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

Description:

Use these commands to verify pod events and confirm that the image exists in ECR.

Common causes:

- Wrong image URI
- Image tag does not exist
- Worker node IAM role lacks ECR pull permissions
- ECR repository is in a different AWS region or account

---

## Application Is OutOfSync

```bash
argocd app get $APP_NAME
argocd app diff $APP_NAME
argocd app sync $APP_NAME
```

Description:

Use these commands to view differences and resync the application.

---

## Application Is Not Healthy

```bash
kubectl get all -n $APP_NAMESPACE
kubectl describe pod <pod-name> -n $APP_NAMESPACE
kubectl logs <pod-name> -n $APP_NAMESPACE
```

Description:

Use these commands to inspect application resources, events, and container logs.

---

# Part 20: Cleanup

## Step 66: Delete the ArgoCD Application

```bash
argocd app delete $APP_NAME --yes
```

Description:

This deletes the ArgoCD Application and the Kubernetes resources it manages.

If the app was created using YAML, you can also run:

```bash
kubectl delete application $APP_NAME -n $ARGOCD_NAMESPACE
```

---

## Step 67: Delete the Application Namespace

```bash
kubectl delete namespace $APP_NAMESPACE
```

Description:

This removes the application namespace and any remaining resources inside it.

---

## Step 68: Delete the ArgoCD Namespace

```bash
kubectl delete namespace $ARGOCD_NAMESPACE
```

Description:

This removes ArgoCD and its Kubernetes resources.

---

## Step 69: Delete the ECR Repository

```bash
aws ecr delete-repository \
  --repository-name $ECR_REPO_NAME \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --force
```

Description:

This deletes the ECR repository and all images inside it.

---

## Step 70: Delete the CodeCommit Repository

```bash
aws codecommit delete-repository \
  --repository-name $CODECOMMIT_REPO_NAME \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

Description:

This deletes the CodeCommit repository created for the lab.

Important:

Only run this command if you no longer need the repository or commit history.

---

## Step 71: Verify Cleanup

```bash
kubectl get namespaces
kubectl get pods -A | grep argocd || true
kubectl get pods -A | grep day21 || true
aws ecr describe-repositories \
  --region $AWS_REGION \
  --profile $AWS_PROFILE | grep $ECR_REPO_NAME || true
aws codecommit list-repositories \
  --region $AWS_REGION \
  --profile $AWS_PROFILE | grep $CODECOMMIT_REPO_NAME || true
```

Description:

This verifies that the Kubernetes, ECR, and CodeCommit resources were removed.

---

# Challenge Exercise

Complete the full GitOps workflow using only AWS-native services:

1. Create an Amazon ECR repository.
2. Build and push a custom Docker image to ECR.
3. Create an AWS CodeCommit repository.
4. Store Kubernetes manifests in CodeCommit.
5. Install ArgoCD on EKS.
6. Connect ArgoCD to CodeCommit.
7. Deploy the application from CodeCommit to EKS.
8. Update the Docker image and Kubernetes manifest.
9. Push the change to CodeCommit.
10. Sync the change using ArgoCD.
11. Manually change the live Kubernetes deployment.
12. Verify ArgoCD detects and corrects drift.
13. Clean up all AWS and Kubernetes resources.

---

# Lab Deliverables

Submit the following evidence:

- AWS CLI identity output.
- EKS cluster status output.
- ECR repository screenshot or CLI output.
- ECR image pushed screenshot or CLI output.
- CodeCommit repository screenshot.
- Git commit history screenshot.
- ArgoCD pods screenshot.
- ArgoCD UI screenshot.
- ArgoCD Application screenshot.
- `argocd app list` output.
- `kubectl get pods -n day21` output.
- Application browser screenshot.
- Drift detection screenshot.
- Cleanup verification screenshot.

---

# Expected Learning Outcomes

After completing this lab, you should be able to:

- Explain GitOps principles.
- Explain ArgoCD architecture.
- Use AWS CodeCommit as a GitOps source repository.
- Use Amazon ECR as a private container image repository.
- Build and push Docker images to ECR.
- Deploy Kubernetes applications to EKS using ArgoCD.
- Sync applications from Git to Kubernetes.
- Detect and correct configuration drift.
- Enable automated sync, prune, and self-healing.
- Review AWS IAM identity and Kubernetes RBAC used by ArgoCD.
- Clean up lab resources safely.
