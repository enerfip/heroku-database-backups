#!/bin/bash

set -e

./bin/check_requirements.sh

BACKUP_FILE_NAME="$(date +"%Y-%m-%d-%H-%M")-$APP-$DATABASE.dump"

heroku pg:backups:download --app $APP -o $BACKUP_FILE_NAME

BACKUP_FILE_NAME=$BACKUP_FILE_NAME ./bin/upload_backup_file.sh
