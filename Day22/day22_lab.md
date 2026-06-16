# Day 22 Lab: Simple Flux CD GitOps on Amazon EKS with CodeCommit, ECR, Secrets, and Flagger

## Trainer Goal

This is a simplified, demonstration-friendly version of the Day 22 lab. It keeps the main learning path short:

1. Create an ECR image.
2. Create a CodeCommit GitOps repository.
3. Install Flux on EKS.
4. Connect Flux to CodeCommit.
5. Deploy an app from Git.
6. Show secret handling with AWS Secrets Manager and Kubernetes Secret.
7. Demonstrate GitOps drift correction.
8. Explain progressive delivery with Flagger.
9. Clean up safely.

> Note: AWS CodeCommit is used here because this lab is AWS-native. If CodeCommit is not available in your AWS account, use GitHub, GitLab, or another Git server and update the Flux `GitRepository` URL and credentials accordingly.

---

## What Participants Will Learn

By the end of this lab, participants can:

- Explain GitOps and Flux CD.
- Store Kubernetes manifests in AWS CodeCommit.
- Build and push a container image to Amazon ECR.
- Install Flux CD on an EKS cluster.
- Deploy an application from Git using Flux.
- Store secrets in AWS Secrets Manager.
- Create a Kubernetes Secret for lab demonstration.
- Verify secure pod settings.
- Demonstrate GitOps drift correction.
- Understand where Flagger fits for progressive delivery.

---

## Lab Assumptions

This lab assumes:

- You already have AWS CLI configured.
- You have permissions for EKS, ECR, CodeCommit, IAM, KMS, and Secrets Manager.
- Docker is available locally or in AWS CloudShell-compatible environment.
- `kubectl`, `git`, `jq`, `helm`, and `flux` are installed or can be installed.
- An EKS cluster already exists, or you are allowed to create one.

---

# 0. Set Environment Variables

Run this once at the beginning.

```bash
export AWS_REGION=us-east-1
export AWS_PROFILE=devops
export CLUSTER_NAME=day-22-sunil-eks-cluster
export NODEGROUP_NAME=sunil-day22-managed-ng

export NAMESPACE=sunil-day22
export FLUX_NAMESPACE=sunil-flux-system

export CODECOMMIT_REPO=sunil-day22-flux-gitops
export CODECOMMIT_BRANCH=main

export ECR_REPO=sunil-day22-secure-nginx
export IMAGE_TAG=v1

export KMS_ALIAS=alias/sunil-day22-devsecops
export SECRET_NAME=sunil-day22/app/config
export FLUX_IAM_USER=flux-codecommit-day22-sunil
```

Get the AWS account ID and build reusable URLs.

```bash
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity \
  --profile $AWS_PROFILE \
  --query Account \
  --output text)

export CODECOMMIT_REPO_URL=https://git-codecommit.${AWS_REGION}.amazonaws.com/v1/repos/${CODECOMMIT_REPO}
export ECR_REPO_URI=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}
```

Verify the values.

```bash
echo "AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID"
echo "CODECOMMIT_REPO_URL=$CODECOMMIT_REPO_URL"
echo "ECR_REPO_URI=$ECR_REPO_URI"
```

## Optional Short Aliases for Training

These aliases are safe and optional. The lab commands below do not depend on them, so everything still works even if aliases are not used.

```bash
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgn='kubectl get nodes'
alias f='flux'
```

Test aliases:

```bash
k version --client
f --version
```

---

# 1. Verify AWS and EKS Access

```bash
aws sts get-caller-identity --profile $AWS_PROFILE
```

Update kubeconfig.

```bash
aws eks update-kubeconfig \
  --region $AWS_REGION \
  --name $CLUSTER_NAME \
  --profile $AWS_PROFILE
```

Verify nodes.

```bash
kubectl get nodes
```

Expected result:

```text
STATUS   ROLES    AGE   VERSION
Ready    <none>   ...   ...
```

If you do not have an EKS cluster yet, create one.

```bash
export VPC_ID=$(aws ec2 describe-vpcs \
  --filters Name=isDefault,Values=true \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --query 'Vpcs[0].VpcId' \
  --output text)

export SUBNET_IDS=$(aws ec2 describe-subnets \
  --filters Name=vpc-id,Values=$VPC_ID \
            Name=availability-zone,Values=us-east-1a,us-east-1b \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --query 'join(`,`, Subnets[*].SubnetId)' \
  --output text)

eksctl create cluster \
  --name $CLUSTER_NAME \
  --region $AWS_REGION \
  --vpc-public-subnets $SUBNET_IDS \
  --nodes 1 \
  --nodes-min 1 \
  --nodes-max 3 \
  --nodegroup-name $NODEGROUP_NAME \
  --managed \
  --profile $AWS_PROFILE
```

