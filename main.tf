provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5985
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2" {
  ami           = "ami-0c02fb55956c7d316" # Windows Server 2019 AMI
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.subnet.id
  security_groups = [aws_security_group.sg.name]
  key_name      = "my-key-pair"

  tags = {
    Name = "sqlserver-ec2"
  }
}

output "ec2_public_ip" {
  value = aws_instance.ec2.public_ip
}