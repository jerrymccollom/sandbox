#!/bin/sh
SITE_NAME=$1
NODE_NUM=$2
VAIL_AWS_ACCESS_KEY=$3
VAIL_AWS_SECRET_KEY=$4
VAIL_AWS_ROLE_ARN=$5
VAIL_AWS_EXTERNAL_ID=$6
VAIL_ENDPOINT_IP=$7
SITE_NUMBER=$8
EFS_DNS_NAME=$9

NODE_NAME=$SITE_NAME:$NODE_NUM

echo Creating mount point....
sudo mkdir -p /tmp/vail
sudo chmod 755 /tmp/vail

echo -n Waiting for EFS $EFS_DNS_NAME
until ping -c3 $EFS_DNS_NAME &>/dev/null; do echo -n .; sleep 1; done
echo

echo Mounting file system....
until sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 $EFS_DNS_NAME:/ /tmp/vail; do echo -n .; sleep 1; done

echo Updating fstab
sudo su -c "echo $EFS_DNS_NAME:/ /tmp/vail nfs defaults,vers=4.1 0 0 >> /etc/fstab"

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

