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
	X int `json:"x"`
	Y int `json:"y"`
}

type Sensor struct {
	Version string `json:"version"`
	Id      string `json:"id"`
	X       string `json:"x"`
	Y       string `json:"y"`
}

func main() {
	version := os.Getenv("version")
	id := os.Getenv("id")
	apiUrl := os.Getenv("apiUrl")

	loc := Location{
		X: 0,
		Y: 0,
	}

	for {
		possibleMoves := calculatePossibleMoves(loc)
		loc = move(possibleMoves)

		sensor := Sensor{
			Version: version,
			Id:      id,
			X:       strconv.Itoa(loc.X),
			Y:       strconv.Itoa(loc.Y),
		}

		b, err := json.Marshal(sensor)
		if err != nil {
			log.Print("Error encoding sensor reading: ", err)
		} else {
			_, _ = http.Post(
				apiUrl+"/sensor",
				"application/json",
				bytes.NewBuffer(b),
			)
		}

		time.Sleep(1 * time.Second)
	}
}

func move(possibleMoves []Location) Location {
	move := rand.Intn(len(possibleMoves))

	return possibleMoves[move]
}

func calculatePossibleMoves(loc Location) []Location {
	var moves []Location

	// Check if move east is valid
	if loc.X-1 >= 0 {
		moves = append(moves, Location{
			X: loc.X - 1,
			Y: loc.Y,
		})
	}

	// Check if move west is valid
	if loc.X+1 <= 8 {
		moves = append(moves, Location{
			X: loc.X + 1,
			Y: loc.Y,
		})
	}

	// Check if move north is valid
	if loc.Y-1 >= 0 {
		moves = append(moves, Location{
			X: loc.X,
			Y: loc.Y - 1,
		})
	}

	// Check if move south is valid
	if loc.Y+1 <= 8 {
		moves = append(moves, Location{
			X: loc.X,
			Y: loc.Y + 1,
		})
	}

	return moves
}
