#!/bin/bash

set -e

CLUSTER_NAME="eks-upgrade-prod"
REGION="us-east-1"

echo "Checking EKS cluster version..."

CURRENT_VERSION=$(aws eks describe-cluster \
  --region "$REGION" \
  --name "$CLUSTER_NAME" \
  --query "cluster.version" \
  --output text)

echo "Current Version: $CURRENT_VERSION"

LATEST_VERSION=$(aws eks describe-addon-versions \
  --query "addons[0].addonVersions[0].compatibilities[0].clusterVersion" \
  --output text)

echo "Latest Supported Version: $LATEST_VERSION"

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    echo "Cluster already on latest version."

    echo "UPGRADE_REQUIRED=false" >> "$GITHUB_ENV"

else
    echo "Upgrade required."

    echo "UPGRADE_REQUIRED=true" >> "$GITHUB_ENV"
fi
