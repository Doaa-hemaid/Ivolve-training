# Ansible Dynamic Inventories

Set up Ansible dynamic inventories to automatically discover and manage AWS EC2 instances.
   
1. **Install prerequisites**
```bash
sudo apt update && sudo apt install -y ansible
pip install boto3 botocore
```
2. **Configure AWS CLI**
```bash
aws configure
```
****
3. **Configure AWS Dynamic Inventory**
```yml
---
plugin: amazon.aws.aws_ec2
regions:
  - us-east-1
filters:
  "tag:Name": servers  
keyed_groups:
  - key: tags.Name  # Group by EC2 tags, if needed
    prefix: iVolve
```
  Test the Dynamic Inventory  
   ```bash
   ansible-inventory -i aws_ec2.yaml --graph
   ```  
  ![2024-12-05 00_18_39-root@ubuntu_ ~_Ivolve-training_Ansible_Lab5](https://github.com/user-attachments/assets/551688ca-891a-4a34-845b-1f852fec310e)


4. **Use an Ansible Galaxy role to install Apache on EC2 instances**  

    **Set Up Ansible Galaxy Role: Install the geerlingguy.apache role**  
   ```bash
    ansible-galaxy install geerlingguy.apache
    ```  
   **Create Ansible Playbook**
   ```yml
   ---
   - hosts: iVolve_servers
     become: yes
     roles:
       - geerlingguy.apache
   ``` 
  **Run the Playbook:**
  ```bash
  ansible-playbook -i aws_ec2.yml playbook.yaml
  ```  
![2024-12-05 00_21_32-root@ubuntu_ ~_Ivolve-training_Ansible_Lab5](https://github.com/user-attachments/assets/c0c7eed1-830a-424a-ba37-5219a32cfa6b)
