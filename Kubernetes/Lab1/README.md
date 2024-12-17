# Kubernetes Deployment and Rollback 

## Prerequisites

- A Kubernetes cluster (Minikube).
- `kubectl` CLI installed and configured.
- Docker installed and running.


## steps:

1. Deploy NGINX with 3 replicas.
2. Expose the deployment as a service and access it locally using port forwarding.
3. Update the NGINX deployment to use an Apache (HTTPD) image.
4. View the deployment's rollout history.
5. Roll back to the previous version and monitor pod status.
   


### 1. Deploy NGINX with 3 replicas.

Run the following command to create a deployment with 3 replicas:

```bash
kubectl create deployment nginx --image=nginx --replicas=3
```
**Verify the deployment:**
```bash
kubectl get deployments
kubectl get pods
```

![2024-12-17 06_11_11-dhemaid@localhost_~](https://github.com/user-attachments/assets/dcffb82d-40f9-449b-ba92-f14c2f352d0c)

### 2. Expose the Deployment as a Service

Expose the deployment with a ClusterIP service:

```bash
kubectl expose deployment nginx --type=ClusterIP --port=80 --name=nginx-service
kubectl get svc
```

Forward a local port to the service:

```bash
kubectl port-forward svc/nginx-service 8880:80
curl http://localhost:8880
```

![2024-12-17 06_16_18-CentOS last one  - VMware Workstation](https://github.com/user-attachments/assets/4105d51b-0e67-4dd6-bc07-19770b7ce694)

## 3. Update the NGINX Deployment to Use the Apache Image

Update the image of the nginx container to httpd:

```bash
kubectl set image deployment/nginx nginx=httpd --record
```
![2024-12-17 06_23_00-CentOS last one  - VMware Workstation](https://github.com/user-attachments/assets/76cf86e3-cd50-42dd-82de-1ad5050d3a79)

## 4. View the Deployment's Rollout History

```bash
kubectl rollout history deployment/nginx
```

![2024-12-17 06_21_29-dhemaid@localhost_~](https://github.com/user-attachments/assets/5fbae899-9aca-43c2-8007-90fe7c68397c)

## 5. Roll Back to the Previous Image Version

```bash
kubectl rollout undo deployment/nginx
kubectl get pods -w
```
![2024-12-17 06_25_26-dhemaid@localhost_~](https://github.com/user-attachments/assets/cdc8267f-2746-45f0-b3f7-34cbcd7213d0)

Monitor the status of the rollback:

```bash
kubectl rollout status deployment/nginx
```

![2024-12-17 06_27_07-dhemaid@localhost_~](https://github.com/user-attachments/assets/31a97cfc-989f-4dc8-9bb8-ab967cf7bbdc)

## 6. Cleanup

```bash
kubectl delete deployment nginx
kubectl delete svc nginx-service
```
