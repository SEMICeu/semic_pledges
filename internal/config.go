package internal

import (
	"github.com/spf13/viper"
	"log"
	"os"
	"strings"
)

func Config() {
	// Initialize Viper
	viper.SetConfigName("env")
	viper.SetConfigFile("./.env")
	viper.AddConfigPath(".")

	// Attempt to read the local configuration
	err := viper.ReadInConfig()
	if err != nil { // Handle errors reading the config file
		Fatalf("Fatal error config file: %s \n", err)
	}

	// Load AWS secrets and integrate with Viper
	loadAWSSecrets()
	saveCertToFile()
}

func GetAppUrl() string {
	if viper.GetString("APP_PORT") != "443" {
		return "https://" + viper.GetString("APP_HOST") + ":" + viper.GetString("APP_PORT")
	} else {
		return "https://" + viper.GetString("APP_HOST")
	}
}

func saveCertToFile() {
	saveSecretToFile("pledges.local.pem", "/opt/certFile")
	saveSecretToFile("pledges.local-key.pem", "/opt/keyFile")
}

func saveSecretToFile(secret string, secretFile string) {
	file, err := os.Create(secretFile)
	if err != nil {
		Fatalf("Unable to create file: %s", err)
	}
	defer file.Close()

	_, err = file.Write([]byte(strings.Replace(viper.GetString(secret), "\\n", "\n", -1)))
	if err != nil {
		log.Fatal(err)
	}
}
