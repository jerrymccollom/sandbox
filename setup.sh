#!/bin/sh

SITE_NAME=$1
NODE_NUM=$2
VAIL_AWS_ACCESS_KEY=$3
VAIL_AWS_SECRET_KEY=$4
VAIL_AWS_ROLE_ARN=$5
VAIL_AWS_EXTERNAL_ID=$6
VAIL_ENDPOINT_IP=$7

NODE_NAME=$SITE_NAME:$NODE_NUM

# uncompress our binary
gunzip vail

# Update to ensure we have librados 
# This has been done and we now have AMI with these updates

# sudo apt update >~/update.log 2>&1
# sudo apt install -y librados-dev awscli >~/install.log 2>&1

# Setup AWS config and credentials
test -d ~/.aws || mkdir ~/.aws

cat <<-EOF >~/.aws/credentials
[default]
aws_access_key_id = $VAIL_AWS_ACCESS_KEY
aws_secret_access_key = $VAIL_AWS_SECRET_KEY
EOF

cat <<-EOF >~/.aws/config
[default]
region = us-west-2

[profile spectra]
source_profile = default
region = us-west-2
role_arn = $VAIL_AWS_ROLE_ARN
external_id = $VAIL_AWS_EXTERNAL_ID
EOF

#setup vail config
mkdir ~/.vail
mv ~/*.yml ~/.vail
sed -e "s/SITE_NAME/$SITE_NAME/" -e "s/NODE_NAME/$NODE_NAME/" -e "s/NODE_NUM/$NODE_NUM/" <~/.vail/vail.template.yml > ~/.vail/vail.yml
sed -e "s/SITE_NAME/$SITE_NAME/" -e "s/NODE_NAME/$NODE_NAME/" -e "s/NODE_NUM/$NODE_NUM/" -e "s/127.0.0.1/$VAIL_ENDPOINT_IP/" <~/.vail/db.template.yml > ~/.vail/db.yml


# startup vail
cd ~
chmod +x ~/vail ~/*.sh
exec ~/start.sh

