# Manage AWS infrastructure as code using Terraform

## [Join AWS User Group Norway meetups!](http://www.meetup.com/AWS-User-Group-Norway/)
This is a group for people interested in Amazon Web Services. Anyone can participate, ranging from AWS evangelists to the curious. The main focus of the group is to build up a community around AWS with socializing and talks on topics like innovations, development and possibilities. Having trouble with a stack? Maybe you'll meet someone with a solution or an approach that you haven't already tried.

[Join now!](http://www.meetup.com/AWS-User-Group-Norway/)

## Presentation

Talk was given by Anton Babenko on DevOps Norway Meetup 14th of December 2015.

[Slides from the talk](http://www.slideshare.net/AntonBabenko/manage-aws-infrastructure-using-terraform-56140321)

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

## Want to destroy? Tired of cycle errors?

If you run `./terraform.sh heavy production plan-destroy` it will raise cycle error like:
```
Error running plan: 1 error(s) occurred:

* Cycle: aws_security_group.elb, aws_security_group.elb (destroy), aws_iam_instance_profile.default (destroy), aws_iam_role.default (destroy), aws_iam_role.default, aws_iam_instance_profile.default, aws_security_group.web_server, aws_launch_configuration.heavy, aws_launch_configuration.heavy (destroy), aws_security_group.web_server (destroy), output.configuration, aws_elb.heavy (destroy), aws_autoscaling_group.heavy (destroy), terraform_remote_state.shared (destroy), terraform_remote_state.shared, aws_elb.heavy, aws_autoscaling_group.heavy
```

It happens because resource `terraform_remote_state.shared` does not have lifecycle event defined, so we should destroy all except it:

```shell
cd projects/heavy
terraform destroy -var-file=production.tfvars -var-file=terraform.tfvars -var 'environment=production' \
-target=aws_iam_instance_profile.default \
-target=aws_elb.heavy \
-target=aws_security_group.web_server \
-target=template_file.heavy_user_data \
-target=aws_iam_role.default \
-target=aws_security_group.elb
```

## Author

Created and maintained by [Anton Babenko](https://github.com/antonbabenko).

Feel free to open github issue, if you found something wrong or just have questions.

## License

Apache 2 Licensed. See LICENSE for full details.
