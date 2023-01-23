# sandbox for exploring and learning Kubernetes

This repo is where I figure out how stuff works. 
It contains code and cofiguration to setup local Kubernetes cluster for development
I use it as my lab to meet the following learning objectives:

- Install and configure local Kubernetes cluster
  - setup ingress controller
- Install and access a Kubernetes web dashboard  
- Code a bash script to capture common tasks
  - create cluster
  - delete cluster
  - open dashboard
  - load docker images
  - deploy
- Deploy simple services locally to the same namespace:
  - HTTP server that pings redis on startup and exposes a health check endpoint
  - redis

## Install and configure local Kubernetes cluster 

create kind cluster 
```shell
./build.sh create lab-1
```

delete kind cluster 
```shell
./build.sh delete lab-1
```



