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

rm $privateKey