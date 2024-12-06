# AWS CLI: S3 Bucket Management

## Prerequisites

- **AWS CLI Installed**: Ensure the AWS CLI is installed.
- **AWS Credentials Configured**: Set up your AWS credentials using:
  ```bash
  aws configure
  ```
  # Steps
  
  ## 1. Create an S3 Bucket
   ```bash
   aws s3api create-bucket ivolve-bucket10 --region  us-east-1
   ```
  ## 2. Configure Permissions
  **1. Allow Public Access to the bucket**  
  **2. Grant Permissions to the logging service principal**
   ```json
   {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::ivolve-bucket10/*"
        },
        {
            "Sid": "S3ServerAccessLogsPolicy",
            "Effect": "Allow",
            "Principal": {
                "Service": "logging.s3.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::ivolve-bucket10/*",
            "Condition": {
                "StringEquals": {
                    "aws:SourceAccount": "676206945743"
                },
                "ArnLike": {
                    "aws:SourceArn": "arn:aws:s3:::ivolve-bucket10"
                }
            }
        }
    ]
    }
   ```
   **Apply the policy**
  
  ```bash
     aws s3api put-bucket-policy --bucket ivolve-bucket10 --policy policy.json
   ```
  ## 3. Enable Versioning
   ```bash
    aws s3api put-bucket-versioning --bucket ivolve-bucket10  --versioning-configuration Status=Enabled
   ```
   ![chrome-capture (23)](https://github.com/user-attachments/assets/2e67501f-66ed-4166-aa46-79e5be88c729)

  ## 4. Enable Logging
     ```bash
     aws s3api put-bucket-logging --bucket ivolve-bucket10 --bucket-logging-status '{
  "LoggingEnabled": {
    "TargetBucket": "ivolve-bucket10",
    "TargetPrefix": "logs/"
   }
  }'

   ```
     ![chrome-capture (28)](https://github.com/user-attachments/assets/f2360e43-539f-4265-b52c-34dc2c755468)
     ![chrome-capture (30)](https://github.com/user-attachments/assets/8c1421b2-53df-494e-add3-ba75a630fb15)

## 5. Upload and Download Files  
   ```bash
  aws s3 cp ./policy.jsson s3://ivolve-bucket10/policy.jsson 
  aws s3 cp s3://ivolve-bucket10/data.json ./data.json
   ```

![chrome-capture (29)](https://github.com/user-attachments/assets/93b08916-e8bb-455e-82ae-0a41b4cf39b6)

