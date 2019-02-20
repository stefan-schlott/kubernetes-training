# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.240.0.0/16"
  enable_dns_hostnames = "true"

  tags {
    Name = "${var.owner}"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.default.id}"
}


# Create a subnet to launch slave private node into
resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "10.240.0.0/24"
  map_public_ip_on_launch = true
}

# A security group that allows all port access to internal vpc
resource "aws_security_group" "any_access_internal" {
  name = "cluster-security-group"
  description = "Manage all ports cluster level"
  vpc_id = "${aws_vpc.default.id}"

  # full access internally
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "${aws_vpc.default.cidr_block}"]
  }

  # full access internally
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "${aws_vpc.default.cidr_block}"]
  }
}

# web access
resource "aws_security_group" "https" {
  name = "http-security-group"
  description = "A security group for the elb"
  vpc_id = "${aws_vpc.default.id}"

  # http access from anywhere
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

# A security group for SSH only access
resource "aws_security_group" "ssh" {
  name = "ssh-security-group"
  description = "SSH only access for terraform and administrators"
  vpc_id = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "${var.admin_cidr}"]
  }
}

# allow all icmp
resource "aws_security_group" "icmp" {
  name = "ICMP-ALL"
  description = "ICMP access for Terraform and Admins"
  vpc_id = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = [
      "${var.admin_cidr}"]
  }
}


# A security group for any machine to download artifacts from the web
# without this, an agent cannot get internet access to pull containers
# This does not expose any ports locally, just external access.
resource "aws_security_group" "internet-outbound" {
  name = "internet-outbound-only-access"
  description = "Security group to control outbound internet access only."
  vpc_id = "${aws_vpc.default.id}"

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}


# Public Controller Load Balancer Access
resource "aws_elb" "public-controller-elb" {
  name = "${data.template_file.cluster-name.rendered}-pub-ctl-elb"

  subnets = [
    "${aws_subnet.private.id}"]
  security_groups = [
    "${aws_security_group.https.id}",
    "${aws_security_group.icmp.id}"]
  instances = [
    "${aws_instance.master.*.id}"]

  listener {
    lb_port = 443
    instance_port = 443
    lb_protocol = "tcp"
    instance_protocol = "tcp"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
    target = "TCP:443"
    interval = 30
  }

  lifecycle {
    ignore_changes = [
      "name"]
  }
}


resource "aws_elb" "private-controller-elb" {
  name = "${data.template_file.cluster-name.rendered}-int-ctl-elb"
  internal = "true"

  subnets = [
    "${aws_subnet.private.id}"]
  security_groups = [
    "${aws_security_group.any_access_internal.id}"]
  instances = [
    "${aws_instance.master.*.id}"]

  listener {
    lb_port = 443
    instance_port = 443
    lb_protocol = "tcp"
    instance_protocol = "tcp"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
    target = "TCP:443"
    interval = 30
  }

  lifecycle {
    ignore_changes = [
      "name"]
  }
}


