terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    },
    github = {
      source  = "integrations/github"
      version = "~> 4.10"
    }
  }
  required_version = ">= 0.14.9"
}

variable "ec2_region" {
  type        = string
  description = "The region where we want to deploy"

  validation {
    condition     = can(regex("(us(-gov)?|ap|ca|cn|eu|sa)-(central|(north|south)?(east|west)?)-\\d", var.ec2_region))
    error_message = "The image_id value must be a valid AMI id, starting with \"ami-\"."
  }
}

provider "aws" {
  profile = "default"
  region  = var.ec2_region
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
