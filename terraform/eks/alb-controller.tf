# -----------------------------
# Custom IAM Policy: AddTags
# -----------------------------
resource "aws_iam_policy" "alb_add_tags" {
  name = "ALBControllerAddTags"
  path = "/"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["elasticloadbalancing:AddTags"],
        Resource = "*"
      }
    ]
  })
}

# -----------------------------
# IAM Role for Service Account (IRSA)
# -----------------------------
module "aws_load_balancer_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.30.0"

  role_name                               = "aws-load-balancer-controller"
  attach_load_balancer_controller_policy  = true

  # 🔧 FIXED: map of strings, not list
  role_policy_arns = {
    alb_add_tags = aws_iam_policy.alb_add_tags.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

# -----------------------------
# Deploy AWS Load Balancer Controller via Helm
# -----------------------------
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.6.0"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.aws_load_balancer_controller_irsa_role.iam_role_arn
  }

  depends_on = [module.eks]
}
