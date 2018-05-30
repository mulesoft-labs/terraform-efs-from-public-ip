provider "aws" {}

variable "node_public_ip" {}
variable "name" {}

data "aws_instance" "master_node" {
  filter {
    name   = "ip-address"
    values = ["${var.node_public_ip}"]
  }
}

output "master_node_ip" {
  value ="${data.aws_instance.master_node.private_ip}"
}

data "aws_subnet" "master_node_subnet" {
  id = "${data.aws_instance.master_node.subnet_id}"
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_subnet.master_node_subnet.vpc_id}"
  tags {
    Name = "*private*"
  }
}

# Create

resource "aws_efs_file_system" "main" {
  tags {
    Name = "${var.name}"
    PublicIP = "${var.node_public_ip}"
  }
}

resource "aws_efs_mount_target" "main" {
  count           = "${length(data.aws_subnet_ids.all.ids)}"
  file_system_id  = "${aws_efs_file_system.main.id}"
  subnet_id       = "${element(data.aws_subnet_ids.all.ids, count.index)}"
  security_groups = ["${data.aws_instance.master_node.vpc_security_group_ids}"]
}

locals {
  cluster_security_group = "${sort(data.aws_instance.master_node.vpc_security_group_ids)}"
}

resource "aws_security_group_rule" "allow_nfs_2049_tcp" {
  type            = "ingress"
  from_port       = 2049
  to_port         = 2049
  protocol        = "tcp"
  self = true
  security_group_id = "${local.cluster_security_group[0]}"
}

resource "aws_security_group_rule" "allow_nfs_2049_udp" {
  type            = "ingress"
  from_port       = 2049
  to_port         = 2049
  protocol        = "udp"
  self = true
  security_group_id = "${local.cluster_security_group[0]}"
}

resource "aws_security_group_rule" "allow_nfs_111_tcp" {
  type            = "ingress"
  from_port       = 111
  to_port         = 111
  protocol        = "tcp"
  self = true
  security_group_id = "${local.cluster_security_group[0]}"
}

resource "aws_security_group_rule" "allow_nfs_111_udp" {
  type            = "ingress"
  from_port       = 111
  to_port         = 111
  protocol        = "udp"
  self = true
  security_group_id = "${local.cluster_security_group[0]}"
}

output "nfs_security_groups" {
  value = "${local.cluster_security_group[0]}"
}

output "security_groups" {
  value = ["${data.aws_instance.master_node.vpc_security_group_ids}"]
}

output "subnets" {
  value = ["${data.aws_subnet_ids.all.ids}"]
}

output "dns_name" {
  value = "${aws_efs_file_system.main.dns_name}"
}

output "id" {
  value = "${aws_efs_file_system.main.id}"
}
