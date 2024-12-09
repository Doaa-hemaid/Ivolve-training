# Remote Backend and Lifecycle Rules
- **Remote Backend**: Store the Terraform state file remotely in an AWS S3 bucket with DynamoDB for state locking.
- **Lifecycle Rules**: Use the `create_before_destroy` lifecycle on an EC2 instance to ensure zero downtime during resource updates.
- **CloudWatch Alarm**: Monitor EC2 instance CPU utilization and trigger an email notification if usage exceeds 70%.
## Steps

### **1. Remote Backend Configuration**
   -  Create an S3 bucket named ivolve-terraform-state
   -  Create a DynamoDB table named terraform_state with a primary key LockID.
   -  Terraform Backend Configuration
```hcl
terraform {
  backend "s3" {
    bucket         = "ivolve-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform_state"
  }
}
 ```

 ![2024-12-09 22_37_38-ivolve-terraform-state - S3 bucket _ S3 _ us-east-1](https://github.com/user-attachments/assets/cb7cff80-f271-4b2f-ab7d-15625c48564a)

### **2. Main Configuration (main.tf)**

 1. **VPC Lookup**: Retrieves an existing VPC by its name.
 2.  **Internet Gateway**: Creates an Internet Gateway and attaches it to the VPC.
 3.  **Public Subnet**: Creates a public subnet within the VPC.
 4.   **Route Table and Association**: Configures a route table for public subnets and associates it with the subnet.
    
![2024-12-09 23_13_30-VPC _ us-east-1](https://github.com/user-attachments/assets/c3286b1a-8555-44d2-bd2d-8f7eeed47ff0)
 
 #### Create EC2 Instance with Lifecycle Rule
 ```hcl
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
 ```
**- AMI: Fetches the latest Amazon Linux 2023 image using a data block (data.aws_ami.amazon_linux_23.id).**     
**- Subnet: Deploys the instance in a public subnet (aws_subnet.public_subnet_1.id) with internet access.**    
**- Lifecycle Rule: The create_before_destroy rule ensures no downtime during updates by creating the replacement instance before destroying the existing one.**   

#### AWS SNS and CloudWatch Configuration
 1. Sets up an SNS topic to handle notifications.
```hcl
resource "aws_sns_topic" "cpu_alarm_topic" {
  name = "cpu-alarm-topic"
}
```
2. Subscribes to the SNS topic with an email endpoint to receive notifications.
```hcl
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.cpu_alarm_topic.arn
  protocol  = "email"
  endpoint  = "doaahemaid01@gmail.com" 
}
```
![2024-12-09 22_44_22-cpu-alarm-topic _ Topics _ Simple Notification Service _ us-east-1](https://github.com/user-attachments/assets/a0200f52-fb17-44e8-be91-aade21d2f151)

3. Monitors the CPU utilization of an EC2 instance and triggers notifications when CPU utilization exceeds threshold (70%).
```hcl
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

  alarm_actions =[aws_sns_topic.cpu_alarm_topic.arn]

  dimensions = {
    InstanceId = aws_instance.web_server.id
  }
}
```
![chrome-capture (59)](https://github.com/user-attachments/assets/cab146cd-08fd-4221-aaa1-5d4f8bd4cacf)

#### Initialization and Deployment
```bash
terraform init
terraform plan
terraform apply
```
![2024-12-09 23_38_04-main tf - Terraform - Visual Studio Code](https://github.com/user-attachments/assets/65183484-15b4-42ab-8db6-feb6c4623f27)

