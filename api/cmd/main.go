package main

import (
	"delivery-api/internal/repository/sensor/repository"
	"delivery-api/internal/router"
	"github.com/go-chi/chi"
	"github.com/go-chi/cors"
	"log"
	"net/http"
	"os"
)

func main() {
	version := os.Getenv("version")
	if version != "1.0.0" && version != "1.0.1" {
		log.Fatal("Version has not been set. Exiting")
	}

	sensorRepository := repository.NewConsulSensorRepository()

	r := chi.NewRouter()

	cors := cors.New(cors.Options{
		AllowedOrigins: []string{"*"},
		AllowedMethods: []string{"GET", "POST"},
		AllowedHeaders: []string{},
	})
	r.Use(cors.Handler)

	r.Mount("/", router.SensorRouter(version, sensorRepository))

	log.Print("API Started")
	err := http.ListenAndServe(":80", r)
	log.Print("Error running Delivery API", err)
}
