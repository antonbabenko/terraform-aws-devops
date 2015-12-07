#!/bin/bash
set -e

. ./common_variables.sh

function usage() {
  echo "Usage: terraform.sh [project_name] [environment] [action] [argument]"
  echo
  echo "project_name:"
  echo " - the name of the terraform project"
  echo
  echo "environment:"
  echo " - staging"
  echo " - production"
  echo " - development (or anything you want)"
  echo
  echo "action:"
  echo " - init"
  echo " - plan"
  echo " - apply"
  echo " - show"
  echo " - output"
  echo " - taint"
  echo " - plan-destroy"
  echo " - destroy"
  echo " - refresh"
  echo " - plan-no-refresh"
  echo " - apply-no-refresh"
  echo
  echo "argument (required only when action is taint and resource belongs to root module)"
}

# Ensure script console output is separated by blank line at top and bottom to improve readability
trap echo EXIT

action="$1"
destroy=""
force=""
refresh=""
environment_var_file=""

# Validate the input arguments
if [[ "$#" -ne 1 && "$action" != "taint" ]]; then
  usage
  exit 1
elif [[ "$#" -ne 2 && "$action" == "taint" ]]; then
  usage
  exit 1
fi

case "$action" in
  init) ;;
  refresh) ;;
  plan-no-refresh) ;;
  apply-no-refresh) ;;
  plan) ;;
  apply) ;;
  show) ;;
  output) ;;
  taint) ;;
  plan-destroy) ;;
  destroy) ;;
  *)
    usage
    exit 1
esac

if [[ ! -e ".terraform/${TF_VAR_environment}.txt" && "$action" != "init" ]]; then
  echo "Environment '${TF_VAR_environment}' should be initiated before use!"
  echo "Run this: ./terraform.sh ${TF_PROJECT} ${TF_VAR_environment} init"
  exit
else
  echo "Environment '${TF_VAR_environment}' is already initiated. Good."
fi

# Check if environment settings file exists, then include it in commands
if [ -e "${TF_VAR_environment}.tfvars" ]; then
  environment_var_file="-var-file=${TF_VAR_environment}.tfvars"
fi

if [ "$action" == "plan-destroy" ]; then
  action="plan"
  destroy="-destroy"
  refresh="-refresh=true"
fi

if [ "$action" == "plan-no-refresh" ]; then
  action="plan"
  refresh="-refresh=false"
fi

if [ "$action" == "apply" ]; then
  refresh="-refresh=true"
fi

if [ "$action" == "apply-no-refresh" ]; then
  action="apply"
  refresh="-refresh=false"
fi

if [ "$action" == "destroy" ]; then
  destroy="-destroy"
  force="-force"
fi

if [ "$action" == "init" ]; then
  rm -rf .terraform/*

  echo
  echo "Bucket: $terraform_bucket_name ; Region: $terraform_bucket_region"
  echo

  set +e # do not stop if bucket does not exist
  aws s3 ls $terraform_bucket_name
  if [ "$?" != 0 ]; then
    aws s3api create-bucket --bucket $terraform_bucket_name --acl authenticated-read --create-bucket-configuration LocationConstraint=$terraform_bucket_region
    aws s3api put-bucket-versioning --bucket $terraform_bucket_name --versioning-configuration Status=Enabled
    echo "Bucket has been created"
  fi
  set -e

  echo

  terraform remote config\
    -backend=s3\
    -backend-config="region=$terraform_bucket_region"\
    -backend-config="bucket=$terraform_bucket_name"\
    -backend-config="key=${TF_PROJECT}_${TF_VAR_environment}"\
    -backend-config="encrypt=true"\
    -pull=true

  terraform get

  terraform refresh\
    $environment_var_file\
    -var-file=terraform.tfvars

  touch .terraform/${TF_VAR_environment}.txt

  exit 0
fi

if [ "$action" == "plan" ]; then
  terraform plan \
    $refresh \
    $destroy \
    -input=false \
    -detailed-exitcode\
    $environment_var_file\
    -var-file=terraform.tfvars

  EXIT_CODE=$?

  if [ $EXIT_CODE == 0 ]; then
    exit 0
  elif [ $EXIT_CODE == 2 ]; then
    echo "There are changes, so we should apply this changes to ${TF_VAR_environment}!!!"
    exit 0
  else
    echo "ERRRRRRROR during plan"
    exit 1
  fi
fi

if [ "$action" == "show" ]; then
  terraform show

  exit 0
fi

if [ "$action" == "taint" ]; then
#    $ ./terraform.sh shared-aws staging init
#    $ terraform taint -module=bastion -state=projects/shared-aws/.terraform/terraform.tfstate aws_instance.bastion
#    $ ./terraform.sh shared-aws staging plan
#    $ ./terraform.sh shared-aws staging apply

  terraform taint\
    -allow-missing\
    $2

  exit 0
fi

if [ "$action" == "output" ]; then
  terraform output

  exit 0
fi

#terraform graph -draw-cycles | dot -Tpng -o graph.png

# Execute the terraform action (apply, destroy, refresh)
terraform "$action" \
  -input=false \
  $environment_var_file\
  -var-file=terraform.tfvars\
  $refresh \
  $force