variable "vpc_id" {
  description = "CPC Id"
  type        = string
}
variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "private_subnets" {
  description = "The private subnets"
  type        = list(string)
}

variable "ami" {
  description = "The AMI ID to use for the instance profile."
  type        = string
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t2.micro"
}