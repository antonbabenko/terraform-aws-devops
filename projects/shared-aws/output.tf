output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}
output "vpc_cidr" {
  value = "${module.vpc.vpc_cidr}"
}
output "azs" {
  value = "${var.azs}"
}
output "public_subnet_ids" {
  value = "${module.public_subnet.subnet_ids}"
}
output "iam_server_certificate_arn" {
  value = "${aws_iam_server_certificate.example.arn}"
}