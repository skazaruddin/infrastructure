# Scorpion AWS Infrastructure Setup

This repository outlines a comprehensive step-by-step guide for deploying a resilient and secure AWS environment under the name `Scorpion`. The architecture leverages multiple AWS services to ensure high availability and fault tolerance across two Availability Zones.

## Architecture Explanation

Setting up a proper VPC architecture is crucial for ensuring both the security and resilience of your applications. By distributing resources across multiple availability zones and creating private subnets, you're adding layers of protection against failures and potential security threats.
The architecture is designed to balance security and availability. While public-facing resources can communicate with the internet, more sensitive resources are isolated in private subnets, shielded from direct exposure.
i.e. In the heart of our Scorpion setup, we have EC2 instances running the NGINX server. These instances are strategically positioned within private subnets, ensuring they are shielded from direct internet access. This positioning is vital for enhancing the security of our applications by preventing unsolicited internet-based threats.

However, to ensure our NGINX servers can still communicate with the outside world for necessary operations, we employ NAT Gateways. These gateways facilitate the instances in initiating outbound internet communications, like updates or patches, while continuing to deter unsolicited inbound traffic.

For incoming connections, our architecture incorporates the Application Load Balancer (ALB) located within the public subnet. This setup ensures that our NGINX servers are accessible only via the ALB. The ALB is responsible for efficiently distributing incoming traffic among our EC2 instances, ensuring smooth application operations and high availability.

In essence, our Scorpion AWS setup prioritizes a shielded yet smoothly operational environment, where our applications are safeguarded from direct exposure but remain highly available via the ALB.

## Components Overview

1. **VPC (Virtual Private Cloud)**: The foundational private network in AWS where all resources are provisioned.
   
2. **Subnets**: Divisions within the VPC:
   - Two Public Subnets: Allow direct communication with the internet.
   - Two Private Subnets: Used for resources that shouldn't be directly exposed to the internet.

3. **Internet Gateway**: Provides a route for communication between resources in the VPC and the internet.

4. **NAT Gateways**: Allow instances in private subnets to initiate outbound traffic to the internet while preventing unsolicited inbound traffic.

5. **Route Tables**: Define rules for traffic routing within the VPC. Separate tables are set up for public and private subnets.

6. **Security Groups**: Act as virtual firewalls to control inbound and outbound traffic for resources.

7. **Application Load Balancer (ALB)**: Distributes incoming application traffic across multiple targets, ensuring efficient traffic management and high availability.

8. **Auto Scaling**: Automatically adjusts compute capacity based on traffic, ensuring optimal performance and cost.

9. **EC2 Instances**: At the core of the Scorpion architecture are EC2 instances provisioned from the Amazon Linux AMI. These instances, situated securely within private subnets, run the NGINX server. User data is utilized during the instance launch to automatically install and configure the HTTPD service. The script for user data is as follows:

## Setup Steps

### 1. Create the VPC

- **AWS Console Navigation**: Services > VPC > Your VPCs > Create VPC.
- **Name**: `Scorpion-VPC`
- **CIDR Block**: `10.0.0.0/24`

**Explanation**: The VPC provides an isolated cloud network, allowing us to control our environment's internal and external communication.

### 2. Create Subnets

Navigate to: Services > VPC > Subnets > Create subnet.

- **Public Subnet in ap-south-1a**:
  - **Name**: `scorpion-public1-ap-south-1a`
  - **CIDR**: `10.0.0.0/26`
  
- **Public Subnet in ap-south-1b**:
  - **Name**: `scorpion-public2-ap-south-1b`
  - **CIDR**: `10.0.0.64/26`
  
- **Private Subnet in ap-south-1a**:
  - **Name**: `scorpion-private1-ap-south-1a`
  - **CIDR**: `10.0.0.128/26`
  
- **Private Subnet in ap-south-1b**:
  - **Name**: `scorpion-private2-ap-south-1b`
  - **CIDR**: `10.0.0.192/26`

**Explanation**: Subnets allow segmentation of the VPC, ensuring better control over resource accessibility.

### 3. Create Internet Gateway

Navigate to: Services > VPC > Internet Gateways > Create internet gateway.

- **Name**: `Scorpion-IGW`
- Attach to `Scorpion-VPC`.

**Explanation**: This provides a connection point between our VPC and the internet.

### 4. Configure Route Tables

Navigate to: Services > VPC > Route Tables > Create route table.

- **Public Route Table**:
  - **Name**: `Scorpion-PublicRouteTable`
  - Add a route directing all traffic (`0.0.0.0/0`) to `Scorpion-IGW`.
  - Associate with `scorpion-public1-ap-south-1a` and `scorpion-public2-ap-south-1b`.

