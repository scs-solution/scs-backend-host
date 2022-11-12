#!/bin/bash
instance=$1
privateKey=$2
updateKey=$3

privateIp=$(echo $instance | yq -oj eval . | jq -r '.privateIp')
initialDesc=$(echo $instance | yq -oj eval . | jq -r '.initialDesc')

imageName=$(echo $initialDesc | yq -oj eval . | jq -r '.imageName')
initialScript=$(echo $initialDesc | yq -oj eval . | jq -r '.initialScript')
runScript=$(echo $initialDesc | yq -oj eval . | jq -r '.runScript')

echo $imageName

# download privateKey
aws s3api get-object --bucket scs-user-pks --key $privateKey.key $privateKey
chmod 700 $privateKey

echo $initialScript >> client-init-script.sh
echo $runScript >> client-run-script.sh

chmod +x client-init-script.sh client-run-script.sh

scp -o StrictHostKeyChecking=no -i $privateKey ./script/common-init-script.sh ec2-user@$privateIp:/home/ec2-user/
scp -o StrictHostKeyChecking=no -i $privateKey ./client-init-script.sh ec2-user@$privateIp:/home/ec2-user/
scp -o StrictHostKeyChecking=no -i $privateKey ./client-run-script.sh ec2-user@$privateIp:/home/ec2-user/

ssh -o StrictHostKeyChecking=no -i $privateKey ec2-user@$privateIp ./home/ec2-user/common-init-script.sh
ssh -o StrictHostKeyChecking=no -i $privateKey ec2-user@$privateIp ./home/ec2-user/client-init-script.sh
ssh -o StrictHostKeyChecking=no -i $privateKey ec2-user@$privateIp ./home/ec2-user/client-run-script.sh

rm $privateKey
rm client-init-script.sh
rm client-run-script.sh
rm $privateKey
