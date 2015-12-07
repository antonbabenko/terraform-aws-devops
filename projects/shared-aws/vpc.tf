######
# VPC
######
module "vpc" {
  source = "github.com/comoyo/terraform-modules//aws/network/vpc?ref=master"

  name   = "${var.environment}"
  cidr   = "${var.vpc_cidr}"
}


###################
# Internet gateway
###################
module "igw" {
  source = "github.com/comoyo/terraform-modules//aws/network/igw?ref=master"

  name   = "${var.environment}"
  vpc_id = "${module.vpc.vpc_id}"
}


#################
# Public subnets
#################
module "public_subnet" {
  source = "github.com/comoyo/terraform-modules//aws/network/public_subnet?ref=master"

  name   = "${var.environment}-public"
  cidrs  = "${var.public_subnets}"
  azs    = "${var.azs}"
  vpc_id = "${module.vpc.vpc_id}"

  igw_id = "${module.igw.igw_id}"
}
