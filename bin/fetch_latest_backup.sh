#!/bin/bash

set -e

./bin/check_requirements.sh

BACKUP_FILE_NAME="$FILENAME_PREFIX-$APP-$DATABASE.dump"

heroku pg:backups:download --app $APP -o $BACKUP_FILE_NAME

BACKUP_FILE_NAME=$BACKUP_FILE_NAME ./bin/upload_backup_file.sh
