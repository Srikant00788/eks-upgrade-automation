#!/bin/bash

set -e

echo "======================================"
echo "EKS Upgrade Validation Started"
echo "======================================"

echo
echo "1. Checking Control Plane"

aws eks describe-cluster \
--name eks-upgrade-prod \
--query cluster.version

echo
echo "2. Checking Nodegroup"

aws eks describe-nodegroup \
--cluster-name eks-upgrade-prod \
--nodegroup-name eks-upgrade-prod-nodes \
--query nodegroup.version

echo
echo "3. Checking Nodes"

kubectl get nodes

NOT_READY=$(kubectl get nodes --no-headers | awk '$2!="Ready"{print $1}')

if [ ! -z "$NOT_READY" ]; then
  echo "Nodes not Ready:"
  echo "$NOT_READY"
  exit 1
fi

echo
echo "4. Checking All Pods"

kubectl get pods -A

FAILED_PODS=$(kubectl get pods -A --no-headers | \
grep -v Running | \
grep -v Completed | \
awk '{print $2}')

if [ ! -z "$FAILED_PODS" ]; then
    echo "Pods not healthy:"
    echo "$FAILED_PODS"
    exit 1
fi

echo
echo "5. CoreDNS"

kubectl rollout status deployment/coredns \
-n kube-system \
--timeout=3m

echo
echo "6. kube-proxy"

kubectl rollout status daemonset/kube-proxy \
-n kube-system \
--timeout=3m

echo
echo "7. AWS VPC CNI"

kubectl rollout status daemonset/aws-node \
-n kube-system \
--timeout=3m

echo
echo "8. AWS Load Balancer Controller"

kubectl rollout status deployment/aws-load-balancer-controller \
-n kube-system \
--timeout=3m

echo
echo "9. Cluster Autoscaler"

kubectl rollout status deployment/cluster-autoscaler-aws-cluster-autoscaler \
-n kube-system \
--timeout=3m

echo
echo "10. ArgoCD"

kubectl rollout status deployment/argocd-server \
-n argocd \
--timeout=3m

echo

echo "======================================"
echo "All Validation Checks Passed"
echo "======================================"
