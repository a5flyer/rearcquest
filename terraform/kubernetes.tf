resource "kubernetes_deployment" "reactf" {
  metadata {
    name      = "reactf"
    namespace = "default"
    labels = {
      app = "reactf"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "reactf"
      }
    }

    template {
      metadata {
        labels = {
          app = "reactf"
        }
      }

      spec {
        automount_service_account_token = false

        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 100
              pod_affinity_term {
                label_selector {
                  match_expressions {
                    key      = "app"
                    operator = "In"
                    values   = ["reactf"]
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
            }
          }
        }

        container {
          image             = "${aws_ecr_repository.reactf.repository_url}:latest"
          name              = "reactf"
          image_pull_policy = "Always"

          port {
            container_port = 3000
            name           = "http"
          }

          env {
            name  = "AWS_REGION"
            value = "us-east-1"
          }

          env {
            name  = "AWS_DEFAULT_REGION"
            value = "us-east-1"
          }

          env {
            name  = "AWS_EXECUTION_ENV"
            value = "AWS_EKS"
          }

          env {
            name  = "AWS_ACCOUNT_ID"
            value = "188358598401"
          }

          env {
            name  = "AWS_ROLE_ARN"
            value = aws_iam_role.eks_node_role.arn
          }

          env {
            name  = "FORCE_AWS"
            value = "true"
          }

          env {
            name  = "SECRET_WORD"
            value = "unknown"
          }

          env_from {
            secret_ref {
              name = "aws-credentials"
            }
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }

  depends_on = [aws_eks_node_group.reactf]
}

resource "kubernetes_service" "reactf" {
  metadata {
    name      = "reactf-service"
    namespace = "default"
    labels = {
      app = "reactf"
    }
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"             = "elb"
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" = "http"
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"         = "arn:aws:iam::188358598401:server-certificate/reactf-cert"
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" = "http"
      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports"        = "443"
    }
  }

  spec {
    selector = {
      app = "reactf"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 3000
      protocol    = "TCP"
    }

    port {
      name        = "https"
      port        = 443
      target_port = 3000
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }

  depends_on = [kubernetes_deployment.reactf]
}
