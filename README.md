# sandbox for exploring and learning Kubernetes

This repo is where I figure out how stuff works. It contains code and configuration to setup local Kubernetes cluster for development.
I use it as my lab to meet the following learning objectives:

- install and configure local Kubernetes cluster with [kind](https://kind.sigs.k8s.io/)
- setup ingress controller to manage external access to the apps inside the cluster
  - use NGINX ingress controller
  - configure ingress rule to route to sample http app running inside the cluster 
- deploy simple services locally to the same namespace:
  - HTTP server that pings redis on startup and exposes a health check endpoint
  - redis
- code a bash script to capture common tasks
  - create cluster
  - delete cluster
  - load docker images
  - deploy
  - open dashboard
- deploy prometheus server and prometheus UI
- install and access Kubernetes web dashboard  

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


`deploy` creates/updates resources to a [cluster] as specified in the "k8s/[cluster].yaml" config file 

```shell
./build.sh deploy [cluster]
```

where [cluster] is e.g "lab-1" and [image] "my-app:0.0.1"

finally you should be able to reach the app from outside of the cluster 

```sh
curl localhost/app

//output
Status: Redis connection successful , REDIS_HOST: redis-service
```

## setup ingress controller 

To allow external access to services running inside the cluster NGINX ingress controller was deployed.
The following ingress rule was defined that routes to the sample http app running inside the cluster

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  namespace: lab-1
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  rules:
  - http:
      paths:
      - pathType: Prefix
        path: /app(/|$)(.*)
        backend:
          service:
            name: my-app-service
            port:
              number: 8080

```



