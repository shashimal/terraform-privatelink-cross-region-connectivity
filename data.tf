data "aws_iam_policy_document" "vpc_access_lambda_policy_document" {

  provider = aws.ap-southeast-1

  statement {
    sid = "SidVpcPermission"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
    ]
    resources = [
      "*"
    ]
  }
}