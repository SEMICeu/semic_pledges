package handler

import (
	"encoding/base64"
	"github.com/gin-gonic/gin"
	"github.com/gorilla/csrf"
	"github.com/oklog/ulid/v2"
	"net/http"
	"os"
	"path/filepath"
	"pledges/internal"
)

func GetUpload(ctx *gin.Context) {
	ctx.HTML(http.StatusOK, "upload.html", gin.H{"csrfField": csrf.TemplateField(ctx.Request)})
}

func PostUpload(ctx *gin.Context) {

	form, _ := ctx.MultipartForm()
	files := form.File["files"]

	tempDir, err := os.MkdirTemp("", "s3Upload")
	if err != nil {
		internal.Fatalf("Unable to create temp directory: %s", err.Error())
	}
	defer os.RemoveAll(tempDir) // Clean up

	pledgeUlid := ulid.Make().Bytes()
	urlSafePledgeUlid := base64.URLEncoding.EncodeToString(pledgeUlid[:])

	for _, file := range files {
		filename := filepath.Base(file.Filename)

		internal.Infof("Handling upload of file: %s", filename)
		if err := ctx.SaveUploadedFile(file, filepath.Join(tempDir, filename)); err != nil {
			ctx.String(http.StatusBadRequest, "upload file err: %s", err.Error())
			return
		}

		s3Object := filepath.Join(urlSafePledgeUlid, filename)
		internal.UploadFileToS3(filepath.Join(tempDir, filename), s3Object)

		ctx.HTML(http.StatusOK, "files_uploaded.html",
			gin.H{"filesShared": true, "urlSafePledgeUlid": urlSafePledgeUlid})

	}

}
