# AWS Configuration
variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
  default     = "ap-south-1"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/24"
}

# Public Subnet Configuration
variable "public_subnet_cidr" {
  description = "CIDR block for the first public subnet"
  type        = string
  default     = "10.0.0.0/24"
}

# EC2 Instance Configuration. You can find free tier AMI on https://ap-south-1.console.aws.amazon.com/ec2/home?region=ap-south-1#LaunchInstances: given our region is ap-south-1
variable "ec2_ami" {
  description = "The AMI ID for EC2 instances"
  type        = string
  default     = "ami-067c21fb1979f0b27"
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

# User data script for EC2 instance
variable "ec2_userdata" {
  description = "User data to configure and launch on the EC2 instance"
  type        = string
  default     = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y httpd
                systemctl start httpd
                systemctl enable httpd
                echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
                EOF
}


# Internet Gateway Configuration
variable "internet_gateway" {
  description = "Internet Gateway for the VPC"
  type        = string
  default     = "Scorpion-IGW"
}

# Security Groups
variable "ec2_security_group" {
  description = "Security group for the EC2 instances"
  type        = string
  default     = "Scorpion-EC2SecurityGroup"
}
