# MultiBranch Pipeline Project
**creating a MultiBranch Pipeline Project in Jenkins to automate Kubernetes deployments based on GitHub branches. It also involves setting up Jenkins slaves to run the pipeline and creating multiple Kubernetes namespaces.**

![127](https://github.com/user-attachments/assets/d8aa456d-51e4-4738-af21-ec6fcecd6ed4)

## 1. Install and Configure Minikube
   ### 1.1 Install Minikube (Linux, Centos)  
 - Install [Minikube](https://minikube.sigs.k8s.io/docs/start/?arch=%2Flinux%2Fx86-64%2Fstable%2Fbinary+download) x86-64 Linux using binary download:
   ```bash
   curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
   sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
   ```
  ### 1.2 Start Minikube
  ```bash
    minikube start --driver=docker
    minikube status
  ```
  ![2024-12-16 14_40_52-dhemaid@localhost_~](https://github.com/user-attachments/assets/95969a0d-b614-41ca-9867-b2de13ba4df4)
 ### 1.3 Create Kubernetes Namespaces
 ```bash
kubectl create namespace dev
kubectl create namespace prod
kubectl create namespace test
kubectl get namespaces
 ```
![2024-12-16 14_44_45-dhemaid@localhost_~](https://github.com/user-attachments/assets/ca2b2159-a0db-49a6-9f70-cf7e686f6502)

### 1.4 Create Service Accounts and Role Bindings for Each Namespace (dev, prod, test)
```bash
kubectl create serviceaccount <service-account-name> -n <namespace>
kubectl create rolebinding jenkins-rolebinding --role=edit --serviceaccount=<namespace>:<service-account-name> -n <namespace>
```
### 1.5 Kubeconfig File Configuration  
- Jenkins needs to know where to find the Kubeconfig file.
- Export the KUBECONFIG environment variable to point to the correct file
```bash
scp ~/.kube/config <jenkins-slave-ip>:/var/jenkins_home/.kube/config
export KUBECONFIG=~/.kube/config # slave vm & user jenkins
```

## 2. Install Jenkins Master ( Linux, Ubuntu)
  ### 2.1 [Install Java](https://www.jenkins.io/doc/book/installing/linux/#installation-of-java)
  ```bash
  sudo apt update
  sudo apt install fontconfig openjdk-17-jre
  java -version
 ```
![2024-12-16 15_20_48-doaa-hemaid@ubuntu_ ~](https://github.com/user-attachments/assets/4fa816e5-09d1-40bd-9073-1ad06c192ade)

### 2.2 [install Jenkins](https://www.jenkins.io/doc/book/installing/linux/#debianubuntu) 
```bash
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins
 ```
### 2.3 [Start Jenkins](https://www.jenkins.io/doc/book/installing/linux/#start-jenkins)
```bash
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins
```
![2024-12-16 15_21_42-doaa-hemaid@ubuntu_ ~](https://github.com/user-attachments/assets/1ec1f61f-acd0-44b2-a181-40055bd34f01)
### 2.4  Configure Jenkins Master Credentials
  #### 2.4.1 Generate SSH Key
   ```bash
   sudo su - jenkins
   ssh-keygen -t rsa -b 4096 
   ```
![2024-12-16 15_36_04-doaa-hemaid@ubuntu_ ~](https://github.com/user-attachments/assets/77b9a62c-aaf1-4f7b-890a-822dae70f40e)

  #### 2.4.2 Setup Credentials on Jenkins  
1. **Open your Jenkins dashboard** and click on 'Credentials' in the left menu.
2. **Select the 'global' domain link**.
3. **Click 'Add Credentials'**.
4. **Choose 'SSH Username with private key'**.
5. **Scope**: Global
6. **Username**: jenkins
7. Paste the 'id_rsa' private key of the Jenkins user from the master server.
8. **Click 'OK'**.
 ![2024-12-16 15_44_34-New credentials  Jenkins](https://github.com/user-attachments/assets/7129125a-fe3c-4ceb-897c-1fad2790a6ee)


## 3. Set Up Jenkins Slave (Linux, Centos)
  ### 3.1 Add New Jenkins User
  ```bash
  useradd -m -s /bin/bash jenkins
  passwd jenkins
   ```
  ### 3.2 [Install Java](https://www.jenkins.io/doc/book/installing/linux/#installation-of-java)
  ![2024-12-16 16_04_21-jenkins@localhost_~](https://github.com/user-attachments/assets/ece09730-7108-49ad-98bc-0955f656076a)
  
  ### 3.3 Copy the SSH Key from Master to Slave
   ```bash
   ssh-copy-id -i ~/.ssh/id_rsa.pub jenkins@192.168.225.131 # master vm
   ```
  ![2024-12-16 16_06_33-doaa-hemaid@ubuntu_ ~](https://github.com/user-attachments/assets/960de135-f25f-41d0-a0b5-d3f8c660561a)

 ### 3.4 Add New Slave Nodes 
1. **On the Jenkins dashboard**, click the 'Manage Jenkins' menu.
2. **Select 'Manage Nodes'**.
3. **Click 'New Node'**.
4. **Type the node name 'slave01'**.
5. **Choose 'permanent agent'**.
6. **Click 'OK'**.
7. **Remote root directory**: `/home/jenkins`
8. **Labels**: ivolve
9. **Launch method**: Launch slave agent via SSH
10. **Type the host IP address '192.168.225.131'**.
11. **Choose the 'Jenkins' credential for authentication**.
12. **Click 'Save'**
    
 ![2024-12-16 16_16_41-slave01  Jenkins](https://github.com/user-attachments/assets/42e9dff6-88aa-48b6-944f-d39ca347a734)
### 3.5 Essential Jenkins Plugins
- Docker Pipeline Plugin
- Kubernetes Plugin
- Git Plugin

### 3.6 Add Credentials for Each Namespace
1. **Click 'Add Credentials'**.
2. **Kind**: Secret text.
3. **ID**: Choose a unique identifier (e.g., `k8s-dev`).
4. **Secret**:
   - **Username**: `jenkins-prod`
   - **Secret Value**: `<token>` (Replace `<token>` with the actual token associated with the `jenkins-prod` service account).
5. **Click 'OK'**.
   
![2024-12-16 18_46_15-Jenkins » Credentials  Jenkins](https://github.com/user-attachments/assets/c077debc-294d-4d00-aad6-3cc6de950b8d)

## 4. Automated Deployments
### 4.1 Create a MultiBranch Pipeline Project
1. **In Jenkins**, click 'New Item'.
2. **Select 'Multibranch Pipeline'** and name it ('Project01-Multibranch-pipline').
3. **Configure the project**:
   - Add the [GitHub repository URL](https://github.com/Doaa-hemaid/project01.git).
   - Add git credential.
   - Under **Discover branches**, filter by name using the regular expression `*`.
  
![2024-12-16 16_41_28-Project01-Multibranch-pipline Config  Jenkins](https://github.com/user-attachments/assets/45878aa2-906e-4e79-a901-47bc15f81689)

4. **Click 'Scan Repository Now'**.
5. Jenkins will detect branches and create jobs for each branch.
   
![2024-12-16 16_30_36-Branches (3)  Project01-Multibranch-pipline   Jenkins](https://github.com/user-attachments/assets/624636c0-b96d-4dfc-9ce8-42ee8fbcc9e6)

### 4.2  Jenkinsfile for Each Branch
- **main**: Deploys to the `prod` namespace.  
- **devlop**: Deploys to the `dev` namespace.  
- **test**: Deploys to the `test` namespace.  

```bash
 @Library('shared-library@main') _
pipeline {
    agent { label 'ivolve' }

    environment {
        DOCKER_IMAGE_BASE = 'doaahemaid01/my-app'
        IMAGE_TAG = "${env.BUILD_ID}-${new Date().format('yyyyMMddHHmmss')}"
        DOCKER_IMAGE = "${DOCKER_IMAGE_BASE}:${IMAGE_TAG}"
        MINIKUBE_IP = '192.168.49.2'
        NAMESPACE = 'prod'
        K8SCREDENTIALS = 'k8s-prod'
    }

    stages {
        stage('Build Image') {

           steps {
                echo 'Building...'
                dockerBuildAndPush(DOCKER_IMAGE,'docker-hub-credentials')
                }
            }
        

        stage('Clean Local Images') {
            steps {
                echo 'Cleaning up local Docker images...'
                cleanDockerImage (DOCKER_IMAGE)
            }
        }

        stage('Deploy to prod Namespace') {
            steps {
                echo 'Deploying...'
               deployK8sApplication(NAMESPACE, DOCKER_IMAGE, K8SCREDENTIALS, MINIKUBE_IP)
           
                }
            }
        }
    

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
```
### 4.3 **Shared Jenkins Library** [repository](https://github.com/Doaa-hemaid/Shared-Library.git)
  #### Functions in the Library
- **dockerBuildAndPush**  
  Builds the Docker image and pushes it to Docker Hub.  
  **Arguments**: `image`, `dockerCredentialsId`.

- **cleanDockerImage**  
  Cleans up the local Docker image to save space.  
  **Arguments**: `image`.

- **deployK8sApplication**  
  Deploys the application to the specified namespace using Kubernetes manifests.  
  **Arguments**: `namespace`, `dockerImage`, `k8sCredentialsId`, `minikubeIp`.
### 4.4 Kubernetes YAML Configuration
#### Deployment Configuration
- Deploys a single replica of the application.  
- Pulls the Docker image from Docker Hub.  
- Targets the specified namespace (`prod`, `dev`, or `test`).  
```yaml
--- # Deployment Configuration
kind: Deployment
apiVersion: apps/v1
metadata:
  name: my-app
  namespace: prod 
  labels:
    app: my-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: "doaahemaid01/my-app:1.0"
---
```

#### Service Configuration
- Exposes the application via a LoadBalancer service type.
- Routes traffic on port 80 to the application’s container port 3000.
```yaml
--- # Service Configuration
apiVersion: v1
kind: Service
metadata:
  name: my-app
  namespace: prod 
spec:
  selector:
    app: my-app
  type: LoadBalancer
  ports:
  - name: http
    targetPort: 3000
    port: 80
```
## 5 Testing the Setup
1. **Push to GitHub**  
   Push application code and Jenkinsfile to the appropriate branch (`main`, `dev`, or `test`).  

2. **Trigger Jenkins Pipeline**  
   Jenkins will automatically trigger the pipeline for the updated branch.  

3. **Verify Docker Image**  
   Log in to Docker Hub and verify that the image with the correct tag has been pushed.  

4. **Verify Deployment**  
   Use `kubectl` to confirm that the application is deployed to the correct namespace.  
 ```bash
kubectl get all -n prod
kubectl get all -n dev
kubectl get all -n test
 ```
![2024-12-16 17_18_16-dhemaid@localhost_~](https://github.com/user-attachments/assets/fbcaf04b-90c3-446a-af0f-76e296eb50df)

![2024-12-16 17_18_35-dhemaid@localhost_~](https://github.com/user-attachments/assets/1f3e327f-df04-4961-9cb2-9e4b2a83a293)

![2024-12-16 17_19_18-dhemaid@localhost_~](https://github.com/user-attachments/assets/8e7181ca-4a6f-4e50-9fea-4a746c4629cb)

