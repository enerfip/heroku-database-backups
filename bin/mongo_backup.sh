#!/bin/bash

set -e

./bin/check_requirements.sh

MONGO_URI=$(heroku config:get MONGODB_URI -a $APP)
BACKUP_FILE_NAME="$(date +"%Y-%m-%d-%H-%M")-$APP.mongodump"

mongodump --uri $MONGO_URI -o $BACKUP_FILE_NAME

BACKUP_FILE_NAME=$BACKUP_FILE_NAME ./bin/upload_backup_file.sh
