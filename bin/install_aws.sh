#!/bin/bash
#install aws-cli

curl https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o awscli-bundle.zip
unzip awscli-bundle.zip
chmod +x ./awscli-bundle/install
./awscli-bundle/install -i /tmp/aws
rm -Rf ./awscli-bundle
rm awscli-bundle.zip