---

# 2. Verify Local Tools

```bash
aws --version
git --version
kubectl version --client
docker --version
helm version
jq --version
flux --version
```

If Flux is missing, install it.

```bash
curl -s https://fluxcd.io/install.sh | sudo bash
flux --version
```

Run Flux precheck.

```bash
flux check --pre
```

Expected result:

```text
checks passed
```

---

# 3. Configure Git for AWS CodeCommit

This lets Git authenticate to CodeCommit using the selected AWS CLI profile.

```bash
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true
export AWS_PROFILE=$AWS_PROFILE
```

Optional check:

```bash
git config --global --get credential.helper
git config --global --get credential.UseHttpPath
```

---

# 4. Create CodeCommit Repository

Create the repository. If it already exists, continue.

```bash
aws codecommit create-repository \
  --repository-name $CODECOMMIT_REPO \
  --repository-description "Day 22 Flux GitOps repository for EKS" \
  --region $AWS_REGION \
  --profile $AWS_PROFILE || true
```

Clone the repository.

```bash
cd ~
rm -rf $CODECOMMIT_REPO
git clone $CODECOMMIT_REPO_URL
cd $CODECOMMIT_REPO
```

Create the first commit if the repository is empty.

```bash
echo "# Day 22 Flux GitOps Repository" > README.md
git add README.md
git commit -m "Initial Day22 GitOps repository" || true
git branch -M $CODECOMMIT_BRANCH
git push -u origin $CODECOMMIT_BRANCH || true
```

---

# 5. Create ECR Repository

```bash
aws ecr create-repository \
  --repository-name $ECR_REPO \
  --image-scanning-configuration scanOnPush=true \
  --encryption-configuration encryptionType=AES256 \
  --region $AWS_REGION \
  --profile $AWS_PROFILE || true
```

Authenticate Docker to ECR.

```bash
aws ecr get-login-password \
  --region $AWS_REGION \
  --profile $AWS_PROFILE | docker login \
  --username AWS \
  --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
```

---

# 6. Build and Push a Simple Nginx Image

Create the image folder.

```bash
cd ~
rm -rf day22-secure-nginx-image
mkdir day22-secure-nginx-image
cd day22-secure-nginx-image
```

Create a simple page.

```bash
cat > index.html <<'APPHTML'
<!DOCTYPE html>
<html>
<head>
  <title>Day 22 Secure GitOps App</title>
</head>
<body>
  <h1>Day 22 Secure GitOps App running on Amazon EKS</h1>
  <p>Image is stored in Amazon ECR and deployed by Flux from AWS CodeCommit.</p>
</body>
</html>
APPHTML
```

Create the Dockerfile.

```bash
cat > Dockerfile <<'DOCKERFILE'
FROM nginxinc/nginx-unprivileged:1.25-alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 8080
DOCKERFILE
```

Build, tag, and push.

```bash
docker build -t $ECR_REPO:$IMAGE_TAG .
docker tag $ECR_REPO:$IMAGE_TAG $ECR_REPO_URI:$IMAGE_TAG
docker push $ECR_REPO_URI:$IMAGE_TAG
```

Verify image.

```bash
aws ecr describe-images \
  --repository-name $ECR_REPO \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --query 'imageDetails[*].{Tags:imageTags,PushedAt:imagePushedAt}' \
  --output table
```

---

# 7. Create Kubernetes Namespace

```bash
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
kubectl get namespace $NAMESPACE
```

---

# 8. Install Flux on EKS

```bash
flux install --namespace=$FLUX_NAMESPACE
```

Verify Flux.

```bash
kubectl get pods -n $FLUX_NAMESPACE
flux check
```

Expected result:

```text
Running
checks passed
```

---

# 9. Create GitOps Manifests in CodeCommit

Return to the Git repository.

```bash
cd ~/$CODECOMMIT_REPO
mkdir -p clusters/$CLUSTER_NAME/apps
mkdir -p apps/day22-secure-app
```

Create deployment.

