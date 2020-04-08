# k8s-kind-bootstrap
A simple script to bootstrap a kubernetes cluster based on kind and docker.

## Usage

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

