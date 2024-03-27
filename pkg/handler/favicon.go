package handler

import "github.com/gin-gonic/gin"

func Favicon(ctx *gin.Context) {
	ctx.Header("Content-Type", "image/svg+xml")
	ctx.File("web/assets/favicon.svg")
}
