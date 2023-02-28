# TODO: Designate a cloud provider, region, and credentials
provider "aws" {
  access_key = "AKIA352XY4J74NOEPQ7T"
  secret_key = "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"
  region = "us-east-1"
}

# TODO: provision 4 AWS t2.micro EC2 instances named Udacity T2
resource "aws_instance" "udacityt2" {
  ami = "ami-0742b4e673072066f"
  instance_type = "t2.micro"
  count = 4
  subnet_id = "subnet-072d417904d8e0633"
  tags = {
    name = "Udacity T2"
  }
}
