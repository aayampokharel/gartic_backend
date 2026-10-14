package main

import (
	"net/http"

	"github.com/go-chi/chi/v5"

	"aayampokharel2.com/internals/handlers"
	"aayampokharel2.com/internals/repository"
	"aayampokharel2.com/internals/service"
)

func main() {
	repo := repository.NewGameRepository()
	svc := service.NewGameService(repo)
	h := handlers.NewHandler(svc)

	chirouter := chi.NewRouter()
	h.RegisterRoutes(chirouter)

	//http.ListenAndServe("0.0.0.0:10000", chirouter)
	http.ListenAndServe(":8080", chirouter) //! i am in local port8080 branch ....CHANGE IT .
}
