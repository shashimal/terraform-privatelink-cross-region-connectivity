module "lambda_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = ">=5.2"

  providers = {
    aws = aws.ap-southeast-1
  }

  name        = "app-service-vpc-sg"
  description = "app-service-vpc-sg"
  vpc_id      = module.service_consumer_vpc.vpc_id
  #ingress_cidr_blocks = [var.vpc_cidr]
  #ingress_rules       = ["http-80-tcp"]
  egress_rules = ["all-all"]
}

module "vpc_endpoint_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = ">=5.2"

  providers = {
    aws = aws.ap-southeast-1
  }

  name        = "vpce-sg"
  description = "VPC endpoint security group"
  vpc_id      = module.service_consumer_vpc.vpc_id
  ingress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp"
      cidr_blocks = module.service_consumer_vpc.vpc_cidr
    }
  ]
  egress_rules = ["all-all"]
}