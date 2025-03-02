# AWS Provider
provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Subnet
resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Security Group for EC2
resource "aws_security_group" "sql_sg" {
  vpc_id = aws_vpc.main_vpc.id

  # Allow RDP access
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow WinRM for Ansible
  ingress {
    from_port   = 5985
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SQL Server access
  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance for SQL Server
resource "aws_instance" "sql_server" {
  ami           = "ami-0c02fb55956c7d316"  # Windows Server 2019 AMI
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.main_subnet.id
  security_groups = [aws_security_group.sql_sg.name]
  key_name      = var.aws_key_pair  # SSH Key for RDP Access

  # User Data Script to Enable WinRM for Ansible
  user_data = <<EOF
<powershell>
winrm quickconfig -q
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
net stop winrm
sc.exe config winrm start=auto
net start winrm
</powershell>
EOF

  tags = {
    Name = "SQL-Server-EC2"
  }
}

# Output the EC2 Public IP
output "ec2_public_ip" {
  value = aws_instance.sql_server.public_ip
}
