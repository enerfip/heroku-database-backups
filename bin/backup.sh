#!/bin/bash

2>&1
set -e

./bin/check_requirements.sh

HOUR=$(date +"%H")
MOD=$(expr $HOUR % 6)

if [ $MOD != 0 ]; then
  echo "Scheduled only every 6 hours"
#  exit 0
else
  echo "It's backup time!"
fi

if [ $KEEP_ONE_BACKUP_PER_WEEK != false ]; then
  BACKUP_FILE_NAME="$(date +"%Y-%U")-$APP-$DATABASE.dump"
elif [ $KEEP_ONE_BACKUP_PER_DAY != false ]; then
  BACKUP_FILE_NAME="$(date +"%Y-%m-%d")-$APP-$DATABASE.dump"
else
  BACKUP_FILE_NAME="$(date +"%Y-%m-%d-%H-%M")-$APP-$DATABASE.dump"
fi

echo "*** capturing $DATABASE on $APP and store it to $BACKUP_FILE_NAME ***"

heroku pg:backups capture $DATABASE --app $APP
curl -o $BACKUP_FILE_NAME `heroku pg:backups:url --app $APP`

echo "*** capture done. Now uploading to S3 ***"

BACKUP_FILE_NAME=$BACKUP_FILE_NAME ./bin/upload_backup_file.sh
