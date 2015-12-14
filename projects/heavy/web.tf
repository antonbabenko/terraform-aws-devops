#############
# Ubuntu AMI
#############
module "ubuntu_ami" {
  source        = "github.com/terraform-community-modules/tf_aws_ubuntu_ami/ebs"
  instance_type = "${var.web_instance_type}"
  region        = "${var.region}"
  distribution  = "trusty"
}

resource "aws_security_group" "web_server" {
  name   = "${var.environment}_${var.name}_web_server"
  vpc_id = "${terraform_remote_state.shared.output.vpc_id}"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
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

  lifecycle {
    create_before_destroy = true
  }
}

resource "template_file" "heavy_user_data" {
  template = "${file("${var.web_user_data_file}")}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "heavy" {
  name_prefix          = "heavy_"
  image_id             = "${module.ubuntu_ami.ami_id}"
  instance_type        = "${var.web_instance_type}"
  security_groups      = ["${aws_security_group.web_server.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.default.name}"
  user_data            = "${template_file.heavy_user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "heavy" {
  name                      = "heavy"
  vpc_zone_identifier       = ["${split(",", terraform_remote_state.shared.output.public_subnet_ids)}"]
  desired_capacity          = "${var.asg_desired_capacity}"
  min_size                  = "${var.asg_min_size}"
  max_size                  = "${var.asg_max_size}"
  health_check_grace_period = 360
  health_check_type         = "ELB"
  min_elb_capacity          = 0 # 0 skips waiting for instances attached to the load balancer
  wait_for_capacity_timeout = "0m" # 0 disables wait for ASG capacity
  launch_configuration      = "${aws_launch_configuration.heavy.name}"
  load_balancers            = ["${aws_elb.heavy.name}"]

  tag {
    key                 = "Name"
    value               = "heavy-web"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group" "elb" {
  name   = "${var.environment}_${var.name}_elb"
  vpc_id = "${terraform_remote_state.shared.output.vpc_id}"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_elb" "heavy" {
  name                      = "heavy"
  subnets                   = ["${split(",", terraform_remote_state.shared.output.public_subnet_ids)}"]
  security_groups           = ["${aws_security_group.elb.id}"]
  cross_zone_load_balancing = true
  idle_timeout              = 60

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${terraform_remote_state.shared.output.iam_server_certificate_arn}"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 7
    timeout             = 5
    target              = "HTTP:80/"
  }

  lifecycle {
    create_before_destroy = true
  }

//  # Taint ELB: terraform taint -state=projects/heavy/.terraform/terraform.tfstate aws_elb.heavy
//  # Taint ASG: terraform taint -state=projects/heavy/.terraform/terraform.tfstate aws_autoscaling_group.heavy
//  provisioner "local-exec" {
//    command = <<EOF
//      POLICY_NAME=SuperSecurePolicy
//
//      aws elb create-load-balancer-policy\
//      --load-balancer-name ${aws_elb.heavy.name}\
//      --policy-name $POLICY_NAME\
//      --policy-type-name SSLNegotiationPolicyType\
//      --policy-attributes \
// AttributeName=Protocol-TLSv1,AttributeValue=true\
// AttributeName=Protocol-TLSv1.1,AttributeValue=true\
// AttributeName=Protocol-TLSv1.2,AttributeValue=true\
// AttributeName=Server-Defined-Cipher-Order,AttributeValue=true\
// AttributeName=ECDHE-ECDSA-AES128-GCM-SHA256,AttributeValue=true\
// AttributeName=ECDHE-RSA-AES128-GCM-SHA256,AttributeValue=true\
// AttributeName=ECDHE-ECDSA-AES128-SHA256,AttributeValue=true\
// AttributeName=ECDHE-RSA-AES128-SHA256,AttributeValue=true\
// AttributeName=ECDHE-ECDSA-AES128-SHA,AttributeValue=true\
// AttributeName=ECDHE-RSA-AES128-SHA,AttributeValue=true\
// AttributeName=DHE-RSA-AES128-SHA,AttributeValue=true\
// AttributeName=ECDHE-ECDSA-AES256-GCM-SHA384,AttributeValue=true\
// AttributeName=ECDHE-RSA-AES256-GCM-SHA384,AttributeValue=true\
// AttributeName=ECDHE-ECDSA-AES256-SHA384,AttributeValue=true\
// AttributeName=ECDHE-RSA-AES256-SHA384,AttributeValue=true\
// AttributeName=ECDHE-RSA-AES256-SHA,AttributeValue=true\
// AttributeName=ECDHE-ECDSA-AES256-SHA,AttributeValue=true\
// AttributeName=AES128-GCM-SHA256,AttributeValue=true\
// AttributeName=AES128-SHA256,AttributeValue=true\
// AttributeName=AES128-SHA,AttributeValue=true\
// AttributeName=AES256-GCM-SHA384,AttributeValue=true\
// AttributeName=AES256-SHA256,AttributeValue=true\
// AttributeName=AES256-SHA,AttributeValue=true\
// AttributeName=DHE-DSS-AES128-SHA,AttributeValue=true\
// AttributeName=DES-CBC3-SHA,AttributeValue=true
//
//      aws elb set-load-balancer-policies-of-listener\
//      --load-balancer-name ${aws_elb.heavy.name}\
//      --load-balancer-port 443\
//      --policy-names $POLICY_NAME
//
//EOF
//  }

}