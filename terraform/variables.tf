# AWS Region Variable
variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

# AWS Key Pair for SSH/RDP
variable "aws_key_pair" {
  description = "The AWS key pair name for SSH/RDP access"
  type        = string
}

# Instance Type
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"
}
