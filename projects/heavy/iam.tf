//resource "aws_iam_instance_profile" "s3_readonly" {
//  name  = "s3-readonly-${var.environment}"
//  roles = ["${aws_iam_role.s3_readonly.name}"]
//}
//
//resource "aws_iam_role" "s3_readonly" {
//  name               = "s3-readonly-role-${var.environment}"
//  path               = "/"
//  assume_role_policy = <<EOF
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Sid": "",
//      "Effect": "Allow",
//      "Principal": {
//        "Service": "ec2.amazonaws.com"
//      },
//      "Action": "sts:AssumeRole"
//    }
//  ]
//}
//EOF
//}
//
//resource "aws_iam_role_policy" "s3_readonly_policy" {
//  name   = "s3-readonly-policy-${var.environment}"
//  role   = "${aws_iam_role.s3_readonly.id}"
//  policy = <<EOF
//{
//    "Version": "2012-10-17",
//    "Statement": [
//        {
//            "Sid": "Stmt1425916919000",
//            "Effect": "Allow",
//            "Action": [
//                "s3:List*",
//                "s3:Get*"
//            ],
//            "Resource": "*"
//        }
//    ]
//}
//EOF
//}