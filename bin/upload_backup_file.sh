#!/bin/bash

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

if [ "$(date +%d)" = 01 ]; then
  BACKUP_TAG="monthly"
else
  BACKUP_TAG="daily"
fi
/tmp/aws/bin/aws s3api put-object-tagging --bucket $S3_BUCKET_PATH --key $APP/$FINAL_FILE_NAME --tagging "TagSet=[{Key=backupPeriod,Value=$BACKUP_TAG}]"
rm $FINAL_FILE_NAME

echo "backup $FINAL_FILE_NAME complete"
