# pledges-backend
* Add a brief paragraph or two that summarizes the purpose and function of this repository.
* You could add relevant links for the consumers of this repository.

## Usage
* Define the purpose of the repository if this is going to be a tool, utility, library or a service.
* Provide the instructions on how to consume this repository for the consumers.

## Get Started
* Provide instructions on how to setup and use this repository for local machine development and testing.

## Prerequisites
* Provide list of recommended modules and steps on how to install them.

EFS 
```
sudo yum install -y amazon-efs-utils
cd 
mkdir efs
sudo mount -t efs fs-07b2c3bdc7f5a8573 efs/
sudo chown mde-user:mde-user efs
cd efs

```

Get model files locally
```
aws s3 sync s3://digit-semic-dev-pledges-model/ .
```

run and mount the model files
```
# Grab latest image id
docker images
export image=<<>>
 docker run -e AWS_ACCESS_KEY_ID=AKIA6ODU57YDXRPT73HT -e AWS_SECRET_ACCESS_KEY=*** -v ./Word2Vec:/app/model/Word2Vec -it $image bash

```




## Install
* Provide step-by-step guide on how to get the development environment running.
* Provide test examples so as to perform a small demo.

## Testing
* Provide commands and configuration details on how to test the repository.

## Contact
* Provide contact details on how to contact the owners managing this repository.
