# Ansible Playbook for MySQL Installation and Configuration
### 1. create inventory file:  
  Add your server details to the `inventory` file
  ```
    [webservers]
   ec2-instance ansible_host=54.157.234.1 ansible_user=ubuntu ansible_ssh_private_key_file=Ec2Key.pem
   ```
### 2. Create an Encrypted Variables File

Create a `vars.yml` file with sensitive information:
```yaml
---
db_user: ivolve
db_password: your_db_password
```

**Encrypt the file using Ansible Vault:**
```bash
ansible-vault encrypt vars.yml
```
This will create an encrypted version of the file (`vars.yml.vault`).    
![17](https://github.com/user-attachments/assets/c047993b-0353-4741-8ad1-cf17db09e4c2)   

### 3. Write the Playbook

Create the `playbook.yml` file:
```yaml
---
- name: Install and configure MySQL
  hosts: all
  become: true
  vars_files:
    - vars.yml
  tasks:
    - name: Installing MySQL and dependencies
      package:
        name: "{{ item }}"
        state: present
        update_cache: yes
      loop:
        - mysql-server
        - mysql-client
        - python3-mysqldb
        - libmysqlclient-dev

    - name: Ensure MySQL service is running
      service:
        name: mysql
        state: started
        enabled: true

    - name: Create MySQL database
      mysql_db:
        name: ivolve
        state: present

    - name: Create MySQL user with privileges
      mysql_user:
        name: "{{ db_user }}"
        password: "{{ db_password }}"
        priv: 'ivolve.*:ALL'
        state: present
```
### 4. Run the Playbook

Run the playbook with Ansible Vault to decrypt sensitive information:
```bash
ansible-playbook -i inventory playbook.yml --ask-vault-pass
```

You will be prompted for the vault password to decrypt the `vars.yml.vault` file.
![run lab](https://github.com/user-attachments/assets/35e4c317-2411-4729-a291-aedf7a59f4ba)
### 5. Test MySQL Setup     
To verify that the MySQL setup is working correctly and the `ivolve` database exists   

**Log in to MySQL remotely:**
   ```bash
   mysql -u ivolve_user -p
   ```
  ![run sql](https://github.com/user-attachments/assets/175666f9-da6f-481d-b329-c080dcc19597)  

  

