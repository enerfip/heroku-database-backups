#!/bin/bash

# terminate script as soon as any command fails
set -e

if [[ -z "$APP" ]]; then
  echo "Missing APP variable which must be set to the name of your app where the db is located"
  exit 1
fi

if [[ -z "$S3_BUCKET_PATH" ]]; then
  echo "Missing S3_BUCKET_PATH variable which must be set the directory in s3 where you would like to store your database backups"
  exit 1
fi

#install aws-cli
curl https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o awscli-bundle.zip
unzip awscli-bundle.zip
chmod +x ./awscli-bundle/install
./awscli-bundle/install -i /tmp/aws
rm -Rf ./awscli-bundle
rm awscli-bundle.zip

MONGO_URI=$(heroku config:get MONGODB_URI -a $APP)

BACKUP_FILE_NAME="$(date +"%Y-%m-%d-%H-%M")-$APP.mongodump"

mongodump --uri $MONGO_URI -o $BACKUP_FILE_NAME

FINAL_FILE_NAME=$BACKUP_FILE_NAME

if [[ -z "$NOGZIP" ]]; then
  tar -zcvf $BACKUP_FILE_NAME.tgz $BACKUP_FILE_NAME
  rm -Rf $BACKUP_FILE_NAME
  FINAL_FILE_NAME=$BACKUP_FILE_NAME.tgz
fi

if [[ "$GPG_PASSPHRASE" ]]; then
  gpg -c --batch --passphrase $GPG_PASSPHRASE $FINAL_FILE_NAME
  rm $FINAL_FILE_NAME
  FINAL_FILE_NAME=$FINAL_FILE_NAME.gpg
fi

/tmp/aws/bin/aws s3 cp $FINAL_FILE_NAME s3://$S3_BUCKET_PATH/$APP/$FINAL_FILE_NAME
rm $FINAL_FILE_NAME

echo "backup $FINAL_FILE_NAME complete"
