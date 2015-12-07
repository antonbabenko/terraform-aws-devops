output "configuration" {
  value = <<CONFIGURATION
Heavy web application has been deployed in ${var.environment} environment

Url:            ${aws_elb.heavy.dns_name}

VPC
----
VPC CIDR:       ${terraform_remote_state.shared.output.vpc_cidr}
VPC ID:         ${terraform_remote_state.shared.output.vpc_id}

CONFIGURATION
}
