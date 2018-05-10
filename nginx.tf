/*
  Swarm Servers
*/
resource "aws_security_group" "web" {
    name = "web"
    description = "Web backends security policies."

    ingress {
        from_port   = -1
        to_port     = -1
        protocol    = "icmp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    ingress { # SSH
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    ingress { # HTTP
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    ingress { # HTTPS
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    ingress { # Private subnet
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["${var.vpc_cidr_private}"]
    }

    egress {
        from_port   = -1
        to_port     = -1
        protocol    = "icmp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    egress { ## SSH/GIT
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress { ## HTTP
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress { ## HTTPS
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress { ## DNS
        from_port   = 53
        to_port     = 53
        protocol    = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress { # Private subnet
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["${var.vpc_cidr_private}"]
    }


    vpc_id = "${aws_vpc.MyVPC.id}"

    tags {
        Name        = "Nginx",
        Description = "Security group for backends"
    }
}

data "aws_ami" "web_ami" {
  most_recent = true

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = ["nginx_*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  name_regex = "nginx_.*"
  owners     = ["${data.aws_caller_identity.current.account_id}"]
}

resource "aws_instance" "web" {
    ami                         = "${data.aws_ami.web_ami.image_id}"
    availability_zone           = "${var.private_az}"
    instance_type               = "t2.micro"
    count                       = "2"
    key_name                    = "${var.aws_key_name}"
    vpc_security_group_ids      = ["${aws_security_group.web.id}"]
    subnet_id                   = "${aws_subnet.aws-subnet-private.id}"
    source_dest_check           = false
    associate_public_ip_address = false
    monitoring                  = true
    root_block_device = {
      volume_size               = "10"
      volume_type               = "gp2"
    }

    lifecycle {
      create_before_destroy = true
    }
    tags {
        Name        = "Nginx",
        Description = "Backend server"
    }
}

output "web_ips" {
  value = ["${aws_instance.web.*.private_ip}"]
}
