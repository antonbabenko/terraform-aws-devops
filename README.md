# Manage AWS infrastructure as code using Terraform

## Presentation

Slides are inside `presentation` folder. Code in this repository and talk was given by Anton Babenko for DevOps Norway Meetup 14th of December 2015.

## Setup

Install Terraform - https://www.terraform.io/intro/getting-started/install.html

Install AWS CLI - `brew update && brew install awscli` (on Mac)

Get AWS IAM access and secret keys from AWS console and export them like this:

    export AWS_ACCESS_KEY_ID="something_here"
	export AWS_SECRET_ACCESS_KEY="something_secret_here"
	export TF_VAR_aws_access_key=$AWS_ACCESS_KEY_ID
	export TF_VAR_aws_secret_key=$AWS_SECRET_ACCESS_KEY
		   
## Description

Let's deploy demo application and work with AWS infrastructure as code using Terraform.

Terraform remote state is configured using S3.

2 projects:
  - web (ELB,ASG,LC)
  - shared-aws (VPC,SN)
1 environment:
  - production
1 region:
  - eu-west-1

## Author

Created and maintained by [Anton Babenko](https://github.com/antonbabenko).

## License

Apache 2 Licensed. See LICENSE for full details.