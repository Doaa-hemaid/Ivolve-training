#  Kubernetes Security and RBAC

## Objectives
- Create a **Service Account**.
- Define a **Role** named `pod-reader` allowing read-only access to pods in the namespace.
- Bind the `pod-reader` Role to the Service Account and retrieve the Service Account token.
- Compare **Service Account**, **Role & Role Binding**, and **Cluster Role & Cluster Role Binding**.

---

## Steps

### 1. Create a Service Account
Run the following command to create a service account named `pod-reader-sa`:

```bash
kubectl create serviceaccount user1 -n default
```

---

### 2. Define a Role
Create a role named `pod-reader` to allow read-only access to pods in the namespace:

```yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```

Apply the Role configuration:

```bash
kubectl apply -f pod-reader-role.yaml
```

---

### 3. Bind the Role to the Service Account
Bind the `pod-reader` Role to the `pod-reader-sa` Service Account:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-binding
  namespace: my-namespace
subjects:
- kind: ServiceAccount
  name: my-sa
  namespace: my-namespace
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```
```bash
kubectl apply -f role-binding.yaml
```

## 4. Get the ServiceAccount Token
manually create a ServiceAccount token using a Secret object:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: user1-token
  annotations:
    kubernetes.io/service-account.name: user1
type: kubernetes.io/service-account-token
```
token is created, extract it using the describe command:
```bash
kubectl describe secret user1-token -n default
```
## 5. Verify Kubernetes Security and RBAC Setup:
```bash 
kubectl get serviceaccount user1 -n default
kubectl get role pod-reader -n default
kubectl get rolebinding pod-reader-binding -n default
kubectl describe secret user1-token -n default
```

![2024-12-17 11_53_58-dhemaid@localhost_~](https://github.com/user-attachments/assets/69514006-f513-40d2-b38a-23985d83bafa)

```bash
kubectl auth can-i create deployments --as=system:serviceaccount:default:user1
kubectl auth can-i list pods --as=system:serviceaccount:default:user1
```
![2024-12-17 12_50_47-dhemaid@localhost_~](https://github.com/user-attachments/assets/c140d359-4e83-4777-b44e-f3b96ea07b16)

---

## Comparison Table

| **Aspect**             | **Service Account**                          | **Role & Role Binding**                                      | **Cluster Role & Cluster Role Binding**                     |
|-------------------------|---------------------------------------------|-------------------------------------------------------------|-------------------------------------------------------------|
| **Scope**              | Namespace-specific authentication entity.   | Namespace-specific authorization rules and bindings.        | Cluster-wide authorization rules and bindings.              |
| **Purpose**            | Used by applications to access the API.     | Grants permissions to service accounts or users in a namespace. | Grants cluster-wide permissions to service accounts or users. |
| **Granularity**        | Tied to a specific namespace.               | Controls access to resources in a specific namespace.        | Controls access to resources across all namespaces.          |
| **Example Use Case**   | Allow a pod to authenticate with the API.   | Give read-only access to pods in a namespace.               | Allow cluster-wide admin access for resource management.     |

---