**Explanation**: Directs network traffic within the VPC based on IP protocol routes.

### 5. Create NAT Gateways

Navigate to: Services > VPC > NAT Gateways > Create NAT gateway.

- For each public subnet, create a NAT gateway and allocate an Elastic IP.
  - **Names**: `Scorpion-NATGateway-1a` and `Scorpion-NATGateway-1b`.

**Explanation**: These allow our private resources, like our EC2 instances, to request external resources without exposing themselves to inbound internet traffic.

### 6. Update Private Subnet Route Tables

Setting up correct routes for our private subnets is essential to ensure that the EC2 instances within them can securely access the internet for necessary operations like updates or external API calls. We'll be setting up these routes to go through the NAT Gateways, ensuring that while outbound traffic is possible, unsolicited inbound traffic is not permitted.

#### For `ap-south-1a`:

1. **Navigate to**: Services > VPC > Route Tables > Create route table.
   
2. **Name**: `Scorpion-PrivateRouteTable-1a`

3. **Add a Route**:
   - **Destination**: `0.0.0.0/0`
   - **Target**: `Scorpion-NATGateway-1a`

4. **Association**:
   - Associate this route table with the subnet: `scorpion-private1-ap-south-1a`.

#### For `ap-south-1b`:

1. **Navigate to**: Services > VPC > Route Tables > Create route table.
   
2. **Name**: `Scorpion-PrivateRouteTable-1b`

3. **Add a Route**:
   - **Destination**: `0.0.0.0/0`
   - **Target**: `Scorpion-NATGateway-1b`

4. **Association**:
   - Associate this route table with the subnet: `scorpion-private2-ap-south-1b`.

---

By routing the traffic from the private subnets through the NAT Gateways, we're ensuring that our instances can make outbound requests to the internet (e.g., for software updates), while still being shielded from direct inbound access.


### 7. Configure EC2 Instances with User Data

Navigate to: Services > EC2 > Launch Instance.

- Choose the `Amazon Linux AMI`.
- Set the User Data under the `Advanced Details` section:
  ```bash
  #!/bin/bash
  yum update -y
  yum install -y httpd
  systemctl start httpd
  systemctl enable httpd
  echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
  ```
- Launch the instance within `scorpion-private1-ap-south-1a` and `scorpion-private2-ap-south-1b`.

**Explanation**: Creates EC2 instances with NGINX servers, initialized and ready for traffic upon boot, securely positioned within private subnets.

### 8. Configure Security Groups

Navigate to: Services > EC2 > Security Groups > Create security group.

- **EC2 Security Group**:
  - **Name**: `Scorpion-EC2SecurityGroup`
  - Allow inbound traffic from the ALB and necessary outbound traffic.
  
- **ALB Security Group**:
  - **Name**: `Scorpion-ALBSecurityGroup`
  - Allow inbound HTTP/HTTPS traffic and necessary outbound traffic.

**Explanation**: These virtual firewalls control inbound and outbound traffic, adding an extra layer of security to our resources.

### 9. Launch Application Load Balancer

Navigate to: Services > EC2 > Load Balancers > Create Load Balancer.

- **Name**: `Scorpion-ALB`
- Configure to listen on HTTP/HTTPS.
- Choose both public subnets.
- Set the ALB's security

 group as `Scorpion-ALBSecurityGroup`.
- Configure health check settings.
- Create a target group named `Scorpion-TargetGroup` for the private subnets.

**Explanation**: The ALB routes incoming internet traffic to the internal NGINX servers, ensuring efficient distribution and high availability.

### 10. Set Up Auto Scaling

Navigate to: Services > EC2 > Auto Scaling Groups > Create Auto Scaling group.

- **Launch Configuration**:
  - **Name**: `Scorpion-LaunchConfig`
  
- **Auto Scaling Group**:
  - **Name**: `Scorpion-ASG`
  - Use `Scorpion-LaunchConfig`, target the two private subnets.
  - Assign `Scorpion-EC2SecurityGroup`.
  - Use `Scorpion-TargetGroup` for traffic routing.

**Explanation**: Ensures our NGINX servers adjust dynamically based on traffic load, maintaining efficient performance and reduced costs.

### 11. Review and Test

After setting up, ensure your `Scorpion-ALB` correctly routes traffic to the NGINX instances within the private subnets. Additionally, verify that these instances can access the internet via the NAT gateways when needed, but remain protected from unsolicited inbound traffic.

---

Remember always to adhere to AWS best practices, ensuring both security and optimal performance.
