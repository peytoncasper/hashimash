package repository

import (
	"delivery-api/internal/model"
)

type LocalSensorRepository struct {
	Sensors map[string]model.Sensor
}

func NewLocalSensorRepository() *LocalSensorRepository {
	return &LocalSensorRepository{Sensors: make(map[string]model.Sensor)}
}

func (r *LocalSensorRepository) UpdateLocation(sensor model.Sensor) {
	r.Sensors[sensor.Id] = sensor
}
