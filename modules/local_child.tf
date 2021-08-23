terraform {
}

variable "latest-ubuntu-id" {
  type        = string
  description = "The AMI to use"
}

resource "aws_instance" "app_server" {
  ami           = var.latest-ubuntu-id
  instance_type = "t2.nano"

  tags = {
    Name      = "ExampleAppServerInstanceFromLocalChildModule"
    Owner     = "helaili"
    Terminate = "2021-06-01"
  }
}
