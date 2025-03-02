provider "aws" {
  region     = "us-east-1"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}

resource "aws_instance" "windows_vm" {
  ami                    = "ami-0893df1bd754c3189"  # Use latest Windows AMI
  instance_type          = "t3.medium"
  key_name               = "sql_server_test_kp"  # Replace with your key pair name
  vpc_security_group_ids = [aws_security_group.windows_sg.id]

  tags = {
    Name = "Windows-VM"
  }

  user_data = <<EOF
<powershell>
# Enable WinRM and allow remote connections
winrm quickconfig -q
Enable-PSRemoting -Force

# Set up WinRM to allow unencrypted connections
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'

# Create a WinRM listener on all network interfaces
winrm create winrm/config/Listener?Address=*+Transport=HTTP "@{Port="5985";Hostname="";Enabled="true"}"

# Configure Windows Firewall to allow WinRM
netsh advfirewall firewall add rule name="WinRM HTTP" dir=in action=allow protocol=TCP localport=5985
netsh advfirewall firewall add rule name="WinRM HTTPS" dir=in action=allow protocol=TCP localport=5986
</powershell>
EOF
}

resource "aws_security_group" "windows_sg" {
  name        = "windows-sg"
  description = "Allow RDP and WinRM access"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict in production!
  }

  ingress {
    from_port   = 5985
    to_port     = 5985
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict in production!
  }

  ingress {
    from_port   = 5986
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict in production!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
