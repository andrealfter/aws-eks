#!/bin/bash
set -o xtrace

/etc/eks/bootstrap.sh ${cluster_name} ${bootstrap_arguments}

/opt/aws/bin/cfn-signal --exit-code $? \
  --stack ${cluster_name} \
  --resource NodeGroup \
  --region ${AWS_DEFAULT_REGION}
