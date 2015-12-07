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
}

resource "template_file" "heavy_user_data" {
  template = "${file("${var.web_user_data_file}")}"

  lifecycle {
    create_before_destroy = true
  }
//  vars {
//    s3_bucket_name = "${var.s3_bucket_name}"
//    ssh_user       = "${var.ssh_user}"
//  }
}

resource "aws_launch_configuration" "heavy" {
  name_prefix     = "heavy_"
  image_id        = "${module.ubuntu_ami.ami_id}"
  instance_type   = "${var.web_instance_type}"
  security_groups = ["${aws_security_group.web_server.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.default.name}"
  user_data       = "${template_file.heavy_user_data.rendered}"

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
  load_balancers            = ["heavy"]

  tag {
    key = "Name"
    value = "heavy-web"
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

//  ingress {
//    protocol    = "tcp"
//    from_port   = 443
//    to_port     = 443
//    cidr_blocks = ["0.0.0.0/0"]
//  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_elb" "heavy" {
  name                        = "heavy"
  subnets                     = ["${split(",", terraform_remote_state.shared.output.public_subnet_ids)}"]
  security_groups             = ["${aws_security_group.elb.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  /* TODO: enable me again with certficiate
    listener {
      instance_port = 8080
      instance_protocol = "http"
      lb_port = 443
      lb_protocol = "https"
      ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
    }
  */

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 15
    timeout             = 5
    target              = "HTTP:80/"
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 60
//  connection_draining         = true
//  connection_draining_timeout = 10
}