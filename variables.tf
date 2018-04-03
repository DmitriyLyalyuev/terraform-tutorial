variable "aws_region" {}

## VPC
variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "172.20.0.0/16"
}

variable "vpc_cidr_public" {
    description = "CIDR for the Public subnet"
    default = "172.20.0.0/24"
}

variable "vpc_cidr_private" {
    description = "CIDR for the Private subnet"
    default = "172.20.1.0/24"
}
