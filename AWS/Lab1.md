# AWS Security

## implement AWS security practices by:
- Setting up a billing alarm.
- Managing IAM groups and users with specific permissions.
- Enabling MFA for secure access.
- Testing access restrictions and permissions.

---

### 1. Set a Billing Alarm
- Navigate to **Billing Dashboard** > **Budgets**.
- Create a cost budget:
  - **Name**: `BillingAlarm`.
  - **Budget amount**: 1$.
- Set an email notification to receive alerts when the budget is exceeded.

![chrome-capture (35)](https://github.com/user-attachments/assets/a887352c-88ff-44bd-911b-36c85fd34165)

---

### 3. Create IAM Groups
#### Admin Group
- Name: `admin-group`.
- Policy: `AdministratorAccess`.

![chrome-capture (36)](https://github.com/user-attachments/assets/2328ad4e-53c8-4395-8c97-74cba6858825)

#### Developer Group
- Name: `developer-group`.
- Policy: `AmazonEC2FullAccess`.

![chrome-capture (37)](https://github.com/user-attachments/assets/9c159d97-2b7e-4fc3-a578-dd0743259d6d)

---

### 4. Create IAM Users
#### Admin-1 User
- **Access type**: Console only.
- Assign to `admin-group`.
- Enable MFA for added security.

![chrome-capture (43)](https://github.com/user-attachments/assets/6089bef9-0455-4073-971b-9482bbfc9403)


#### Admin-2-Prog User
- **Access type**: CLI only (Programmatic access).
- Assign to `admin-group`.

  ![chrome-capture (44)](https://github.com/user-attachments/assets/36a0bf5b-ad0a-4d8d-9c10-e206f9e1248c)
  

#### Dev-User
- **Access type**: Both Console and CLI.
- Assign to `developer-group`.

![chrome-capture (45)](https://github.com/user-attachments/assets/c988f418-8ee7-42f3-b71a-61e44458331b)

---

### 5. List Users and Groups via AWS CLI 
**1. list all users:**
  ```bash
   aws iam list-users
  ```
  ![chrome-capture (41)](https://github.com/user-attachments/assets/5ced9fe2-4df5-4d3a-986f-79a4b1fc950f)

**2. List all groups:**
  ```bash
    aws iam list-groups
  ```
  ![chrome-capture (42)](https://github.com/user-attachments/assets/ef9e5712-5c8d-41d5-a8e3-e37ae8550e2e)
  
### 6. Test Permissions
####  Configure the AWS CLI for dev-user
 ```bash
    aws configure
    aws ec2 describe-instances
    aws s3 ls
  ```
 ![2024-12-07 22_57_36-doaa-hemaid@ubuntu_ ~](https://github.com/user-attachments/assets/3bcb70ca-5a46-491b-81c5-d7850c3f81c9)
