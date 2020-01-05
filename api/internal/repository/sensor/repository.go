package sensor

import "api/internal/model"

type Repository interface {
	UpdateLocation(sensor model.SensorReading)
	GetSensorData()
}
