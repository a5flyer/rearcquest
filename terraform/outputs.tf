output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.reactf.endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.reactf.name
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.reactf.arn
}

output "ecr_repository_url" {
  description = "ECR repository URL for pushing Docker image"
  value       = aws_ecr_repository.reactf.repository_url
}

output "service_endpoint" {
  description = "LoadBalancer service endpoint (external IP/hostname)"
  value       = try(kubernetes_service.reactf.status[0].load_balancer[0].ingress[0].hostname, "pending")
}
