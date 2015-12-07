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

//# instance profile
//resource "aws_iam_instance_profile" "ddyt_instance_profile" {
//  name  = "ddyt_instance_profile"
//  roles = ["${aws_iam_role.ddyt_trust_role.name}"]
//}
//
//resource "aws_iam_role" "ddyt_trust_role" {
//  name               = "ddyt_trust_role"
//  path               = "/"
//  assume_role_policy = <<EOF
//{
//    "Version": "2012-10-17",
//    "Statement": [
//        {
//            "Sid": "",
//            "Effect": "Allow",
//            "Principal": {
//                "Service": "ec2.amazonaws.com"
//            },
//            "Action": "sts:AssumeRole"
//        }
//    ]
//}
//EOF
//}
//
//resource "aws_iam_role_policy" "ddyt_trust_role_policy" {
//  name   = "ddyt_trust_role_policy"
//  role   = "${aws_iam_role.ddyt_trust_role.id}"
//  policy = <<EOF
//{
//    "Version": "2012-10-17",
//    "Statement": [
//        {
//            "Effect": "Allow",
//            "Action": [
//                "s3:Get*",
//                "s3:List*"
//            ],
//            "Resource": [
//                "arn:aws:s3:::instance-secrets/*"
//            ]
//        }
//    ]
//}
//EOF
//}
