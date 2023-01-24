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

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "Main"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta" {
  route_table_id = aws_route_table.rt.id
  subnet_id = aws_subnet.main.id
}

resource "aws_route_table_association" "rta2" {
  route_table_id = aws_route_table.rt.id
  subnet_id = aws_subnet.main2.id
}

resource "aws_subnet" "main2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "Main"
  }
}

resource "aws_instance" "ec2_instance" {
  ami = var.ami_id
  count = var.number_of_instances
  instance_type = var.instance_type
  key_name = var.ami_key_pair_name
  subnet_id = aws_subnet.main.id
  associate_public_ip_address = true
  security_groups = [aws_security_group.ec2_security.id]
}

resource "aws_lb_target_group" "api_group" {
  name = "apilb"
  port = 3000
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "attach-app1" {
  target_group_arn = aws_lb_target_group.api_group.arn
  target_id = aws_instance.ec2_instance[0].id
}

resource "aws_lb_target_group_attachment" "attach-app2" {
  target_group_arn = aws_lb_target_group.api_group.arn
  target_id = aws_instance.ec2_instance[1].id
}

resource "aws_lb" "api" {
  name = "api"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_security.id]
  subnets = [aws_subnet.main.id, aws_subnet.main2.id]
}

resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.api.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.api_group.arn
  }
}

resource "aws_security_group" "ec2_security" {
  name = "allow_ssh"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_security_group" "alb_security" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}