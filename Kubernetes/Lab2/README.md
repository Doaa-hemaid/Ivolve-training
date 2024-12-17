# Deployment vs. StatefulSet
<br />

| **What Is Kubernetes Deployment?** |
|----------------------------------|
A Deployment is a Kubernetes resource object used for declarative application updates. Deployments allow you to define the lifecycle of applications, including the container images they use, the number of pods, and the manner of updating them. <br /><br /> Deployments are fully managed by the backend in Kubernetes, with the entire update process being server-side, with no client involvement. They ensure that a specified number of pods are always running and available. The entire update process is recorded, with versioning to provide options for pausing, resuming, or rolling back to previous versions.<br /><br />

| **What Is Kubernetes StatefulSet?** |
|----------------------------------|
A StatefulSet is a workload API object for managing stateful applications. Usually, Kubernetes users are not concerned with how pods are scheduled, although they do require pods to be deployed in order, to be attached to persistent storage volumes, and to have unique, persistent network IDs that are retained through rescheduling. StatefulSets can help achieve these objectives. <br /> <br />Like Deployments, StatefulSets manage the pods based on the same container specifications. However, they differ from deployments in that they maintain sticky identities for each pod. Pods may be created from an identical spec, but they are not interchangeable and are thus assigned unique identifiers that persist through rescheduling.<br /><br />

## Create a MySQL StatefulSet Configuration YAML

Below is the YAML configuration to create a MySQL StatefulSet with 3 replicas:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
  namespace: default
spec:
  replicas: 3
  serviceName: mysql
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
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: rootpassword
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-data
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: mysql-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 5Gi
```
## Create a Service for the MySQL StatefulSet

Below is the YAML configuration to expose the MySQL StatefulSet via a Service:

 ```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: default
spec:
  ports:
  - port: 3306
    targetPort: 3306
    protocol: TCP
  clusterIP: None 
  selector:
    app: mysql
 ```

## Deploy and Test in Minikube
Apply the MySQL StatefulSet YAML & MySQL Service YAML:
 ```bash
kubectl apply -f mysql-statefulset.yaml
kubectl apply -f mysql-service.yaml
```
**Verify the Deployment:**
 ```bash
kubectl get statefulsets
kubectl get pods
 ```
![2024-12-17 08_28_44-dhemaid@localhost_~](https://github.com/user-attachments/assets/a7a5efa5-49b0-4f5b-81cf-cbae3f00f8a6)

## Access MySQL Pods
 ```bash
kubectl exec -it mysql-0 -- mysql -u root -prootpassword
 ```
![2024-12-17 08_31_15-dhemaid@localhost_~](https://github.com/user-attachments/assets/dd7a6d8d-6762-41c3-980d-463872a1afdc)


