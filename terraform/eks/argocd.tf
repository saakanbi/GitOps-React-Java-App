resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "5.46.7" # Use the latest stable version

  values = [<<EOF
server:
  service:
    type: LoadBalancer
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: alb
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/target-type: ip
    hosts:
      - argocd.${module.eks.cluster_name}.example.com
  extraArgs:
    - --insecure
  config:
    repositories: |
      - type: git
        url: https://github.com/YOUR_USERNAME/GitOps-React-Java-App.git
EOF
  ]

  depends_on = [module.eks]
}