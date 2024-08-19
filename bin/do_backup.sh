#!/bin/bash

echo "*** capturing $DATABASE on $APP and store it to $BACKUP_FILE_NAME ***"

heroku pg:backups capture $DATABASE --app $APP
LATEST_BACKUP=$(heroku pg:backups --app $APP | grep $DATABASE | head -n 1 | awk '{ print $1 }')
BACKUP_URL=$(heroku pg:backups:url $LATEST_BACKUP --app $APP)
curl -o $BACKUP_FILE_NAME $BACKUP_URL

echo "*** capture done. Now uploading to S3 ***"

BACKUP_FILE_NAME=$BACKUP_FILE_NAME ./bin/upload_backup_file.sh
