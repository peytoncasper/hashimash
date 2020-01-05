package repository

import (
	"api/internal/model"
)

type LocalSensorRepository struct {
	SensorHistory map[string][]model.SensorReading
}

func NewLocalSensorRepository() *LocalSensorRepository {
	//sensorRepository := map[string][]model.SensorReading {
	//	"1": []model.SensorReading {
	//		model.SensorReading{
	//			SensorVersion: "1.0.0",
	//			ApiVersion:    "1.0.0",
	//			Id:            "1",
	//			Location:      model.Location{
	//				X: "0",
	//				Y: "0",
	//			},
	//		},
	//		model.SensorReading{
	//			SensorVersion: "1.0.0",
	//			ApiVersion:    "1.0.0",
	//			Id:            "1",
	//			Location:      model.Location{
	//				X: "1",
	//				Y: "0",
	//			},
	//		},
	//	},
	//	"2": []model.SensorReading {
	//		model.SensorReading{
	//			SensorVersion: "1.0.0",
	//			ApiVersion:    "1.0.1",
	//			Id:            "2",
	//			Location:      model.Location{
	//				X: "2",
	//				Y: "2",
	//			},
	//		},
	//		model.SensorReading{
	//			SensorVersion: "1.0.0",
	//			ApiVersion:    "1.0.1",
	//			Id:            "2",
	//			Location:      model.Location{
	//				X: "2",
	//				Y: "1",
	//			},
	//		},
	//	},
	//	"3": []model.SensorReading {
	//		model.SensorReading{
	//			SensorVersion: "1.0.0",
	//			ApiVersion:    "1.0.1",
	//			Id:            "3",
	//			Location:      model.Location{
	//				X: "0",
	//				Y: "2",
	//			},
	//		},
	//		model.SensorReading{
	//			SensorVersion: "1.0.0",
	//			ApiVersion:    "1.0.0",
	//			Id:            "3",
	//			Location:      model.Location{
	//				X: "0",
	//				Y: "1",
	//			},
	//		},
	//	},
	//}

	sensorRepository := make(map[string][]model.SensorReading)

	return &LocalSensorRepository{SensorHistory: sensorRepository}
}

func (r *LocalSensorRepository) UpdateLocation(sensorReadings []model.SensorReading) {
	r.SensorHistory[sensorReadings[0].Id] = sensorReadings
}

func (r *LocalSensorRepository) GetSensorData() map[string][]model.SensorReading {
	return r.SensorHistory
}
