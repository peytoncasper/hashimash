package main

import (
	"delivery-api/internal/router"
	"github.com/go-chi/chi"
	"log"
	"net/http"
)

func main() {
	r := chi.NewRouter()

	r.Mount("/", router.DeliveryRouter())

	log.Print("Delivery API Started")
	err := http.ListenAndServe(":80", r)
	log.Print("Error running Delivery API", err)
}
