#!/bin/bash
instance=$1
privateKey=$2
updateKey=$3

privateIp=$(echo $instance | yq -oj eval . | jq -r '.privateIp')
initialDesc=$(echo $instance | yq -oj eval . | jq -r '.initialDesc')

imageName=$(echo $initalDesc | yq -oj eval . | jq -r '.imageName')
initialScript=$(echo $initialDesc | yq -oj eval . | jq -r '.initialScript')
runScript=$(echo $initalDesc | yq -oj eval . | jq -r '.runScript')

# download privateKey
aws s3api get-object --bucket scs-user-pks --key $privateKey.key $privateKey
chmod 700 $privateKey

echo $initialScript >> client-init-script.sh
echo $runScript >> client-run-script.sh

scp -i $privateKey ./common-init-script.sh ec2-user@$privateIp:/home/ec2-user/
scp -i $privateKey ./client-init-script.sh ec2-user@$privateIp:/home/ec2-user/
scp -i $privateKey ./client-run-script.sh ec2-user@$privateIp:/home/ec2-user/

ssh -i $privateKey ec2-user@$privateIp /home/ec2-user/common-init-script.sh
ssh -i $privateKey ec2-user@$privateIp /home/ec2-user/client-init-script.sh
ssh -i $privateKey ec2-user@$privateIp /home/ec2-user/client-run-script.sh

rm $privateKey
rm common-init-script.sh
rm client-init-script.sh
rm client-run-script.sh