```bash
cat > apps/day22-secure-app/deployment.yaml <<APPDEPLOY
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-nginx
  namespace: ${NAMESPACE}
  labels:
    app: secure-nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: secure-nginx
  template:
    metadata:
      labels:
        app: secure-nginx
    spec:
      securityContext:
        runAsNonRoot: true
        seccompProfile:
          type: RuntimeDefault
      containers:
      - name: nginx
        image: ${ECR_REPO_URI}:${IMAGE_TAG}
        ports:
        - containerPort: 8080
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: false
          capabilities:
            drop:
            - ALL
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 256Mi
APPDEPLOY
```

Create service.

```bash
cat > apps/day22-secure-app/service.yaml <<APPSERVICE
apiVersion: v1
kind: Service
metadata:
  name: secure-nginx
  namespace: ${NAMESPACE}
spec:
  type: ClusterIP
  selector:
    app: secure-nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
APPSERVICE
```

Create app kustomization.

```bash
cat > apps/day22-secure-app/kustomization.yaml <<APPKUSTOMIZE
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
APPKUSTOMIZE
```

Create Flux application kustomization.

```bash
cat > clusters/$CLUSTER_NAME/apps/day22-secure-app.yaml <<FLUXAPP
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: day22-secure-app
  namespace: ${FLUX_NAMESPACE}
spec:
  interval: 1m
  path: ./apps/day22-secure-app
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
  targetNamespace: ${NAMESPACE}
FLUXAPP
```

Create root kustomization.

```bash
cat > clusters/$CLUSTER_NAME/kustomization.yaml <<ROOTKUSTOMIZE
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - apps/day22-secure-app.yaml
ROOTKUSTOMIZE
```

Commit and push.

```bash
git add .
git commit -m "Add Day22 secure app manifests"
git push origin $CODECOMMIT_BRANCH
```

---

# 10. Connect Flux to AWS CodeCommit

For a simple training lab, use a dedicated IAM user with CodeCommit service-specific Git credentials.

> Production note: use least privilege, rotate credentials, and prefer short-lived or centrally managed access where possible.

Create IAM user and attach read-only policy.

```bash
aws iam create-user \
  --user-name $FLUX_IAM_USER \
  --profile $AWS_PROFILE || true

aws iam attach-user-policy \
  --user-name $FLUX_IAM_USER \
  --policy-arn arn:aws:iam::aws:policy/AWSCodeCommitReadOnly \
  --profile $AWS_PROFILE
```

Create CodeCommit HTTPS Git credentials.

```bash
aws iam create-service-specific-credential \
  --user-name $FLUX_IAM_USER \
  --service-name codecommit.amazonaws.com \
  --profile $AWS_PROFILE \
  --output json > ~/flux-codecommit-credentials.json
```

Export credentials.

```bash
export FLUX_GIT_USERNAME=$(jq -r '.ServiceSpecificCredential.ServiceUserName' ~/flux-codecommit-credentials.json)
export FLUX_GIT_PASSWORD=$(jq -r '.ServiceSpecificCredential.ServicePassword' ~/flux-codecommit-credentials.json)
export FLUX_GIT_CREDENTIAL_ID=$(jq -r '.ServiceSpecificCredential.ServiceSpecificCredentialId' ~/flux-codecommit-credentials.json)
```

Create the Flux Git auth secret.

```bash
kubectl create secret generic codecommit-auth \
  --namespace=$FLUX_NAMESPACE \
  --from-literal=username=$FLUX_GIT_USERNAME \
  --from-literal=password=$FLUX_GIT_PASSWORD \
  --dry-run=client -o yaml | kubectl apply -f -
```

Create Flux `GitRepository`.

```bash
cat > ~/flux-gitrepository.yaml <<FLUXGIT
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: flux-system
  namespace: ${FLUX_NAMESPACE}
spec:
  interval: 1m
  url: ${CODECOMMIT_REPO_URL}
  ref:
    branch: ${CODECOMMIT_BRANCH}
  secretRef:
    name: codecommit-auth
FLUXGIT

kubectl apply -f ~/flux-gitrepository.yaml
```

Create Flux root `Kustomization`.

```bash
cat > ~/flux-root-kustomization.yaml <<FLUXROOT
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: flux-system
  namespace: ${FLUX_NAMESPACE}
spec:
  interval: 1m
  path: ./clusters/${CLUSTER_NAME}
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
FLUXROOT

kubectl apply -f ~/flux-root-kustomization.yaml
```

Force reconciliation.

