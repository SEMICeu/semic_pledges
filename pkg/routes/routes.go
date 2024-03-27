package routes

import (
	"encoding/gob"
	"fmt"
	"github.com/gin-contrib/sessions"
	"github.com/gin-contrib/sessions/cookie"
	"github.com/gin-gonic/gin"
	"github.com/spf13/viper"
	"html/template"
	"pledges/pkg/handler"
	"time"
)

func SetupRoutes(router *gin.Engine) {

	funcMap := template.FuncMap{
		"formatDate":     formatDate,
		"formatFileSize": formatFileSize,
	}

	gob.Register(map[string]interface{}{})

	store := cookie.NewStore([]byte(viper.GetString("COOKIE_SECRET")))
	router.Use(sessions.Sessions("auth-session", store))

	// Load templates & the custom function
	router.SetFuncMap(funcMap)
	router.Static("/public", "web/assets/")
	router.LoadHTMLGlob("web/templates/*")

	router.GET("/favicon.svg", handler.Favicon)

	router.GET("/", handler.Home)
	router.GET("/about", handler.About)

	router.GET("/upload", handler.GetUpload)
	router.POST("/upload", handler.PostUpload)

	router.GET("/topic_analysis/:sessionid", handler.TopicAnalysis)
	router.GET("/keyword_search/:sessionid", handler.KeywordSearch)
	router.GET("/summarization/:sessionid", handler.Summarization)

}

func formatDate(t time.Time) string {
	// Define your date format here
	return t.Format(time.RFC822)
}

func formatFileSize(size int64) string {
	const (
		KB = 1 << 10 // 1024
		MB = 1 << 20 // 1024 * 1024
		GB = 1 << 30 // 1024 * 1024 * 1024
	)

	switch {
	case size >= GB:
		return fmt.Sprintf("%.2f GB", float64(size)/GB)
	case size >= MB:
		return fmt.Sprintf("%.2f MB", float64(size)/MB)
	case size >= KB:
		return fmt.Sprintf("%.2f KB", float64(size)/KB)
	default:
		return fmt.Sprintf("%d bytes", size)
	}
}
