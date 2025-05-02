resource "aws_security_group" "nginx_sg" {
  name        = "nginx_security_group"
  description = "Allow SSH and HTTP traffic"

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.egress_ports
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}

resource "aws_instance" "nginx_instance" {
  ami           = "ami-0c02fb55956c7d316" // Amazon Linux 2 AMI (replace with your region's AMI)
  instance_type = "t2.micro"

  security_groups = [aws_security_group.nginx_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras enable nginx1
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "nginx-instance"
  }
}