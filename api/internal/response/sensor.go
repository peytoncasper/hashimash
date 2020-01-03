package response

import (
	"delivery-api/internal/model"
	"encoding/json"
	"log"
	"net/http"
)

func VersionSuccess(version string, w http.ResponseWriter) error {
	body := Success{
		Data: struct {
			Version string `json:"version"`
		}{
			Version: version,
		},
	}
	bodyString, err := json.Marshal(body)
	if err != nil {
		log.Print("Error marshaling response", err)
		return err
	}

	w.WriteHeader(http.StatusOK)
	_, err = w.Write(bodyString)
	if err != nil {
		return err
	}
	return nil
}

func SensorSuccess(w http.ResponseWriter) error {
	body := Success{
		Data: struct {
			Message string `json:"message"`
		}{
			Message: "Success",
		},
	}
	bodyString, err := json.Marshal(body)
	if err != nil {
		log.Print("Error marshaling response", err)
		return err
	}

	w.WriteHeader(http.StatusOK)
	_, err = w.Write(bodyString)
	if err != nil {
		return err
	}
	return nil
}

func SensorData(w http.ResponseWriter, sensorData map[string][]model.SensorReading) error {
	bodyString, err := json.Marshal(sensorData)
	if err != nil {
		log.Print("Error marshaling response", err)
		return err
	}

	w.WriteHeader(http.StatusOK)
	_, err = w.Write(bodyString)
	if err != nil {
		return err
	}
	return nil
}
