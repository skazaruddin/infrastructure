# Provider Configuration
provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "Scorpion-VPC" {
  cidr_block = var.vpc_cidr
  
  tags = {
    Name = "Scorpion-VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "Scorpion-IGW" {
  vpc_id = aws_vpc.Scorpion-VPC.id
  
  tags = {
    Name = var.internet_gateway
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.Scorpion-VPC.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  
  tags = {
    Name = "Scorpion-Public-Subnet"
  }
}

# Public Route Table
resource "aws_route_table" "Scorpion-PublicRouteTable" {
  vpc_id = aws_vpc.Scorpion-VPC.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Scorpion-IGW.id
  }
  
  tags = {
    Name = "Scorpion-PublicRouteTable"
  }
}

# Associate the Public Subnet with the Route Table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.Scorpion-PublicRouteTable.id
}

# Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  name        = var.ec2_security_group
  description = "Allow inbound internet traffic"
  vpc_id      = aws_vpc.Scorpion-VPC.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = var.ec2_security_group
  }
}

# EC2 Instance
resource "aws_instance" "Scorpion-EC2" {
  ami           = var.ec2_ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet.id
  user_data     = var.ec2_userdata
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  
  tags = {
    Name = "Scorpion-EC2"
  }
  
  associate_public_ip_address = true
}
