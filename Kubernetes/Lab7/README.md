# Multi-container Applications

## Objectives

1. **Create a deployment for Jenkins with an init container:**
   - The init container should sleep for 10 seconds before the Jenkins container starts.
2. **Implement readiness and liveness probes:**
   - Configure probes for Jenkins to ensure proper health checks.
3. **Expose Jenkins using a NodePort service:**
   - Create a NodePort service to make Jenkins accessible externally.
4. **Verify the setup:**
   - Ensure the init container runs successfully and Jenkins is properly initialized.

---

## Steps

### 1. Create the Deployment YAML file
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins-deployment
  labels:
    app: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      containers:
      - name: jenkins
        image: jenkins/jenkins:lts
        ports:
        - containerPort: 8080
        readinessProbe:
          httpGet:
            path: /login
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /login
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 20
      initContainers:
      - name: init-sleep
        image: busybox
        command: ["sh", "-c", "sleep 10"]
```


### 2. Create the NodePort Service YAML file
```yaml
apiVersion: v1
kind: Service
metadata:
  name: jenkins-service
  labels:
    app: jenkins
spec:
  type: NodePort
  selector:
    app: jenkins
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 8080
    nodePort: 30000
```

### 3. Apply the Configuration
Run the following commands to deploy Jenkins:
```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

### 4. Verify the Setup
- **Check Pods:**
  ```bash
  kubectl get pods
  ```
![2024-12-18 18_19_25-dhemaid@localhost_~](https://github.com/user-attachments/assets/7281d74f-c1a0-42a5-a8b0-59db498f41d8)

- **Describe Pod:**
  ```bash
  kubectl describe pod jenkins-b76945f79-nwf5m
  ```

![2024-12-18 18_14_47-dhemaid@localhost_~](https://github.com/user-attachments/assets/32c16a79-e311-4ea0-b3cb-9a866ce4e1de)

---

## Key Concepts

### Init Container

 **Purpose**:
The `initContainer` is used to perform setup tasks before the main application container starts. It is run only once per Pod and must complete successfully before the main container can start. This ensures that necessary configurations or pre-requisites are set up before the main application runs.

**Behavior**:
If the `initContainer` fails, Kubernetes will not start the main container until the `initContainer` completes successfully. This makes `initContainers` ideal for tasks like copying files, setting up configuration files, applying migrations, or setting up databases.

```yaml
initContainers:
- name: init-sleep
  image: busybox
  command: ["sh", "-c", "sleep 10"]
```
### Readiness Probe

**Purpose**: The `readinessProbe` checks if the application inside the container is ready to start serving traffic. It determines if the container is operational and capable of handling requests. A container that fails the readiness probe will not receive traffic until it passes, ensuring only healthy containers handle requests.

**Behavior**: Kubernetes periodically checks the `readinessProbe` to determine if the container is healthy. If it fails, the container is not included in the load balancer until it becomes healthy.

**Example in YAML**:
```yaml
readinessProbe:
  httpGet:
    path: /login
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
```
- **initialDelaySeconds**: Specifies the delay (in seconds) after the container starts before the probe is initiated.
- **periodSeconds**: Specifies the interval (in seconds) at which the probe is performed.
- **httpGet**: Specifies that the probe will use HTTP to check the `/login` path on port `8080` to determine if the container is ready.

### Liveness Probe

**Purpose**: The `livenessProbe` checks if a container is alive and responding. It monitors the health of the container to detect crashes, hangs, or other issues. If a container fails the `livenessProbe`, Kubernetes considers it unhealthy and restarts it to recover from the issue.

**Behavior**: If the `livenessProbe` fails, Kubernetes attempts to restart the container to bring it back to a healthy state.

**Example in YAML**:
```yaml
livenessProbe:
  httpGet:
    path: /login
    port: 8080
  initialDelaySeconds: 60
  periodSeconds: 20
```
- **initialDelaySeconds**: Specifies the delay (in seconds) after the container starts before the liveness probe is initiated.
- **periodSeconds**: Specifies the interval (in seconds) at which the probe is performed.
- **httpGet**: Uses HTTP to check the `/login` path on port `8080` to determine if the container is still responsive.

---

## References
- [Kubernetes Documentation: Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Kubernetes Documentation: Init Containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)
