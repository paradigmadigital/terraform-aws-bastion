variable "environment" {
  description = "Environment to deploy the bastion [dev|pre|pro]"
  type        = "string"
}

variable "vpc_id" {
  description = "VPC ID to deploy the bastion"
  type        = "string"
}

variable "subnets_bastion" {
  description = "List of subnets the bastion could be deployed to"
  type        = "list"
}

variable "cidr_egress_from_asg_bastion" {
  description = "List of CIDRs the bastion must have access to"
  type        = "list"
}

variable "cidr_ingress_to_elb_bastion" {
  description = "List of CIDRs that will be able to log in the bastion"
  type        = "list"
}

variable "ssh_key_bastion" {
  description = "Bastion ssh key name"
  type        = "string"
}

variable "ami_bastion" {
  description = "Bastion base AMI"
  type        = "string"
}

variable "instance_type_bastion" {
  description = "Bastion instance type"
  type        = "string"
}

variable "asg_bastion_min_size" {
  description = "Bastion minimum number of instances"
  type        = "string"
}

variable "asg_bastion_max_size" {
  description = "Bastion maximum number of instances"
  type        = "string"
}
