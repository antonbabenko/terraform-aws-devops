######
# VPC
######
module "vpc" {
  source               = "github.com/terraform-community-modules/tf_aws_vpc_only?ref=v1.0.0"

  name                 = "${var.environment}"
  cidr                 = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true
}


###################
# Internet gateway
###################
module "igw" {
  source = "github.com/terraform-community-modules/tf_aws_igw"

  name   = "${var.environment}"
  vpc_id = "${module.vpc.vpc_id}"
}


#################
# Public subnets
#################
module "public_subnet" {
  source = "github.com/terraform-community-modules/tf_aws_public_subnet"

  name   = "${var.environment}-public"
  cidrs  = "${var.public_subnets}"
  azs    = "${var.azs}"
  vpc_id = "${module.vpc.vpc_id}"

  igw_id = "${module.igw.igw_id}"
}
