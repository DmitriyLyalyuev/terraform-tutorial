resource "aws_vpc" "MyVPC" {
    cidr_block           = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
        Name        = "TF:VPC",
        Owner       = "owner@example.com",
        Environment = "Production",
        Description = "Custom VPC"
    }
}

## Public subnet

resource "aws_subnet" "aws-subnet-public" {
  vpc_id            = "${aws_vpc.MyVPC.id}"
  cidr_block        = "${var.vpc_cidr_public}"
  availability_zone = "${var.aws_region}a"
  tags = {
    Name            = "Public subnet"
  }
}

## Private subnet

resource "aws_subnet" "aws-subnet-private" {
  vpc_id            = "${aws_vpc.MyVPC.id}"
  cidr_block        = "${var.vpc_cidr_private}"
  availability_zone = "${var.aws_region}b"
  tags = {
    Name            = "Private subnet"
  }
}


## Internet gateway
resource "aws_internet_gateway" "gateway" {
    vpc_id = "${aws_vpc.MyVPC.id}"
}


## Elastic IP for NAT GW
resource "aws_eip" "eip" {
  vpc        = true
  depends_on = ["aws_internet_gateway.gateway"]
}


## NAT gateway
resource "aws_nat_gateway" "gateway" {
    allocation_id = "${aws_eip.eip.id}"
    subnet_id     = "${aws_subnet.aws-subnet-public.id}"
    depends_on    = ["aws_internet_gateway.gateway"]
}

output "NAT_GW_IP" {
  value = "${aws_eip.eip.public_ip}"
}
