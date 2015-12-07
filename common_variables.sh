#!/bin/bash

# Hardcode values for simple demo. Comment them for more complex demos.
#export TF_PROJECT=web
#export TF_VAR_environment=production

# Uncomment these 4 lines to add support for multiple projects and environments
export TF_PROJECT=$1
export TF_VAR_environment=$2
shift
shift

export TF_MODULE_DEPTH=-1

# Location where state files for project should be created or loaded from
terraform_bucket_region='eu-west-1'
terraform_bucket_name='tf-states.devops-demo'

set -u

if [ "x${TF_VAR_environment}" == "x" ]; then
  TF_VAR_environment=staging
fi

if [ "x${TF_PROJECT}" == "x" ]; then
  echo "Missing project name"
  exit 1
fi

WORK_DIR=$(pwd)/projects/${TF_PROJECT}

cd $WORK_DIR