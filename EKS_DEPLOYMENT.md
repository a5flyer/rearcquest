## Docker Build & EKS Deployment Guide for reactf

### 1. Build the Docker Image Locally

```bash
docker build -t reactf:latest .
```

Test it locally with:
```bash
docker compose up
```

Access the app at `http://localhost:3000`

### 2. Push to AWS ECR

First, create an ECR repository:
```bash
aws ecr create-repository --repository-name reactf --region us-east-1
```

Then authenticate Docker with ECR:
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
```

Tag and push the image:
```bash
docker tag reactf:latest <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/reactf:latest
docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/reactf:latest
```

### 3. Deploy to EKS

First, update the image in `k8s-deployment.yaml`:
Replace `<YOUR_ECR_REGISTRY>` with `<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com`

Then deploy:
```bash
kubectl apply -f k8s-deployment.yaml
```

Check deployment status:
```bash
kubectl get deployments
kubectl get pods
kubectl get services
```

To access your app:
```bash
kubectl port-forward service/reactf-service 3000:80
```

Then open `http://localhost:3000`

### 4. Verify App is Running

```bash
kubectl logs -l app=reactf
kubectl describe pod -l app=reactf
```
