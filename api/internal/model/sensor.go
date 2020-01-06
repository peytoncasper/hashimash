package model

type Location struct {
	X string `json:"x"`
	Y string `json:"y"`
}

type SensorReading struct {
	SensorVersion string   `json:"sensor_version"`
	ApiVersion    string   `json:"api_version"`
	Id            string   `json:"id"`
	Location      Location `json:"location"`
	Token 		  string   `json:"token"`
}
