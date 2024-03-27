package main

import (
	"github.com/gin-gonic/gin"
	"github.com/gorilla/csrf"
	"github.com/spf13/viper"
	"net/http"
	"pledges/internal"
	"pledges/pkg/routes"
)

func main() {
	internal.Config()

	internal.Infof("Pledges UI")

	gin.SetMode(viper.GetString("GIN_MODE"))
	router := gin.Default()
	routes.SetupRoutes(router)

	addr := ":" + viper.GetString("INTERNAL_PORT")
	internal.Infof("Webserver binding: %s", addr)

	err := http.ListenAndServeTLS(addr, "/opt/certFile", "/opt/keyFile", csrf.Protect([]byte(viper.GetString("CSRF_AUTH_KEY")))(router))
	internal.Fatalf("Unable to start HTTP server: %s", err.Error())

}
