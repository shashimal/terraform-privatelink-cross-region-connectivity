locals {
  consumer_app_name        = "consumer-app"
  consumer_azs             = ["ap-southeast-1a", "ap-southeast-1b"] #Singapore
  consumer_cidr            = "30.0.0.0/16"
  consumer_private_subnets = ["30.0.0.0/19", "30.0.32.0/19"]
  consumer_public_subnets  = ["30.0.64.0/19", "30.0.96.0/19"]
}

################################################################################
# Setup service consumer VPC
################################################################################
module "service_consumer_vpc" {
  source = "./modules/vpc"

  providers = {
    aws = aws.ap-southeast-1
  }

  name               = local.consumer_app_name
  azs                = local.consumer_azs
  cidr               = local.consumer_cidr
  private_subnets    = local.consumer_private_subnets
  public_subnets     = local.consumer_public_subnets
  enable_nat_gateway = true
  single_nat_gateway = true
}

################################################################################
# Setup VPC interface endpoint to consume the endpoint service created in us-east-1
################################################################################
resource "aws_vpc_endpoint" "vpc_endpoint" {
  provider = aws.ap-southeast-1

  vpc_endpoint_type  = "Interface"
  service_name       = module.service_provider_app.endpoint_service_name #Endpoint service name
  service_region     = "us-east-1"                                       #This is the region where we created the VPC endpoint service
  vpc_id             = module.service_consumer_vpc.vpc_id
  subnet_ids         = module.service_consumer_vpc.private_subnets
  security_group_ids = [module.vpc_endpoint_sg.security_group_id]

  depends_on = [module.service_provider_app]
}

################################################################################
# Setup a Lambda function to test the VPC endpoint service
################################################################################
module "test_cross_region_private_link" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.20"

  providers = {
    aws = aws.ap-southeast-1
  }

  function_name                     = "test-cross-region-privatelink"
  description                       = "Testing private link cross region connectivity"
  source_path                       = "${path.module}/lambda_handler"
  handler                           = "index.handler"
  create_package                    = true
  runtime                           = "nodejs20.x"
  create_role                       = false
  lambda_role                       = module.iam_lambda_assumable_role.iam_role_arn
  vpc_subnet_ids                    = module.service_consumer_vpc.private_subnets
  vpc_security_group_ids            = [module.lambda_sg.security_group_id]
  timeout                           = 20
  cloudwatch_logs_retention_in_days = 7

  environment_variables = {
    VPC_ENDPOINT_DNS = aws_vpc_endpoint.vpc_endpoint.dns_entry[0]["dns_name"]
  }
}

################################################################################
# Setup Lambda execution role
################################################################################
module "iam_lambda_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.52"

  providers = {
    aws = aws.ap-southeast-1
  }

  role_name             = "test-cross-region-privatelink-role"
  trusted_role_services = ["lambda.amazonaws.com"]
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaRole",
    aws_iam_policy.vpc_access_policy.arn,
  ]

  create_role             = true
  create_instance_profile = false
  role_requires_mfa       = false
}

resource "aws_iam_policy" "vpc_access_policy" {
  provider = aws.ap-southeast-1
  policy   = data.aws_iam_policy_document.vpc_access_lambda_policy_document.json
}
