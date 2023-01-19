resource "aws_vpc" "eqex-vpc" {
    cidr_block       = "172.20.0.0/16"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    instance_tenancy = "default"
    tags = {
      Name = "${terraform.workspace}-vpc"
    }
  }

resource "aws_subnet" "eqex-public" {
     vpc_id     = aws_vpc.eqex-vpc.id
    cidr_block = "172.20.10.0/24"
    map_public_ip_on_launch = "true"
    tags = {
      Name = "${terraform.workspace}-public-subnet"
    }
  }

resource "aws_subnet" "eqex-private" {
     vpc_id     = aws_vpc.eqex-vpc.id
    cidr_block = "171.20.20.0/24"
    tags = {
      Name = "${terraform.workspace}-private-subnet"
    }
  }

resource "aws_internet_gateway" "eqex-igw" {
      vpc_id = aws_vpc.eqex-vpc.id

      tags = {
        Name = "${terraform.workspace}-igw"
      }
    }

resource "aws_eip" "eqex-eip" {
    vpc      = true

    tags = {
      Name = "${terraform.workspace}-eip"
    }
  }

resource "aws_nat_gateway" "eqex-ngw" {
    allocation_id = aws_eip.eqex-eip.id
    subnet_id     = aws_subnet.eqex-private.id

    tags = {
      Name = "${terraform.workspace}-ngw"
    }
  }

resource "aws_route_table" "eqex-rt-pub" {
  vpc_id = aws_vpc.eqex-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eqex-igw.id
  }

  tags = {
    Name = "${terraform.workspace}-rt-pub"
  }
}

resource "aws_route_table" "eqex-rt-private" {
    vpc_id = aws_vpc.eqex-vpc.id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.eqex-ngw.id
    }

    tags = {
      Name = "${terraform.workspace}-rt-private"
    }
}

resource "aws_route_table_association" "eqex-rta-pub" {
    subnet_id      = aws_subnet.eqex-public.id
    route_table_id = aws_route_table.eqex-rt-pub.id
}

resource "aws_route_table_association" "eqex-rta-private" {
    subnet_id      = aws_subnet.eqex-private.id
    route_table_id = aws_route_table.eqex-rt-private.id
}

resource "aws_security_group" "eqex-sg" {
    name        = "eqex-securtiy-group"
    description = "Allow terraform-securtiy-group inbound traffic"
    vpc_id      = aws_vpc.eqex-vpc.id

    ingress {
      description      = "TLS from VPC"
        from_port   = 8080
        to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = [aws_vpc.eqex-vpc.cidr_block]
  }
   
    ingress {
      description      = "TLS from VPC"
          from_port        = 22
          to_port          = 22
      protocol         = "ssh"
      cidr_blocks      = [aws_vpc.eqex-vpc.cidr_block]
    }
   
    egress {
          from_port        = 0
          to_port          = 0  
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }
   
    tags = {
      Name = "tf-sg"
    }
}

output "vpc" {
  value = aws_vpc.eqex-vpc.id
}

output "sg_pub_id" {
  value = aws_security_group.eqex-sg.id
}

