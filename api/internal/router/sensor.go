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

func handleSensor(w http.ResponseWriter, r *http.Request, version string, sensorRepository *repository.ConsulSensorRepository) {
	decoder := json.NewDecoder(r.Body)

	var sensorReading []model.SensorReading
	err := decoder.Decode(&sensorReading)
	if err != nil {
		log.Print("Error reading Sensor data: ", err)
	}

	// Data Validation
	if (sensorReading[0].Id != "" && sensorReading[1].Id != "" && sensorReading[0].Id == sensorReading[1].Id) &&
		(sensorReading[0].SensorVersion != "" && sensorReading[1].SensorVersion != "") &&
		(sensorReading[0].Location.X != "" && sensorReading[1].Location.X != "") &&
		(sensorReading[0].Location.Y != "" && sensorReading[1].Location.Y != "") {

		sensorReading[0].ApiVersion = version
		sensorReading[1].ApiVersion = version

		sensorRepository.UpdateLocation(sensorReading)
	}

	_ = response.SensorSuccess(w)
}

func getSensorData(w http.ResponseWriter, r *http.Request, sensorRepository *repository.ConsulSensorRepository) {
	sensorData := sensorRepository.GetSensorData()

	err := response.SensorData(w, sensorData)
	if err != nil {
		// TODO: Handle error sending reponse
	}
}

func SensorRouter(version string, sensorRepository *repository.ConsulSensorRepository) http.Handler {
	r := chi.NewRouter()

	r.Get("/version", func(w http.ResponseWriter, r *http.Request) {
		handleVersion(w, r, version)
	})

	r.Get("/", func(w http.ResponseWriter, r *http.Request) {
		getSensorData(w, r, sensorRepository)
	})

	r.Post("/sensor", func(w http.ResponseWriter, r *http.Request) {
		handleSensor(w, r, version, sensorRepository)
	})

	return r
}
