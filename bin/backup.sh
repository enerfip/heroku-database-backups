#!/bin/bash

set -e

./bin/check_requirements.sh

HOUR=$(date +"%H")
MOD=$(expr $HOUR % 6)

if [ $MOD != 0 ]; then
  echo "Scheduled only every 6 hours"
  exit 0
fi

BACKUP_FILE_NAME="$(date +"%Y-%m-%d-%H-%M")-$APP-$DATABASE.dump"

heroku pg:backups capture $DATABASE --app $APP
curl -o $BACKUP_FILE_NAME `heroku pg:backups:url --app $APP`

BACKUP_FILE_NAME=$BACKUP_FILE_NAME ./bin/upload_backup_file.sh
