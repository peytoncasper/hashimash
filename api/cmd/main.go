package main

import (
	"api/internal/repository/sensor/repository"
	"api/internal/router"
	"github.com/go-chi/chi"
	"github.com/hashicorp/vault/api"
	"time"

	"log"
	"net/http"
	"os"
)

func main() {
	version := os.Getenv("version")
	consulHost := os.Getenv("consul_host")
	vaultHost := os.Getenv("vault_host")
	vaultToken := os.Getenv("vault_token")
	apiToken := os.Getenv("api_token")


	// Dont start API server until API token has been registered in Vault
	err := StoreApiToken(vaultHost, vaultToken, apiToken)
	for err != nil {
		log.Print("Error storing API token in Vault, trying again...")
		time.Sleep(5 * time.Second)
		err = StoreApiToken(vaultHost, vaultToken, apiToken)
	}

	if version != "1.0.0" && version != "1.0.1" {
		log.Fatal("Version has not been set. Exiting")
	}

	sensorRepository := repository.NewConsulSensorRepository(consulHost)

	r := chi.NewRouter()

	r.Mount("/", router.SensorRouter(apiToken, version, sensorRepository))

	log.Print("API Started")
	err = http.ListenAndServe(":80", r)
	log.Print("Error running Delivery API", err)
}

func StoreApiToken(vaultHost string, vaultToken string, apiToken string) error {
	config := &api.Config{
		Address: "http://" + vaultHost,
	}
	client, err := api.NewClient(config)
	if err != nil {
		log.Print("Error creating Vault Client Connection", err)
		return err
	}

	// Set Vault Authentication Token
	client.SetToken(vaultToken)

	// Register/Save Api Token Secret for Sensors to Fetch
	secret, err := client.Logical().Write("secret/data/api_token", map[string]interface{}{
		"data": map[string]interface{}{
			"value": apiToken,
		},
	})

	if err != nil {
		log.Print("Error registering/creating secret in Vault", err, secret)
		return err
	}
	return nil
}
