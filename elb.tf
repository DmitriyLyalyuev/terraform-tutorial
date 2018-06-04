resource "aws_elb" "elb" {
  name    = "terraform-elb"
  subnets = ["${aws_subnet.aws-subnet-public.id}", "${aws_subnet.aws-subnet-private.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = ["${aws_instance.web.*.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "terraform-elb"
  }
}

output "elb_instances" {
  value = ["${aws_elb.elb.instances}"]
}

output "elb_public_dns_name" {
  value = ["${aws_elb.elb.dns_name}"]
}
