package handler

import (
	"github.com/gin-gonic/gin"
	"net/http"
	"pledges/internal"
)

func TopicAnalysis(ctx *gin.Context) {
	sessionId := ctx.Param("sessionid")

	ctx.HTML(http.StatusOK, "topic_analysis.html", gin.H{"url": internal.GetDashboardUrl(), "sessionId": sessionId, "csvDownloadUrl": internal.GetCSVDownloadUrl(sessionId)})
}
