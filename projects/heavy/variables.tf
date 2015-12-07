# AWS
variable "region" {
}
variable "aws_access_key" {
}
variable "aws_secret_key" {
}

variable "environment" {
}
variable "name" {
}

# Web app
variable "web_instance_type" {
  default = "t2.micro"
}
variable "web_user_data_file" {
  default = "heavy_web_user_data.sh"
}
variable "asg_desired_capacity" {
}
variable "asg_min_size" {
}
variable "asg_max_size" {
}