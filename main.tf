terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
  required_version = ">= 1.2.0"
  backend "s3" {
    bucket         = "testebucketcarol"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "dynamodb_table_name"
  }
}

provider "aws" {
  region = var.region
}

#Modulo VPC, com subnets, routers, igw,...tudo importando de um git hub externo. Somente utilizado 
#para criar o ambiente de networking
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "172.31.0.0/16"
  azs = var.azs

  # Define CIDR blocks for your private subnets
  private_subnets = ["172.31.0.0/26", "172.31.0.64/26"]

  # Define CIDR blocks for your public subnets
  public_subnets = ["172.31.0.128/26", "172.31.0.192/26"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "Development"
    Project = "my"
  }
}

#Adicionando security Groups
module "securityGroups" {
  source = "./modules/securityGroups"
  vpc_id = module.vpc.vpc_id
}

#adicionando keyPair
module "keyPair" {
  source = "./modules/keyPair"
}

#adicionando launch template
module "launchTemplate" {
  source = "./modules/launchTemplate"
  ami_id = "ami-0d86d19bb909a6c95"
  db_username = var.db_username
  db_password = var.db_password
  db_name = "my-db"
  instance_type = "t2.micro"
  instance_security_group = [module.securityGroups.ec2_sg_id]
  key_pair_name = module.keyPair.keyPair_name
  vpc_public_subnets = module.vpc.public_subnets[0]
  rds_instance_address = module.rds.rds_instance_address
}

#Adicionando autoScaling group
module "autoScaling" {
  source = "./modules/autoScaling"
  vpc_public_subnets = module.vpc.public_subnets
  target_group_arn = [module.alb.alb_target_group_arn]
  launch_template_id = module.launchTemplate.launch_template_id
  lb_target_group_arn = module.alb.alb_target_group_arn
}

#Adicionando cloudwatch

module "cloudWatch" {
  source = "./modules/cloudWatch"
  auto_scale_down_policy_arn = [module.autoScaling.auto_scale_down_policy_arn]
  auto_scale_up_policy_arn = [module.autoScaling.auto_scale_up_policy_arn]
  auto_scale_group_name = module.autoScaling.auto_scale_group_name
}

#Adicionando aplication load balancer
module "alb" {
  source = "./modules/alb"
  vpc_public_subnets = module.vpc.public_subnets
  vpc_id = module.vpc.vpc_id
  security_group_alb_id = [module.securityGroups.alb_sg_id]
}

#adicionando rds
module "rds" {
  source = "./modules/rds"
  db_name = var.db_name
  db_password = var.db_password
  db_username = var.db_username
  vpc_subnet_private = module.vpc.private_subnets
  security_group_rds_id = [module.securityGroups.rds_sg_id]
}