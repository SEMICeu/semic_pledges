package handler

import (
	"github.com/gin-gonic/gin"
	"net/http"
)

var Version = "development"

func About(ctx *gin.Context) {

	ctx.HTML(http.StatusOK, "about.html", gin.H{"version": Version})
}
