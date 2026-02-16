## Terraform Deployment Guide for reactf on EKS

### Prerequisites

1. **AWS Account** with credentials configured
2. **Terraform** installed (https://www.terraform.io/downloads)
3. **AWS CLI** installed (https://aws.amazon.com/cli/)
4. **kubectl** installed (https://kubernetes.io/docs/tasks/tools/)
5. **Docker** (already have it)

### Setup AWS Credentials

```powershell
# Configure AWS CLI with your credentials
aws configure

# You'll be prompted for:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (us-east-1)
# - Default output format (json)
```

### Step 1: Build and Push Docker Image to ECR

First, deploy the infrastructure to create ECR:
```powershell
cd terraform
terraform init
terraform plan
terraform apply
```

After applying, get the ECR repository URL:
```powershell
$ECR_URL = terraform output -raw ecr_repository_url
```

Authenticate Docker with ECR:
```powershell
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL
```

Build and push the image:
```powershell
# From project root
docker build -t reactf:latest .
docker tag reactf:latest "$ECR_URL`:latest"
docker push "$ECR_URL`:latest"
```

### Step 2: Deploy to EKS

The Terraform configuration will automatically deploy:
- VPC with public subnets
- EKS cluster
- Worker node group
- ECR repository
- Kubernetes Deployment (2 replicas)
- LoadBalancer Service

After `terraform apply` completes, get the service endpoint:
```powershell
cd terraform
terraform output service_endpoint
```

It may take a few minutes for the LoadBalancer to be created. Check status:
```powershell
kubectl get svc reactf-service
```

### Step 3: Access the Application

Once the LoadBalancer has an external IP/hostname:
```powershell
$ENDPOINT = kubectl get svc reactf-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
Start-Process "http://$ENDPOINT"
```

### Step 4: View Logs

```powershell
# View pod logs
kubectl logs -l app=reactf --tail=50 -f

# Describe pods
kubectl describe pod -l app=reactf

# Get pod status
kubectl get pods -l app=reactf -o wide
```

### Cleanup

To destroy all resources:
```powershell
cd terraform
terraform destroy
```

### Troubleshooting

**Pods stuck in pending:**
```powershell
kubectl describe pod <pod-name>
kubectl get nodes
```

**Image pull errors:**
```powershell
# Verify ECR push succeeded
aws ecr describe-images --repository-name reactf

# Check node IAM role has ECR read permissions (should be automatic with our terraform)
```

**Service endpoint not showing:**
```powershell
kubectl describe svc reactf-service
# May take 2-5 minutes for AWS to provision LoadBalancer
```
