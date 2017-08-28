
# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  count = "${length(var.list_of_sites)}"
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.${count.index + 1}.0/24"
  map_public_ip_on_launch = true
}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb" {
  count = "${length(var.list_of_sites)}"

  name        = "SITE-${count.index + 1} ELB"
  description = "Security group for SITE-${count.index + 1} ELB"
  vpc_id      = "${aws_vpc.default.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  count = "${length(var.list_of_sites)}"
  name        = "SITE-${count.index + 1}"
  description = "Security group for SITE-${count.index + 1}"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # NFS access
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "web" {
  count = "${length(var.list_of_sites)}"
  name = "site-${count.index + 1}-elb"

  subnets         = ["${element(aws_subnet.default.*.id, count.index)}"]
  security_groups = ["${element(aws_security_group.elb.*.id, count.index)}"]
  instances = ["${compact(slice(split(",", join(",",aws_instance.SITE.*.id)), count.index * var.nodes_per_site, (count.index * var.nodes_per_site) + var.nodes_per_site))}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

