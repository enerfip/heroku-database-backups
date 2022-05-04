#!/bin/bash

#set -e
2>&1

source ./bin/check_requirements.sh

HOUR=$(date +"%-H")
MOD=$(expr $HOUR % 6)

if [[ -z "$KEEP_ONE_BACKUP_PER_WEEK" ]]; then
  echo "- KEEP_ONE_BACKUP_PER_WEEK Yes"
  KEEP_ONE_BACKUP_PER_WEEK=false
else
  echo "- KEEP_ONE_BACKUP_PER_WEEK No"
  KEEP_ONE_BACKUP_PER_WEEK=true
fi

if [[ -z "$KEEP_ONE_BACKUP_PER_DAY" ]]; then
  echo "- KEEP_ONE_BACKUP_PER_DAY Yes"
  KEEP_ONE_BACKUP_PER_DAY=false
else
  echo "- KEEP_ONE_BACKUP_PER_DAY No"
  KEEP_ONE_BACKUP_PER_DAY=true
fi

if [ $KEEP_ONE_BACKUP_PER_WEEK != false ]; then
  BACKUP_FILE_NAME="$(date +"%Y-%U")-$APP-$DATABASE.dump"
elif [ $KEEP_ONE_BACKUP_PER_DAY != false ]; then
  BACKUP_FILE_NAME="$(date +"%Y-%m-%d")-$APP-$DATABASE.dump"
else
  BACKUP_FILE_NAME="$(date +"%Y-%m-%d-%H-%M")-$APP-$DATABASE.dump"
fi

echo "HOUR is set to $HOUR"
echo "MOD is set to $MOD"

if [[ $MOD -gt 0 ]]
then
  echo "Scheduled only every 6 hours"
  echo "$MOD is not a multiple of 6. Current hour is $HOUR"
else
  echo "Backup time"

  BACKUP_FILE_NAME=$BACKUP_FILE_NAME DATABASE=$DATABASE APP=$APP ./bin/do_backup.sh
fi
