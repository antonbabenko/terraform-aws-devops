#!/bin/bash -ex

# Install deps
pip install --upgrade awscli

# Install terraform
mkdir -p ~/cache/terraform
cd ~/cache/terraform

# 0.6.7 freezes during fetching modules from git
TERRAFORM_VERSION=0.6.6
TERRAFORM_ZIP=https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

if [ ! -f "terraform_${TERRAFORM_VERSION}" ]; then

  echo "Downloading terraform.zip"
  curl --silent -o terraform_${TERRAFORM_VERSION}.zip --location -w "Downloaded: %{size_download} bytes (HTTP Code: %{http_code})\n" $TERRAFORM_ZIP

  echo "Extracting terraform.zip"
  unzip -o terraform_${TERRAFORM_VERSION}.zip -d terraform_${TERRAFORM_VERSION} > /dev/null

  cp -R terraform_${TERRAFORM_VERSION}/terraform* ~/bin/
else
  echo "terraform_${TERRAFORM_VERSION}.zip is already extracted"
fi

which terraform
terraform version
aws --version
