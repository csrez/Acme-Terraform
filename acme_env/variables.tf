# Create variables to be reference by module. These variables are also copied to the root terraform directory
## Values for these variables are passed in from the "*.tfvars" file in the root directory

variable "region" {
  default = "us-east-2"
}

variable "vpc_cidr_block" {}
variable "public_subnet_1_cidr" {}
variable "public_subnet_2_cidr" {}
variable "public_subnet_3_cidr" {}
variable "private_subnet_1_cidr" {}
variable "private_subnet_2_cidr" {}
variable "private_subnet_3_cidr" {}
variable "eip_association_address" {}
variable "ec2_keypair" {}
variable "ec2_instance_type" {}
#variable "amiSelection" {}
variable "accessKey" {}
variable "secretKey" {}