```bash
flux reconcile source git flux-system -n $FLUX_NAMESPACE
flux reconcile kustomization flux-system -n $FLUX_NAMESPACE
flux reconcile kustomization day22-secure-app -n $FLUX_NAMESPACE
```

---

# 11. Verify Application Deployment

Check Flux source and kustomizations.

```bash
flux get sources git -n $FLUX_NAMESPACE
flux get kustomizations -n $FLUX_NAMESPACE
```

Check application.

```bash
kubectl get pods -n $NAMESPACE
kubectl get deployment secure-nginx -n $NAMESPACE
kubectl get svc secure-nginx -n $NAMESPACE
```

Expected result:

```text
secure-nginx pods are Running
```

Test with port-forward.

```bash
kubectl port-forward svc/secure-nginx -n $NAMESPACE 8080:80
```

Open another terminal and run:

```bash
curl http://localhost:8080
```

Expected text:

```text
Day 22 Secure GitOps App running on Amazon EKS
```

---

# 12. Create AWS KMS Key and Secrets Manager Secret

Create KMS key and alias.

```bash
export KMS_KEY_ID=$(aws kms create-key \
  --description "Day22 EKS DevSecOps secrets encryption key" \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --query 'KeyMetadata.KeyId' \
  --output text)

aws kms create-alias \
  --alias-name $KMS_ALIAS \
  --target-key-id $KMS_KEY_ID \
  --region $AWS_REGION \
  --profile $AWS_PROFILE || true
```

Create a Secrets Manager secret.

```bash
aws secretsmanager create-secret \
  --name $SECRET_NAME \
  --description "Day22 sample application secret" \
  --kms-key-id $KMS_ALIAS \
  --secret-string '{"APP_USER":"admin","APP_PASSWORD":"ChangeMe123!"}' \
  --region $AWS_REGION \
  --profile $AWS_PROFILE || true
```

Verify metadata only.

```bash
aws secretsmanager describe-secret \
  --secret-id $SECRET_NAME \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --query '{Name:Name,ARN:ARN,KmsKeyId:KmsKeyId}' \
  --output table
```

---

# 13. Create Kubernetes Secret for Lab Demonstration

> Production note: in real environments, prefer External Secrets Operator or Secrets Store CSI Driver instead of manually copying secrets into Kubernetes.

```bash
export APP_USER=$(aws secretsmanager get-secret-value \
  --secret-id $SECRET_NAME \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --query SecretString \
  --output text | jq -r .APP_USER)

export APP_PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id $SECRET_NAME \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --query SecretString \
  --output text | jq -r .APP_PASSWORD)

kubectl create secret generic app-secret \
  --from-literal=APP_USER=$APP_USER \
  --from-literal=APP_PASSWORD=$APP_PASSWORD \
  -n $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -
```

Verify secret exists without printing values.

```bash
kubectl get secret app-secret -n $NAMESPACE
```

---

# 14. Update Deployment to Use the Kubernetes Secret

Update the Git manifest.

```bash
cd ~/$CODECOMMIT_REPO

cat > apps/day22-secure-app/deployment.yaml <<APPDEPLOY2
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-nginx
  namespace: ${NAMESPACE}
  labels:
    app: secure-nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: secure-nginx
  template:
    metadata:
      labels:
        app: secure-nginx
    spec:
      securityContext:
        runAsNonRoot: true
        seccompProfile:
          type: RuntimeDefault
      containers:
      - name: nginx
        image: ${ECR_REPO_URI}:${IMAGE_TAG}
        ports:
        - containerPort: 8080
        env:
        - name: APP_USER
          valueFrom:
            secretKeyRef:
              name: app-secret
              key: APP_USER
        - name: APP_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secret
              key: APP_PASSWORD
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: false
          capabilities:
            drop:
            - ALL
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 256Mi
APPDEPLOY2
```

Commit and push.

```bash
git add apps/day22-secure-app/deployment.yaml
git commit -m "Use Kubernetes secret in Day22 app"
git push origin $CODECOMMIT_BRANCH
```

Reconcile and verify rollout.

```bash
flux reconcile source git flux-system -n $FLUX_NAMESPACE
flux reconcile kustomization day22-secure-app -n $FLUX_NAMESPACE
kubectl rollout status deployment/secure-nginx -n $NAMESPACE
```

Verify only the environment variable names.

```bash
export POD_NAME=$(kubectl get pods -n $NAMESPACE \
  -l app=secure-nginx \
  -o jsonpath='{.items[0].metadata.name}')

kubectl exec -n $NAMESPACE $POD_NAME -- printenv | grep '^APP_' | cut -d= -f1
```

