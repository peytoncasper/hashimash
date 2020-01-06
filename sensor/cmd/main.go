package main

import (
	"bytes"
	"encoding/json"
	"github.com/hashicorp/vault/api"
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
	Token		  string   `json:"token"`
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

	vaultHost := os.Getenv("vault_host")
	vaultToken := os.Getenv("vault_token")

	// Dont start sensor until API token is retrieved from Vault
	apiToken, err := GetApiToken(vaultHost, vaultToken)
	for err != nil {
		log.Print("Error getting API token in Vault, trying again...")
		time.Sleep(5 * time.Second)
		apiToken, err = GetApiToken(vaultHost, vaultToken)
	}


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
			Token: 		   apiToken,
		}

		possibleMoves := calculatePossibleMoves(loc)
		loc = move(possibleMoves)

		payload[1] = SensorReading{
			SensorVersion: version,
			ApiVersion:    "",
			Id:            id,
			Location:      loc,
			Token: 		   apiToken,
		}

		b, err := json.Marshal(payload)
		if err != nil {
			log.Print("Error encoding sensor reading: ", err)
		} else {
			client := http.Client{
				Timeout: 5 * time.Second,
			}

			request, err := http.NewRequest(
				http.MethodPost,
				"http://"+apiHost+"/sensor",
				bytes.NewBuffer(b),
			)

			if err != nil {
				log.Print("Error creating sensor POST request: ", err)
				return
			}

			request.Header.Set("Content-Type", "application/json")

			_, err = client.Do(request)

			if err != nil {
				log.Print("Error sending sensor data: ", err)
			}

			client.CloseIdleConnections()
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

func GetApiToken(vaultHost string, vaultToken string) (string, error) {
	var apiToken string

	config := &api.Config{
		Address: "http://" + vaultHost,
	}
	client, err := api.NewClient(config)
	if err != nil {
		log.Print("Error creating Vault Client Connection", err)
		return apiToken, err
	}

	// Set Vault Authentication Token
	client.SetToken(vaultToken)

	// Register/Save Api Token Secret for Sensors to Fetch
	secret, err := client.Logical().Read("secret/data/api_token")

	if err != nil {
		log.Print("Error getting api_token secret from Vault", err, secret)
		return apiToken, err
	}

	secretData := secret.Data["data"].(map[string]interface{})

	return secretData["value"].(string), nil
}