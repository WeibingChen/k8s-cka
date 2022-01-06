# CKA
## Chanllenges
### No:1
- Create a new pod called `amdin-pod` with image `busybox`.
- Allow the pod to be able to `set system_time`
- The container should `sleep for 3200 seconds`.

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
- A kubeconfig file called `test.kubeconfig` has been created in `/root/Test`.
- There is something wrong with the configuration.
- Toubelshoot and fix it.
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
- Create a new `deployment` called `web-proj-268`, with image `nginx:1.16` and `1 replica`.
- Next upgrade the deployment to `version 1.17` using rolling update.
- Make sure that the version upgrade is recorded in the `resource annotation`.

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


### No:4
- Create a new deployment called web-003
- Scale the deployment to 3 replicas
- Make sure desired number of pod always running

这道题考的目的不是创建deployment，而是诊断集群错误！
但是我们按着题目要求，创建一个Deployment，镜像使用nginx:latest, replicas为3

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: web-003
  name: web-003
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-003
  template:
    metadata:
      labels:
        app: web-003
    spec:
      containers:
      - image: nginx
        name: nginx
```

首先检查deploy，这是创建成功的，但是pod没有创建。
```shell
$ kg deploy
NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
web-003                  0/3     0            0           10s
```
检查下集群状态，显示controller-manager的状态为`Unhealthy`
```shell
$ kg cs
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS      MESSAGE                                                                                        ERROR
controller-manager   Unhealthy   Get "https://127.0.0.1:10257/healthz": dial tcp 127.0.0.1:10257: connect: connection refused
scheduler            Healthy     ok
etcd-0               Healthy     {"health":"true","reason":""}
```
查看logs，没有输出
检查一下pod events，显示`kube-controller-man`命令没有找到，这个命令的名称是不对的，正确的是`kube-controller-manager`，需要更正一下：
```shell
starting container process caused: exec: "kube-controller-man": executable file not found in $PATH: unknown
```
找到`/etc/kubernetes/manifest/kube-controller-manager.yaml`将命令改为正确的，然后重启下kubelet。等待一下再次观察pod是否创建好了。

### No:5 
- Upgrade the Cluster (Master and worker Node) from 1.18.0 to 1.19.0.
- Make sure first drain both Node and make it available after upgrade.
查看版本
```shell
$ kg nodes
$ kubectl version --short
```
drain pods
```shell
$ k drain master01 --ignore-daemonsets
```

升级kubeadm
```shell
$ apt update
$ apt install kubeadm=1.19.0-00
$ kubeadm upgrade apply 1.19.0
$ apt install kubelet=1.19.0-00
$ systemctl restart kubectl
```

uncordon pods
```shell
$ k uncordon master01
```

> 在node01上也执行一遍

### No:6
Deploy a `web-load-5461` pod using the `nginx:1.17` image with the labels set to `tier=web`

```shell
$ k run web-load-5461 --image=nginx:1.17 --labels tire=web
$ kg pod web-load-5461 --show-labels
NAME            READY   STATUS    RESTARTS   AGE   LABELS
web-load-5461   1/1     Running   0          12s   tire=web
```

### No:7
- Create a `static pod` on `node01` called `static-nginx` with image `nginx` and you have to make sure that it is `recreated/restarted automatically` in case of any failure happens.
首先在node01上找到config的位置, 
```shell
$ ps uax | grep kubelet
root      1799  1.2  3.0 1816748 122772 ?      Ssl   2021 154:15 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --network-plugin=cni --pod-infra-container-image=registry.aliyuncs.com/google_containers/pause:3.6
```
然后从config中找到staticPodPath
```shell
$ cat /var/lib/kubelet/config.yaml | grep staticPodPath
staticPodPath: /etc/kubernetes/manifests
```
在/etc/kubernetes/manifests里面创建yaml文件，kubelet会自动把pod拉起。

### No:8
- Create a pod called `pod-multi` with two containers, description mentioned below:
	- Container 1 => name: `container1`i image: `nginx`
	- Container 2 => name: `container2`, image: `busybox`, command sleep 4800

```
$ 
```

### No:9
- Create a pod called `delta-pod` in `defense` namespace belonging to the development environment (`env=dev`) and frontend tier(`tier=front`).
- image: nginx:1.17

```shell
$ k create namespace defense
$ k run delta-pod --image=nginx:1.17 -n defense --labels env=dev,tier=front

