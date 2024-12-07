# Launching an EC2 Instance
 creating a secure VPC network architecture with public and private subnets, deploying EC2 instances, 
 and using a bastion host for SSH access to private resources.
### 1. Create VPC and Subnets
1. **Create a VPC**:
    - CIDR Block: `10.0.0.0/16`
    - Name: `ivolve-vpc`
2. **Create Subnets**:
    - Public-subnet:
        - Name: `public-subnet`
        - CIDR Block: `10.0.1.0/24`
        - Availability Zone: us-east-1a
    - Private-subnet:
        - Name: `public-subnet-2`
        - CIDR Block: `10.0.2.0/24`
        - Availability Zone: us-east-1b
     
3. **Create and Attach Internet Gateway**
   1. **Create an Internet Gateway**:
      - Name: `iVolve-igw`
   2. **Attach Internet Gateway to VPC**:
      - Attach `my-internet-gateway` to `iVolve-vpc`.
   3. **Update Route Tables**
      **Add Route to the Internet Gateway**:
      - Destination: `0.0.0.0/0` - Target: `iVolve-igw`
        
     ![chrome-capture (15)](https://github.com/user-attachments/assets/1b1fb2e2-b807-42a1-9945-cc2178c4742d)

   
![chrome-capture (34)](https://github.com/user-attachments/assets/374b795e-2d06-4a72-bd1a-f4198c5733ce)

### 4. **Launch EC2 Instances**
- Launch two EC2 instances:
  1. **Public EC2 Instance**
     - Select an AMI (e.g., Amazon Linux 2).
     - Launch in the public subnet.
     - Assign a public IP address.
     - Use an SSH key pair for authentication.
  2. **Private EC2 Instance**
     - Select the same AMI.
     - Launch in the private subnet.
     - No public IP address.
    
  ![chrome-capture (31)](https://github.com/user-attachments/assets/0c23097b-2661-44a3-806f-a81c224c206b)

5. **Test the Setup**
   1. Transfer the SSH Key to the Public EC2 Instance
   ```bash
     scp -i Ec2Key.pem Ec2Key.pem ec2-user@52.91.68.237:/home/ec2-user/
    ```
   ![2024-12-07 21_05_40-doaa-hemaid@ubuntu_ ~](https://github.com/user-attachments/assets/56f76a82-34e5-4334-968a-329d7dec5c52)

   2. SSH into the Public EC2 Instance using local machine
    ```bash
     ssh -i "Ec2Key.pem" ec2-user@52.91.68.237 
    ```
   3. From the public EC2 instance, SSH into the Private EC2 Instance
    ```bash
     ssh -i "Ec2Key.pem" ec2-user@10.0.2.169
    ```
    ![2024-12-07 21_06_32-ec2-user@ip-10-0-2-169_~](https://github.com/user-attachments/assets/50a07116-73bf-4215-a2da-4d19844f9b83)
