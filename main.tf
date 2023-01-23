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

resource "aws_instance" "ec2_instance" {
  ami = var.ami_id
  count = var.number_of_instances
  instance_type = var.instance_type
  key_name = var.ami_key_pair_name
}
