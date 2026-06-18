# Assignment: Deploy a Python App with Docker, ECR, GitOps, and ArgoCD

**Duration:** 1 Hour  
**Level:** Basic

## Goal
Build a small Python Docker image, push it to Amazon ECR, store Kubernetes manifests in Git, and deploy through ArgoCD.

---

# Scenario

You are given an existing EKS cluster and ArgoCD installation. Your task is to deploy a simple Python web application using GitOps.

---

# Part 1: Create a Python Web App

Create a folder named:

```text
python-gitops-app
```

Inside it, create **app.py**:

```python
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from Python GitOps App v1"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

Create **requirements.txt**:

```text
flask
```

Create **Dockerfile**:

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]
```

---

# Part 2: Build and Push Docker Image

Build the image:

```bash
docker build -t python-gitops-app:v1 .
```

Tag it for ECR:

```bash
docker tag python-gitops-app:v1 <account-id>.dkr.ecr.<region>.amazonaws.com/python-gitops-app:v1
```

Push it:

```bash
docker push <account-id>.dkr.ecr.<region>.amazonaws.com/python-gitops-app:v1
```

---

# Part 3: Create Kubernetes Manifests

Create a folder named:

```text
manifests
```

Create **deployment.yaml**:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: python-gitops-app
  namespace: training

spec:
  replicas: 2

  selector:
    matchLabels:
      app: python-gitops-app

  template:
    metadata:
      labels:
        app: python-gitops-app

    spec:
      containers:
        - name: python-gitops-app
          image: <account-id>.dkr.ecr.<region>.amazonaws.com/python-gitops-app:v1
          ports:
            - containerPort: 5000
```

Create **service.yaml**:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: python-gitops-app
  namespace: training

spec:
  type: ClusterIP

  selector:
    app: python-gitops-app

  ports:
    - port: 80
      targetPort: 5000
```

---

# Part 4: GitOps Deployment

Push the manifests to Git.

Create an ArgoCD application pointing to the manifest repository:

```bash
argocd app create python-gitops-app \
  --repo <git-repo-url> \
  --revision main \
  --path manifests \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace training
```

Sync the application:

```bash
argocd app sync python-gitops-app
```

Verify deployment:

```bash
kubectl get pods -n training
kubectl get svc -n training
argocd app get python-gitops-app
```

---

# Evaluation Checklist

Students must submit:

- Docker image build output
- ECR image push confirmation
- Git repository containing:
  - deployment.yaml
  - service.yaml
- `argocd app get python-gitops-app` output
- `kubectl get pods -n training` output
- Browser or curl output showing:

```text
Hello from Python GitOps App v1
```

---

# Additional Task

Update **app.py**:

```python
return "Hello from Python GitOps App v2"
```

Then:

1. Build and push image tag `v2`
2. Update Kubernetes manifest with image tag `v2`
3. Commit and push changes to Git
4. Sync application with ArgoCD
5. Verify updated deployment

---

# Evaluation Rubric (100 Marks)

## 1. Project Structure and README (15 Marks)

| Criteria | Marks |
|-----------|------:|
| Repository has clear folder structure: app/, manifests/, README.md | 5 |
| README explains objective, prerequisites, tools, and workflow | 4 |
| README includes Docker build/run instructions | 2 |
| README includes ECR push steps | 2 |
| README includes ArgoCD deployment/sync steps | 2 |

---

## 2. Python Application (10 Marks)

| Criteria | Marks |
|-----------|------:|
| Flask app runs successfully on port 5000 | 4 |
| `/` route returns expected message | 3 |
| Code is simple, readable, and error-free | 3 |

---

## 3. Docker Image (15 Marks)

| Criteria | Marks |
|-----------|------:|
| Correct Dockerfile using Python base image | 4 |
| requirements.txt included and used | 3 |
| Image builds successfully | 4 |
| Container runs locally and serves app | 4 |

---

## 4. Amazon ECR (10 Marks)

| Criteria | Marks |
|-----------|------:|
| ECR repository created correctly | 3 |
| Docker login to ECR successful | 2 |
| Image tagged with correct ECR URI | 2 |
| Image pushed successfully with tag v1 | 3 |

---

## 5. Kubernetes Manifests (15 Marks)

| Criteria | Marks |
|-----------|------:|
| deployment.yaml is valid | 4 |
| service.yaml is valid | 3 |
| Correct namespace used | 2 |
| Deployment uses correct ECR image URI | 3 |
| Service correctly maps port 80 to container port 5000 | 3 |

---

## 6. GitOps Repository (10 Marks)

| Criteria | Marks |
|-----------|------:|
| Manifests committed to Git repository | 3 |
| Commit history is clear and meaningful | 2 |
| Repository is used as source of truth | 3 |
| Manifest changes are pushed before ArgoCD sync | 2 |

---

## 7. ArgoCD Deployment (15 Marks)

| Criteria | Marks |
|-----------|------:|
| ArgoCD app created successfully | 4 |
| App points to correct repo, branch, and path | 3 |
| App sync completes successfully | 3 |
| App status is Synced | 2 |
| App health is Healthy | 3 |

---

## 8. Validation and Evidence (10 Marks)

| Criteria | Marks |
|-----------|------:|
| kubectl get pods -n training output submitted | 2 |
| kubectl get svc -n training output submitted | 2 |
| argocd app get python-gitops-app output submitted | 2 |
| Browser or curl output shows application response | 2 |
| Screenshots/CLI outputs are clear and readable | 2 |

---

# Bonus Evaluation (10 Extra Marks)

| Criteria | Marks |
|-----------|------:|
| App updated from v1 to v2 | 2 |
| New Docker image built and pushed to ECR | 2 |
| Manifest updated with image tag v2 | 2 |
| Change committed and pushed to Git | 2 |
| ArgoCD sync deploys updated version successfully | 2 |

---

**Total: 100 Marks + 10 Bonus Marks**
