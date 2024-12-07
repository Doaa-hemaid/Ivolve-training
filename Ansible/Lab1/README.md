# Lab 7: Ansible Installation
Deploy and configure the Ansible Automation Platform on control nodes, create inventories for managed hosts, and use ad-hoc commands to test and verify functionality.

### 1. **Install Ansible on Control Node**
- Connect to the control node.
- Run the following command to install Ansible:

  ```bash
  sudo apt-get update
  sudo apt-get install -y ansible
  ```
- Verify the installation
  
  ```bash
  ansible --version
  ```
### 2. **Configure ansible.cfg file**
 ```ini
 [defaults]
 private_key_file =./Ec2Key.pem
 user = ubuntu
 ``` 
### 3. **Create An Inventory File**
 ```ini
 [webservers]
 ec2-instance ansible_host=52.23.161.219
 ```
### 4. **Execute Ad-hoc Commands**
 ```bash
 ansible all -a "df -h"
 ```
