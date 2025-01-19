module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = ">= 9.13"

  name               = "app-service-nlb"
  load_balancer_type = "network"
  vpc_id             = var.vpc_id
  subnets            = var.private_subnets
  internal           = true

  enable_deletion_protection = false

  enforce_security_group_inbound_rules_on_private_link_traffic = "off"
  create_security_group                                        = false
  security_groups                                              = [module.app_sg.security_group_id]

  listeners = {
    ex-one = {
      port     = 80
      protocol = "TCP"
      forward = {
        target_group_key = "ex-target-one"
      }
    }
  }

  target_groups = {
    ex-target-one = {
      name_prefix = "sp-"
      protocol    = "TCP"
      port        = 80
      target_type = "instance"
      target_id   = module.app.id

      health_check = {
        enabled             = true
        interval            = 6
        path                = "/"
        port                = "80"
        healthy_threshold   = 2
        unhealthy_threshold = 3
        timeout             = 6
      }
    }
  }
}