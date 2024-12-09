
resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name

user_data = <<-EOF
            #!/bin/bash
            yum update -y
            yum install -y nginx
            systemctl start nginx
            systemctl enable nginx
            EOF
  tags = {
    Name = var.instance_name
  }

  security_groups = [var.security_groups_id]
}

