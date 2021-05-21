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

resource "aws_instance" "app_server" {
  ami           = "ami-0b3e57ee3b63dd76b"
  instance_type = "t2.nano"

  tags = {
    Name      = "ExampleAppServerInstance"
    Owner     = "helaili"
    Terminate = "2021-06-01"
  }
}
