package api

import (
	"06h_http/internals/app/handlers"

	"github.com/gorilla/mux"
)

func CreateRoutes(userHandler *handlers.UsersHandler, carsHandler *handlers.CarsHandler) *mux.Router {
	router := mux.NewRouter()
	router.HandleFunc("/users/create", userHandler.Create).Methods("POST")
	router.HandleFunc("/users/list", userHandler.List).Methods("GET")
	router.HandleFunc("/users/find/{id:[0-9]+}", userHandler.Find).Methods("GET")

	router.HandleFunc("/cars/create", carsHandler.Create).Methods("POST")
	router.HandleFunc("/cars/list", carsHandler.List).Methods("GET")
	router.HandleFunc("/cars/find/{id:[0-9]+}", carsHandler.Find).Methods("GET")

	router.NotFoundHandler = router.NewRoute().HandlerFunc(handlers.NotFound).GetHandler()
	return router
}
