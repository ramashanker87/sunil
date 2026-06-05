# Day 15 – 05-Jun-2026 (Friday)
# Module 3 – Containerization & Registry Management

## Theory: Docker Optimization & Amazon ECR

### Learning Objectives
- Understand Docker image optimization techniques.
- Reduce image size and improve build performance.
- Understand Docker caching and layer management.
- Learn Docker security best practices.
- Understand Amazon ECR architecture and workflows.
- Learn image lifecycle management and tagging strategies.

---

## Docker Optimization

### Why Optimize Docker Images?
- Faster image downloads
- Faster deployments
- Reduced storage costs
- Reduced attack surface
- Improved CI/CD performance

### Docker Image Layers
Docker images are built using layers.

Example:
```dockerfile
FROM ubuntu
RUN apt update
RUN apt install -y nginx
COPY app /app
```

Each instruction creates a layer.

### Build Cache
```bash
docker build -t myapp:v1 .
```

Force rebuild:
```bash
docker build --no-cache -t myapp:v1 .
```

### Optimization Techniques
- Use slim or alpine base images.
- Combine RUN commands.
- Remove unnecessary packages.
- Use specific image tags.
- Use multi-stage builds.
- Scan images for vulnerabilities.

### Security Best Practices
- Use official images.
- Avoid running as root.
- Regularly update images.
- Scan images using Trivy, Scout, or Snyk.

---

## Amazon Elastic Container Registry (ECR)

### What is Amazon ECR?
Amazon ECR is a fully managed AWS container image registry.

### Benefits
- Secure image storage
- IAM integration
- Vulnerability scanning
- High availability
- Lifecycle policies

### ECR Workflow
1. Build image
2. Authenticate Docker
3. Tag image
4. Push image
5. Pull image
6. Deploy application

### Repository Types
#### Private Repository
Internal enterprise applications.

#### Public Repository
Publicly shared container images.

### Authentication
```bash
aws ecr get-login-password --region us-east-1 --profile devops
```

### Tagging Strategy
- latest
- dev
- test
- prod
- v1.0.0

### Lifecycle Policies
Automatically remove old images and reduce storage costs.

### CI/CD Integration
- Jenkins
- GitHub Actions
- GitLab CI/CD
- AWS CodePipeline

---

## Summary
✓ Docker Optimization
✓ Layer Management
✓ Build Cache
✓ Multi-Stage Builds
✓ Amazon ECR Architecture
✓ Repository Management
✓ Lifecycle Policies
✓ Security Best Practices
