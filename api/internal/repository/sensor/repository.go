package sensor

import "delivery-api/internal/model"

type Repository interface {
	UpdateLocation(sensor model.Sensor)
}
