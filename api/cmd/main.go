package main

import (
	"api/internal/repository/sensor/repository"
	"api/internal/router"
	"github.com/go-chi/chi"
	"log"
	"net/http"
	"os"
)

func main() {
	version := os.Getenv("version")
	consulHost := os.Getenv("consulHost")
	if version != "1.0.0" && version != "1.0.1" {
		log.Fatal("Version has not been set. Exiting")
	}

	sensorRepository := repository.NewConsulSensorRepository(consulHost)

	r := chi.NewRouter()

	r.Mount("/", router.SensorRouter(version, sensorRepository))

	log.Print("API Started")
	err := http.ListenAndServe(":80", r)
	log.Print("Error running Delivery API", err)
}
