package main

import (
	"bytes"
	"encoding/json"
	"log"
	"math/rand"
	"net/http"
	"os"
	"strconv"
	"time"
)

type Location struct {
	X string `json:"x"`
	Y string `json:"y"`
}

type SensorReading struct {
	SensorVersion string   `json:"sensor_version"`
	ApiVersion    string   `json:"api_version"`
	Id            string   `json:"id"`
	Location      Location `json:"location"`
}

func main() {
	// Set a time based seed value so that each instance
	// generates its own sensor values
	rand.Seed(time.Now().UnixNano())

	version := os.Getenv("version")
	id := os.Getenv("id")
	apiHost := os.Getenv("api_host")

	xStart := os.Getenv("x_start")
	yStart := os.Getenv("y_start")

	loc := Location{
		X: xStart,
		Y: yStart,
	}

	var payload [2]SensorReading

	for {
		payload[0] = SensorReading{
			SensorVersion: version,
			ApiVersion:    "",
			Id:            id,
			Location:      loc,
		}

		possibleMoves := calculatePossibleMoves(loc)
		loc = move(possibleMoves)

		payload[1] = SensorReading{
			SensorVersion: version,
			ApiVersion:    "",
			Id:            id,
			Location:      loc,
		}

		b, err := json.Marshal(payload)
		if err != nil {
			log.Print("Error encoding sensor reading: ", err)
		} else {
			_, err := http.Post(
				"http://"+apiHost+"/sensor",
				"application/json",
				bytes.NewBuffer(b),
			)
			if err != nil {
				log.Print("Error sending sensor data: ", err)
			}
		}

		log.Print("Reading Sent: ", payload)

		time.Sleep(1 * time.Second)
	}
}

func move(possibleMoves []Location) Location {
	move := rand.Intn(len(possibleMoves))

	return possibleMoves[move]
}

func calculatePossibleMoves(loc Location) []Location {
	var moves []Location

	x, _ := strconv.Atoi(loc.X)
	y, _ := strconv.Atoi(loc.Y)

	// Check if move east is valid
	if x-1 >= 0 {

		moves = append(moves, Location{
			X: strconv.Itoa(x - 1),
			Y: strconv.Itoa(y),
		})
	}

	// Check if move west is valid
	if x+1 <= 2 {
		moves = append(moves, Location{
			X: strconv.Itoa(x + 1),
			Y: strconv.Itoa(y),
		})
	}

	// Check if move north is valid
	if y-1 >= 0 {
		moves = append(moves, Location{
			X: strconv.Itoa(x),
			Y: strconv.Itoa(y - 1),
		})
	}

	// Check if move south is valid
	if y+1 <= 2 {
		moves = append(moves, Location{
			X: strconv.Itoa(x),
			Y: strconv.Itoa(y + 1),
		})
	}

	return moves
}
