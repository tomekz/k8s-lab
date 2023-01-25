# sandbox for exploring and learning Kubernetes

This repo is where I figure out how stuff works. It contains code and configuration to setup local Kubernetes cluster for development.
I use it as my lab to meet the following learning objectives:

- install and configure local Kubernetes cluster with [kind](https://kind.sigs.k8s.io/)
- install and access Kubernetes web dashboard  
- deploy sample services to the same namespace:
  - redis instace
  - sample HTTP server that pings redis on startup and exposes health status for the index route
- setup ingress controller to manage external access to the HTTP server running inside the cluster
  - use NGINX ingress controller
  - configure ingress rule to route external traffic to http server
- deploy prometheus server and prometheus UI
- code a bash script to capture common tasks
  - create cluster
  - delete cluster
  - load docker images
  - deploy
  - open dashboard

## install and configure local Kubernetes cluster 

`create` command:
- creates kind cluster using the `kind-[name].yaml` config file
- deploys NGINX ingress controller

```shell
./build.sh create [name]
```

`delete` deletes kind cluster with specified [name]

```shell
./build.sh delete [name]
```

## install and access Kubernetes web dashboard  

The Dashboard UI is not deployed by default. To deploy it, run the following command:

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
```

Accessing the dashboard UI  

- create service account with admin permissions to the entire cluster 

```shell
./build.sh admin [cluster]
```
- command line proxy

You can enable access to the Dashboard by running the following command:

```
kubectl proxy

// in another terminal
./build.sh opendash
```

Kubectl will make Dashboard available at http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

- login to Dashboard using a bearer token tied to a user. You can use default user
To find the token we can use to log in execute the following command:
```
kubectl -n kubernetes-dashboard create token admin-user
```

## deploy sample services to the same namespace:

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

```
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







