package main

import (
	"fmt"
	"net/http"
	"os"

	"github.com/go-redis/redis"
)

var REDIS_HOST = os.Getenv("REDIS_HOST")

func main() {
	client := redis.NewClient(&redis.Options{
		Addr:     fmt.Sprintf("%s:6379", REDIS_HOST),
		Password: "", // no password set
		DB:       0,  // use default DB
	})

	http.HandleFunc("/", healthCheckHandler(healthCheck(client)))

	if err := http.ListenAndServe(":8080", nil); err != nil {
		panic(fmt.Sprintf("Error starting server: %s", err))
	}
}

func healthCheck(client *redis.Client) string {
	_, err := client.Ping().Result()

	var healthCheck string
	if err != nil {
		healthCheck = fmt.Sprintf("Error connecting to redis: %s", err)
	} else {
		healthCheck = fmt.Sprintln("Redis connection successful")
	}
	return healthCheck
}

func healthCheckHandler(status string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		_, err := w.Write([]byte(fmt.Sprintf("Status: %s, REDIS_HOST: %s", status, REDIS_HOST)))
		if err != nil {
			fmt.Println("Error writing response: ", err)
		}
	}
}
