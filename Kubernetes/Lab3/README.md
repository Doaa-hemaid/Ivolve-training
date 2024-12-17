# Storage Configuration
## Steps:

1. **Create a deployment** named `my-deployment` with 1 replica using the `NGINX` image.
2. **Create and verify a file** in the NGINX container that persists across pod restarts.
3. **Create and attach a PVC** to the NGINX deployment and verify persistence after pod deletion.
4. **Compare PV, PVC, and StorageClass**.

  ## 1. Create the Deployment

  - **create a simple deployment using the `NGINX` image with 1 replica:**

   ```bash
   kubectl create deployment my-deployment --image=nginx --replicas=1
   ```
- **Check the status of the deployment and pod:**

 ```bash
kubectl get deployment my-deployment
kubectl get pods
 ```

![2024-12-17 08_54_21-dhemaid@localhost_~](https://github.com/user-attachments/assets/a751cda3-84f3-4745-b155-d28d95d31d5a)

## 2. Exec into the NGINX Pod and Create the File
- **Exec into the NGINX pod:**
 ```bash
kubectl exec -it my-deployment-577d9fbfb9-997vd  -- /bin/bash
 ```
- **Create a file at /usr/share/nginx/html/hello.txt with the content hello, this is 'your-name':**
```bash
echo "hello, this is Doaa " > /usr/share/nginx/html/hello.txt
 ```
- **Verify the file is served by NGINX by running curl on localhost:**
 ```bash
curl localhost/hello.txt
 ```

![2024-12-17 09_00_14-dhemaid@localhost_~](https://github.com/user-attachments/assets/4bb901be-db9d-4291-9ef4-e2da500e1c2b)

## 3. Delete the NGINX Pod and Wait for a New Pod to be Created
- **delete the NGINX pod:**
 ```bash
kubectl delete pod my-deployment-577d9fbfb9-997vd
 ```
- **Kubernetes will automatically create a new pod for the deployment. Wait for the new pod to come up:**
```bash
kubectl get pods
 ```
![2024-12-17 09_08_06-dhemaid@localhost_~](https://github.com/user-attachments/assets/f8071950-551f-4e05-87a3-6d9576ad884e)

## 4. Exec into the New Pod and Verify the File is Gone
- **exec into new pod :**
 ```bash
kubectl exec -it my-deployment-577d9fbfb9-jvnpd  -- /bin/bash
 ```
- **Navigate to the directory and check if the file is present:**
   ```bash
   cat /usr/share/nginx/html/hello.txt
   ```
![2024-12-17 09_11_45-dhemaid@localhost_~](https://github.com/user-attachments/assets/0865c05c-fc7e-4d52-ab38-ead0a449d5c2)

## 5. Create a PVC and Modify the Deployment to Attach the PVC

- **Create a Persistent Volume Claim (PVC) for storage. Create a pvc.yaml file:**

   ```yaml
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: nginx-pvc
   spec:
    accessModes:
     - ReadWriteOnce
    resources:
      requests:
       storage: 1Gi
    ```
- **Apply the PVC:**
   ```bash
   kubectl apply -f pvc.yaml
   ```
## 6. Modify the Deployment to Attach the PVC
- **Edit your deployment to mount the PVC to /usr/share/nginx/html**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        volumeMounts:
        - name: nginx-storage
          mountPath: /usr/share/nginx/html
      volumes:
      - name: nginx-storage
        persistentVolumeClaim:
          claimName: nginx-pvc
```
- **Apply the updated deployment:**

``` bash
kubectl apply -f deployment-with-pvc.yaml
```

![2024-12-17 09_32_42-dhemaid@localhost_~](https://github.com/user-attachments/assets/9cdb9acd-1bc3-4775-9ebf-e2a54a048392)


## 7. Repeat the Previous Steps and Verify Persistence

 - **Exec into the NGINX Pod and Create the File Again**
    ```bash
    kubectl exec -it my-deployment-b4b9fc88d-zgm4g -- /bin/bash
    echo "hello, this is Doaa " > /usr/share/nginx/html/hello.txt
    curl localhost/hello.txt
    ```
    ![2024-12-17 09_34_58-dhemaid@localhost_~](https://github.com/user-attachments/assets/18105220-620f-4608-bade-f1262d5b2417)
- **Delete the NGINX Pod and Wait for the New Pod**
   ```bash
   kubectl delete pod my-deployment-b4b9fc88d-zgm4g
   ```
- **A new pod is created, exec into it and verify that the file still exists:**
   ```bash
   kubectl exec -it my-deployment-b4b9fc88d-fhdcm -- /bin/bash
   cat /usr/share/nginx/html/hello.txt
   ```
   ![2024-12-17 09_39_23-dhemaid@localhost_~](https://github.com/user-attachments/assets/ff9f8e55-29b7-472a-81fc-4af62bff8010)
  
## 8. Compare PV, PVC, and StorageClass

| **Persistent Volumes (PV)** |
|-------------------------------|
Persistent Volumes are a way to abstract and represent physical or networked storage resources in a cluster. They serve as the “backend” storage configuration in a Kubernetes cluster.

### Features:

- **Resource Abstraction**: PVs decouple storage from applications, enabling easier management of storage resources.
- **Resource Management**: Administrators can allocate and optimize storage resources, ensuring efficient hardware utilization.
- **Data Persistence**: PVs guarantee data remains available even when pods or containers are recreated or rescheduled, essential for stateful applications.
- **Access Control**: PVs enforce access modes (e.g., ReadWriteOnce, ReadOnlyMany, ReadWriteMany) and security settings, safeguarding data integrity and security.

| **Persistent Volume Claims (PVC)** |
|-----------------------------------|
Persistent Volume Claims act as requests for storage by pods. They are used by developers to specify their storage requirements.

### Features:

- **Resource Request**: PVCs let developers request storage without needing to understand the underlying infrastructure, simplifying application scaling.
- **Dynamic Provisioning**: With a StorageClass, PVCs enable automatic provisioning of storage resources based on predefined policies, streamlining deployment.
- **Isolation**: PVCs separate storage concerns from application code, enhancing maintainability and portability.

| **Storage Classes** |
|---------------------|
Storage Classes are an abstraction layer over the underlying storage infrastructure. They define the properties and behavior of PVs dynamically provisioned from them.

### Features:

- **Dynamic Provisioning**: Automates the creation of PVs with specific attributes (e.g., storage type, access mode), simplifying storage management.
- **Resource Optimization**: Matches storage resources to application needs, ensuring efficient and appropriate storage allocation.
- **Scaling and Automation**: Enables administrators to define policies for storage allocation, supporting scalability and streamlined automation.


