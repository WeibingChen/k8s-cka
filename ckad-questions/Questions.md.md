

[原文：Practice Enough With These 150 Questions for the CKAD Exam](https://medium.com/bb-tutorials-and-thoughts/practice-enough-with-these-questions-for-the-ckad-exam-2f42d1228552)

## Curriculum:

- **[Core Concepts (13%)](#1)**

- **[Multi-Container Pods (10%)](#2)**

- **Pod Design (20%)**

- **State Persistence (8%)**

- **Configuration (18%)**

- **Observability (18%)**

- **Services and Networking (13%)**

  

## Core Concepts (13%)<div id="1">1</div>
 Practice questions based on these concepts
* Understand Kubernetes API Primitives
* Create and Configure Basic Pods
### 1. List all the namespaces in the cluster
<details><summary>show</summary>
<p>

```bash
kubectl get namespaces
kubectl get ns  
```

</p>
</details>
### 2. List all the pods in all namespaces
<details><summary>show</summary>
<p>

```bash
kubectl get po --all-namespaces
or 
kubectl get po -A
```

</p>
</details>
### 3. List all the pods in the particular namespace
<details><summary>show</summary>
<p>

```bash
// foo namespace
kubectl get po -n foo
```

</p>
</details>
### 4. List all the services in the particular namespace
<details><summary>show</summary>
<p>

```bash
// foo namespace
kubectl get svc -n foo
or 
kubectl get svc -n foo
```

</p>
</details>
### 5. List all the pods showing name and namespace with a json path expression
<details><summary>show</summary>
<p>

```bash
kubectl get pods -o=jsonpath='{range .items[*]}{@.metadata.namespace}/{@.metadata.name}{"\n"}{end}'

or

kubectl get pods -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name"
```

</p>
</details>
### 6. Create an nginx pod in a default namespace and verify the pod running
<details><summary>show</summary>
<p>

```bash
// creating a pod
kubectl run nginx --image=nginx --restart=Never
// List the pod
kubectl get po
```

</p>
</details>
### 7. Create the same nginx pod with a yaml file
<details><summary>show</summary>
<p>

```bash
// get the yaml file with --dry-run flag
kubectl run nginx --image=nginx --restart=Never --dry-run=client -oyaml > nginx-pod.yaml
// cat nginx-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
// create a pod 
kubectl create -f nginx-pod.yaml
```

</p>
</details>

### 8. Output the yaml file of the pod you just created
<details><summary>show</summary>
<p>

```bash
kubectl get po nginx -oyaml
```

</p>
</details>

### 9. ~~Output the yaml file of the pod you just created without the cluster-specific information~~
> 注：`--export` option has been deprecated in version 1.14 and removed in version 1.18.
<details><summary>show</summary>
<p>

```bash
kubectl get po nginx -o yaml --export
```

</p>
</details>

### 10 Get the complete details of the pod you just created
> 注： `describe`命令

<details><summary>show</summary>
<p>

```bash
kubectl describe pod nginx
```

</p>
</details>

### 11. Delete the pod you just created
<details><summary>show</summary>
<p>

```bash
kubectl delete po nginx
kubectl delete -f nginx-pod.yaml
```

</p>
</details>

### 12. Delete the pod you just created without any delay (force delete)

> 两个选项 --force --grace-period=0
<details><summary>show</summary>
<p>

```bash
kubectl delete po nginx --grace-period=0 --force
```

</p>
</details>

### 13. Create the nginx pod with version 1.17.4 and expose it on port 80
> --port 选项
<details><summary>show</summary>
<p>

```bash
kubectl run nginx --image=nginx:1.17.4 --restart=Never --port=80
```

</p>
</details>

### 14. Change the Image version to 1.15-alpine for the pod you just created and verify the image version is updated

<details><summary>show</summary>
<p>

```bash
kubectl set image pod/nginx nginx=nginx:1.15-alpine
kubectl describe po nginx

// another way it will open vi editor and change the version
kubeclt edit po nginx
kubectl describe po nginx

// 或者 生成文件，编辑文件然后apply
kubectl get pod nginx -oyaml > nginx.yaml
// 修改文件中的image版本
kubectl apply -f ./nginx.yaml
```

</p>
</details>

### 15. Change the Image version back to 1.17.1 for the pod you just updated and observe the changes

<details><summary>show</summary>
<p>

```bash
kubectl set image pod/nginx nginx=nginx:1.17.1
kubectl describe po nginx
kubectl get po nginx -w # watch it
```

</p>
</details>

### 16. Check the Image version without the describe command
<details><summary>show</summary>
<p>

```bash
kubectl get po nginx -o jsonpath='{.spec.containers[].image}{"\n"}'
```

</p>
</details>

### 17. Create the nginx pod and execute the simple shell on the pod
<details><summary>show</summary>
<p>

```bash
// creating a pod
kubectl run nginx --image=nginx --restart=Never
// exec into the pod
kubectl exec -it nginx -- /bin/sh
```

</p>
</details>

### 18. Get the IP Address of the pod you just created
<details><summary>show</summary>
<p>

```bash
kubectl get po nginx -o wide
// 或者：
kg pod nginx -o jsonpath='{.status.podIP}'
```

</p>
</details>

### 19. Create a busybox pod and run command ls while creating it and check the logs
<details><summary>show</summary>
<p>

```bash
kubectl run busybox --image=busybox --restart=Never -- ls
kubectl logs busybox
```

</p>
</details>

### 20. If pod crashed check the previous logs of the pod
>  选项 -p, --previous=false: If true, print the logs for the previous instance of the container in a pod if it exists.
<details><summary>show</summary>
<p>

```bash
kubectl logs busybox -p
```

</p>
</details>

### 21. Create a busybox pod with command sleep 3600
<details><summary>show</summary>
<p>

```bash
kubectl run busybox --image=busybox --restart=Never -- /bin/sh -c "sleep 3600"
// 或者
kubectl run busybox --image=busybox --restart=Never --command sleep 3600
```

</p>
</details>

### 22. Check the connection of the nginx pod from the busybox pod

<details><summary>show</summary>
<p>

```bash
kubectl get po nginx -o wide
// 或
kg pod nginx -o jsonpath='{.status.podIP}'
// check the connection
kubectl exec -it busybox -- wget -o- &lt;IP Address>
```

</p>
</details>

### 23. Create a busybox pod and echo message ‘How are you’ and delete it manually
<details><summary>show</summary>
<p>

```bash
kubectl run busybox --image=nginx --restart=Never -it -- echo "How are you"
kubectl delete po busybox
```

</p>
</details>

### 24. Create a busybox pod and echo message ‘How are you’ and have it deleted immediately
> --rm选项

<details><summary>show</summary>
<p>

```bash
// notice the --rm flag
kubectl run busybox --image=nginx --restart=Never -it --rm -- echo "How are you"
```

</p>
</details>

### 25. Create an nginx pod and list the pod with different levels of verbosity
> --v=0: 指定输出日志的级别。 

<details><summary>show</summary>
<p>

```bash
// create a pod
kubectl run nginx --image=nginx --restart=Never --port=80
// List the pod with different verbosity
kubectl get po nginx --v=7
kubectl get po nginx --v=8
kubectl get po nginx --v=9
```

</p>
</details>

### 26. List the nginx pod with custom columns POD_NAME and POD_STATUS
<details><summary>show</summary>
<p>

```bash
kubectl get po -o=custom-columns="POD_NAME:.metadata.name, POD_STATUS:.status.containerStatuses[].state"
```

</p>
</details>

### 27. List all the pods sorted by name
<details><summary>show</summary>
<p>

```bash
kubectl get pods --sort-by=.metadata.name
```

</p>
</details>

### 28. List all the pods sorted by created timestamp
<details><summary>show</summary>
<p>

```bash
kubectl get pods--sort-by=.metadata.creationTimestamp
```

</p>
</details>


## Multi-Container Pods (10%)<div id="2"></div>
Practice questions based on these concepts

* Understand multi-container pod design patterns (eg: ambassador, adaptor, sidecar)

### 29. Create a Pod with three busy box containers with commands "ls; sleep 3600;", "echo Hello World; sleep 3600;" and "echo this is the third container; sleep 3600" respectively and check the status

<details><summary>show</summary>
<p>

```bash
// first create single container pod with dry run flag
kubectl run busybox --image=busybox --restart=Never --dry-run=client -oyaml -- bin/sh -c "ls;sleep 3600;" > multi-container.yaml
// edit the pod to following yaml and create it
kubectl create -f multi-container.yaml
kubectl get po busybox
```

</p>
</details>


### 30. Check the logs of each container that you just created

<details><summary>show</summary>
<p>

```bash
kubectl logs busybox -c busybox1
kubectl logs busybox -c busybox2
kubectl logs busybox -c busybox3
```

</p>
</details>

### 31. Check the previous logs of the second container busybox2 if any

<details><summary>show</summary>
<p>

```bash
kubectl logs busybox -c busybox2 --previous
```

</p>
</details>

### 32. Run command ls in the third container busybox3 of the above pod

<details><summary>show</summary>
<p>

```bash
kubectl exec busybox -c busybox3 -- ls
```

</p>
</details>

### 33. Show metrics of the above pod containers and puts them into the file.log and verify
> 1. 集群已经安装了metrics
> 2. 等pod启动之后需要待一段时间才能有结果统计，可以使用watch观察
> 3. 在pod结束之前，running状态时才能统计

<details><summary>show</summary>
<p>

```bash
kubectl top pod busybox --containers
// putting them into file
kubectl top pod busybox --containers > file.log
cat file.log
```

</p>
</details>

### 34. Create a Pod with main container busybox and which executes this "while true; do echo 'Hi I am from Main container' >> /var/log/index.html; sleep 5; done" and with sidecar container with nginx image which exposes on port 80. Use emptyDir Volume and mount this volume on path /var/log for busybox and on path /usr/share/nginx/html for nginx container. Verify both containers are running.

<details><summary>show</summary>
<p>

```bash
// create an initial yaml file with this
kubectl run multi-cont-pod --image=busbox --restart=Never --dry-run -o yaml > multi-container.yaml
// edit the yml as below and create it
kubectl create -f multi-container.yaml
kubectl get po multi-cont-pod
```

</p>
</details>

[multi-container.yaml](./yaml/multi-container.yaml)


### 35. Exec into both containers and verify that main.txt exist and query the main.txt from sidecar container with curl localhost
> 这里的main.txt应该是index.html

<details><summary>show</summary>
<p>

```bash
// exec into main container
kubectl exec -it  multi-cont-pod -c main-container -- sh
cat /var/log/main.txt
// exec into sidecar container
kubectl exec -it  multi-cont-pod -c sidecar-container -- sh
cat /usr/share/nginx/html/index.html
// install curl and get default page
kubectl exec -it  multi-cont-pod -c sidecar-container -- sh
// apt-get update && apt-get install -y curl
// curl localhost
```

</p>
</details>


## Pod Design (20%)
Practice questions based on these concepts

* Understand how to use Labels, Selectors and Annotations
* Understand Deployments and how to perform rolling updates
* Understand Deployments and how to perform rollbacks
* Understand Jobs and CronJobs

### 36. Get the pods with label information

<details><summary>show</summary>
<p>

```bash
kubectl get pods --show-labels
```

</p>
</details>

### 37. Create 5 nginx pods in which two of them is labeled env=prod and three of them is labeled env=dev

<details><summary>show</summary>
<p>


```bash
kubectl run nginx-dev1 --image=nginx --restart=Never --labels=env=dev
kubectl run nginx-dev2 --image=nginx --restart=Never --labels=env=dev
kubectl run nginx-dev3 --image=nginx --restart=Never --labels=env=dev
kubectl run nginx-prod1 --image=nginx --restart=Never --labels=env=prod
kubectl run nginx-prod2 --image=nginx --restart=Never --labels=env=prod
```


</p>
</details>

### 38. Verify all the pods are created with correct labels

<details><summary>show</summary>
<p>


```bash
kubeclt get pods --show-labels
```

</p>
</details>

### 39. Get the pods with label env=dev

<details><summary>show</summary>
<p>

```bash
kubectl get pods -l env=dev
```

</p>
</details>

### 40. Get the pods with label env=dev and also output the labels

<details><summary>show</summary>
<p>

```bash
kubectl get pods -l env=dev --show-labels
```

</p>
</details>

### 41. Get the pods with label env=prod

<details><summary>show</summary>
<p>

```bash
kubectl get pods -l env=prod
```

</p>
</details>

### 42. Get the pods with label env=prod and also output the labels

<details><summary>show</summary>
<p>

```bash
kubectl get pods -l env=prod --show-labels
```

</p>
</details>

### 43. Get the pods with label env

<details><summary>show</summary>
<p>

```bash
kubectl get pods -l env
```

</p>
</details>

### 44. Get the pods with labels env=dev and env=prod

<details><summary>show</summary>
<p>

```bash
kubectl get pods -l 'env in (dev,prod)'
```

</p>
</details>

### 45. Get the pods with labels env=dev and env=prod and output the labels as well

<details><summary>show</summary>
<p>

```bash
kubectl get pods -l 'env in (dev,prod)' --show-labels
```

</p>
</details>

### 46. Change the label for one of the pod to env=uat and list all the pods to verify

<details><summary>show</summary>
<p>

```bash
kubectl label pod/nginx-dev3 env=uat --overwrite
kubectl get pods --show-labels
```

</p>
</details>

### 47. Remove the labels for the pods that we created now and verify all the labels are removed

<details><summary>show</summary>
<p>

```bash
kubectl label pod nginx-dev{1..3} env-
kubectl label pod nginx-prod{1..2} env-
kubectl get po --show-labels
```

</p>
</details>

### 48. Let’s add the label app=nginx for all the pods and verify

<details><summary>show</summary>
<p>

```bash
kubectl label pod nginx-dev{1..3} app=nginx
kubectl label pod nginx-prod{1..2} app=nginx
kubectl get po --show-labels
```

</p>
</details>

### 49. Get all the nodes with labels (if using minikube you would get only master node)

<details><summary>show</summary>
<p>

```bash
kubectl get nodes --show-labels
```

</p>
</details>

### 50. Label the node (minikube if you are using) nodeName=nginxnode

<details><summary>show</summary>
<p>

```bash
kubectl label node minikube nodeName=nginxnode
```

</p>
</details>

### 51. Create a Pod that will be deployed on this node with the label nodeName=nginxnode

<details><summary>show</summary>
<p>

```bash
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > pod.yaml
// add the nodeSelector like below and create the pod
kubectl create -f pod.yaml
```

</p>
</details>

[pod.yaml](./yaml/pod.yaml)

> 注意这里的nodeName是标签的名字，不是node的Name，spec
.nodeName也可以用于pod的分配，但是是直接分配，跳过调度。
### 52. Verify the pod that it is scheduled with the node selector

<details><summary>show</summary>
<p>

```bash
kubectl describe po nginx | grep Node-Selectors
```

</p>
</details>


### 53. Verify the pod nginx that we just created has this label

<details><summary>show</summary>
<p>

```bash
kubectl describe po nginx | grep Labels
```

</p>
</details>

> 没有看到哪里需要给pod打标签，默认这里应该是run=nginx，和node的标签没有关系

### 54. Annotate the pods with name=webapp

<details><summary>show</summary>
<p>

```bash
kubectl annotate pod nginx-dev{1..3} name=webapp
kubectl annotate pod nginx-prod{1..2} name=webapp
```

</p>
</details>

> 这里用的复数，指上面那5个nginx-pod*吧

### 55. Verify the pods that have been annotated correctly

<details><summary>show</summary>
<p>

```bash
kubectl describe po nginx-dev{1..3} | grep -i annotations
kubectl describe po nginx-prod{1..2} | grep -i annotations
```

</p>
</details>

### 56. Remove the annotations on the pods and verify

<details><summary>show</summary>
<p>

```bash
kubectl annotate pod nginx-dev{1..3} name-
kubectl annotate pod nginx-prod{1..2} name-
kubectl describe po nginx-dev{1..3} | grep -i annotations
kubectl describe po nginx-prod{1..2} | grep -i annotations
```

</p>
</details>

### 57. Remove all the pods that we created so far

<details><summary>show</summary>
<p>

```bash
kubectl delete po --all
```

</p>
</details>

### 58. Create a deployment called webapp with image nginx with 5 replicas

<details><summary>show</summary>
<p>

```bash
kubectl create deploy webapp --image=nginx --dry-run -o yaml > webapp.yaml
// change the replicas to 5 in the yaml and create it
kubectl create -f webapp.yaml
```

</p>
</details>

[webapp.yaml](./yaml/webapp.yaml)

### 59. Get the deployment you just created with labels

<details><summary>show</summary>
<p>

```bash
kubectl get deploy webapp --show-labels
```

</p>
</details>

### 60. Output the yaml file of the deployment you just created

<details><summary>show</summary>
<p>

```bash
kubectl get deploy webapp -o yaml
```

</p>
</details>

### 61. Get the pods of this deployment

<details><summary>show</summary>
<p>

```bash
// get the label of the deployment
kubectl get deploy --show-labels
// get the pods with that label
kubectl get pods -l app=webapp
```

</p>
</details>

### 62. Scale the deployment from 5 replicas to 20 replicas and verify

<details><summary>show</summary>
<p>

```bash
kubectl scale deploy webapp --replicas=20
kubectl get po -l app=webapp
```

</p>
</details>

### 63. Get the deployment rollout status

<details><summary>show</summary>
<p>

```bash
kubectl rollout status deploy webapp
```

</p>
</details>

### 64. Get the replicaset that created with this deployment

<details><summary>show</summary>
<p>

```bash
kubectl get rs -l app=webapp
```

</p>
</details>

### 65. Get the yaml of the replicaset and pods of this deployment

<details><summary>show</summary>
<p>

```bash
kubectl get rs -l app=webapp -o yaml
kubectl get po -l app=webapp -o yaml
```

</p>
</details>

### 66. Delete the deployment you just created and watch all the pods are also being deleted

<details><summary>show</summary>
<p>

```bash
kubectl delete deploy webapp
kubectl get po -l app=webapp -w
```

</p>
</details>

### 67. Create a deployment of webapp with image nginx:1.17.1 with container port 80 and verify the image version

<details><summary>show</summary>
<p>

```bash
kubectl create deploy webapp --image=nginx:1.17.1 --dry-run -o yaml > webapp.yaml
// add the port section and create the deployment
kubectl create -f webapp.yaml
// verify
kubectl describe deploy webapp | grep Image
```

</p>
</details>

[webapp.yaml](./yaml/webapp2.yaml)

### 68. Update the deployment with the image version 1.17.4 and verify

<details><summary>show</summary>
<p>

```bash
kubectl set image deploy/webapp nginx=nginx:1.17.4
kubectl describe deploy webapp | grep Image
```

</p>
</details>

### 69. Check the rollout history and make sure everything is ok after the update

<details><summary>show</summary>
<p>

```bash
kubectl rollout history deploy webapp
kubectl get deploy webapp --show-labels
kubectl get rs -l app=webapp
kubectl get po -l app=webapp
```

</p>
</details>

### 70. Undo the deployment to the previous version 1.17.1 and verify Image has the previous version

<details><summary>show</summary>
<p>

```bash
kubectl rollout undo deploy webapp
kubectl describe deploy webapp | grep Image
```

</p>
</details>

### 71. Update the deployment with the image version 1.16.1 and verify the image and also check the rollout history

<details><summary>show</summary>
<p>

```bash
kubectl set image deploy/webapp nginx=nginx:1.16.1
kubectl describe deploy webapp | grep Image
kubectl rollout history deploy webapp
```

</p>
</details>

### 72. Update the deployment to the Image 1.17.1 and verify everything is ok

<details><summary>show</summary>
<p>

```bash
kubectl rollout undo deploy webapp --to-revision=3
kubectl describe deploy webapp | grep Image
kubectl rollout status deploy webapp
```

</p>
</details>

### 73. Update the deployment with the wrong image version 1.100 and verify something is wrong with the deployment

<details><summary>show</summary>
<p>

```bash
kubectl set image deploy/webapp nginx=nginx:1.100
kubectl rollout status deploy webapp (still pending state)
kubectl get pods (ImagePullErr)
```

</p>
</details>

### 74. Undo the deployment with the previous version and verify everything is Ok

<details><summary>show</summary>
<p>

```bash
kubectl rollout undo deploy webapp
kubectl rollout status deploy webapp
kubectl get pods
```

</p>
</details>

### 75. Check the history of the specific revision of that deployment

<details><summary>show</summary>
<p>

```bash
kubectl rollout history deploy webapp --revision=7
```

</p>
</details>

### 76. Pause the rollout of the deployment

<details><summary>show</summary>
<p>

```bash
kubectl rollout pause deploy webapp
```

</p>
</details>

### 77. Update the deployment with the image version latest and check the history and verify nothing is going on

<details><summary>show</summary>
<p>

```bash
kubectl set image deploy/webapp nginx=nginx:latest
kubectl rollout history deploy webapp (No new revision)
```

</p>
</details>

### 78. Resume the rollout of the deployment

<details><summary>show</summary>
<p>

```bash
kubectl rollout resume deploy webapp
```

</p>
</details>

### 79. Check the rollout history and verify it has the new version

<details><summary>show</summary>
<p>

```bash
kubectl rollout history deploy webapp
kubectl rollout history deploy webapp --revision=9
```

</p>
</details>

### 80. Apply the autoscaling to this deployment with minimum 10 and maximum 20 replicas and target CPU of 85% and verify hpa is created and replicas are increased to 10 from 1

<details><summary>show</summary>
<p>

```bash
kubectl autoscale deploy webapp --min=10 --max=20 --cpu-percent=85
kubectl get hpa
kubectl get pod -l app=webapp
```

</p>
</details>

### 81. Clean the cluster by deleting deployment and hpa you just created

<details><summary>show</summary>
<p>

```bash
kubectl delete deploy webapp
kubectl delete hpa webapp
```

</p>
</details>

### 82. Create a Job with an image node which prints node version and also verifies there is a pod created for this job

<details><summary>show</summary>
<p>

```bash
kubectl create job nodeversion --image=node -- node -v
kubectl get job -w
kubectl get pod
```

</p>
</details>

> 这里的node是指NodeJS

### 83. Get the logs of the job just created

<details><summary>show</summary>
<p>

```bash
kubectl logs &lt;pod name> // created from the job
```

</p>
</details>

### 84.Output the yaml file for the Job with the image busybox which echos “Hello I am from job”

<details><summary>show</summary>
<p>

```bash
kubectl create job hello-job --image=busybox --dry-run -o yaml -- echo "Hello I am from job"
```

</p>
</details>

### 85. Copy the above YAML file to hello-job.yaml file and create the job

<details><summary>show</summary>
<p>

```bash
kubectl create job hello-job --image=busybox --dry-run -o yaml -- echo "Hello I am from job" > hello-job.yaml
kubectl create -f hello-job.yaml
```

</p>
</details>

### 86. Verify the job and the associated pod is created and check the logs as well

<details><summary>show</summary>
<p>

```bash
kubectl get job
kubectl get po
kubectl logs hello-job-*
```

</p>
</details>

### 87. Delete the job we just created

<details><summary>show</summary>
<p>

```bash
kubectl delete job hello-job
```

</p>
</details>

### 88. Create the same job and make it run 10 times one after one

<details><summary>show</summary>
<p>

```bash
kubectl create job hello-job --image=busybox --dry-run -o yaml -- echo "Hello I am from job" > hello-job.yaml
// edit the yaml file to add completions: 10
kubectl create -f hello-job.yaml
```

</p>
</details>

[hello-job.yaml](./yaml/hello-job.yaml)

### 89. Watch the job that runs 10 times one by one and verify 10 pods are created and delete those after it’s completed

<details><summary>show</summary>
<p>

```bash
kubectl get job -w
kubectl get po
kubectl delete job hello-job
```

</p>
</details>

### 90. Create the same job and make it run 10 times parallel

<details><summary>show</summary>
<p>

```bash
kubectl create job hello-job --image=busybox --dry-run -o yaml -- echo "Hello I am from job" > hello-job.yaml
// edit the yaml file to add parallelism: 10
kubectl create -f hello-job.yaml
```

</p>
</details>

[hello-job.yaml](./yaml/hello-job2.yaml)

### 91. Watch the job that runs 10 times parallelly and verify 10 pods are created and delete those after it’s completed

<details><summary>show</summary>
<p>

```bash
kubectl get job -w
kubectl get po
kubectl delete job hello-job
```

</p>
</details>

### 92. Create a Cronjob with busybox image that prints date and hello from kubernetes cluster message for every minute

<details><summary>show</summary>
<p>

```bash
kubectl create cronjob date-job --image=busybox --schedule="*/1 * * * *" -- bin/sh -c "date; echo Hello from kubernetes cluster"
```

</p>
</details>

### 93. Output the YAML file of the above cronjob

<details><summary>show</summary>
<p>

```bash
kubectl get cj date-job -o yaml
```

</p>
</details>

### 94. Verify that CronJob creating a separate job and pods for every minute to run and verify the logs of the pod

<details><summary>show</summary>
<p>

```bash
kubectl get job
kubectl get po
kubectl logs date-job-&lt;jobid>-&lt;pod>
```

</p>
</details>

### 95. Delete the CronJob and verify all the associated jobs and pods are also deleted.

<details><summary>show</summary>
<p>

```bash
kubectl delete cj date-job
// verify pods and jobs
kubectl get po
kubectl get job
```

</p>
</details>

## State Persistence (8%)
Practice questions based on these concepts
* Understand PersistentVolumeClaims for Storage

### 96. List Persistent Volumes in the cluster

<details><summary>show</summary>
<p>

```bash
kubectl get pv
```

</p>
</details>

### 97. Create a hostPath PersistentVolume named task-pv-volume with storage 10Gi, access modes ReadWriteOnce, storageClassName manual, and volume at /mnt/data and verify

<details><summary>show</summary>
<p>

```bash
kubectl create -f task-pv-volume.yaml
kubectl get pv
```

</p>
</details>

[task-pv-volume.yaml](./yaml/task-pv-volume.yaml)

### 98. Create a PersistentVolumeClaim of at least 3Gi storage and access mode ReadWriteOnce and verify status is Bound

<details><summary>show</summary>
<p>

```bash
kubectl create -f task-pv-claim.yaml
kubectl get pvc
```

</p>
</details>

[task-pv-claim.yaml](./yaml/task-pv-claim.yaml)

### 99. Delete persistent volume and PersistentVolumeClaim we just created

<details><summary>show</summary>
<p>

```bash
kubectl delete pvc task-pv-claim
kubectl delete pv task-pv-volume
```

</p>
</details>

### 100. Create a Pod with an image Redis and configure a volume that lasts for the lifetime of the Pod

<details><summary>show</summary>
<p>

```bash
// emptyDir is the volume that lasts for the life of the pod
kubectl create -f redis-storage.yaml
```

</p>
</details>

[redis-storage.yaml](./yaml/redis-storage.yaml)

### 101. Exec into the above pod and create a file named file.txt with the text ‘This is called the file’ in the path /data/redis and open another tab and exec again with the same pod and verifies file exist in the same path.

<details><summary>show</summary>
<p>

```bash
// first terminal
kubectl exec -it redis-storage /bin/sh
cd /data/redis
echo 'This is called the file' > file.txt
//open another tab
kubectl exec -it redis-storage /bin/sh
cat /data/redis/file.txt
```

</p>
</details>

### 102. Delete the above pod and create again from the same yaml file and verifies there is no file.txt in the path /data/redis

<details><summary>show</summary>
<p>

```bash
kubectl delete pod redis
kubectl create -f redis-storage.yaml
kubectl exec -it redis-storage /bin/sh
cat /data/redis/file.txt // file doesn't exist
```

</p>
</details>

### 103. Create PersistentVolume named task-pv-volume with storage 10Gi, access modes ReadWriteOnce, storageClassName manual, and volume at /mnt/data and Create a PersistentVolumeClaim of at least 3Gi storage and access mode ReadWriteOnce and verify status is Bound

<details><summary>show</summary>
<p>

```bash

kubectl create -f task-pv-volume.yaml
kubectl create -f task-pv-claim.yaml
kubectl get pv
kubectl get pvc

```

</p>
</details>

### 104. Create an nginx pod with containerPort 80 and with a PersistentVolumeClaim task-pv-claim and has a mouth path "/usr/share/nginx/html"
<details><summary>show</summary>
<p>

```bash
kubectl create -f task-pv-pod.yaml
```

</p>
</details>

[task-pv-pod.yaml](./yaml/task-pv-pod.yaml)

## Configuration (18%)
Practice questions based on these concepts
* Understand ConfigMaps
* Understand SecurityContexts
* Define an application’s resource requirements
* Create & Consume Secrets
* Understand ServiceAccounts

### 105. List all the configmaps in the cluster

<details><summary>show</summary>
<p>

```bash
kubectl get cm
// or
kubectl get configmap
```

</p>
</details>

### 106. Create a configmap called myconfigmap with literal value appname=myapp

<details><summary>show</summary>
<p>

```bash
kubectl create cm myconfigmap --from-literal=appname=myapp
```

</p>
</details>

### 107. Verify the configmap we just created has this data

<details><summary>show</summary>
<p>

```bash
// you will see under data
kubectl get cm -o yaml
// or
kubectl describe cm
```

</p>
</details>

### 108. delete the configmap myconfigmap we just created

<details><summary>show</summary>
<p>

```bash
kubectl delete cm myconfigmap
```

</p>
</details>

### 109. Create a file called config.txt with two values key1=value1 and key2=value2 and verify the file

<details><summary>show</summary>
<p>

```bash
cat >> config.txt << EOF
key1=value1
key2=value2
EOF

cat config.txt
```

</p>
</details>

### 110. Create a configmap named keyvalcfgmap and read data from the file config.txt and verify that configmap is created correctly

<details><summary>show</summary>
<p>

```bash
kubectl create cm keyvalcfgmap --from-file=config.txt
kubectl get cm keyvalcfgmap -o yaml
```

</p>
</details>

### 111. Create an nginx pod and load environment values from the above configmap keyvalcfgmap and exec into the pod and verify the environment variables and delete the pod

<details><summary>show</summary>
<p>

```bash
// first run this command to save the pod yml
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > nginx-pod.yml
// edit the yml to below file and create
kubectl create -f nginx-pod.yml
// verify
kubectl exec -it nginx -- env
kubectl delete po nginx
```

</p>
</details>

[nginx-pod.yml](./yaml/nginx-pod.yaml)

### 112. Create an env file file.env with var1=val1 and create a configmap envcfgmap from this env file and verify the configmap

<details><summary>show</summary>
<p>

```bash
echo var1=val1 > file.env
cat file.env
kubectl create cm envcfgmap --from-env-file=file.env
kubectl get cm envcfgmap -o yaml --export
```

</p>
</details>

> 使用--from-env-file选项

### 113. Create an nginx pod and load environment values from the above configmap envcfgmap and exec into the pod and verify the environment variables and delete the pod

<details><summary>show</summary>
<p>

```bash
// first run this command to save the pod yml
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > nginx-pod2.yml
// edit the yml to below file and create
kubectl create -f nginx-pod.yml
// verify
kubectl exec -it nginx -- env
kubectl delete po nginx
```

</p>
</details>

[nginx-pod2.yaml](./yaml/nginx-pod2.yaml)


### 114. Create a configmap called cfgvolume with values var1=val1, var2=val2 and create an nginx pod with volume nginx-volume which reads data from this configmap cfgvolume and put it on the path /etc/cfg

<details><summary>show</summary>
<p>

```bash
// first create a configmap cfgvolume
kubectl create cm cfgvolume --from-literal=var1=val1 --from-literal=var2=val2
// verify the configmap
kubectl describe cm cfgvolume
// create the config map 
kubectl create -f nginx-volume.yml
// exec into the pod
kubectl exec -it nginx -- /bin/sh
// check the path
cd /etc/cfg
ls
```

</p>
</details>

[nginx-volume.yml](./yaml/nginx-volume.yml)

### 115. Create a pod called secbusybox with the image busybox which executes command sleep 3600 and makes sure any Containers in the Pod, all processes run with user ID 1000 and with group id 2000 and verify.

<details><summary>show</summary>
<p>

```bash
// create yml file with dry-run
kubectl run secbusybox --image=busybox --restart=Never --dry-run -o yaml -- /bin/sh -c "sleep 3600;" > busybox.yml
// edit the pod like below and create
kubectl create -f busybox.yml
// verify
kubectl exec -it secbusybox -- sh
id // it will show the id and group
```

</p>
</details>

[busybox.yml](./yaml/busybox.yml)


### 116. Create the same pod as above this time set the securityContext for the container as well and verify that the securityContext of container overrides the Pod level securityContext.

<details><summary>show</summary>
<p>

```bash
// create yml file with dry-run
kubectl run secbusybox --image=busybox --restart=Never --dry-run -o yaml -- /bin/sh -c "sleep 3600;" > busybox2.yml
// edit the pod like below and create
kubectl create -f busybox2.yml
// verify
kubectl exec -it secbusybox -- sh
id // you can see container securityContext overides the Pod level
```

</p>
</details>

[busybox2.yml](./yaml/busybox2.yml)

### 117. Create pod with an nginx image and configure the pod with capabilities NET_ADMIN and SYS_TIME verify the capabilities

<details><summary>show</summary>
<p>

```bash
// create the yaml file
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > nginx.yml
// edit as below and create pod
kubectl create -f nginx.yml
// exec and verify
kubectl exec -it nginx -- sh
cd /proc/1
cat status
// you should see these values
CapPrm: 00000000aa0435fb
CapEff: 00000000aa0435fb
```

</p>
</details>

[nginx.yml](./yaml/nginx.yml)

### 118. Create a Pod nginx and specify a memory request and a memory limit of 100Mi and 200Mi respectively.

<details><summary>show</summary>
<p>

```bash
// create a yml file
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > nginx2.yml
// add the resources section and create
kubectl create -f nginx2.yml
// verify
kubectl top pod
```

</p>
</details>

[nginx2.yml](./yaml/nginx2.yaml)


### 119. Create a Pod nginx and specify a CPU request and a CPU limit of 0.5 and 1 respectively.

<details><summary>show</summary>
<p>

```bash
// create a yml file
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > nginx3.yml
// add the resources section and create
kubectl create -f nginx3.yml
// verify
kubectl top pod
```

</p>
</details>

[nginx3.yml](./yaml/nginx3.yml)

### 120. Create a Pod nginx and specify both CPU, memory requests and limits together and verify.

<details><summary>show</summary>
<p>

```bash
// create a yml file
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > nginx4.yml
// add the resources section and create
kubectl create -f nginx4.yml
// verify
kubectl top pod
```

</p>
</details>

[nginx4.yml](./yaml/nginx4.yml)

### 121. Create a Pod nginx and specify a memory request and a memory limit of 100Gi and 200Gi respectively which is too big for the nodes and verify pod fails to start because of insufficient memory

<details><summary>show</summary>
<p>

```bash
// create a yml file
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > nginxt.yml
// add the resources section and create
kubectl create -f nginx5.yml
// verify
kubectl describe po nginx // you can see pending state
```

</p>
</details>

[nginx5.yml](./yaml/nginx5.yml)

### 122. Create a secret mysecret with values user=myuser and password=mypassword

<details><summary>show</summary>
<p>

```bash
kubectl create secret generic my-secret --from-literal=username=user --from-literal=password=mypassword
```

</p>
</details>

### 123. List the secrets in all namespaces

<details><summary>show</summary>
<p>

```bash
kubectl get secret --all-namespaces
```

</p>
</details>

### 124. Output the yaml of the secret created above

<details><summary>show</summary>
<p>

```bash
kubectl get secret my-secret -o yaml
```

</p>
</details>

### 125. Create an nginx pod which reads username as the environment variable

<details><summary>show</summary>
<p>

```bash
// create a yml file
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > nginx6.yml
// add env section below and create
kubectl create -f nginxy.yml
//verify
kubectl exec -it nginx -- env
```

</p>
</details>

[nginx6.yml](./yaml/nginx6.yml)

### 126. Create an nginx pod which loads the secret as environment variables

<details><summary>show</summary>
<p>

```bash
// create a yml file
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > nginx7.yml
// add env section below and create
kubectl create -f nginx7.yml
//verify
kubectl exec -it nginx -- env
```

</p>
</details>

[nginx7.yml](./yaml/nginx7.yml)

### 127. List all the service accounts in the default namespace

<details><summary>show</summary>
<p>

```bash
kubectl get sa
```

</p>
</details>

### 128. List all the service accounts in all namespaces

<details><summary>show</summary>
<p>

```bash
kubectl get sa --all-namespaces
```

</p>
</details>

### 129. Create a service account called admin

<details><summary>show</summary>
<p>

```bash
kubectl create sa admin
```

</p>
</details>

### 130. Output the YAML file for the service account we just created

<details><summary>show</summary>
<p>

```bash
kubectl get sa admin -o yaml
```

</p>
</details>

### 131. Create a busybox pod which executes this command sleep 3600 with the service account admin and verify

<details><summary>show</summary>
<p>

```bash
kubectl run busybox --image=busybox --restart=Never --dry-run -o yaml -- /bin/sh -c "sleep 3600" > busybox3.yml
kubectl create -f busybox3.yml
// verify
kubectl describe po busybox
```

</p>
</details>

[busybox3.yml](./yaml/busybox3.yml)

## Observability (18%)
Practice questions based on these concepts
* Understand LivenessProbes and ReadinessProbes
* Understand Container Logging
* Understand how to monitor applications in kubernetes
* Understand Debugging in Kubernetes


### 132. Create an nginx pod with containerPort 80 and it should only receive traffic only it checks the endpoint / on port 80 and verify and delete the pod.

<details><summary>show</summary>
<p>

```bash
kubectl run nginx --image=nginx --restart=Never --port=80 --dry-run -o yaml > nginx-pod3.yaml
// add the readinessProbe section and create
kubectl create -f nginx-pod3.yaml
// verify
kubectl describe pod nginx | grep -i readiness
kubectl delete po nginx
```

</p>
</details>

[nginx-pod3.yaml](./yaml/nginx-pod3.yaml)

### 133. Create an nginx pod with containerPort 80 and it should check the pod running at endpoint / healthz on port 80 and verify and delete the pod.

<details><summary>show</summary>
<p>

```bash
kubectl run nginx --image=nginx --restart=Never --port=80 --dry-run -o yaml > nginx-pod4.yaml
// add the livenessProbe section and create
kubectl create -f nginx-pod4.yaml
// verify
kubectl describe pod nginx | grep -i readiness
kubectl delete po nginx
```

</p>
</details>

[nginx-pod4.yaml](./yaml/nginx-pod4.yaml)

### 134. Create an nginx pod with containerPort 80 and it should check the pod running at endpoint /healthz on port 80 and it should only receive traffic only it checks the endpoint / on port 80. verify the pod.

<details><summary>show</summary>
<p>

```bash
kubectl run nginx --image=nginx --restart=Never --port=80 --dry-run -o yaml > nginx-pod5.yaml
// add the livenessProbe and readiness section and create
kubectl create -f nginx-pod5.yaml
// verify
kubectl describe pod nginx | grep -i readiness
kubectl describe pod nginx | grep -i liveness
```

</p>
</details>

[nginx-pod5.yaml](./yaml/nginx-pod5.yaml)

### 135. Check what all are the options that we can configure with readiness and liveness probes

<details><summary>show</summary>
<p>

```bash
kubectl explain Pod.spec.containers.livenessProbe
kubectl explain Pod.spec.containers.readinessProbe
```

</p>
</details>

### 136. Create the pod nginx with the above liveness and readiness probes so that it should wait for 20 seconds before it checks liveness and readiness probes and it should check every 25 seconds.

<details><summary>show</summary>
<p>

```bash
kubectl create -f nginx-pod6.yaml
```

</p>
</details>

[nginx-pod6.yaml](./yaml/nginx-pod6.yaml)

### 137. Create a busybox pod with this command “echo I am from busybox pod; sleep 3600;” and verify the logs.

<details><summary>show</summary>
<p>

```bash
kubectl run busybox --image=busybox --restart=Never -- /bin/sh -c "echo I am from busybox pod; sleep 3600;"
kubectl logs busybox
```

</p>
</details>

### 138. copy the logs of the above pod to the busybox-logs.txt and verify

<details><summary>show</summary>
<p>

```bash
kubectl logs busybox > busybox-logs.txt
cat busybox-logs.txt
```

</p>
</details>

### 139. List all the events sorted by timestamp and put them into file.log and verify

<details><summary>show</summary>
<p>

```bash
kubectl get events --sort-by=.metadata.creationTimestamp
// putting them into file.log
kubectl get events --sort-by=.metadata.creationTimestamp > file.log
cat file.log

// 此外还有
kubectl get events --sort-by='{.firstTimestamp}'

kubectl get events --sort-by='{.lastTimestamp}'
```

</p>
</details>

### 140. Create a pod with an image alpine which executes this command ”while true; do echo ‘Hi I am from alpine’; sleep 5; done” and verify and follow the logs of the pod.

<details><summary>show</summary>
<p>

```bash
// create the pod
kubectl run hello --image=alpine --restart=Never  -- /bin/sh -c "while true; do echo 'Hi I am from Alpine'; sleep 5;done"
// verify and follow the logs
kubectl logs --follow hello
```

</p>
</details>

### 141. Create the pod with the yaml file [not-running.yaml](https://gist.githubusercontent.com/bbachi/212168375b39e36e2e2984c097167b00/raw/1fd63509c3ae3a3d3da844640fb4cca744543c1c/not-running.yml). The pod is not in the running state. Debug it.

<details><summary>show</summary>
<p>

```bash
// create the pod
kubectl create -f https://gist.githubusercontent.com/bbachi/212168375b39e36e2e2984c097167b00/raw/1fd63509c3ae3a3d3da844640fb4cca744543c1c/not-running.yml
// get the pod
kubectl get pod not-running
kubectl describe po not-running
// it clearly says ImagePullBackOff something wrong with image
kubectl edit pod not-running // it will open vim editor
                     or
kubectl set image pod/not-running not-running=nginx
```

</p>
</details>

> image名称写错了
[not-running.yml](./yaml/not-running.yml)

### 142. This following yaml creates 4 namespaces and 4 pods. One of the pod in one of the namespaces are not in the running state. Debug and fix it. [problem-pod.yaml](https://gist.githubusercontent.com/bbachi/1f001f10337234d46806929d12245397/raw/84b7295fb077f15de979fec5b3f7a13fc69c6d83/problem-pod.yaml).

<details><summary>show</summary>
<p>

```bash
kubectl create -f https://gist.githubusercontent.com/bbachi/1f001f10337234d46806929d12245397/raw/84b7295fb077f15de979fec5b3f7a13fc69c6d83/problem-pod.yaml
// get all the pods in all namespaces
kubectl get po --all-namespaces
// find out which pod is not running
kubectl get po -n namespace2
// update the image
kubectl set image pod/pod2 pod2=nginx -n namespace2
// verify again
kubectl get po -n namespace2
```

</p>
</details>

> pod2的image名称写错了

[problem-pod.yaml](./yaml/problem-prod.yaml)


### 143. Get the memory and CPU usage of all the pods and find out top 3 pods which have the highest usage and put them into the cpu-usage.txt file

<details><summary>show</summary>
<p>

```bash
// get the top 3 hungry pods
kubectl top pod --all-namespaces | sort --reverse --key 3 --numeric | head -3
// putting into file
kubectl top pod --all-namespaces | sort --reverse --key 3 --numeric | head -3 > cpu-usage.txt
// verify
cat cpu-usage.txt
```

</p>
</details>

> 前提安装了metrics插件 [metrics-server](https://github.com/kubernetes-sigs/metrics-server)

## Services and Networking (13%)
Practice questions based on these concepts
* Understand Services
* Demonstrate a basic understanding of NetworkPolicies

### 144. Create an nginx pod with a yaml file with label my-nginx and expose the port 80

<details><summary>show</summary>
<p>

```bash
kubectl run nginx --image=nginx --restart=Never --port=80 --dry-run -oyaml > nginx8.yaml
// edit the label app: my-nginx and create the pod
kubectl create -f nginx8.yaml
```

</p>
</details>


[nginx8.yaml](./yaml/nginx8.yaml)

### 145. Create the service for this nginx pod with the pod selector app: my-nginx
<details><summary>show</summary>
<p>

```bash
// create the below service
kubectl create -f nginx-svc.yaml
```

</p>
</details>

[nginx-svc.yaml](./yaml/nginx-svc.yaml)

### 146. Find out the label of the pod and verify the service has the same label

<details><summary>show</summary>
<p>

```bash
// get the pod with labels
kubectl get po nginx --show-labels
// get the service and chekc the selector column
kubectl get svc my-service -o wide
```

</p>
</details>

### 147. Delete the service and create the service with kubectl expose command and verify the label

<details><summary>show</summary>
<p>

```bash
// delete the service
kubectl delete svc my-service
// create the service again
kubectl expose po nginx --port=80 --target-port=9376
// verify the label
kubectl get svc -l app=my-nginx
```

</p>
</details>

### 148. Delete the service and create the service again with type NodePort

<details><summary>show</summary>
<p>

```bash
// delete the service
kubectl delete svc nginx
// create service with expose command
kubectl expose po nginx --port=80 --type=NodePort
```

</p>
</details>


### 149. Create the temporary busybox pod and hit the service. Verify the service that it should return the nginx page index.html.

<details><summary>show</summary>
<p>

```bash
// get the clusterIP from this command
kubectl get svc nginx -o wide
// create temporary busybox to check the nodeport
kubectl run busybox --image=busybox --restart=Never -it --rm -- wget -o- &lt;Cluster IP>:80
```

</p>
</details>

### 150. Create a NetworkPolicy which denies all ingress traffic

<details><summary>show</summary>
<p>

```bash
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

</p>
</details>
