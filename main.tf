provider "aws" {}

variable "node_public_ip" {}
variable "name" {}

data "aws_availability_zones" "available" {}

data "aws_instance" "master_node" {
  filter {
    name   = "ip-address"
    values = ["${var.node_public_ip}"]
  }
}

output "master_node_ip" {
  value = "${data.aws_instance.master_node.private_ip}"
}

data "aws_subnet" "master_node_subnet" {
  id = "${data.aws_instance.master_node.subnet_id}"
}

data "aws_subnet_ids" "cluster" {
  vpc_id = "${data.aws_subnet.master_node_subnet.vpc_id}"

  tags {
    Name = "*${var.name}-private*"
  }
}

# Create

resource "aws_efs_file_system" "main" {
  tags {
    Name     = "${var.name}"
    PublicIP = "${var.node_public_ip}"
  }
}

resource "aws_efs_mount_target" "main" {
  count           = "${min(length(data.aws_subnet_ids.cluster.ids), length(data.aws_availability_zones.available.names))}"
  file_system_id  = "${aws_efs_file_system.main.id}"
  subnet_id       = "${element(data.aws_subnet_ids.cluster.ids, count.index)}"
  security_groups = ["${aws_security_group.efs.id}"]
}

resource "aws_security_group" "efs" {
  name   = "${var.name}-efs-sg"
  vpc_id = "${data.aws_subnet.master_node_subnet.vpc_id}"
}

resource "aws_security_group_rule" "allow_nfs_2049_tcp" {
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.efs.id}"
}

resource "aws_security_group_rule" "allow_nfs_2049_udp" {
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.efs.id}"
}

resource "aws_security_group_rule" "allow_nfs_111_tcp" {
  type              = "ingress"
  from_port         = 111
  to_port           = 111
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.efs.id}"
}

resource "aws_security_group_rule" "allow_nfs_111_udp" {
  type              = "ingress"
  from_port         = 111
  to_port           = 111
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.efs.id}"
}

output "efs_security_group_id" {
  value = "${aws_security_group.efs.id}"
}

output "security_groups" {
  value = ["${data.aws_instance.master_node.vpc_security_group_ids}"]
}

output "subnets" {
  value = ["${data.aws_subnet_ids.cluster.ids}"]
}

output "dns_name" {
  value = "${aws_efs_file_system.main.dns_name}"
}

output "id" {
  value = "${aws_efs_file_system.main.id}"
}
