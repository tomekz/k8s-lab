# lab app

Useful little HTTP server that pings redis on startup.
The index route returns redis connection status.

## local development 

To setup local development in a container

- start containers

```sh
docker-compose up
```

- exec into `app-myapp-1` container 

```sh
docker exec -it app-myapp-1 bash 
```

- start server

```sh
go run main.go 

curl localhost:8080
```


## deploy to local kubernetes cluster

- build the image

```sh
docker build -f Dockerfile -t my-app:0.0.1 .
```

- load the image to kubernetes 
 
```sh
./build.sh image my-app:0.0.1 lab-1
```


