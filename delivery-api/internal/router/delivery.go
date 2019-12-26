package router

import (
	"delivery-api/internal/response"
	"github.com/go-chi/chi"
	"log"
	"net/http"
)

func version(w http.ResponseWriter, r *http.Request) {
	err := response.Version("1.0.0", w)
	if err != nil {
		log.Print("Error sending version response")
	}
}

func DeliveryRouter() http.Handler {
	r := chi.NewRouter()

	r.Get("/version", func(w http.ResponseWriter, r *http.Request) {
		version(w, r)
	})

	return r
}
