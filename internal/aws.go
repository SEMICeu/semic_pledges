package internal

import (
	"context"
	"encoding/json"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/feature/s3/manager"
	"github.com/aws/aws-sdk-go-v2/service/quicksight"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/secretsmanager"
	"github.com/aws/aws-sdk-go-v2/service/sts"
	"github.com/spf13/viper"
	"os"
	"time"
)

var region = "eu-west-1"

func loadAWSSecrets() {
	if err := viper.BindEnv("secretName", "SECRET_NAME"); err != nil {
		Fatalf("Missing mandatory environment variable for secrets manager: %v", err)
	}
	secretName := viper.GetString("secretName")

	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion(region),
	)
	if err != nil {
		Fatalf("Unable to load SDK config, %v", err)
	}

	svc := secretsmanager.NewFromConfig(cfg)

	result, err := svc.GetSecretValue(context.TODO(), &secretsmanager.GetSecretValueInput{
		SecretId: aws.String(secretName),
	})
	if err != nil {
		Fatalf("Unable to get secret value, %v", err)
	}

	var secret map[string]interface{}
	err = json.Unmarshal([]byte(*result.SecretString), &secret)
	if err != nil {
		Fatalf("Failed to unmarshal secret string, %v", err)
	}

	// Set each secret key-value pair in Viper
	for key, value := range secret {
		Infof("Setting secret key: %v", key)
		viper.Set(key, value)
	}

}

func UploadFileToS3(filePath string, keyName string) {

	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion(region),
	)
	if err != nil {
		Fatalf("Unable to load SDK config, %v", err)
	}

	// Create an S3 service client
	svc := s3.NewFromConfig(cfg)

	// Open the file
	file, err := os.Open(filePath)
	if err != nil {
		Fatalf("Error opening file: %v", err.Error())
	}
	defer func(file *os.File) {
		err := file.Close()
		if err != nil {
			Fatalf("Unable to close file")
		}
	}(file)

	uploader := manager.NewUploader(svc)

	// Upload the file
	_, err = uploader.Upload(context.TODO(), &s3.PutObjectInput{
		Bucket: aws.String(viper.GetString("S3_BUCKET_INPUT")),
		Key:    aws.String(keyName),
		Body:   file,
	})
	if err != nil {
		Fatalf("Error uploading file: %v", err.Error())
	}

}

func GetCSVDownloadUrl(sessionId string) string {
	prefix := "csv" + "/" + sessionId + "/"

	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion(region),
	)
	if err != nil {
		Fatalf("Unable to load SDK config, %v", err)
	}

	// Create an S3 service client
	svc := s3.NewFromConfig(cfg)

	// List objects with MaxKeys set to 1
	keys, err := svc.ListObjectsV2(context.TODO(), &s3.ListObjectsV2Input{
		Bucket:  aws.String(viper.GetString("S3_BUCKET_OUTPUT")),
		Prefix:  aws.String(prefix),
		MaxKeys: aws.Int32(1),
	})
	if err != nil {
		Infof("Failed to list objects, %v", err)
		return "noFileFoundInBucket"
	}

	// check number of keys
	if len(keys.Contents) == 0 {
		Warnf("No objects found under prefix: %v", prefix)
		return "noFileFoundInBucket"
	}

	// Create a GetObject presigned URL
	getObjectInput := &s3.GetObjectInput{
		Bucket: aws.String(viper.GetString("S3_BUCKET_OUTPUT")),
		Key:    aws.String(*keys.Contents[0].Key),
	}

	// Create a Presigned Client from the S3 client
	presignClient := s3.NewPresignClient(svc)

	// Presign a GetObject request
	presignedURL, err := presignClient.PresignGetObject(context.TODO(), getObjectInput,
		s3.WithPresignExpires(12*time.Hour),
	)

	if err != nil {
		Fatalf("Failed to sign request %v", err.Error())
	}

	return presignedURL.URL

}

func GetDashboardUrl() string {
	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion(region),
	)
	if err != nil {
		Fatalf("Unable to load SDK config, %v", err)
	}

	// Create an QuickSight service client
	svc := quicksight.NewFromConfig(cfg)

	awsAccountId := GetAwsAccountId()

	input := &quicksight.GetDashboardEmbedUrlInput{
		AwsAccountId:             aws.String(awsAccountId),
		DashboardId:              aws.String(viper.GetString("DASHBOARD_ID_01")),
		IdentityType:             "ANONYMOUS",
		SessionLifetimeInMinutes: aws.Int64(600),
		UndoRedoDisabled:         false,
		ResetDisabled:            false,
		StatePersistenceEnabled:  false,
		Namespace:                aws.String("default"),
	}

	result, err := svc.GetDashboardEmbedUrl(context.TODO(), input)
	if err != nil {
		Fatalf("Failed to get dashboard embed url, %v", err)
	}

	return *result.EmbedUrl

}

func GetAwsAccountId() string {
	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion(region),
	)
	if err != nil {
		Fatalf("Unable to load SDK config, %v", err)
	}

	// Create an STS service client
	svc := sts.NewFromConfig(cfg)

	// Call the GetCallerIdentity API
	result, err := svc.GetCallerIdentity(context.TODO(), &sts.GetCallerIdentityInput{})
	if err != nil {
		Fatalf("Unable to get caller identity, %v", err)
	}

	return aws.ToString(result.Account)
}
