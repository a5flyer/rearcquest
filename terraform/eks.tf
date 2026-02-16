resource "aws_iam_role" "eks_cluster_role" {
  name = "reactf-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_security_group" "eks_cluster" {
  name        = "reactf-eks-cluster-sg"
  description = "Security group for reactf EKS cluster"
  vpc_id      = aws_vpc.reactf.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "reactf-eks-cluster-sg"
  }
}

resource "aws_eks_cluster" "reactf" {
  name            = var.cluster_name
  role_arn        = aws_iam_role.eks_cluster_role.arn
  version         = var.kubernetes_version
  
  vpc_config {
    subnet_ids              = [aws_subnet.reactf_public_1.id, aws_subnet.reactf_public_2.id]
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.eks_cluster.id]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]

  tags = {
    Name = "reactf-eks-cluster"
  }
}

data "aws_eks_cluster_auth" "reactf" {
  name = aws_eks_cluster.reactf.name
}
