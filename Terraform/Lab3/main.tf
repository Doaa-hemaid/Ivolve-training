
# Data block to get the VPC ID
data "aws_vpc" "main_vpc" {
  filter {
    name   = "tag:Name"
    values = ["MyVPC"]
  }
}
# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = data.aws_vpc.main_vpc.id

  tags = {
    Name = "MyInternetGateway"
  }
}

# Create Public Subnet 1
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = data.aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a" # Replace with your desired AZ
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet1"
  }
}
# Create Route Table for Public Subnets
resource "aws_route_table" "public_rt" {
  vpc_id = data.aws_vpc.main_vpc.id

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
#Create the EC2 Instance
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux_23.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_1.id
  key_name      = "Ec2Key"
  tags = {
    Name = "ivolve-server"
  }
  lifecycle {
    create_before_destroy = true
   }

  security_groups = [aws_security_group.ec2_sg.id]
}
# Create a Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Allow SSH and HTTP traffic"
  vpc_id      =  data.aws_vpc.main_vpc.id
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
# Data block to fetch the latest Amazon Linux 
data "aws_ami" "amazon_linux_23" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}
#Create an SNS Topic
resource "aws_sns_topic" "cpu_alarm_topic" {
  name = "cpu-alarm-topic"
}
#Create an SNS Topic and Subscription
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.cpu_alarm_topic.arn
  protocol  = "email"
  endpoint  = "doaahemaid01@gmail.com" 
}
# Create a CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm" {
  alarm_name          = "High-CPU-Utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "This alarm triggers when CPU utilization exceeds 70%."
  actions_enabled     = true

  alarm_actions = [
    aws_sns_topic.cpu_alarm_topic.arn
  ]

  dimensions = {
    InstanceId = aws_instance.web_server.id
  }
}
