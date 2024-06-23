terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"
  s3_use_path_style           = false
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway     = "http://localhost:4566"
    apigatewayv2   = "http://localhost:4566"
    cloudformation = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    ec2            = "http://localhost:4566"
    es             = "http://localhost:4566"
    elasticache    = "http://localhost:4566"
    firehose       = "http://localhost:4566"
    iam            = "http://localhost:4566"
    kinesis        = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    rds            = "http://localhost:4566"
    redshift       = "http://localhost:4566"
    route53        = "http://localhost:4566"
    s3             = "http://s3.localhost.localstack.cloud:4566"
    secretsmanager = "http://localhost:4566"
    ses            = "http://localhost:4566"
    sns            = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    stepfunctions  = "http://localhost:4566"
    sts            = "http://localhost:4566"
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name                 = "eks-cluster-role"
  assume_role_policy   = jsonencode({
    Version            = "2012-10-17",
    Statement          = [{
      Effect           = "Allow",
      Principal        = {
        Service        = "eks.amazonaws.com"
      },
      Action           = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  role                 = aws_iam_role.eks_cluster_role.name
  policy_arn           = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy_attachment" {
  role                 = aws_iam_role.eks_cluster_role.name
  policy_arn           = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_eks_cluster" "eks_cluster" {
  name                  = "eks-cluster"
  role_arn              = aws_iam_role.eks_cluster_role.arn
  version               = "1.21"  # Replace with your desired EKS version

  vpc_config {
    subnet_ids           = ["subnet-xxxxxxxxxx", "subnet-yyyyyyyyyy"]  # Replace with your subnet IDs
    security_group_ids   = ["sg-xxxxxxxxxx"]  # Replace with your security group ID
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy_attachment,
    aws_iam_role_policy_attachment.eks_service_policy_attachment,
  ]
}

provider "kubectl" {
  config_context_cluster = aws_eks_cluster.eks_cluster.name
  load_config_file       = false
  host = "http://localhost:4566"
  validate_tls = false
}

output "kubeconfig" {
  value = provider.kubectl.kubeconfig
}
