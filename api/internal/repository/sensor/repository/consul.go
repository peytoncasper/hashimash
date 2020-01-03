package repository

import (
	"bytes"
	"delivery-api/internal/model"
	"encoding/base64"
	"encoding/json"
	"fmt"
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

type KeyNotFoundError struct{}

func (e *KeyNotFoundError) Error() string {
	return fmt.Sprintf("key not found in consul")
}

func NewConsulSensorRepository() *ConsulSensorRepository {
	return &ConsulSensorRepository{
		Host: "localhost",
		Port: "8500",
	}
}

func (r *ConsulSensorRepository) UpdateLocation(sensorReadings []model.SensorReading) error {
	id := sensorReadings[0].Id

	serializedReadings, err := json.Marshal(sensorReadings)
	if err != nil {
		log.Print("Error serializing sensor readings")
		return err
	}

	err = r.Save(id, string(serializedReadings))
	if err != nil {
		return err
	}

	err = r.UpdateIndex(id)
	if err != nil {
		return err
	}

	return nil
}

func (r *ConsulSensorRepository) GetSensorData() (map[string][]model.SensorReading, error) {
	sensorReadings := make(map[string][]model.SensorReading)

	index, err := r.GetIndex()
	if err != nil {
		return sensorReadings, err
	}

	for _, v := range index {
		var sensorReading []model.SensorReading
		response, err := r.Get(v)
		if err != nil {
			return sensorReadings, err
		}

		sensorReadingString, err := base64.StdEncoding.DecodeString(response[0].Value)
		if err != nil {
			log.Print("Error base64 decoding sensor reading: ", err)
			return sensorReadings, err
		}

		decoder := json.NewDecoder(bytes.NewReader(sensorReadingString))
		err = decoder.Decode(&sensorReading)
		if err != nil {
			log.Print("Error json decoding sensor reading: ", err)
			return sensorReadings, err
		}

		sensorReadings[sensorReading[0].Id] = sensorReading
	}

	return sensorReadings, nil
}

func (r *ConsulSensorRepository) UpdateIndex(sensorId string) error {

	index, err := r.GetIndex()
	if err != nil {
		return err
	}

	if !contains(index, sensorId) {
		index = append(index, sensorId)
	}

	err = r.Save("sensorIndex", strings.Join(index, ","))
	if err != nil {
		return err
	}

	return nil
}

func contains(index []string, key string) bool {
	for _, a := range index {
		if a == key {
			return true
		}
	}
	return false
}

func (r *ConsulSensorRepository) GetIndex() ([]string, error) {

	var sensorIndex []string

	response, err := r.Get("sensorIndex")
	if err != nil {
		if _, ok := err.(*KeyNotFoundError); ok {
			return []string{}, nil
		}
		return sensorIndex, err
	}

	indexBytes, err := base64.StdEncoding.DecodeString(response[0].Value)
	if err != nil {
		return sensorIndex, err
	}

	sensorIndex = strings.Split(string(indexBytes), ",")

	return sensorIndex, nil
}

func (r *ConsulSensorRepository) Get(key string) ([]ConsulGetResponse, error) {
	var consulResponse []ConsulGetResponse

	client := http.Client{
		Timeout: 5 * time.Second,
	}

	request, err := http.NewRequest(
		http.MethodGet,
		"http://"+r.Host+":"+r.Port+"/v1/kv/"+key,
		nil,
	)

	resp, err := client.Do(request)

	if err != nil {
		log.Print("Error performing Consul KV HTTP request: ", err)
		return consulResponse, err
	}

	if resp.StatusCode == 404 {
		log.Print("Key not found in Consul KV")
		return consulResponse, &KeyNotFoundError{}
	}

	decoder := json.NewDecoder(resp.Body)

	err = decoder.Decode(&consulResponse)
	if err != nil {
		log.Print("Error consul KV response body: ", err)
		return consulResponse, err
	}

	return consulResponse, nil
}

func (r *ConsulSensorRepository) Save(key string, value string) error {
	client := http.Client{
		Timeout: 5 * time.Second,
	}

	request, err := http.NewRequest(
		http.MethodPut,
		"http://"+r.Host+":"+r.Port+"/v1/kv/"+key,
		strings.NewReader(value),
	)

	if err != nil {
		log.Print("Error creating consul HTTP Put request: ", err)
		return err
	}

	request.Header.Set("Content-Type", "application/json")

	_, err = client.Do(request)

	if err != nil {
		log.Print("Error performing consul KV Put request: ", err)
	}
	return nil
}
