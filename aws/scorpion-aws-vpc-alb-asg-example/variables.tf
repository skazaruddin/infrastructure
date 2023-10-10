variable "aws_region" {
  description = "The AWS region where resources will be created"
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/24"
}

variable "public_subnet1_cidr" {
  description = "CIDR block for the first public subnet"
  default     = "10.0.0.0/26"
}

variable "public_subnet2_cidr" {
  description = "CIDR block for the second public subnet"
  default     = "10.0.0.64/26"
}

variable "private_subnet1_cidr" {
  description = "CIDR block for the first private subnet"
  default     = "10.0.0.128/26"
}

variable "private_subnet2_cidr" {
  description = "CIDR block for the second private subnet"
  default     = "10.0.0.192/26"
}

variable "ec2_ami" {
  description = "The AMI ID for EC2 instances"
  default     = "ami-067c21fb1979f0b27"
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  default     = "t2.micro"
}

variable "ec2_userdata" {
  description = "User data to configure and launch on the EC2 instance"
  default     = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y httpd
                systemctl start httpd
                systemctl enable httpd
                echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
                EOF
}
