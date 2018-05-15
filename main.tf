provider "aws" {}

variable "master_node_public_ip" {}
variable "name" {}

data "aws_instance" "master_node" {
  filter {
    name   = "ip-address"
    values = ["${var.master_node_public_ip}"]
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
    PublicIP = "${var.master_node_public_ip}"
  }
}

resource "aws_efs_mount_target" "main" {
  count           = "${length(data.aws_subnet_ids.all.ids)}"
  file_system_id  = "${aws_efs_file_system.main.id}"
  subnet_id       = "${element(data.aws_subnet_ids.all.ids, count.index)}"
  security_groups = ["${data.aws_instance.master_node.vpc_security_group_ids}"]
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
