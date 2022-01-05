# CKA
## Chanllenges
### No:1
Create a new pod called `amdin-pod` with image `busybox`.
Allow the pod to be able to `set system_time`
The container should `sleep for 3200 seconds`.

```shell
$ kubectl run admin-pod --image=busybox --command sleep 3200 --dry-run=client -o yaml > challenge_01.yaml
```


```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: admin-pod
  name: admin-pod
spec:
  containers:
  - command:
    - sleep
    - "3200"
    image: busybox
    name: admin-pod
    securityContext:
      capabilities:
        add: ["SYS_TIME"]
```

### No:2
A kubeconfig file called `test.kubeconfig` has been created in `/root/Test`.
There is something wrong with the configuration.
Toubelshoot and fix it.
`/root/TEST/test.kubeconfig`
```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://controlplane:4380
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    namespace: default
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: DATA+OMITTED
    client-key-data: DATA+OMITTED
```

```shell
$ kubectl config view
```
> 发现server端口错误

### No:3
Create a new `deployment` called `web-proj-268`, with image `nginx:1.16` and `1 replica`.
Next upgrade the deployment to `version 1.17` using rolling update.

Make sure that the version upgrade is recorded in the `resource annotation`.

```shell
$ kubectl create deploy web-proj-268 --image=nginx:1.16 --replicas=1 -o yaml > challenge_03.yaml
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: web-proj-268
  name: web-proj-268
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: web-proj-268
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: web-proj-268
    spec:
      containers:
      - image: nginx:1.16
        imagePullPolicy: IfNotPresent
        name: nginx
```

```shell
$ kubectl set image deployment web-proj-268 nginx=nginx:1.17 --record
Flag --record has been deprecated, --record will be removed in the future
```