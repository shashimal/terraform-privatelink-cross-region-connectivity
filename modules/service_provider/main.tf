locals {
  user_data = <<-EOT
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y httpd.x86_64
    sudo systemctl start httpd.service
    sudo systemctl enable httpd.service
    echo "Service is running in US-EAST-1" | sudo tee /var/www/html/index.html
  EOT
}

module "app" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">=5.7"

  name                   = "private-service"
  ami                    = var.ami
  instance_type          = var.instance_type
  monitoring             = true
  vpc_security_group_ids = [module.app_sg.security_group_id]
  subnet_id              = var.private_subnets[0]
  user_data_base64       = base64encode(local.user_data)
  user_data_replace_on_change = true
}

module "app_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = ">=5.2"

  name                = "app-service-sg"
  description         = "app-service-sg"
  vpc_id              = var.vpc_id
  ingress_cidr_blocks = [var.vpc_cidr]
  ingress_rules       = ["http-80-tcp"]
  egress_rules        = ["all-all"]
}

