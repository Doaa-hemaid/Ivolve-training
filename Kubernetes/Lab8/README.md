#  DaemonSets & Taint and Toleration

## Objectives

1. **Understand DaemonSet and its usage:**
   - Learn what DaemonSets are and their purposes in Kubernetes.
2. **Create a DaemonSet:**
   - Create a DaemonSet with an Nginx container and verify the number of pods running.
3. **Taint the Minikube node:**
   - Apply a taint to the Minikube node using the key-value pair `color=red`.
4. **Test tolerations:**
   - Create a pod with a toleration `color=blue` and observe its status.
   - Change the toleration to `color=red` and analyze the result.
5. **Compare Taint, Toleration, and Node Affinity:**
   - Understand the differences and use cases of these Kubernetes features.

---
## What is a Kubernetes DaemonSet?

A **DaemonSet** is a Kubernetes resource that ensures a specified Pod runs on all nodes or a specific subset of nodes in a cluster. DaemonSets are commonly used to deploy special programs that run in the background, performing tasks such as monitoring and logging.

## Node Affinity

Node affinity is a feature that allows you to define rules for scheduling Pods on specific nodes based on their labels. It is more flexible and expressive compared to `nodeSelector`. Node affinity provides two levels of strictness:

1. **requiredDuringSchedulingIgnoredDuringExecution**
   - **Strict Rule**: The Pod can only be scheduled on nodes that satisfy the specified condition. If no such nodes are available, the Pod will not be scheduled.
   - **Behavior**:
     - **During Scheduling**: The rule is mandatory, and the Pod will remain unscheduled until a suitable node becomes available.

2. **preferredDuringSchedulingIgnoredDuringExecution**
   - **Soft Rule**: The scheduler will try to place the Pod on a node that satisfies the condition but will still schedule the Pod on other nodes if no such nodes are available.
   - **Behavior**:
     - **During Scheduling**: The rule is preferred but not mandatory. The scheduler attempts to honor it but falls back to other nodes if necessary.

## Taints

Taints are applied to nodes in a Kubernetes cluster to repel pods from being scheduled on those nodes, except for pods that explicitly tolerate the taint. Each taint consists of three parts:

- **Key**: The key represents the name of the taint and is used to uniquely identify it.
- **Value**: An optional value associated with the taint key.
- **Effect**: The effect determines how the taint affects pod scheduling.
## Tolerations
Tolerations are applied to pods and indicate that the pod can be scheduled on nodes with specific taints. A pod with toleration will only be scheduled on nodes that have a matching taint.

## Comparison of Taint Effects

| Effect           | Prevents Scheduling | Evicts Running Pods | Description                                                            |
|------------------|---------------------|---------------------|-----------------------------------------------------------------------|
| **NoSchedule**   | Yes                 | No                  | Strictly prevents new Pods from being scheduled unless they tolerate the taint. |
| **PreferNoSchedule** | Tries to prevent   | No                  | Softly discourages scheduling Pods on the Node.                        |
| **NoExecute**    | Yes                 | Yes                 | Prevents scheduling and actively evicts Pods without a matching toleration.     |

## Steps

### 1. Create a DaemonSet YAML file
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-daemonset
  labels:
    app: nginx
spec:
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
        image: nginx:latest
        ports:
        - containerPort: 80
```

Apply the DaemonSet configuration:
```bash
kubectl apply -f daemonset.yaml
```

Verify the number of pods created:
```bash
kubectl get pods -o wide
```



### 2. Taint the Minikube Node
Taint the node to restrict scheduling:
```bash
kubectl taint nodes <node-name> color=red:NoSchedule
```

Verify the taint:
```bash
kubectl describe node <node-name> | grep Taints
```

### 3. Create a Pod with a Toleration `color=blue`
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
  tolerations:
  - key: "color"
    operator: "Equal"
    value: "blue"
    effect: "NoSchedule"
```

Apply the configuration:
```bash
kubectl apply -f test-pod-blue.yaml
```

Check the pod status:
```bash
kubectl get pods
```

### 4. Change the Toleration to `color=red`
Update the pod YAML:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
  tolerations:
  - key: "color"
    operator: "Equal"
    value: "red"
    effect: "NoSchedule"
```

Reapply the configuration:
```bash
kubectl apply -f test-pod-red.yaml
```

Verify the pod status:
```bash
kubectl get pods
```



### 5. Comparison: Taint, Toleration, and Node Affinity

| Feature         | Description                                                                                 | Use Case                                                                                         |
|-----------------|---------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|
| **Taint**       | Restricts a node from accepting pods unless they have a matching toleration.                | Prevent specific workloads from running on certain nodes.                                       |
| **Toleration**  | Allows a pod to be scheduled on a tainted node.                                             | Enable specific pods to override node taints for scheduling.                                    |
| **Node Affinity** | Ensures that pods are scheduled on nodes matching certain labels.                          | Schedule pods on specific nodes with desired characteristics (e.g., hardware, region).          |

---

## References
- [Kubernetes Documentation: DaemonSets](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)
- [Kubernetes Documentation: Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)
- [Kubernetes Documentation: Node Affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)
