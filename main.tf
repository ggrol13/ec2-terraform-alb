terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

# provider :: terraform 에서 aws configure 값을 참조해서 생성자를 정의함
# 여기에 직접 Accesskey를 넣을 수 있지만, 보안상의 이유로 추천하지 않음
provider "aws" {
  profile = "default"
  region  = "ap-northeast-2"
}

# resource :: 실제로 생성할 인프라 자원
resource "aws_instance" "api_server1" {
  # Amazon Linux2 ami
  ami           = "ami-035233c9da2fabf52"
  instance_type = "t2.micro"

  tags = {
    Name = "TerraformApiServer"
  }
}

resource "aws_instance" "api_server2" {
  # Amazon Linux2 ami
  ami           = "ami-035233c9da2fabf52"
  instance_type = "t2.micro"

  tags = {
    Name = "TerraformApiServer"
  }
}

resource "aws_vpc" "DEV-VPC" {
  assign_generated_ipv6_cidr_block = false
  cidr_block                       = "10.0.0.0/16"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  instance_tenancy                 = "default"
  tags = {
    Name    = "DEV-VPC"
    Service = "DEV"
  }
}