#!/bin/bash

#set -e
2>&1

source ./bin/check_requirements.sh

if [[ -z "$KEEP_ONE_BACKUP_PER_WEEK" ]]; then
  echo "- KEEP_ONE_BACKUP_PER_WEEK No"
  KEEP_ONE_BACKUP_PER_WEEK=false
else
  echo "- KEEP_ONE_BACKUP_PER_WEEK Yes"
  KEEP_ONE_BACKUP_PER_WEEK=true
fi

if [[ -z "$KEEP_ONE_BACKUP_PER_DAY" ]]; then
  echo "- KEEP_ONE_BACKUP_PER_DAY No"
  KEEP_ONE_BACKUP_PER_DAY=false
else
  echo "- KEEP_ONE_BACKUP_PER_DAY Yes"
  KEEP_ONE_BACKUP_PER_DAY=true
fi

if [ $KEEP_ONE_BACKUP_PER_WEEK != false ]; then
  BACKUP_FILE_NAME="$(date +"%Y-%U")-$APP-$DATABASE.dump"
elif [ $KEEP_ONE_BACKUP_PER_DAY != false ]; then
  BACKUP_FILE_NAME="$(date +"%Y-%m-%d")-$APP-$DATABASE.dump"
else
  BACKUP_FILE_NAME="$(date +"%Y-%m-%d-%H-%M")-$APP-$DATABASE.dump"
fi

if [[ -z "$FREQUENCY_HOUR" ]]; then
  FREQUENCY_HOUR=24
fi

echo "- FREQUENCY_HOUR $FREQUENCY_HOUR"

HOUR=$(date +"%-H")
MOD=$(($HOUR % $FREQUENCY_HOUR))

echo "HOUR is set to $HOUR"
echo "MOD is set to $MOD"

if [[ $MOD -gt 0 ]]
then
  echo "Scheduled only every $FREQUENCY_HOUR hours"
  echo "$MOD is not a multiple of $FREQUENCY_HOUR. Current hour is $HOUR"
else
  echo "Backup time"

  BACKUP_FILE_NAME=$BACKUP_FILE_NAME DATABASE=$DATABASE APP=$APP ./bin/do_backup.sh
  BACKUP_DONE_URL="https://nosnch.in/$SNITCH_ID"
  curl -d "m=$DATABASE backup was successful" $BACKUP_DONE_URL
fi

curl -d "m=$DATABASE backup was executed (maybe no backup processed)" $MONITORING_URL
