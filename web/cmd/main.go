package main

import (
	"github.com/go-chi/chi"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"
)

func main() {
	apiHost := os.Getenv("apiHost")

	r := chi.NewRouter()

	r.Get("/api",  func(w http.ResponseWriter, r *http.Request) {
		HandleApiRequest(w, r, apiHost)
	})

	r.Post("/api/upgrade",  func(w http.ResponseWriter, r *http.Request) {
		HandleUpgradeRequest(w, r, apiHost)
	})

	workDir, _ := os.Getwd()
	filesDir := filepath.Join(workDir, "js/public")
	FileServer(r, "/", http.Dir(filesDir))

	_ = http.ListenAndServe(":80", r)
}

func FileServer(r chi.Router, path string, root http.FileSystem) {
	if strings.ContainsAny(path, "{}*") {
		panic("FileServer does not permit URL parameters.")
	}

	fs := http.StripPrefix(path, http.FileServer(root))

	if path != "/" && path[len(path)-1] != '/' {
		r.Get(path, http.RedirectHandler(path+"/", 301).ServeHTTP)
		path += "/"
	}
	path += "*"

	r.Get(path, http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fs.ServeHTTP(w, r)
	}))
}

func HandleApiRequest(w http.ResponseWriter, r *http.Request, apiHost string) {

	client := http.Client{
		Timeout: 5 * time.Second,
	}


	request, err := http.NewRequest(
		http.MethodGet,
		"http://"+apiHost,
		nil,
	)

	if err != nil {
		log.Print("Error creating GET request to backend API: ", err)
		return
	}

	resp, err := client.Do(request)
	if err != nil {
		log.Print("Error making request to backend API: ", err)
		_ = Error(w)
		return
	}

	bodyBytes, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Print("Error reading backend API response body: ", err)
		_ = Error(w)
		return
	}

	_ = Success(w, bodyBytes)
}

func HandleUpgradeRequest(w http.ResponseWriter, r *http.Request, apiHost string) {

	client := http.Client{
		Timeout: 5 * time.Second,
	}

	path := strings.ReplaceAll(r.URL.Path, "/api", "")

	request, err := http.NewRequest(
		http.MethodPost,
		"http://"+apiHost + path,
		r.Body,
	)

	if err != nil {
		log.Print("Error creating POST request to backend API: ", err)
		return
	}

	resp, err := client.Do(request)
	if err != nil {
		log.Print("Error making request to backend API: ", err)
		_ = Error(w)
		return
	}

	bodyBytes, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Print("Error reading backend API response body: ", err)
		_ = Error(w)
		return
	}

	_ = Success(w, bodyBytes)
}

func Success(w http.ResponseWriter, body []byte) error {
	w.WriteHeader(http.StatusOK)
	_, err := w.Write(body)
	if err != nil {
		return err
	}
	return nil
}

func Error(w http.ResponseWriter) error {
	w.WriteHeader(http.StatusInternalServerError)
	_, err := w.Write([]byte("Error"))
	if err != nil {
		return err
	}
	return nil
}