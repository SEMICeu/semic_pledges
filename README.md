# pledges-ui
* Add a brief paragraph or two that summarizes the purpose and function of this repository.
* You could add relevant links for the consumers of this repository.

## Usage
* Define the purpose of the repository if this is going to be a tool, utility, library or a service.
* Provide the instructions on how to consume this repository for the consumers.

## Get Started
* Provide instructions on how to setup and use this repository for local machine development and testing.

## Prerequisites
* Provide list of recommended modules and steps on how to install them.

```
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin ***.dkr.ecr.eu-west-1.amazonaws.com

sudo touch /opt/certFile
sudo touch /opt/keyFile
sudo chown mde-user:mde-user /opt/*File
```

## Install
```
```

## Setup of QuickSight shared folders
```
# https://docs.aws.amazon.com/quicksight/latest/user/folders.html

aws quicksight create-folder \
--aws-account-id *** \
--region eu-west-1 \
--folder-id semic-pledges \
--folder-type RESTRICTED \
--name "Semic-Pledges"


aws quicksight update-folder-permissions \
--aws-account-id *** \
--region eu-west-1 \
--folder-id semic-pledges \
--grant-permissions Principal=arn:aws:quicksight:eu-west-1:***:user/default/thierry.turpin@pwc.com,Actions=quicksight:CreateFolder,quicksight:DescribeFolder,quicksight:CreateFolderMembership,quicksight:DeleteFolderMembership,quicksight:DescribeFolderPermissions

```


## Testing
* Provide commands and configuration details on how to test the repository.

## Contact

