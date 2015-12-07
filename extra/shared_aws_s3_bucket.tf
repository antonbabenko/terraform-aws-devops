resource "aws_s3_bucket" "terraform_aws_devops_demo" {
  bucket = "terraform-aws-devops-demo"
  region = "eu-west-1"
  acl = "private"
}

output "terraform_aws_devops_demo_s3_bucket" {
  value = "${aws_s3_bucket.terraform_aws_devops_demo.bucket}"
}