variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "us-east-1"
}

variable "amis" {
    description = "AMIs by region"
    default = {
        us-east-1 = "ami-0db7b10d370d9341f" # Redhat
    }
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "172.20.0.0/16"
}

variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "172.20.10.0/24"
}

variable "private_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = "172.20.20.0/24"
}


variable key_name {
default     = "eqex-key"
type = string
}
