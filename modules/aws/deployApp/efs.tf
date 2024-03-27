# default performance_mode is generalPurpose
resource "aws_efs_file_system" "this" {
  creation_token   = "${var.global_name}-${var.app_name}-model"
  performance_mode = "maxIO"
  encrypted        = true
  kms_key_id       = aws_kms_key.this.arn
  tags             = {
    Name   = "${var.global_name}-${var.app_name}"
    backup = true
  }
}

resource "aws_efs_mount_target" "this" {
  for_each        = toset(var.private_subnets)
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.key
  security_groups = [aws_security_group.sg_efs.id]
}

resource "aws_security_group" "sg_efs" {
  description = "${var.global_name}-${var.app_name}-efs"
  vpc_id      = var.vpc_id
  name        = "${var.global_name}-${var.app_name}-efs"
  tags        = {
    Name = "${var.global_name}-${var.app_name}-efs"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "sg_efs_ingress_vpc" {
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  description       = "EFS private subnets"
  cidr_blocks       = var.private_cidrs
  security_group_id = aws_security_group.sg_efs.id
}

resource "aws_security_group_rule" "sf_efs_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_efs.id
}