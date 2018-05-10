## Proxy instance

resource "aws_security_group" "ssh_proxy" {
    name = "vpc_proxy"
    description = "Proxy scurity policies."

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.MyVPC.id}"

    tags {
        Name        = "SshProxy",
        Description = "Security group for SSH proxy to VPC"
    }
}

data "aws_ami" "ssh_proxy_ami" {
  most_recent = true

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = ["ssh-proxy_*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  name_regex = "ssh-proxy_.*"
  owners     = ["${data.aws_caller_identity.current.account_id}"]
}

resource "aws_instance" "ssh_proxy" {
    ami = "${data.aws_ami.ssh_proxy_ami.image_id}"
    availability_zone = "${var.public_az}"
    instance_type = "t2.micro"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.ssh_proxy.id}"]
    associate_public_ip_address = true
    subnet_id = "${aws_subnet.aws-subnet-public.id}"
    source_dest_check = false
    monitoring = false
    root_block_device = {
      volume_size = "10"
      volume_type = "gp2"
    }
    user_data                   = <<EOF
#!/bin/bash
echo "Server ready" > /tmp/up.log
EOF
    tags {
        Name        = "SshProxy",
        Description = "SSH Proxy to VPC"
    }
}

resource "aws_eip" "eip_proxy" {
  instance = "${aws_instance.ssh_proxy.id}"
}

output "ssh_proxy_ip" {
  value = "${aws_eip.eip_proxy.public_ip}"
}
