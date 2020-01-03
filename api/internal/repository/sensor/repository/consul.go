package repository

import (
	"bytes"
	"delivery-api/internal/model"
	"encoding/base64"
	"encoding/json"
	"log"
	"net/http"
	"strings"
	"time"
)

type ConsulSensorRepository struct {
	Host string `json:"host"`
	Port string `json:"port"`
}

type ConsulGetResponse struct {
	CreateIndex int    `json:"CreateIndex"`
	ModifyIndex int    `json:"ModifyIndex"`
	LockIndex   int    `json:"LockIndex"`
	Key         string `json:"Key"`
	Flags       int    `json:"Flags"`
	Value       string `json:"Value"`
	Session     string `json:"Session"`
}

func NewConsulSensorRepository() *ConsulSensorRepository {
	return &ConsulSensorRepository{
		Host: "localhost",
		Port: "8500",
	}
}

func (r *ConsulSensorRepository) UpdateLocation(sensorReadings []model.SensorReading) {

	client := http.Client{
		Timeout: 5 * time.Second,
	}

	b, err := json.Marshal(sensorReadings)

	request, err := http.NewRequest(
		http.MethodPut,
		"http://"+r.Host+":"+r.Port+"/v1/kv/"+sensorReadings[0].Id,
		bytes.NewBuffer(b),
	)
	request.Header.Set("Content-Type", "application/json")

	_, err = client.Do(request)

	if err != nil {
		log.Print("Error saving sensor reading: ", err)
	}
	updateIndex(r.Host, r.Port, sensorReadings[0].Id)
}

func (r *ConsulSensorRepository) GetSensorData() map[string][]model.SensorReading {
	client := http.Client{
		Timeout: 5 * time.Second,
	}

	request, err := http.NewRequest(
		http.MethodGet,
		"http://"+r.Host+":"+r.Port+"/v1/kv/sensorIndex",
		nil,
	)
	resp, err := client.Do(request)

	if err != nil {
		log.Print("Error getting Sensor Index: ", err)
	}

	decoder := json.NewDecoder(resp.Body)

	var sensorIndex []string
	err = decoder.Decode(&sensorIndex)
	if err != nil {
		log.Print("Error decoding sensor index body: ", err)
	}

	sensorReadings := make(map[string][]model.SensorReading)

	for i := range sensorIndex {
		id := sensorIndex[i]

		client := http.Client{
			Timeout: 5 * time.Second,
		}

		request, err := http.NewRequest(
			http.MethodGet,
			"http://"+r.Host+":"+r.Port+"/v1/kv/"+id,
			nil,
		)
		resp, err := client.Do(request)

		if err != nil {
			log.Print("Error getting Sensor Index: ", err)
		}

		decoder := json.NewDecoder(resp.Body)

		var sensorReading []model.SensorReading
		err = decoder.Decode(&sensorIndex)
		if err != nil {
			log.Print("Error decoding sensor index body: ", err)
		}
		sensorReadings[id] = sensorReading
	}

	return sensorReadings
}

func updateIndex(host string, port string, sensorId string) {
	client := http.Client{
		Timeout: 5 * time.Second,
	}

	request, err := http.NewRequest(
		http.MethodGet,
		"http://"+host+":"+port+"/v1/kv/sensorIndex",
		nil,
	)
	resp, err := client.Do(request)

	if err != nil {
		log.Print("Error getting Sensor Index: ", err)
	}

	var consulResponse []ConsulGetResponse
	var sensorIndex []string

	if resp.StatusCode == 200 {
		decoder := json.NewDecoder(resp.Body)

		err = decoder.Decode(&consulResponse)
		if err != nil {
			log.Print("Error decoding consul response body: ", err)
		}

		sensorIndexString, err := base64.StdEncoding.DecodeString(consulResponse[0].Value)
		if err != nil {
			log.Print("Error converting vlaue from base64: ", err)
		}

		sensorIndex = strings.Split(string(sensorIndexString), ",")

		if !contains(sensorIndex, sensorId) {
			sensorIndex = append(sensorIndex, sensorId)
		}
	} else {
		sensorIndex = append(sensorIndex, sensorId)
	}

	client = http.Client{
		Timeout: 5 * time.Second,
	}
	request, err = http.NewRequest(
		http.MethodPut,
		"http://"+host+":"+port+"/v1/kv/sensorIndex",
		bytes.NewBuffer([]byte(strings.Join(sensorIndex, ","))),
	)
	request.Header.Set("Content-Type", "application/json")

	_, err = client.Do(request)

	if err != nil {
		log.Print("Error saving sensor index: ", err)
	}

}

func contains(index []string, key string) bool {
	for _, a := range index {
		if a == key {
			return true
		}
	}
	return false
}
