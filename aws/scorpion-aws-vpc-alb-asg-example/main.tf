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
    Name = "Scorpion-IGW"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.Scorpion-VPC.id
  cidr_block              = var.public_subnet1_cidr
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"
  tags = {
    Name = "Scorpion-Public-Subnet-1a"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.Scorpion-VPC.id
  cidr_block              = var.public_subnet2_cidr
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1b"
  tags = {
    Name = "Scorpion-Public-Subnet-1b"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet1" {
  vpc_id     = aws_vpc.Scorpion-VPC.id
  cidr_block = var.private_subnet1_cidr
  availability_zone = "ap-south-1a"
  tags = {
    Name = "Scorpion-Private-Subnet-1a"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id     = aws_vpc.Scorpion-VPC.id
  cidr_block = var.private_subnet2_cidr
  availability_zone = "ap-south-1b"
  tags = {
    Name = "Scorpion-Private-Subnet-1b"
  }
}

# NAT Gateways and associated Elastic IPs
resource "aws_eip" "nat_eip1" {
  vpc = true
}

resource "aws_nat_gateway" "Scorpion-NATGateway-1a" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id     = aws_subnet.public_subnet1.id

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.Scorpion-IGW]
}

resource "aws_eip" "nat_eip2" {
  vpc = true
}

resource "aws_nat_gateway" "Scorpion-NATGateway-1b" {
  allocation_id = aws_eip.nat_eip2.id
  subnet_id     = aws_subnet.public_subnet2.id
}

# Public Route Table and its associations
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.Scorpion-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Scorpion-IGW.id
  }
  tags = {
    Name = "Scorpion-Public-RouteTable"
  }
}

resource "aws_route_table_association" "public_rta_subnet1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_rta_subnet2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Private Route Tables and their associations
resource "aws_route_table" "private_route_table1" {
  vpc_id = aws_vpc.Scorpion-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Scorpion-NATGateway-1a.id
  }
  tags = {
    Name = "Scorpion-Private-RouteTable-1a"
  }
}

resource "aws_route_table_association" "private_rta_subnet1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_route_table1.id
}

resource "aws_route_table" "private_route_table2" {
  vpc_id = aws_vpc.Scorpion-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Scorpion-NATGateway-1b.id
  }
  tags = {
    Name = "Scorpion-Private-RouteTable-1b"
  }
}

resource "aws_route_table_association" "private_rta_subnet2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_route_table2.id
}

# Security Groups and their rules
resource "aws_security_group" "alb_sg" {
  name        = "Scorpion-ALBSecurityGroup"
  description = "Allow inbound traffic from the ALB only"
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
}

resource "aws_security_group" "ec2_sg" {
  name        = "Scorpion-EC2SSHSecurityGroup"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.Scorpion-VPC.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # This allows SSH from anywhere. Consider restricting this.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # This allows all outbound traffic.
  }

  tags = {
    Name = "Scorpion-EC2SSHSecurityGroup"
  }
}


resource "aws_security_group" "asg_sg" {
  name        = "Scorpion-ASGSecurityGroup"
  description = "Allow inbound traffic from the ALB and necessary outbound traffic"

  vpc_id      = aws_vpc.Scorpion-VPC.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# IAM Roles, Policies, and Instance Profiles for EC2
resource "aws_iam_role" "ec2_role" {
  name = "Scorpion-EC2Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "Scorpion-EC2InstanceProfile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceConnect" # This is just an example. Adjust the policy based on your needs.
}

# Application Load Balancer and related resources
resource "aws_lb" "Scorpion-ALB" {
  name               = "Scorpion-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id, aws_security_group.ec2_sg.id]
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
  enable_deletion_protection = false
  tags = {
    Name = "Scorpion-ALB"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.Scorpion-ALB.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}

resource "aws_lb_target_group" "front_end" {
  name     = "front-end-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.Scorpion-VPC.id
  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "80"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "HTTP"
    matcher             = "200-299"
  }
}



resource "aws_autoscaling_group" "Scorpion-ASG" {
  name                      = "Scorpion-ASG"
  launch_configuration      = aws_launch_configuration.Scorpion-LaunchConfig.name
  min_size                  = 2
  desired_capacity          = 2
  max_size                  = 4
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  vpc_zone_identifier       = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
  tag {
    key                 = "Name"
    value               = "Scorpion-EC2"
    propagate_at_launch = true
  }
  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }
}

# EC2 Launch Configuration and Auto Scaling Group
resource "aws_launch_configuration" "Scorpion-LaunchConfig" {
  name          = "Scorpion-LaunchConfig"
  image_id      = var.ec2_ami
  instance_type = var.instance_type
  user_data = var.ec2_userdata
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  security_groups = [aws_security_group.asg_sg.id]
  associate_public_ip_address = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "Scorpion-ASG-attachment" {
  autoscaling_group_name = aws_autoscaling_group.Scorpion-ASG.name
  lb_target_group_arn   = aws_lb_target_group.front_end.arn
}

resource "aws_autoscaling_policy" "cpu_scale_up" {
  name                   = "cpu-scale-up-policy"
  autoscaling_group_name = aws_autoscaling_group.Scorpion-ASG.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "40"
  alarm_description   = "This metric triggers when CPU exceeds 40% for 2 minutes"
  alarm_actions       = [aws_autoscaling_policy.cpu_scale_up.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.Scorpion-ASG.name
  }
}