Expected:

```text
APP_USER
APP_PASSWORD
```

---

# 15. Demonstrate GitOps Drift Correction

Manually change the live cluster to 1 replica.

```bash
kubectl scale deployment secure-nginx --replicas=1 -n $NAMESPACE
kubectl get deployment secure-nginx -n $NAMESPACE
```

Force Flux to reconcile from Git.

```bash
flux reconcile kustomization day22-secure-app -n $FLUX_NAMESPACE
```

Verify the replica count returns to 2.

```bash
kubectl get deployment secure-nginx \
  -n $NAMESPACE \
  -o jsonpath='{.spec.replicas}'
echo
```

Expected:

```text
2
```

Training explanation:

- Git says replicas should be `2`.
- A user manually changed the cluster to `1`.
- Flux detected drift and restored the desired state from Git.

---

# 16. Progressive Delivery Demo with Flagger

For a simple classroom demo, explain that Flux applies the manifests and Flagger can manage progressive delivery behavior such as canary rollout and rollback.

Install Flagger.

```bash
helm repo add flagger https://flagger.app
helm repo update

helm upgrade -i flagger flagger/flagger \
  --namespace flagger-system \
  --create-namespace \
  --set meshProvider=kubernetes
```

Verify Flagger.

```bash
kubectl get pods -n flagger-system
```

Create a simple Canary resource in Git.

```bash
cd ~/$CODECOMMIT_REPO

cat > apps/day22-secure-app/canary.yaml <<CANARY
apiVersion: flagger.app/v1beta1
kind: Canary
metadata:
  name: secure-nginx
  namespace: ${NAMESPACE}
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: secure-nginx
  progressDeadlineSeconds: 60
  service:
    port: 80
    targetPort: 8080
  analysis:
    interval: 1m
    threshold: 3
    iterations: 3
CANARY

cat > apps/day22-secure-app/kustomization.yaml <<APPKUSTOMIZE2
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
  - canary.yaml
APPKUSTOMIZE2

git add apps/day22-secure-app/canary.yaml apps/day22-secure-app/kustomization.yaml
git commit -m "Add Flagger canary example"
git push origin $CODECOMMIT_BRANCH
```

Reconcile and verify.

```bash
flux reconcile source git flux-system -n $FLUX_NAMESPACE
flux reconcile kustomization day22-secure-app -n $FLUX_NAMESPACE
kubectl get canary -n $NAMESPACE
kubectl describe canary secure-nginx -n $NAMESPACE
```

Trainer note:

- This shows the progressive delivery resource.
- Full traffic shifting requires a supported ingress, gateway, or service mesh configuration.

---

# 17. DevSecOps Validation Checklist

Check that secrets are not committed to Git.

```bash
cd ~/$CODECOMMIT_REPO
git grep -i "ChangeMe123" || true
git grep -i "APP_PASSWORD=.*" || true
```

Expected:

```text
No output
```

Check Kubernetes secret exists.

```bash
kubectl get secret app-secret -n $NAMESPACE
```

Check secure pod settings.

```bash
kubectl get deployment secure-nginx -n $NAMESPACE -o yaml | grep -A30 securityContext
```

Check ECR image scan summary.

```bash
aws ecr describe-image-scan-findings \
  --repository-name $ECR_REPO \
  --image-id imageTag=$IMAGE_TAG \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --query 'imageScanFindings.findingSeverityCounts' \
  --output table || true
```

Check Flux health.

```bash
flux get sources git -n $FLUX_NAMESPACE
flux get kustomizations -n $FLUX_NAMESPACE
```

---

# 18. Common Troubleshooting

## Flux Cannot Pull CodeCommit

```bash
flux get sources git -n $FLUX_NAMESPACE
kubectl describe gitrepository flux-system -n $FLUX_NAMESPACE
kubectl get secret codecommit-auth -n $FLUX_NAMESPACE
```

Check:

- Repository URL is correct.
- Branch name is correct.
- IAM user has CodeCommit read-only access.
- Service-specific credentials were created successfully.
- Secret name is `codecommit-auth`.

## Kustomization Fails

```bash
flux get kustomizations -n $FLUX_NAMESPACE
kubectl describe kustomization day22-secure-app -n $FLUX_NAMESPACE
```

Check:

- YAML indentation.
- Git path exists.
- Namespace exists.
- Flagger CRD exists before applying `canary.yaml`.

