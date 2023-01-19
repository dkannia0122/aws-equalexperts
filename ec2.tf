resource "aws_instance" "ec2_public" {
  ami                         = "ami-028490b1640067251"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.eqex-public.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.eqex-sg.id]
  user_data       = "${file("install_jenkins.sh")}"

  tags = {
    "Name" = "${terraform.workspace}-Jenkins"
  }

  # Copies the ssh key file to home dir
  provisioner "file" {
    source      = "./${var.key_name}.pem"
    destination = "/home/ec2-user/${var.key_name}.pem"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.key_name}.pem")
      host        = self.public_ip
    }
  }
  
  //chmod key 400 on EC2 instance
  provisioner "remote-exec" {
    inline = ["chmod 400 ~/${var.key_name}.pem"]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${var.key_name}.pem")
      host        = self.public_ip
    }

  }

}


### Resource block for private instance ###

resource "aws_instance" "ec2_public" {
  ami                         = "ami-028490b1640067251"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.eqex-private.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.eqex-sg.id]
  user_data       = "${file("install_docker.sh")}"

  tags = {
    "Name" = "${terraform.workspace}-Jenkins"
  }

  # Copies the ssh key file to home dir
  provisioner "file" {
    source      = "./${var.key_name}.pem"
    destination = "/home/ec2-user/${var.key_name}.pem"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.key_name}.pem")
      host        = self.private_ip
    }
  }

  //chmod key 400 on EC2 instance
  provisioner "remote-exec" {
    inline = ["chmod 400 ~/${var.key_name}.pem"]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${var.key_name}.pem")
      host        = self.public_ip
    }

  }

}


