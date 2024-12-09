# Create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  tags = {
    Name = "MyVPC"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "MyInternetGateway"
  }
}

# Create Public Subnet 1
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a" # Replace with your desired AZ
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet1"
  }
}

# Create Public Subnet 2
resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b" # Replace with your desired AZ
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet2"
  }
}

# Create Route Table for Public Subnets
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

# Associate Route Table with Public Subnet 1
resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

# Associate Route Table with Public Subnet 2
resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# Data block to fetch the latest Amazon Linux 
data "aws_ami" "amazon_linux_23" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

module "ec2_instance1" {
  source           = "./modules/Ec2"
  ami_id           = data.aws_ami.amazon_linux_23.id 
  instance_type    = "t2.micro"
  subnet_id        = aws_subnet.public_subnet_1.id       
  key_name         = "Ec2Key"        
  instance_name    = "nginx-web-server1"
  security_groups_id = aws_security_group.ec2_sg.id  
}
module "ec2_instance2" {
  source           = "./modules/Ec2"
  ami_id           = data.aws_ami.amazon_linux_23.id
  instance_type    = "t2.micro"
  subnet_id        = aws_subnet.public_subnet_2.id     
  key_name         = "Ec2Key"         
  instance_name    = "nginx-web-server2"
  security_groups_id = aws_security_group.ec2_sg.id   
}
# Create a Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Allow SSH and HTTP traffic"
  vpc_id      =  aws_vpc.main_vpc.id
  # Ingress Rules (Allow Incoming Traffic)
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allows SSH from anywhere. Restrict to your IP for security.
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allows HTTP from anywhere
  }

  # Egress Rules (Allow Outgoing Traffic)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2-Security-Group"
  }
}