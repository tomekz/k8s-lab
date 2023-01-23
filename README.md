# sandbox for exploring and learning Kubernetes

This repo is where I figure out how stuff works. It contains code and configuration to setup local Kubernetes cluster for development.
I use it as my lab to meet the following learning objectives:

- install and configure local Kubernetes cluster
- setup ingress controller
- install and access Kubernetes web dashboard  
- deploy simple services locally to the same namespace:
  - HTTP server that pings redis on startup and exposes a health check endpoint
  - redis
- code a bash script to capture common tasks
  - create cluster
  - delete cluster
  - load docker images
  - deploy
  - open dashboard

## Install and configure local Kubernetes cluster 

`create` command:
- creates kind cluster using the `kind-$name.yaml` config file
- deploys NGINX ingress controller


```shell
./build.sh create [name]
```

`delete` deletes kind cluster with specified [name]

```shell
./build.sh delete [name]
```

`image` loads [image] to [cluster] cluster 

```shell
./build.sh image [image] [cluster]
```


