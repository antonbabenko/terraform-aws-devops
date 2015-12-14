provider "aws" {
  region     = "${var.region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

resource "terraform_remote_state" "shared" {
  backend = "s3"
  config {
    bucket  = "tf-states.devops-demo"
    region  = "eu-west-1"
    key     = "shared-aws_${var.environment}"
    encrypt = true
  }
}
