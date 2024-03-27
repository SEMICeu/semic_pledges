package handler

import (
	"github.com/gin-gonic/gin"
	"net/http"
)

func Summarization(ctx *gin.Context) {
	sessionId := ctx.Param("sessionid")

	ctx.HTML(http.StatusOK, "wip.html", gin.H{"sessionId": sessionId})
}
