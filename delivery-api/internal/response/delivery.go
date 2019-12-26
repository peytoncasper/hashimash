package response

import (
	"encoding/json"
	"log"
	"net/http"
)

func Version(version string, w http.ResponseWriter) error {
	body := Success{
		Data: struct {
			Version string `json:"version"`
		}{
			Version: version,
		},
	}
	bodyString, err := json.Marshal(body)
	if err != nil {
		log.Print("Error marshaling response", err)
		return err
	}

	w.WriteHeader(http.StatusOK)
	_, err = w.Write(bodyString)
	if err != nil {
		return err
	}
	return nil
}
