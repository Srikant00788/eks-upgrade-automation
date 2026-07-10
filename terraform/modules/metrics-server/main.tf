resource "helm_release" "metrics_server" {

  name = "metrics-server"

  repository = "https://kubernetes-sigs.github.io/metrics-server"

  chart = "metrics-server"

  namespace = "kube-system"

  create_namespace = false

  version = var.chart_version

  wait = true

  timeout = 300

  set {
    name = "replicas"
    value = "2"
  }

  set {
    name = "args[0]"
    value = "--kubelet-preferred-address-types=InternalIP"
  }

  set {
    name = "args[1]"
    value = "--kubelet-use-node-status-port"
  }

  depends_on = []
}
