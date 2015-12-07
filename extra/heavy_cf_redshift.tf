# Cloudformation template was downloaded from http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/quickref-redshift.html

# Taint may be required:
# terraform taint -state=projects/heavy/.terraform/terraform.tfstate aws_cloudformation_stack.heavy_redshift
resource "aws_security_group" "redshift" {
  name   = "redshift"
  vpc_id = "${terraform_remote_state.shared.output.vpc_id}"

  ingress {
    protocol    = "tcp"
    from_port   = 5439
    to_port     = 5439
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "template_file" "redshift_cloudformation" {
  template = "${file("redshift.cloudformation")}"

  vars {
    redshift_public_subnet_id  = "${element(split(",", terraform_remote_state.shared.output.public_subnet_ids), 0)}"
    redshift_security_group_id = "${aws_security_group.redshift.id}"
  }
}

resource "aws_cloudformation_stack" "heavy_redshift" {
  name          = "heavy-redshift"
  template_body = "${template_file.redshift_cloudformation.rendered}"

  parameters {
    MasterUsername     = "master"
    MasterUserPassword = "MasterPassword123"
  }
}

output "redshift_endpoint" {
  value = "${aws_cloudformation_stack.heavy_redshift.outputs.ClusterEndpoint}"
}