$ kg pod -n defense --show-labels
NAME        READY   STATUS    RESTARTS   AGE   LABELS
delta-pod   1/1     Running   0          23s   env=dev,tier=front
```

### No:10
Get the node `node01` in `JSON` format and store it in a file at `/opt/outputs/nodes-fz456723je.json`

```shell
$ kg node node01 -o json > /opt/outputs/nodes-fz456723je.json
```


### No:11
Take a backup of the `ETCD database` and save it to root with name of back `etcd-backup.db`

```shell
$ kg pod -n kube-system etcd-master01
NAME            READY   STATUS    RESTARTS   AGE
etcd-master01   1/1     Running   1          8d

$ kdesc pod etcd-master01 -n kube-system

# 从describe的输出中得到相关信息
$ cat challenge-11.sh
#!/bin/bash
ETCDCTL_API=3 etcdctl \
--endpoints=https://127.0.0.1:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
snapshot save /root/etcd-backup.db
```

### No:12
- A new application `finance-audit-pod` is deployed in `finance` namespace.
- There is something wrong with it. Identify and fix the issue.

> Note: No configuration changed allowed, you can only delete and recreate the pod (if requed)

使用`challeng-12.yaml`创建pod，等待一段时间后，会显示CrashLoopback状态，接下来分析一下。

```shell
$ kg pod -n finance
NAME                READY   STATUS             RESTARTS      AGE
finance-audit-pod   0/1     CrashLoopBackOff   5 (49s ago)   4m11s

# 从描述中找到关键性信息，`sheep`命令没找到，这里是写错了，应该是`sleep`
$ kdesc pod finance-audit-pod -n finance
...
 starting container process caused: exec: "sheep": executable file not found in $PATH: unknown
 
 $ $ kdesc pod finance-audit-pod -n finance | grep -A 3 -i command
    Command:
      sheep
      12000
    State:          Waiting
 ...

# 直接编辑，修改cmmand会报错，可以导出yaml修改之后再重建
$ kedit pod finance-audit-pod -n finance
error: pods "finance-audit-pod" is invalid
A copy of your changes has been stored to "/tmp/kubectl-edit-1086823956.yaml"
error: Edit cancelled, no valid changes were saved.


$ kg pod finance-audit-pod -n finance -o yaml > /tmp/finance-audit-pod.yaml
# 编辑/tmp/finance-audit-pod.yaml，修改为正确的命令
# 删除旧pod
$ kdel pod finance-audit-pod -n finance --grace-period=0 --force
warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
pod "finance-audit-pod" force deleted

$ ka -f /tmp/finance-audit-pod.yaml

```

### No:13
- Create a pod called `web-pod` using image `nginx`, expose it internally with a service called `web-pod-svc`.
- Check that you are able to look up the service and pod from within the cluster.
	- Use the image: `busybox:1.28` for dns lookup.
	- Record results in `/root/web-svc.svc` and `/root/web-pod.pod`

```shell
$ k run web-pod --image=nginx --dry-run=client -o yaml > challenge-13.yaml

# 编辑challenge-13.yaml，增加Service定义
```

`cat challenge-13.yaml`
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: web-pod
  name: web-pod
spec:
  containers:
  - image: nginx
    name: web-pod

---
kind: Service
apiVersion: v1
metadata:
  labels:
    run: web-pod-svc
  name: web-pod-svc
spec:
  selector:
    run: web-pod
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 80
```

```shell
# 或者，直接使用命令行方式创建
$ k run web-pod --image=nginx
$ k expose pod web-pod --name=web-pod-svc --port=80
```

