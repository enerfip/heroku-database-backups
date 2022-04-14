#!/bin/bash

# terminate script as soon as any command fails
set -e

if [[ -z "$APP" ]]; then
  echo "Missing APP variable which must be set to the name of your app where the db is located"
  exit 1
fi

if [[ -z "$DATABASE" ]]; then
  DATABASE="DATABASE_URL"
  echo "Using default DATABASE_URL. If you want to backup a specific database, please provide DATABASE=xxxx while invoking this command"
fi

if [[ -z "$FILENAME_PREFIX" ]]; then
  FILENAME_PREFIX="$(date +"%Y-%m-%d-%H-%M")"
  echo "Using default filename prefix: $FILENAME_PREFIX. If you want to override this value provide FILENAME_PREFIX while invoking this command"
fi

if [[ -z "$S3_BUCKET_PATH" ]]; then
  echo "Missing S3_BUCKET_PATH variable which must be set the directory in s3 where you would like to store your database backups"
  exit 1
fi

if [[ -z "$KEEP_ONE_BACKUP_PER_WEEK" ]]; then
  KEEP_ONE_BACKUP_PER_WEEK=false
fi

if [[ -z "$KEEP_ONE_BACKUP_PER_DAY" ]]; then
  KEEP_ONE_BACKUP_PER_DAY=false
fi
