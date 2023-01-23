variable "instance_name" {
  description = "Name of the instance to be created"
  default = "awsbuilder-demo"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  description = "The AMI to use"
  default = "ami-035233c9da2fabf52"
}

variable "number_of_instances" {
  description = "number of instances to be created"
  default = 2
}

variable "ami_key_pair_name" {
  default = "test"
}