## Pod Has ImagePullBackOff

```bash
kubectl describe pod -n $NAMESPACE <pod-name>
aws ecr describe-images --repository-name $ECR_REPO --region $AWS_REGION --profile $AWS_PROFILE
```

Check:

- Image URI is correct.
- Image tag exists.
- EKS node role can pull from ECR.

## Secret Not Found

```bash
kubectl get secret app-secret -n $NAMESPACE
```

Recreate it from Secrets Manager using section 13.

---

# 19. Cleanup

Delete Flagger.

```bash
helm uninstall flagger -n flagger-system || true
kubectl delete namespace flagger-system --ignore-not-found=true
```

Delete app namespace.

```bash
kubectl delete namespace $NAMESPACE --ignore-not-found=true
```

Uninstall Flux.

```bash
flux uninstall --namespace=$FLUX_NAMESPACE --silent || true
```

Delete Secrets Manager secret.

```bash
aws secretsmanager delete-secret \
  --secret-id $SECRET_NAME \
  --force-delete-without-recovery \
  --region $AWS_REGION \
  --profile $AWS_PROFILE || true
```

Delete KMS alias and schedule key deletion.

```bash
aws kms delete-alias \
  --alias-name $KMS_ALIAS \
  --region $AWS_REGION \
  --profile $AWS_PROFILE || true

aws kms schedule-key-deletion \
  --key-id $KMS_KEY_ID \
  --pending-window-in-days 7 \
  --region $AWS_REGION \
  --profile $AWS_PROFILE || true
```

Delete ECR repository.

```bash
aws ecr delete-repository \
  --repository-name $ECR_REPO \
  --force \
  --region $AWS_REGION \
  --profile $AWS_PROFILE || true
```

Delete CodeCommit repository.

```bash
aws codecommit delete-repository \
  --repository-name $CODECOMMIT_REPO \
  --region $AWS_REGION \
  --profile $AWS_PROFILE || true
```

Delete Flux IAM credentials and user.

If `FLUX_GIT_CREDENTIAL_ID` is still available:

```bash
aws iam delete-service-specific-credential \
  --user-name $FLUX_IAM_USER \
  --service-specific-credential-id $FLUX_GIT_CREDENTIAL_ID \
  --profile $AWS_PROFILE || true
```

If the variable is not available, list credentials first:

```bash
aws iam list-service-specific-credentials \
  --user-name $FLUX_IAM_USER \
  --service-name codecommit.amazonaws.com \
  --profile $AWS_PROFILE
```

Then delete the listed credential ID.

Detach policy and delete user.

```bash
aws iam detach-user-policy \
  --user-name $FLUX_IAM_USER \
  --policy-arn arn:aws:iam::aws:policy/AWSCodeCommitReadOnly \
  --profile $AWS_PROFILE || true

aws iam delete-user \
  --user-name $FLUX_IAM_USER \
  --profile $AWS_PROFILE || true
```

Final verification.

```bash
kubectl get namespaces | grep -E 'day22|flux-system|flagger-system' || true
aws ecr describe-repositories --repository-names $ECR_REPO --region $AWS_REGION --profile $AWS_PROFILE || true
aws codecommit get-repository --repository-name $CODECOMMIT_REPO --region $AWS_REGION --profile $AWS_PROFILE || true
```

---

# Trainer Demo Script

Use this 5-minute explanation flow:

1. **Show GitOps idea**: Git is the desired state.
2. **Show ECR image**: App image is built and pushed to AWS.
3. **Show CodeCommit repo**: Kubernetes manifests are stored in Git.
4. **Show Flux**: Flux watches Git and applies manifests.
5. **Show app running**: `kubectl get pods -n day22`.
6. **Show drift demo**: scale to 1, reconcile, and watch it return to 2.
7. **Show security**: secret is in Secrets Manager, not Git.
8. **Show progressive delivery idea**: Flagger Canary resource is applied by Flux.

---

# Lab Deliverables

Participants should capture:

- AWS identity output.
- Flux version and `flux check` output.
- CodeCommit repository.
- ECR repository and pushed image.
- Flux pods in `flux-system`.
- Git repository structure.
- Flux `GitRepository` and `Kustomization` status.
- Application pods and service.
- KMS key and Secrets Manager metadata.
- Kubernetes Secret existence.
- Secure deployment YAML.
- Drift correction result.
- Flagger Canary resource.
- Cleanup verification.
