#!/bin/bash

#set -e
2>&1

source ./bin/check_requirements.sh

HOUR=$(date +"%H")
MOD=$(expr $HOUR % 6)

if [ $MOD != 0 ]; then
  echo "Scheduled only every 6 hours"
  exit 0
fi

if [[ -z "$KEEP_ONE_BACKUP_PER_WEEK" ]]; then
  KEEP_ONE_BACKUP_PER_WEEK=false
else
  KEEP_ONE_BACKUP_PER_WEEK=true
fi

if [[ -z "$KEEP_ONE_BACKUP_PER_DAY" ]]; then
  KEEP_ONE_BACKUP_PER_DAY=false
else
  KEEP_ONE_BACKUP_PER_DAY=true
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
LATEST_BACKUP=$(heroku pg:backups --app $APP | grep $DATABASE | head -n 1 | awk '{ print $1 }')
BACKUP_URL=$(heroku pg:backups:url $LATEST_BACKUP --app $APP)
curl -o $BACKUP_FILE_NAME $BACKUP_URL

echo "*** capture done. Now uploading to S3 ***"

BACKUP_FILE_NAME=$BACKUP_FILE_NAME ./bin/upload_backup_file.sh
