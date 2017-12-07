output "bastion_dns" {
  value = "${aws_elb.elb_bastion.dns_name}"
}

output "sg_asg_bastion" {
  value = "${aws_security_group.asg_bastion.id}"
}

output "iam_role_bastion" {
  value = "${aws_iam_role.bastion.name}"
}
