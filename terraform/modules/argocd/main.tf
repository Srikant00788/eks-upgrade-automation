resource "helm_release" "argocd" {

  name             = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"

  chart            = "argo-cd"

  namespace        = "argocd"

  create_namespace = true

  version          = "8.3.2"

  wait             = true

  timeout          = 600

  values = [
<<EOF
server:
  service:
    type: LoadBalancer

configs:
  params:
    server.insecure: true
EOF
  ]
}
