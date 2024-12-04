# Ansible Playbook for Nginx Web Server on AWS EC2
Write an Ansible playbook to automate the configuration of a web server.
This setup installs Nginx and deploys an `index.html` file on an AWS EC2 instance.

### playbook.yml
The Ansible playbook to install Nginx and deploy `index.html`:
```yaml
---
- name: Install Nginx and deploy index.html
  hosts: webservers
  become: yes  # Run tasks as a privileged user
  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present
        update_cache: yes

    - name: Copy index.html to the server
      copy:
        src: ./index.html  
        dest: /var/www/html/index.html

    - name: Ensure Nginx is started and enabled
      service:
        name: nginx
        state: started
        enabled: yes
```
### inventory.ini
lists the EC2 instance:
```yaml
[webservers]
ec2-instance ansible_host=52.23.161.219 ansible_user=ubuntu ansible_ssh_private_key_file=Ec2Key.pem
```
**Run the Playbook**
```bash 
ansible-playbook i inventory.ini playbook.yml
```
