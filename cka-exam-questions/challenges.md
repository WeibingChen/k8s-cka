# CKA Exam Questions
来源：[Kubernetes CKA Exam Questions](https://www.youtube.com/playlist?list=PL6nVblW4NNAQrgSjhT8iK_v7ROIV2ikVu)

### Challenge:1
- Create a new pod called `amdin-pod` with image `busybox`.
- Allow the pod to be able to `set system_time`
- The container should `sleep for 3200 seconds`.

<details><summary>show</summary>
<p>

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
</details>

### Challenge:2
- A kubeconfig file called `test.kubeconfig` has been created in `/root/Test`.
- There is something wrong with the configuration.
- Toubelshoot and fix it.


<details><summary>show</summary>
<p>

`cat /root/TEST/test.kubeconfig`
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
...
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://master01:6443
...
```
> 发现server端口错误，正确端口应该是6443

</details>

### Challenge:3
- Create a new `deployment` called `web-proj-268`, with image `nginx:1.16` and `1 replica`.
- Next upgrade the deployment to `version 1.17` using rolling update.
- Make sure that the version upgrade is recorded in the `resource annotation`.

<details><summary>show</summary>
<p>


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
</details>

### Challenge:4
- Create a new deployment called `web-003`
- Scale the deployment to `3 replicas`
- Make sure desired number of pod always running

<details><summary>实验准备</summary>
<p>

这道题考的目的不是创建deployment，而是诊断集群错误！首先需要破坏一下集群，编辑`/etc/kubernetes/manifest/kube-controller-manager.yaml`, 将`kube-controller-manager`改为`kube-controller-man`，然后重启一下kubelet。 
</details>

<details><summary>show</summary>
<p>
按着题目要求，创建一个Deployment，镜像使用nginx:latest, replicas为3

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

首先检查deploy，这是创建成功的，但是显示pod没有创建成功。</br>
```shell
$ kg deploy
NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
web-003                  0/3     0            0           10s
```
检查下集群状态，显示controller-manager的状态为`Unhealthy`</br>
```shell
$ kg cs
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS      MESSAGE                                                                                        ERROR
controller-manager   Unhealthy   Get "https://127.0.0.1:10257/healthz": dial tcp 127.0.0.1:10257: connect: connection refused
scheduler            Healthy     ok
etcd-0               Healthy     {"health":"true","reason":""}
```
查看pod logs，没有错误信息</br>
检查一下pod events，显示`kube-controller-man`命令没有找到，
```shell
starting container process caused: exec: "kube-controller-man": executable file not found in $PATH: unknown
```
这个命令的名称是不对的，正确的是`kube-controller-manager`，需要更正一下：
找到`/etc/kubernetes/manifest/kube-controller-manager.yaml`将命令改为正确的，然后重启下kubelet。等待一下再次观察pod是否创建好了。

</details>

### Challenge:5 
- Upgrade the Cluster (`Master` and `worker` Node) from `1.18.0` to `1.19.0`.
- Make sure first `drain` both Node and make it available after upgrade.


<details><summary>show</summary>
<p>

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
</details>

### Challenge:6
- Deploy a `web-load-5461` pod using the `nginx:1.17` image with the labels set to `tier=web`


<details><summary>show</summary>
<p>

```shell
$ k run web-load-5461 --image=nginx:1.17 --labels tire=web
$ kg pod web-load-5461 --show-labels
NAME            READY   STATUS    RESTARTS   AGE   LABELS
web-load-5461   1/1     Running   0          12s   tire=web
```
</details>

### Challenge:7
- Create a `static pod` on `node01` called `static-nginx` with image `nginx` and you have to make sure that it is `recreated/restarted automatically` in case of any failure happens.


<details><summary>show</summary>
<p>

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

</details>

### Challenge:8
- Create a pod called `pod-multi` with two containers, description mentioned below:
	- Container 1 => name: `container1`i image: `nginx`
	- Container 2 => name: `container2`, image: `busybox`, command sleep 4800


<details><summary>show</summary>
<p>

```
$ 
```

</details>

### Challenge:9
- Create a pod called `delta-pod` in `defense` namespace belonging to the development environment (`env=dev`) and frontend tier(`tier=front`).
- image: nginx:1.17


<details><summary>show</summary>
<p>

```shell
$ k create namespace defense
$ k run delta-pod --image=nginx:1.17 -n defense --labels env=dev,tier=front

$ kg pod -n defense --show-labels
NAME        READY   STATUS    RESTARTS   AGE   LABELS
delta-pod   1/1     Running   0          23s   env=dev,tier=front
```
</details>

### Challenge:10
Get the node `node01` in `JSON` format and store it in a file at `/opt/outputs/nodes-fz456723je.json`


<details><summary>show</summary>
<p>

```shell
$ kg node node01 -o json > /opt/outputs/nodes-fz456723je.json
```
</details>

### Challenge:11
- Take a backup of the `ETCD database` and save it to root with name of back `etcd-backup.db`

<details><summary>show</summary>
<p>

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
</details>

### Challenge:12
- A new application `finance-audit-pod` is deployed in `finance` namespace.
- There is something wrong with it. Identify and fix the issue.

> Note: No configuration changed allowed, you can only delete and recreate the pod (if requed)

<details><summary>准备实验</summary>
<p>

使用`challeng-12.yaml`创建pod，等待一段时间后，会显示CrashLoopback状态，接下来分析一下。

</details>

<details><summary>show</summary>
<p>


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
</details>

### Challenge:13
- Create a pod called `web-pod` using image `nginx`, expose it internally with a service called `web-pod-svc`.
- Check that you are able to look up the service and pod from within the cluster.
	- Use the image: `busybox:1.28` for dns lookup.
	- Record results in `/root/web-svc.svc` and `/root/web-pod.pod`


<details><summary>show</summary>
<p>

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

</details>

### Challenge:14
- Use `JSON PATH` query to retrieve the `osImages` of all the nodes and store it in a file `"allNodes_osImage_45CVB34Ji.txt"` at `root location`.
> Note: The `osImages` are under the `nodeInfo` section under status of each `node`.


<details><summary>show</summary>
<p>

```shell
$ kubectl get nodes -o jsonpath='{.items[*].status.nodeInfo.osImage}' > /root/allNodes_osImage_45CVB34Ji.txt
```
</details>

### Challenge:15
- Create a `PersistentVolume` with the given specification.
	- Volume Name: `pv-rnd`
	- Storage: `100Mi`
	- Access modes: `ReadWriteMany`
	- Host Path: `/pv/host_data-rnd`
	

<details><summary>show</summary>
<p>

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
</details>

### Challenge:16
- Expose the "audit-web-app" web pod as service "audit-web-app-service" application on port 30002 on the nodes on the cluster.
> Note: The web application listens on port 80


<details><summary>show</summary>
<p>

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
</details>

### Challenge:17
- Taint the worker node `node01` with details provide below. Create a pod called `dev-pod-nginx` using `image=nginx`, make sure that workloads are not scheduled to this worker node(`node01`)
- Create a another pod called `prod-pod-nginx` using `image=nginx` with toleration to be scheduled on `node01`.

Details:
 key: `env_type` value: `production`, operator `Equal` and effect: `NoSchedule`

<details><summary>实验准备</summary>
<p>
 先给node01打taint
 ```shell
 $ kdesc node node01 | grep -i taint
Taints:             <none>
 $ k taint node node01 env_type=production:NoSchedule
 $ kdesc node node01 | grep -i taint
Taints:             env_type=production:NoSchedule
 ```
 </details>

<details><summary>show</summary>
<p>


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

</details>

### Challenge:18
- Create a Pod called `pod-jxc56fv`, using details metioned below:
	1. securityContext: runAsUser:1000, fsGroup:2000
	2. image=redis:alpine


<details><summary>show</summary>
<p>

`cat challenge-18.yaml`
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: pod-jxc56fv
  name: pod-jxc56fv
spec:
  securityContext:
    runAsUser: 1000
    fsGroup: 2000
  containers:
  - image: redis:alpine
    name: pod-jxc56fv
```

```shell
$ k exec pod-jxc56fv -- whoami
whoami: unknown uid 1000
command terminated with exit code 1
```

</details>

### Challenge:19
- Worker Node "node01" not responding, have a look and fix the issue.
<details><summary>实验准备</summary>
<p>

登录到node01节点， 提前把kubelet停掉`systemctl stop kubelet`
</details>
<details><summary>show</summary>
<p>


```shell
$ $ kg nodes
NAME       STATUS     ROLES                  AGE   VERSION
master01   Ready      control-plane,master   9d    v1.23.1
node01     NotReady   <none>                 9d    v1.23.1

# describe未发现异常
$ kdesc node node01

# 登录到node01上，查看kubelet的状态，发现kubelet的状态为stop
node01 ] $ systemctl status kubelet
Active: inactive (dead) since Thu 2022-01-06 20:59:16 CST; 3min 55s ago

# 启动kubelet
node01 ] $ systemctl start kubelet
# 回到master01节点查看
$ kg nodes
NAME       STATUS   ROLES                  AGE   VERSION
master01   Ready    control-plane,master   9d    v1.23.1
node01     Ready    <none>                 9d    v1.23.1
```


</details>

### Challenge:20
- List the `InternalIp` of all nodes of the cluster. Save the result to a file `/root/Internal_IP_List`.
- Answere should be int the format: InternalIP of First Node\<space\>InternalIP of SecondNode (in a single line)

<details><summary>show</summary>
<p>

```shell
$ kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}' >/root/Internal_IP_List
```
[cheat sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

</details>

### Challenge:21
- One Static Pod `"web-static"`, image busybox, is currently running on controlpane node, move that static pod to run on node01, don't need to do any other changes.
> Note: Static Pod name should be changed from web-static-controlplane to web-static-node01.


<details><summary>show</summary>
<p>

首先找到manifest的路径
```shell
$ $ kg pod web-static-master01 -o wide
NAME                  READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
web-static-master01   1/1     Running   0          21s   10.244.0.6   master01   <none>           <none>


# 从输出中找到---config的配置参数
$ ps axu | grep /usr/bin/kubelet
# 找到manifest的路径
$ grep -i static /var/lib/kubelet/config.yaml
staticPodPath: /etc/kubernetes/manifests
# 找到web-static的yaml文件
$ grep -i 'web-static' /etc/kubernetes/manifests/*
/etc/kubernetes/manifests/challenge-21.yaml:    run: web-static
/etc/kubernetes/manifests/challenge-21.yaml:  name: web-static
/etc/kubernetes/manifests/challenge-21.yaml:    name: web-static
# 将改文件挪到tmp目录
$ mv /etc/kubernetes/manifests/challenge-21.yaml /tmp/.
# 将/tmp/challenge-21.yaml拷贝到node01上一份，或者在node01直接编辑文件，内容相同
$ scp /tmp/challenge-21.yaml node01:/etc/kubernetes/manifests/
# 再次查看
$ kg pod web-static-node01 -o wide
NAME                READY   STATUS    RESTARTS   AGE   IP             NODE     NOMINATED NODE   READINESS GATES
web-static-node01   1/1     Running   0          13s   10.244.2.126   node01   <none>           <none>
```
</details>

### Challenge:22
- A new user named `"alok"` need to be created. Grant him access to the cluster.
- User `"alok"` should have permission to `create`, `list`, `get`, `update` and `delete` pods in the `space` namespace.
- The private key exists at location: `/root/alok.key` and csr at `/root/alok.csr.`


<details><summary>准备环境</summary>
<p>
首先准备一下实验环境，生成私钥和证书CSR

```shell
# 生成CA证书私钥，密码123456
$ openssl genrsa -des3 -out alok.key 2048
# 生成CA证书
$ openssl req -new subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=alok.com" -key alok.key -out alok.csr
# 创建一个namespce 'space'
$ k create namespace space
```

</details>

<details><summary>show</summary>
<p>

接下来进行实验，首先创建csr资源：
```yaml
kind: CertificateSigningRequest
metadata:
  name: alok
spec:
  request: <cat alok.csr | base64 | tr -d "\n">
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
```

```shell
# 目前状态还是Pending
$ kg csr
NAME   AGE   SIGNERNAME                            REQUESTOR          REQUESTEDDURATION   CONDITION
alok   5s    kubernetes.io/kube-apiserver-client   kubernetes-admin   <none>              Pending
# 测试一下能否访问space中的pods
$ kg pod -n space --as alok
Error from server (Forbidden): pods is forbidden: User "alok" cannot list resource "pods" in API group "" in the namespace "space"

# 先对alok的csr请求通过
$ k certificate approve alok
# 状态变为Approved,Issued
$ kg csr
NAME   AGE     SIGNERNAME                            REQUESTOR          REQUESTEDDURATION   CONDITION
alok   3m41s   kubernetes.io/kube-apiserver-client   kubernetes-admin   <none>              Approved,Issued
```

接下来创建Role和RoleBinding
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: space
  name: pod-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["create", "get", "update" ,"delete", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  namespace: space
  name: read-pods
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: User
  name: alok
  apiGroup: rbac.authorization.k8s.io
```

```shell
$ kg role -n space
NAME         CREATED AT
pod-reader   2022-01-07T01:47:30Z
$ kg rolebinding -n space
NAME        ROLE              AGE
read-pods   Role/pod-reader   45s
```
再次测试下：
```shell
$ kg pod -n space --as alok
No resources found in space namespace.
# 其他几个verb也可以试下
$ k auth can-i get pods -n space --as alok
yes
```

</details>

### Challenge:23
- Create a PersistentVolume, PersistentVolumeClaim and Pod with below specifications:
- PV
```shell
=====
Volume Name: mypvlog
Storage: 100Mi
Access Modes: ReadWriteMany
Host Path: /pv/log
Reclaim Policy: Retain
```
- PVC
```shell
=====
Volume Name: pv-claim-log
Storage Request: 50Mi
Access Modes: ReadWriteMany
```
- Pod
```shell
=====
Name: my-nginx-pod
Image Name: nginx
Volume: PersistentVolumeClaim=pv-claim-log
Volume Mount: /log
```
<details><summary>show</summary>
<p>

`cat challenge-23.yaml`

</details>

### Challenge:24
- Worker Node "node01" not respnding, have a look and fix the issue.

<details><summary>实验环境准备</summary>
<p>

```shell
修改node01上kubelet的--config文件，将clientCAFile对应的字段修改为：/etc/kubernetes/pki/HEY_THERE_ARE_YOU_LOOKING_FOR_ME.crt， 然后重启kubelet。
```
</details>

<details><summary>show</summary>
<p>

这题第二次出现，不过这次重启kubelet无效，需要继续排查
```shell
$  kg nodes
NAME       STATUS     ROLES                  AGE   VERSION
master01   Ready      control-plane,master   9d    v1.23.1
node01     NotReady   <none>                 9d    v1.23.1
```
登录node01
```shell
$  systemctl status kubelet.service
● kubelet.service - kubelet: The Kubernetes Node Agent
   Loaded: loaded (/usr/lib/systemd/system/kubelet.service; enabled; vendor preset: disabled)
  Drop-In: /usr/lib/systemd/system/kubelet.service.d
           └─10-kubeadm.conf
   Active: activating (auto-restart) (Result: exit-code) since Fri 2022-01-07 10:58:18 CST; 2s ago
     Docs: https://kubernetes.io/docs/
  Process: 2853 ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS (code=exited, status=1/FAILURE)
 Main PID: 2853 (code=exited, status=1/FAILURE)

Jan 07 10:58:18 node01 systemd[1]: kubelet.service: main process exited, code=exited, status=1/FAILURE
Jan 07 10:58:18 node01 systemd[1]: Unit kubelet.service entered failed state.
Jan 07 10:58:18 node01 systemd[1]: kubelet.service failed.

# 先重启写一下，发现没有作用
```
接下来查看一下日志
```shell
# 查看日志
$ journalctl -u kubelet
# 在日志中发下了如下的错误提示, ca文件路径不对
Jan 07 11:00:52 node01 kubelet[3404]: E0107 11:00:52.296988    3404 server.go:279] "Failed to construct kubelet dependencies" err="unable to load client CA file /etc/kubernetes/pki/HEY_THERE_ARE_YOU_L..."

# 下一步，看下kubelet的--config配置文件的内容 (额可以通过ps找到kubelet的启动参数)
$ grep -C 5 HEY_THERE_ARE_YOU /var/lib/kubelet/config.yaml
    enabled: true
  x509:
    clientCAFile: /etc/kubernetes/pki/HEY_THERE_ARE_YOU_LOOKING_FOR_ME.crt
authorization:
  mode: Webhook
# 将这个路径改为/etc/kubernetes/pki/ca.crt, 然后重启
$ kg pod
NAME       STATUS   ROLES                  AGE   VERSION
master01   Ready    control-plane,master   9d    v1.23.1
node01     Ready    <none>                 9d    v1.23.1
```

</details>

### Challenge:25
- A pod `"my-nginx-pod"` (`image=nginx`) in `custom` namespaces is not running. Find the problem and fix it and make it running.
> Note: All the supported definition files has been placed at root.


<details><summary>实验准备</summary>
<p>

```shell
# 创建custom namespace
$ kc namespace custom
```
创建pod
`cat challenge-25-pod.yaml`
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-nginx-pod
  namespace: custom
spec:
  volumes:
  - name: mypod
    persistentVolumeClaim:
      claimName: pv-claim-log
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: mypod
      mountPath: /log
```
`cat challenge-25-pvc.yaml`
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-nginx-pod
  namespace: custom
spec:
  volumes:
  - name: mypod
    persistentVolumeClaim:
      claimName: pv-claim-log
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: mypod
      mountPath: /log
```
</details>

<details><summary>show</summary>
<p>

下面开始分析问题：
```shell
$ kg pod -n custom
NAME           READY   STATUS    RESTARTS   AGE
my-nginx-pod   0/1     Pending   0          59m

# kdesc显示有错误，缺少对应的pvc
$ kdesc pod -n custom
default-scheduler  0/3 nodes are available: 3 persistentvolumeclaim "pv-claim-log" not found.

# 查看pvc及pv，发现有定义，但是在default名称空间，所以需要修正
kg pvc -A
NAMESPACE   NAME           STATUS   VOLUME    CAPACITY   ACCESS MODES   STORAGECLASS   AGE
default     pv-claim-log   Bound    mypvlog   100Mi      RWX                           113s

# root下有对应pv和pvc的yaml文件，需要修改pvc的namespace，然后重新应用（删除之前的）
```
</details>

### Challenge:26
- Create a multi-container pod, `"multi-pod"` in `development` namespace using images: `nginx` and `redis`.

<details><summary>show</summary>
<p>

`cat challenge-26.yaml`
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: multi-pod
  name: multi-pod
  namespace: development
spec:
  containers:
  - image: nginx
    name: multi-nginx
  - image: redis
    name: multi-redis
```
</details>

### Challenge:27
- A pod `"nginx-pod" (image=nginx)` in `default` namespace is not running.
- Find the problem and fix it and make it running.

<details><summary>实验环境准备</summary>
<p>

1. 给node打taint
```shell
$ k taint node node01 color=blue:NoSchedule
$ k taint node node02 color=yellow:NoSchedule
```
2. 使用`challenge-27.yaml`创建资源

</details>
<details><summary>show</summary>
<p>

接下来分析问题：
```shell
$ kg pod nginx-pod
NAME        READY   STATUS    RESTARTS   AGE
nginx-pod   0/1     Pending   0          2m25s

# 看下描述，发现有如下类似的报错，没有可以调度的pod
$ kdesc pod nginx-pod
 0/3 nodes are available: 1 node(s) had taint {color: blue}, that the pod didn't tolerate, 1 node(s) had taint {color: yellow}, that the pod didn't tolerate, 1 node(s) had taint {node-role.kubernetes.io/master: }, that the pod didn't tolerate.

# 打个tolerations的patch
$ k patch pod nginx-pod -p "$(cat ./challenge-27-patch.yaml)"
```

`cat challenge-27-patch.yaml`
```yaml
spec:
  tolerations:
  - key: "color"
    operator: "Equal"
    value: "blue"
    effect: "NoSchedule"
```
</details>