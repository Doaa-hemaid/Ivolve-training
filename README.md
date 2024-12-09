# Terraform Modules

## Objective
- Create a VPC with 2 public subnets in `main.tf` file.
- Create an EC2 module to create 1 EC2 instance with Nginx installed on it using user data.
- Use this module to deploy 1 EC2 instance in each subnet.

## Steps

### 1. Create VPC with 2 Public Subnets

#### main.tf
1. **Create a VPC**:
   ```hcl
    resource "aws_vpc" "main_vpc" {
        cidr_block = "10.0.0.0/16"
        tags = {
           Name = "MyVPC"
        }
     }
   ```
    - Resource Type: aws_vpc
    - CIDR Block: `10.0.0.0/16`
    - Name: `MyVPC`
3. **Create Subnets**:
   ```hcl
    resource "aws_subnet" "public_subnet_1" {
       vpc_id            = aws_vpc.main_vpc.id
       cidr_block        = "10.0.1.0/24"
       availability_zone = "us-east-1a" # Replace with your desired AZ
       map_public_ip_on_launch = true

       tags = {
            Name = "PublicSubnet1"
       }
    }

   ```
    - Resource Type: aws_subnet
    - Name: `public-subnet-1`
    - CIDR Block: `10.0.1.0/24`
    - Availability Zone: us-east-1a
    - Public IPs on Launch: true
      
   **The configuration for public-subnet-2 follows the same steps as those defined for public-subnet-1.**   
      - Name: `public-subnet-2`  
      - CIDR Block: `10.0.2.0/24`  
      - Availability Zone: us-east-1b  
4. **Create and Attach Internet Gateway**
```hcl
  resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main_vpc.id

    tags = {
       Name = "MyInternetGateway"
    }
  }
```
- Resource Type: aws_internet_gateway
- VPC ID: Ties the gateway to `MyVPC`.
- Name: `MyInternetGateway` .
5. **Create Route Table for Public Subnets**
  ```hcl
     resource "aws_route_table" "public_rt" {
       vpc_id = aws_vpc.main_vpc.id

        route {
         cidr_block = "0.0.0.0/0"
         gateway_id = aws_internet_gateway.igw.id
       }

       tags = {
         Name = "PublicRouteTable"
       }
     }
  ```
- Resource Type: aws_route_table
- CIDR Block: "0.0.0.0/0" for all traffic to be routed to the internet gateway.
- Gateway ID: "MyInternetGateway".
- Name: `PublicRouteTable`.
5. **Associate Route Table with Subnets**
```hcl
  resource "aws_route_table_association" "public_assoc_1" {
     subnet_id      = aws_subnet.public_subnet_1.id
     route_table_id = aws_route_table.public_rt.id
  }
 
```
 - Resource Type: aws_route_table_association
 - Subnet ID: public_subnet1 | public_subnet1.
 - Route Table ID: PublicRouteTable ID .
 
 ![2024-12-09 16_59_58-VPC _ us-east-1](https://github.com/user-attachments/assets/d7eea6fa-0b85-45f3-b12d-54a10850c816)

### 2.Create EC2 Module
        modules/   
        └── Ec2/    
              ├── main.tf   
              ├── variables.tf    
              └── outputs.tf   
#### - Main Configuration (`main.tf`)
```hcl

resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name

user_data = <<-EOF
            #!/bin/bash
            yum update -y
            yum install -y nginx
            systemctl start nginx
            systemctl enable nginx
            EOF
  tags = {
    Name = var.instance_name
  }

  security_groups = [var.security_groups_id]
}
```
##### Variables 
- `ami_id`: The AMI ID to use for the instance.
- `instance_type`: The type of instance to create. 
- `subnet_id`: The subnet ID where the instance will be deployed.
- `key_name`: The name of the key pair to use for SSH access.
- `instance_name`: The name to tag the instance with.
- `security_groups_id`: The ID of the security group to associate with the instance.
#### Create 2 EC2 instance using EC2 module
```hcl
module "ec2_instance1" {
  source           = "./modules/Ec2"
  ami_id           = data.aws_ami.amazon_linux_23.id 
  instance_type    = "t2.micro"
  subnet_id        = aws_subnet.public_subnet_1.id       
  key_name         = "Ec2Key"        
  instance_name    = "nginx-web-server1"
  security_groups_id = aws_security_group.ec2_sg.id  
}
```
![2024-12-09 16_58_50-Instances _ EC2 _ us-east-1](https://github.com/user-attachments/assets/db7a9ad8-88df-4bd0-ac24-b6c1701d597d)

#### Initialization and Deployment
```bash
terraform init
terraform plan
terraform apply
```
![2024-12-09 19_51_55-● main tf - Terraform - Visual Studio Code](https://github.com/user-attachments/assets/f5a6a278-67b2-4081-bcb8-0ed0b8c6d80a)

![2024-12-09 16_55_55-Welcome to nginx!](https://github.com/user-attachments/assets/05209326-2587-48a1-98fa-b7d6ba2c1764)

![2024-12-09 16_56_51-Welcome to nginx!](https://github.com/user-attachments/assets/f5aa2c66-7edc-499b-88b0-d9cc9c86be4a)

