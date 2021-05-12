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
  region  = "us-west-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0d5eff06f840b45e9"
  instance_type = "t2.micro"

  tags = {
    Name      = "ExampleAppServerInstance"
    Owner     = "helaili"
    Terminate = "2021-06-01"
  }
}
