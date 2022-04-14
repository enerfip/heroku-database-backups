#!/bin/bash

set -e

./bin/check_requirements.sh

HOUR=$(date +"%H")
MOD=$(expr $HOUR % 6)

if [ $MOD != 0 ]; then
  echo "Scheduled only every 6 hours"
  exit 0
fi

if [ $KEEP_ONE_BACKUP_PER_WEEK != false ]; then
  BACKUP_FILE_NAME="$(date +"%Y-%U")-$APP-$DATABASE.dump"
else
  BACKUP_FILE_NAME="$(date +"%Y-%m-%d-%H-%M")-$APP-$DATABASE.dump"
fi

heroku pg:backups capture $DATABASE --app $APP
curl -o $BACKUP_FILE_NAME `heroku pg:backups:url --app $APP`

BACKUP_FILE_NAME=$BACKUP_FILE_NAME ./bin/upload_backup_file.sh
