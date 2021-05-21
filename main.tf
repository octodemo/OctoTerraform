terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "eu-west-3"
}

data "aws_ami" "latest-ubuntu" {
most_recent = true
owners = ["099720109477"] # Canonical

  filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}


resource "aws_instance" "app_server" {
  ami           = "${data.aws_ami.latest-ubuntu.id}"
  instance_type = "t2.nano"

  tags = {
    Name      = "ExampleAppServerInstance"
    Owner     = "helaili"
    Terminate = "2021-06-01"
  }
}
