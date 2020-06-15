# Kubernetes: the simple way

A simple script to bootstrap a kubernetes cluster based on kind and docker.

## Prerequisites

Kind uses **Docker** to create cluster nodes. To install docker, please refer to: https://docs.docker.com/get-docker/

## Usage

```shell
$ git clone https://github.com/abousselmi/k8s-kind.git
$ cd k8s-kind
$ sudo ./k8s-kind.sh -m start
```

```shell
Usage: ./k8s-kind.sh OPTION COMMAND

Options:
  -m      bootstrap a multi node cluster
  -s      bootstrap a single node cluster

Commands:
  start   setup kubernetes cluster
  stop    remove the current cluster
  help    print usage

Example:
  To bootstrap a multi node ckuster, you can do:
  sudo ./k8s-kind.sh -m start
```

## Sample output

```shell
🔥 07:14:21 PM[INFO] start bootstrapping.. 
🔥 07:14:21 PM[INFO] check dependencies.. 
🔥 07:14:21 PM[INFO] 'curl' is installed, continue.. 
🔥 07:14:21 PM[INFO] 'docker' is installed, continue.. 
🔥 07:14:21 PM[INFO] 'kind' is already installed, continue.. 
🔥 07:14:21 PM[INFO] 'kubectl' is already installed, continue.. 
🔥 07:14:21 PM[INFO] enable 'kubectl' autocompletion 
🔥 07:14:21 PM[INFO] create kubernetes cluster 'k8s' 
Creating cluster "k8s" ...
 ✓ Ensuring node image (kindest/node:v1.17.0) 🖼
 ✓ Preparing nodes 📦 📦 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
 ✓ Joining worker nodes 🚜 
Set kubectl context to "kind-k8s"
You can now use your cluster with:

kubectl cluster-info --context kind-k8s

Have a question, bug, or feature request? Let us know! https://kind.sigs.k8s.io/#community 🙂
🔥 07:15:15 PM[INFO] specify the cluster 'k8s' as the current context for kubectl 
Kubernetes master is running at https://127.0.0.1:32771
KubeDNS is running at https://127.0.0.1:32771/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
🔥 07:15:16 PM[INFO] Update kubernetes config ownership 
🔥 07:15:16 PM[INFO] finished in 55 seconds.
```

## Licence

MIT