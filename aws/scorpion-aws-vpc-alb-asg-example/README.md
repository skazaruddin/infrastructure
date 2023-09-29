
---

# Scorpion AWS Infrastructure Setup

This repository contains the infrastructure-as-code setup for the `Scorpion` AWS environment. It outlines a resilient and secure architecture for deploying applications in an environment across two Availability Zones.
Note: This not fully hardened infra setup.
## Architecture Overview

- **VPC**: Scorpion-VPC with CIDR `10.0.0.0/24`.
- **Subnets**:
  - Public Subnets: 
    - `scorpion-public1-ap-south-1a`
    - `scorpion-public2-ap-south-1b`
  - Private Subnets:
    - `scorpion-private1-ap-south-1a`
    - `scorpion-private2-ap-south-1b`
- **Internet Gateway**: Scorpion-IGW
- **NAT Gateways**: 
  - Scorpion-NATGateway-1a
  - Scorpion-NATGateway-1b
- **Route Tables**: Public and private route tables for directing traffic.
- **Security Groups**:
  - Scorpion-EC2SecurityGroup
  - Scorpion-ALBSecurityGroup
- **Application Load Balancer**: Scorpion-ALB
- **Auto Scaling Group**: Scorpion-ASG

## Additional Resources

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/index.html)
- [AWS Best Practices](https://aws.amazon.com/architecture/best-practices/)

## Contributions

Contributions to improve the infrastructure setup are welcome. Please follow the contribution guidelines provided.

## License

[Specify license type, e.g., MIT, Apache, etc.]

---

Remember to replace placeholders such as `[repository-url]` and `[repository-name]` with the actual values. This is a template, so feel free to add, modify, or remove sections as per your project's needs. Given your expertise, ensure all sections reflect the security and robustness of the architecture.
