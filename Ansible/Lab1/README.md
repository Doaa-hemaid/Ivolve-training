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
user = dhemaid
inventory = ./inventory
 ``` 
### 3. **Create An Inventory File**
 ```ini
 [webservers]
 dhemaid@192.168.225.131
 ```
### 4. **Execute Ad-hoc Commands**
 ```bash
 ansible all -a "df -h"
 ```
![2024-12-08 00_29_41-doaa-hemaid@ubuntu_ ~_Lab1](https://github.com/user-attachments/assets/d62b30b4-7474-4ec9-af1f-7c7735c683d1)
