#!/bin/bash
target=$1 #aws instance id
privateKey=$2 #ssh 접속 할 수 있는 비밀 키 
desc=$3 #인프라 description name,endpoint,instances
updateKey=$4 #handling 완료했을 떄 backend로 신호보내기

# The name of the base AMI (Ubuntu 20.04).
AMI_ID_BASE="ami-00399ec92321828f5"

# The name of the custom AMI.
# 랜덤값 생성해서 넣기
# 중복체크는 하지 않음 

AMI_NAME_TARGET=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)

# Region in which creating AMI.
REGION="ap-northeast-2"
# The type of EC2 instance used to build the AMI.
TYPE="t2.nano"

# File into instance configuration will be written.
JSON_EC2="ec2-details.json"
# File into AMI configuration will be written.
JSON_AMI="ami-details.json"


# generate public key from private key
ssh-keygen -f ./../$privateKey -y > _$privateKey.pub

#Launch an EC2 Instance
# aws ec2 run-instances \
#     --region $REGION \
#     --image-id $AMI_ID_BASE \
#     --count 1 \
#     --block-device-mappings file://device-mapping.json \
#     --instance-type $TYPE \
#     --key-name $KEYPAIR \
#     >$JSON_EC2

