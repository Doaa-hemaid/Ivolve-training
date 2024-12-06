
# AWS Load Balancer Setup

**Create a Virtual Private Cloud (VPC) with 2 public subnets** 
**launch 2 EC2 instances with Nginx and Apache installed using user data**
**and set up a Load Balancer to access the 2 web servers.**

### 1. Create VPC and Subnets
1. **Create a VPC**:
    - CIDR Block: `10.0.0.0/16`
    - Name: `ivolve-vpc`
2. **Create Public Subnets**:
    - Subnet 1:
        - Name: `public-subnet-1`
        - CIDR Block: `10.0.1.0/24`
        - Availability Zone: us-east-1a
    - Subnet 2:
        - Name: `public-subnet-2`
        - CIDR Block: `10.0.2.0/24`
        - Availability Zone: us-east-1b
   
   ![chrome-capture (14)](https://github.com/user-attachments/assets/d62ec5cb-479e-4216-a9e5-17e126076e9f)

3. **Create and Attach Internet Gateway**
   1. **Create an Internet Gateway**:
      - Name: `iVolve-igw`
   2. **Attach Internet Gateway to VPC**:
      - Attach `my-internet-gateway` to `iVolve-vpc`.
   3. **Update Route Tables**
      **Add Route to the Internet Gateway**:
      - Destination: `0.0.0.0/0` - Target: `iVolve-igw`  
      ![chrome-capture (15)](https://github.com/user-attachments/assets/1b1fb2e2-b807-42a1-9945-cc2178c4742d)


### 2. Launch EC2 Instances
1. **Launch EC2 Instance 1 (Nginx)**:
    - AMI: Amazon Linux 2
    - Instance Type: t2.micro
    - Key Pair: Select or create a new key pair
    - Network: Select `ivolve-vpc`
    - Subnet: Select `public-subnet-1`
    - User Data:
      ```bash
      #!/bin/bash
      yum update -y
      systemctl start nginx
      systemctl enable nginx
      echo "Hello World from Nginx" > /usr/share/nginx/html/index.html
      ```
2. **Launch EC2 Instance 2 (Apache)**:
    - AMI: Amazon Linux 2
    - Instance Type: t2.micro
    - Key Pair: Select or create a new key pair
    - Network: Select `ivolve-vpc`
    - Subnet: Select `public-subnet-2`
    - User Data:
      ```bash
      #!/bin/bash
      yum update -y
      yum install httpd -y
      systemctl start httpd
      systemctl enable httpd
      echo "Hello World from Nginx Apache" > /var/www/html/index.html
      ```
      ![chrome-capture (18)](https://github.com/user-attachments/assets/9350c9b6-ef69-488a-ac7a-f79bb9d1e4bd)

### 3. Create and Configure Load Balancer
1. **Create Load Balancer**:
    - Type: Application Load Balancer
    - Name: `iVolve-ALB`
    - Scheme: Internet-facing
    - Network: Select `iVolve-vpc`
    - Subnets: Select both `public-subnet-1` and `public-subnet-2`
2. **Configure Security Groups**:
    - Create a ALB-sg for the Load Balancer to allow HTTP (port 80) traffic.
3. **Register Targets**:
    - Target Group: Create a new target group (HTTP)
    - Name: `iVolve-tg`
    - Protocol: HTTP
    - Port: 80
    - Targets: Add the two EC2 instances.

### 4. Access the Web Servers
- Open the Load Balancer DNS in a browser to access the web servers.

![chrome-capture (17)](https://github.com/user-attachments/assets/1ff7606b-59cf-4072-a7cf-e6c76e93d76f)
![chrome-capture (16)](https://github.com/user-attachments/assets/f1f8982a-c24d-49f8-a989-239984d33a7c)
