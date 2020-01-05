package router

import (
	"api/internal/model"
	"api/internal/repository/sensor/repository"
	"api/internal/response"
	"encoding/json"
	"github.com/go-chi/chi"
	"log"
	"net/http"
	"strings"
	"time"
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

		err := sensorRepository.UpdateLocation(sensorReading)
		if err != nil {
			// TODO: Handle error updating sensor data
			return
		}
	}

	_ = response.SensorSuccess(w)
}

func getSensorData(w http.ResponseWriter, r *http.Request, sensorRepository *repository.ConsulSensorRepository) {
	sensorData, err := sensorRepository.GetSensorData()
	if err != nil {
		// TODO: Handle error getting sensor data
		return
	}

	err = response.SensorData(w, sensorData)
	if err != nil {
		// TODO: Handle error sending reponse
	}
}

func upgradeSensor(w http.ResponseWriter, r *http.Request, version string, sensorRepository *repository.ConsulSensorRepository) {
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

		id := sensorReading[0].Id

		client := http.Client{
			Timeout: 5 * time.Second,
		}

		request, err := http.NewRequest(
			http.MethodPut,
			"http://consul.service.sensor-"+id+".consul"+":8500/v1/kv/sensor/version",
			strings.NewReader("1.0.1"),
		)

		if err != nil {
			log.Print("Error creating consul HTTP Put upgrade request: ", err)
			return
		}

		request.Header.Set("Content-Type", "application/json")

		_, err = client.Do(request)

		if err != nil {
			log.Print("Error performing consul KV Put upgrade request: ", err)
		}
	}

	_ = response.SensorSuccess(w)
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

	r.Post("/upgrade", func(w http.ResponseWriter, r *http.Request) {
		upgradeSensor(w, r, version, sensorRepository)
	})

	return r
}
