package router

import (
	"delivery-api/internal/model"
	"delivery-api/internal/repository/sensor/repository"
	"delivery-api/internal/response"
	"encoding/json"
	"github.com/go-chi/chi"
	"log"
	"net/http"
)

func handleVersion(w http.ResponseWriter, r *http.Request, version string) {
	_ = response.VersionSuccess(version, w)
}

func handleSensor(w http.ResponseWriter, r *http.Request, sensorRepository *repository.LocalSensorRepository) {
	decoder := json.NewDecoder(r.Body)

	var sensor model.Sensor
	err := decoder.Decode(&sensor)
	if err != nil {
		log.Print("Error reading Sensor data: ", err)
	}

	if sensor.Id != "" && sensor.Version != "" && sensor.X != "" && sensor.Y != "" {
		sensorRepository.UpdateLocation(sensor)
	}

	_ = response.SensorSuccess(w)
}

func SensorRouter(version string, sensorRepository *repository.LocalSensorRepository) http.Handler {
	r := chi.NewRouter()

	r.Get("/version", func(w http.ResponseWriter, r *http.Request) {
		handleVersion(w, r, version)
	})

	r.Post("/sensor", func(w http.ResponseWriter, r *http.Request) {
		handleSensor(w, r, sensorRepository)
	})

	return r
}
