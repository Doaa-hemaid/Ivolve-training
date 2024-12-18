#  Configuring a MySQL Pod using ConfigMap and Secret

## Objectives
- Create a namespace called `ivolve` and apply a resource quota to limit resource usage within the namespace.
- Deploy a MySQL pod with specific resource requests and limits.
- Use a **ConfigMap** to define MySQL database configurations.
- Use a **Secret** to securely store sensitive data like passwords.
- Verify the database configuration by accessing the MySQL pod.

---

## Steps

### 1. Create a Namespace

- **Create the `ivolve` namespace:**

```bash
kubectl create namespace ivolve
```

- **Apply a resource quota to limit resource usage in the `ivolve` namespace:**

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: ivolve-quota
  namespace: ivolve
spec:
  hard:
    pods: "2"
```
- **Apply the quota configuration:**

```bash
kubectl apply -f resource-quota.yaml
```

![2024-12-18 11_52_16-dhemaid@localhost_~_static-website](https://github.com/user-attachments/assets/4047c04a-2fe0-4671-b283-710ccb84475d)

---

### 2. Create the MySQL Deployment

- **Define a Deployment for MySQL in the `ivolve` namespace with the following resource requests and limits:**

- **Requests**: CPU: 0.5 vCPU, Memory: 1Gi
- **Limits**: CPU: 1 vCPU, Memory: 2Gi

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-deployment
  namespace: ivolve
spec:
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:5.7
        resources:
          requests:
            cpu: "500m"
            memory: "1Gi"
          limits:
            cpu: "1"
            memory: "2Gi"
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: root-password
        - name: MYSQL_DATABASE
          valueFrom:
            configMapKeyRef:
              name: mysql-config
              key: database-name
        - name: MYSQL_USER
          valueFrom:
            configMapKeyRef:
              name: mysql-config
              key: database-user
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: user-password
```

Apply the Deployment configuration:

```bash
kubectl apply -f mysql-deployment.yaml
```
![2024-12-18 11_58_07-dhemaid@localhost_~_static-website](https://github.com/user-attachments/assets/e6d9f59d-4e71-4ca1-84d9-1beb0b6efd31)

---

### 3. Create a ConfigMap for MySQL Configuration

Define a ConfigMap with the MySQL database name and user:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
  namespace: ivolve
data:
  MYSQL_DATABASE: mydb
  MYSQL_USER: myuser

```

Apply the ConfigMap:

```bash
kubectl apply -f mysql-config.yaml
```

---

### 4. Create a Secret for MySQL Passwords

Store the MySQL root password and user password in a Secret:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
  namespace: ivolve
type: Opaque
data:
  MYSQL_ROOT_PASSWORD: $(echo -n "rootpassword" | base64)
  MYSQL_PASSWORD: $(echo -n "userpassword" | base64)
```

Apply the Secret:

```bash
kubectl apply -f mysql-secret.yaml
```

---

### 5. Verify the MySQL Configuration

Exec into the MySQL pod to verify the database configurations:

```bash
exec -n ivolve -it mysql-6589698956-vgc6m -- bash
```

Once inside the pod, access the MySQL shell:

```bash
mysql -u root -p$MYSQL_ROOT_PASSWORD
```

Enter the user password (retrieved from the Secret) and verify the database setup:

```sql
SHOW DATABASES;
SELECT host, user FROM mysql.user;
```
![2024-12-18 12_03_12-dhemaid@localhost_~_static-website](https://github.com/user-attachments/assets/350a3db3-e710-4b8b-9f0c-06bd7d254ca4)

