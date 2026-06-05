# Day 15 – 05-Jun-2026 (Friday)
# Module 3 – Containerization & Registry Management

## Lab: Multi-Stage Builds & Amazon ECR Publishing

### Objectives
- Create optimized Docker images
- Implement multi-stage builds
- Create Amazon ECR repositories
- Push and pull images
- Verify deployments

---

## Lab 1: Create Sample Application

Create app.py

```python
from http.server import BaseHTTPRequestHandler, HTTPServer

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'Hello from Docker and Amazon ECR!')

HTTPServer(('0.0.0.0',8080), Handler).serve_forever()
```

---

## Lab 2: Standard Docker Build

Dockerfile:

```dockerfile
FROM python:3.12
WORKDIR /app
COPY app.py .
EXPOSE 8080
CMD ['python','app.py']
```

Build:

```bash
docker build -t sunil-ecr:v1 .
```

Check image size:

```bash
docker images
```

---

## Lab 3: Multi-Stage Build

Dockerfile.multi

```dockerfile
FROM python:3.12-slim AS builder
WORKDIR /build
COPY app.py .

FROM python:3.12-slim
WORKDIR /app
COPY --from=builder /build/app.py .
EXPOSE 8080
CMD ["python","app.py"]
```

Build:

```bash
docker build -f Dockerfile.multi -t sunil-ecr:v2 .
```

Compare image sizes.

---

## Lab 4: Run Container
d
```bash
docker run -d --name sunil-app -p 8080:8080 sunil-ecr:v2
curl http://localhost:8080
```

---

## Lab 5: Configure AWS CLI

```bash
aws configure
aws sts get-caller-identity
```

---

## Lab 6: Create ECR Repository

```bash
aws ecr create-repository \
--repository-name sunil-ecr \
--region us-east-1 --profile devops
```

---

## Lab 7: Authenticate Docker

```bash
aws ecr get-login-password \
--region us-east-1 --profile devops | \
docker login \
--username AWS \
--password-stdin \
386757865964.dkr.ecr.us-east-1.amazonaws.com
```

---

## Lab 8: Tag Image

```bash
docker tag sunil-ecr:v2 \
386757865964.dkr.ecr.us-east-1.amazonaws.com/sunil-ecr:v2
```

---

## Lab 9: Push Image to ECR

```bash
docker push \
386757865964.dkr.ecr.us-east-1.amazonaws.com/sunil-ecr:v2
```

---

## Lab 10: Verify Images

```bash
aws ecr list-images \
--repository-name sunil-ecr \
--region us-east-1 --profile devops
```

---

## Lab 11: Pull Image

```bash
docker pull \
386757865964.dkr.ecr.us-east-1.amazonaws.com/sunil-ecr:v2
```

---

## Lab 12: Run Pulled Image

```bash
docker run -d -p 8081:8080 \
386757865964.dkr.ecr.us-east-1.amazonaws.com/sunil-ecr:v2
```

Verify:

```bash
curl http://localhost:8081
```

---

## Challenge Exercise
1. Build a custom app.
2. Create a multi-stage Docker image.
3. Create a private ECR repository.
4. Push image.
5. Pull image.
6. Run successfully.

---

## Expected Outcome
✓ Multi-stage Docker builds
✓ Optimized images
✓ ECR repository management
✓ Image publishing
✓ Image retrieval from ECR
