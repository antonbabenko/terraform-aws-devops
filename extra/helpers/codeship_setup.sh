#!/bin/bash -ex

# Install deps
pip install --upgrade awscli

# Install terraform
mkdir -p ~/cache/terraform
cd ~/cache/terraform

TERRAFORM_VERSION=0.6.8
TERRAFORM_ZIP=https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

HUB_VERSION=2.2.2
HUB_TGZ=https://github.com/github/hub/releases/download/v${HUB_VERSION}/hub-linux-amd64-${HUB_VERSION}.tgz

if [ ! -f "terraform_${TERRAFORM_VERSION}" ]; then

  echo "Downloading terraform.zip"
  curl --silent -o terraform_${TERRAFORM_VERSION}.zip --location -w "Downloaded: %{size_download} bytes (HTTP Code: %{http_code})\n" $TERRAFORM_ZIP

  echo "Extracting terraform.zip"
  unzip -o terraform_${TERRAFORM_VERSION}.zip -d terraform_${TERRAFORM_VERSION} > /dev/null

  cp -R terraform_${TERRAFORM_VERSION}/terraform* ~/bin/
else
  echo "terraform_${TERRAFORM_VERSION}.zip is already extracted"
fi

# Install github
mkdir -p ~/cache/hub
cd ~/cache/hub

if [ ! -f "hub_${HUB_VERSION}.tgz" ]; then

  echo "Downloading hub"
  curl --silent -o hub_${HUB_VERSION}.tgz --location -w "Downloaded: %{size_download} bytes (HTTP Code: %{http_code})\n" $HUB_TGZ

  echo "Extracting hub"
  mkdir hub_${HUB_VERSION}
  tar zxvf hub_${HUB_VERSION}.tgz -C hub_${HUB_VERSION} --strip-components=1 > /dev/null

  cp -R hub_${HUB_VERSION}/bin/hub ~/bin/
else
  echo "hub version ${HUB_VERSION} is already extracted"
fi

which terraform
which hub

terraform version
hub version
aws --version
