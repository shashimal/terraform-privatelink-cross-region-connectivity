resource "aws_vpc_endpoint_service" "endpoint_service" {
  network_load_balancer_arns = [module.nlb.arn]
  acceptance_required        = false
  supported_regions          = ["ap-southeast-1", "us-east-1"]
}

