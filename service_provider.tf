locals {

  #Service Provider
  svc_app_name        = "private-app-service"
  svc_azs             = ["us-east-1a", "us-east-1b"]
  svc_cidr            = "20.0.0.0/16"
  svc_private_subnets = ["20.0.0.0/19", "20.0.32.0/19"]
  svc_public_subnets  = ["20.0.64.0/19", "20.0.96.0/19"]

  #EC2
  ami           = "ami-01816d07b1128cd2d"
  instance_type = "t2.micro"
}

################################################################################
# Setup service provider VPC
################################################################################
module "service_provider_vpc" {
  source = "./modules/vpc"

  providers = {
    aws = aws.us-east-1
  }

  name               = local.svc_app_name
  azs                = local.svc_azs
  cidr               = local.svc_cidr
  private_subnets    = local.svc_private_subnets
  public_subnets     = local.svc_public_subnets
  enable_nat_gateway = true
  single_nat_gateway = true
}

module "service_provider_app" {
  source = "./modules/service_provider"

  providers = {
    aws = aws.us-east-1
  }

  ami           = local.ami
  instance_type = local.instance_type

  vpc_cidr        = module.service_provider_vpc.vpc_cidr
  vpc_id          = module.service_provider_vpc.vpc_id
  private_subnets = module.service_provider_vpc.private_subnets
}