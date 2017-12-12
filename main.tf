# Bastion

data "aws_availability_zones" "all" {}

resource "aws_security_group" "asg_bastion" {
  name        = "${var.environment}-sg-asg-bastion"
  description = "Allow traffic to the bastion ASG"
  vpc_id      = "${var.vpc_id}"
  tags {
    Name = "${var.environment}-sg-asg-bastion"
  }
}

resource "aws_security_group_rule" "ingress_to_asg_bastion_from_elb_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.asg_bastion.id}"
  source_security_group_id = "${aws_security_group.elb_bastion.id}"
}

resource "aws_security_group_rule" "egress_from_elb_bastion_to_asg_bastion" {
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.elb_bastion.id}"
  source_security_group_id = "${aws_security_group.asg_bastion.id}"
}

resource "aws_security_group_rule" "egress_from_asg_bastion_to_vpc" {
  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.asg_bastion.id}"
  cidr_blocks       = ["${var.cidr_egress_from_asg_bastion}"]
}

resource "aws_security_group" "elb_bastion" {
  name        = "${var.environment}-sg-elb-bastion"
  description = "Allow traffic to the bastion ELB"
  vpc_id      = "${var.vpc_id}"
  tags {
    Name = "${var.environment}-sg-elb-bastion"
  }
}

resource "aws_security_group_rule" "ingress_to_elb_bastion_from_ops" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.elb_bastion.id}"
  cidr_blocks       = ["${var.cidr_ingress_to_elb_bastion}"]
}

resource "aws_iam_role" "bastion" {
  name               = "pro-iam_role-bastion"
  description        = "Role for the bastion"
  assume_role_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"},\"Action\":\"sts:AssumeRole\"}]}"
}

resource "aws_launch_configuration" "lc_bastion" {
  name                 = "${var.environment}-lc-bastion-${replace(timestamp(), ":", "")}"
  key_name             = "${var.ssh_key_bastion}"
  image_id             = "${var.ami_bastion}"
  instance_type        = "${var.instance_type_bastion}"
  iam_instance_profile = "${aws_iam_role.bastion.name}"
  security_groups      = ["${aws_security_group.asg_bastion.id}"]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "elb_bastion" {
  name            = "${var.environment}-elb-bastion"
  security_groups = ["${aws_security_group.elb_bastion.id}"]
  subnets         = ["${var.subnets_bastion}"]
  listener {
    lb_port           = 22
    lb_protocol       = "tcp"
    instance_port     = 22
    instance_protocol = "tcp"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "TCP:22"
  }
}

resource "aws_autoscaling_group" "asg_bastion" {
  name                 = "${var.environment}-asg-bastion"
  launch_configuration = "${aws_launch_configuration.lc_bastion.id}"
  availability_zones   = ["${data.aws_availability_zones.all.names}"]
  load_balancers       = ["${aws_elb.elb_bastion.name}"]
  health_check_type    = "ELB"
  vpc_zone_identifier  = ["${var.subnets_bastion}"]
  min_size             = "${var.asg_bastion_min_size}"
  max_size             = "${var.asg_bastion_max_size}"
  tag {
    key                 = "Name"
    value               = "${var.environment}-asg-bastion"
    propagate_at_launch = true
  }
}
