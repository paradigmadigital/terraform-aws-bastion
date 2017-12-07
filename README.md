# aws-bastion

Terraform module to deploy a bastion in AWS

It will:
* Create the required security groups
* Create a launch configuration
* Create an auto scaling group
* Create an elastic load balancer

## Requirements

None

## Module Variables

* `environment`                  : Environment to deploy the bastion [dev|pre|pro]
* `vpc_id`                       : VPC ID to deploy the bastion
* `subnets_bastion`              : List of subnets the bastion could be deployed to
* `cidr_egress_from_asg_bastion` : List of CIDRs the bastion must have access to
* `cidr_ingress_to_elb_bastion`  : List of CIDRs that will be able to log in the bastion
* `ssh_key_bastion`              : Bastion ssh key name
* `ami_bastion`                  : Bastion base AMI
* `instance_type_bastion`        : Bastion instance type
* `asg_bastion_min_size`         : Bastion minimum number of instances
* `asg_bastion_max_size`         : Bastion maximum number of instances

## Outputs
* `bastion_dns`: AWS bastion ELB url
* `sg_asg_bastion`: ID of the security group associated to the bastion
* `iam_role_bastion`: Name of the IAM role associated to the bastion

## Example use

```terraform
module "bastion" {
  source = "../../../modules/services/bastion"
  environment = "pro"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  cidr_egress_from_asg_bastion = ["${data.terraform_remote_state.vpc.vpc_cidr_block}"]
  cidr_ingress_to_elb_bastion = "${data.terraform_remote_state.vpc.cidr_ops}"
  ssh_key_bastion = "PRO-KP-BASTION"
  ami_bastion = "ami-d97da3a0"
  instance_type_bastion = "t2.nano"
  subnets_bastion = ["${data.terraform_remote_state.vpc.subnet_public_id}"]
  asg_bastion_min_size = 1
  asg_bastion_max_size = 1
}
```

## License

GPLv2

## Author Information
jamatute (jamatute@paradigmadigital.com)
