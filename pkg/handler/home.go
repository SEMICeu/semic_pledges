package handler

import (
	"github.com/gin-gonic/gin"
	"github.com/gorilla/csrf"
	"net/http"
)

func Home(ctx *gin.Context) {
	ctx.HTML(http.StatusOK, "home.html", gin.H{"csrfField": csrf.TemplateField(ctx.Request)})
}
