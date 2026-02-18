Summary of Quest Completion
✅ Completed Tasks
Infrastructure as Code (IaC) with Terraform

Created complete Terraform configuration for AWS EKS deployment
VPC with 2 public subnets across availability zones
EKS cluster (Kubernetes 1.35)
2 worker nodes (t3.small instances)
ECR repository for Docker images
Security groups with proper networking rules
IAM roles and policies for cluster and nodes
Containerization

Used Node.js 10.24.1 base image (node:10.24.1-alpine)
Built Docker image from provided Rearc quest app
Pushed image to AWS ECR
Configured auto-pull in Kubernetes deployment
Kubernetes Deployment (EKS)

Deployed app with 2 replicas for High Availability
Pod anti-affinity to spread replicas across nodes
Resource requests/limits configured
Service account setup (attempted IRSA)
Environment variables injected for AWS detection
Load Balancer

AWS Network Load Balancer (NLB) deployed
LoadBalancer service in Kubernetes
Public endpoint accessible via DNS
Environment Variables

AWS_REGION, AWS_DEFAULT_REGION
AWS_EXECUTION_ENV, AWS_ACCOUNT_ID
SECRET_WORD=unknown (injected)
AWS credentials (attempted)
Kubernetes Version

Upgraded cluster to Kubernetes 1.35 (latest supported)
Avoided extended support charges
Certificate Installed on Load Balancer--TLS

Created Cert locally using openssl
Created Https Listener with the certificate
⚠️ Limitations
AWS Detection: The app's AWS detection requires EC2 infrastructure markers. EKS containerized workloads don't expose the same metadata service authentication, so the index page cannot display the SECRET_WORD
📦 Deliverables Ready
Complete Terraform code (IaC)
Dockerfile with Node 10 base image
Docker image in ECR
Running EKS cluster with LoadBalancer
LoadBalancer public endpoint
Documentation of approach and limitations
Next Steps (if continuing)
Consider EC2-based alternative for full quest completion
The deployment demonstrates modern cloud best practices with containerization, Kubernetes orchestration, infrastructure automation, and load balancing - even though the specific app's AWS detection isn't compatible with container environments.

Docker Desktop was installed on a Windows 10 laptop and a deployment was done to AWS
I used Ask Gordan for the first time to assist me with this quest.
Prompt Summary
Initial Setup & Problems
Asked why build was failing (package-lock.json missing)
Discussed Node version 10 installation options
Chose Docker/EKS deployment over local Node installation
Created Terraform configuration for EKS deployment
Terraform & Infrastructure
Updated Kubernetes version (1.30 → 1.31 → 1.32 → 1.33 → 1.35)
Fixed invalid Terraform arguments (vpc_config, security_groups)
Fixed duplicate outputs in Terraform files
Changed node count from 1 to 2 for HA
Updated instance type from t3.micro to t3.small
Changed deployment replicas from 1 to 2 with pod anti-affinity
Removed liveness and readiness probes (causing crashes)
Kubernetes & Deployment Issues
Fixed Kubernetes provider authentication errors
Handled state file corruption multiple times
Removed and re-imported resources into state
Deleted and recreated deployments to fix conflicts
Updated kubeconfig after cluster upgrades
Fixed pod scheduling issues (too many pods on node)
AWS Detection & Environment Variables
Attempted to detect AWS cloud provider in app
Checked metadata service accessibility (169.254.169.254)
Added AWS environment variables (AWS_REGION, AWS_ACCOUNT_ID, etc.)
Tried IRSA (IAM Roles for Service Accounts) setup
Added IAM policies to node role (AmazonEC2ReadOnlyAccess)
Attempted to pass AWS credentials as secrets and environment variables
Finally injected SECRET_WORD=unknown as environment variable
Docker & Image Management
Built Docker image with Node 10
Pushed image to AWS ECR
Authenticated Docker with ECR
Managed image pull errors and retries
LoadBalancer & Networking
Created AWS Network Load Balancer
Configured security groups for metadata service access
Tested access via port-forward and LoadBalancer endpoint
Documentation & Quest Understanding
Reviewed quest requirements and success criteria
Identified AWS detection limitation in containerized environment
Discussed alternatives (EC2 vs EKS deployment)
Key Learnings
Terraform state management complexities
Kubernetes provider authentication in Terraform
EKS networking and IAM role configuration
Container metadata service limitations
High availability patterns (replicas, anti-affinity, multi-zone)
AWS cloud detection requirements
An answer to the prompt: "Given more time, I would improve..."

Since I do not have the code, behind the binaries I could only guess how the /aws check was being done. Both the index and the /aws check show that it could not detect AWS GCP or Azure. I spent some time on this working through various options about allowing the container to access the aws metadata service, and also adding AWS specific environment variables, but in the end, it did not work. Gordon suggested that the code might only work in an EC2, but I did not think it worth the time to try this given the purpose seemed to be oriented towards proving knowledge of Docker/Kubernetes/terraform.
The terraform could be improved by the creation of modules. Using this technique you could limit the size of the clusters and also specify versions which could be used to avoid the sneaky AWS support charges on the 1.31 cluster which I got hit with for the first day LOL
I would also deploy this to AKS and GKE.
I didn't love how long it took to create the cluster and nodes in terraform. It seemed brittle and Terraform timed out when deploying after 10 mins. I prefer to use it for shorter deployments. I might look towards using Helm to deploy.
Q. What if I find a bug or part of my solution isn't detected? Public cloud & index page (contains the secret word) - http(s)://<ip_or_host>[:port]/ A. The index page isn't being detected properly as running from AWS. You can see this when you browse to the load balancer here: https://afa5e961225d74b2c9c19b41607eea75-841740817.us-east-1.elb.amazonaws.com/ The message returned is: You don't seem to be running in AWS or GCP or Azure.
Docker check - http(s)://<ip_or_host>[:port]/docker A. The Docker check is not working locally on http://localhost:3000 which is running from Docker Desktop, or when deployed to AWS. The message returned is: "You dont seem to be running in a Docker container. This might be OK as many cloud container orchestration platforms do not use Docker" It would seem that this code may need to be updated or studied to determine why it isn't detecting in either scenario. Secret Word check - http(s)://<ip_or_host>[:port]/secret_word A. The secret word check works with the word "unknown" however, the index page does not display the actual secret word so I cannot update the env variable with the correct word. Load Balancer check - http(s)://<ip_or_host>[:port]/loadbalanced A. The load balanced check does succeed and displays: "Congratulations! Looks like you successfully configured an AWS loadbalancer" TLS check - http(s)://<ip_or_host>[:port]/tls A. The TLS check does display "Congratulations! Looks like you successfully configured TLS (https)"