```shell
$ kg pod web-pod -o wide
NAME      READY   STATUS    RESTARTS   AGE   IP             NODE     NOMINATED NODE   READINESS GATES
web-pod   1/1     Running   0          14m   10.244.2.114   node01   <none>           <none>
$ kdesc svc web-pod-svc
Name:              web-pod-svc
Namespace:         default
Labels:            run=web-pod-svc
Annotations:       <none>
Selector:          run=web-pod
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.96.242.140
IPs:               10.96.242.140
Port:              <unset>  8080/TCP
TargetPort:        80/TCP
Endpoints:         10.244.2.114:80
Session Affinity:  None
Events:            <none>
```

使用busybox测试
```shell
$ k run nslookup --image=busybox:1.28 --command sleep 4800

$ k exec nslookup -- nslookup web-pod-svc > /root/web-svc.svc

$ k exec nslookup -- nslookup 10-244-2-114.default.pod > /root/web-pod.pod
```

### No:14
- Use `JSON PATH` query to retrieve the `osImages` of all the nodes and store it in a file `"allNodes_osImage_45CVB34Ji.txt"` at `root location`.
> Note: The `osImages` are under the `nodeInfo` section under status of each `node`.

```shell
$ kubectl get nodes -o jsonpath='{.items[*].status.nodeInfo.osImage}' > /root/allNodes_osImage_45CVB34Ji.txt
```

### No:15
- Create a `PersistentVolume` with the given specification.
	- Volume Name: `pv-rnd`
	- Storage: `100Mi`
	- Access modes: `ReadWriteMany`
	- Host Path: `/pv/host_data-rnd`
	
`cat challenge-15.yaml`
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-rnd
spec:
  capacity:
    storage: 100Mi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: /pv/host_data-rnd
```

```shell
$ kdesc pv pv-rnd
Name:            pv-rnd
Labels:          <none>
Annotations:     <none>
Finalizers:      [kubernetes.io/pv-protection]
StorageClass:
Status:          Available
Claim:
Reclaim Policy:  Retain
Access Modes:    RWX
VolumeMode:      Filesystem
Capacity:        100Mi
Node Affinity:   <none>
Message:
Source:
    Type:          HostPath (bare host directory volume)
    Path:          /pv/host_data-rnd
    HostPathType:
Events:            <none>
```

### No:16
- Expose the "audit-web-app" web pod as service "audit-web-app-service" application on port 30002 on the nodes on the cluster.
> Note: The web application listens on port 80

通过`challenge-16-pre.yaml`创建`audit-web-app`

```shell
$ k expose pod audit-web-app --name=audit-web-app-service --type=NodePort --dry-run=client -o yaml > challenge-16.yaml
```

`cat challenge-16.yaml`
```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    run: audit-web-app
  name: audit-web-app-service
spec:
  selector:
    run: audit-web-app
  ports:
  - port: 8080
    protocol: TCP
    targetPort: 80
    nodePort: 30002
  type: NodePort
```


### No:17
- Taint the worker node `node01` with details provide below. Create a pod called `dev-pod-nginx` using `image=nginx`, make sure that workloads are not scheduled to this worker node(`node01`)
- Create a another pod called `prod-pod-nginx` using `image=nginx` with toleration to be scheduled on `node01`.

Details:
 key: env_type value: production, operator Equal and effect: NoSchedule
 
 先给node01打taint
 ```shell
 $ kdesc node node01 | grep -i taint
Taints:             <none>
 $ k taint node node01 env_type=production:NoSchedule
 $ kdesc node node01 | grep -i taint
Taints:             env_type=production:NoSchedule
 ```
 
 `cat challenge-17-dev.yaml`
 ```yaml
 apiVersion: v1
kind: Pod
metadata:
  labels:
    run: dev-pod-nginx
  name: dev-pod-nginx
spec:
  containers:
  - image: nginx
    name: dev-pod-nginx
 ```
 
> 删除创建反复几次，发现pod都不会调度到node01上

`cat challenge-17-prod.yaml`
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: prod-pod-nginx
  name: prod-pod-nginx
spec:
  tolerations:
  - key: "env_type"
    operator: "Equal"
    value: "production"
    effect: "NoSchedule"
  containers:
  - image: nginx
    name: prod-pod-nginx
```

> 增加了tolerations，反复试几次，发现pod只会调度到node01上