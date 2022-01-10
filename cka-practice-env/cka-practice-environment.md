## cka-practice-environment
[来源 CKA practice environment](https://github.com/arush-sal/cka-practice-environment)

### Q01. Bootstrap a Kubernetes v1.10 cluster using kubeadm
- You need to bootstrap a Kubernetes v1.10 cluster with one master and one worker node using kubeadm.

<details><summary>Show</summary></details>

### Q02. Enable cluster auditing
- Enable cluster wide auditing. You can use the audit policy provide at [here](https://github.com/kubernetes/website/blob/master/content/en/docs/tasks/debug-application-cluster/audit-policy.yaml).
- Make sure the audit logs are properly generated and saved to a log file.

<details><summary>Show</summary></details>

### Q03. Create a deployment running nginx version 1.12.2 that will run in 2 pods
- Scale this to 4 pods.
- Scale it back to 2 pods.
- Upgrade nginx version to 1.13.8
- Check the status of the upgrade
- How do you do this in a way that you can see history of what happened?
- Undo the upgrade

<details><summary>Show</summary></details>

### Q04. Create a service that uses a scratch disk
- Change the service to mount a disk from the host.
- Change the service to mount a persistent volume.


<details><summary>Show</summary></details>

### Q05. Create a pod with a Liveness and Readiness probes
- You need to create a pod called upNready that has liveness and readiness probes configured for it. Feel free to choose any application of your choice for the pod.

<details><summary>Show</summary></details>

### Q06. Create a daemon set
- Create a daemon set and change the update strategy to do a rolling update with a delay of 30 seconds between each update.

<details><summary>Show</summary></details>

### Q07. Create a busybox pod
- Create a busybox pod without using a manifest and then edit the manifest as per your liking.

<details><summary>Show</summary></details>

### Q08. Create a pod that uses secrets
- Pull secrets from environment variables.
- Pull secrets from a volume.
- Dump the secrets out via kubectl to show it worked.

<details><summary>Show</summary></details>

### Q09. Create a scheduled Job
- Create a job that runs every 3 minutes and prints out the current time.

<details><summary>Show</summary></details>

### Q10. Create a parallel Job
- Create a job that runs 80 times, with 5 containers at a time, and prints "Hello parallel world".

<details><summary>Show</summary></details>

### Q11. Create a service
- Create a service that uses an external load balancer and points to a 3 pod cluster running nginx.

<details><summary>Show</summary></details>

### Q12. Create a horizontal autoscaling group
- Create a horizontal autoscaling group that should start with 2 pods and scale when CPU usage is over 50%.

<details><summary>Show</summary></details>

### Q13. Create pods with restricted resource usage
- Create 2 pods that has a CPU limit of 2 and should request 0.5 CPU when started.
- Limit the memory usage for one of the pod to 100Mb.

<details><summary>Show</summary></details>

### Q14. Create an init container
- Create a nginx pod with an init container that populates the webroot of nginx pod with the homepage of Kubernauts.io

<details><summary>Show</summary></details>

### Q15. Create a pod with specific UID
- Create a pod that runs all processes as user 1000.

<details><summary>Show</summary></details>

### Q16. Create a namespace
- Run a pod in the new namespace.
- Put memory limits on the namespace.
- Limit pods to 2 persistent volumes in this namespace.

<details><summary>Show</summary></details>

### Q17. Write an ingress rule that redirects calls to /foo to one service and to /bar to another

<details><summary>Show</summary></details>

### Q18. Write a service that exposes nginx on a nodeport
- Change it to use a cluster port.
- Scale the service.
- Change it to use an external IP.
- Change it to use a load balancer.

<details><summary>Show</summary></details>

### Q19. Backup the etcd database
- Backup the etcd database at /opt/baks/etcd0001/ .

<details><summary>Show</summary></details>

### Q20. Create a networking policy such that only pods with the label access=granted can talk to it
- Create an nginx pod and attach this policy to it.
- Create a busybox pod and attempt to talk to nginx - should be blocked.
- Attach the label to busybox and try again - should be allowed.

<details><summary>Show</summary></details>

### Q21. Enable certificate rotation for the cluster.

<details><summary>Show</summary></details>

### Q22. Create 2 pod definitions.
Create 2 pod definitions with following features:

- The first pod should be called master and second pod should be called sidecar.
- The second pod should be scheduled to run anywhere the first pod is running i.e. The 2nd pod should run alongside the first pod on the same node.

<details><summary>Show</summary></details>

### Q23. Debug pod failure
Deploy a pod using this [manifest](https://github.com/kubernetes/website/blob/master/content/en/docs/tasks/debug-application-cluster/termination.yaml).
- Monitor the pod's deployment status.
- Debug the cause of pod failure.
- Customize the termination message as per your liking.

<details><summary>Show</summary></details>

### Q24. Audit the cluster
Audit the whole cluster to determine the cluster health and activities.

<details><summary>Show</summary></details>