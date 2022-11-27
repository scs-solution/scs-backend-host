#!/bin/bash
# target=$1 #aws instance id
# privateKey=$2 #ssh 접속 할 수 있는 비밀 키 
# desc=$3 #인프라 description name,endpoint,instances
# updateKey=$4 #handling 완료했을 떄 backend로 신호보내기

instanceId=$1 # ami로 복제할 instance id  
latestAMI=$2  # 기존의 삭제할 ami id
updateKey=$3  # handling 완료했을 떄 backend로 신호보내기


# The name of the base AMI (Ubuntu 20.04).
#AMI_ID_BASE="ami-00399ec92321828f5"

# The name of the custom AMI.

# Region in which creating AMI.
REGION="ap-northeast-2"

# The type of EC2 instance used to build the AMI.
#TYPE="t2.nano"

# File into instance configuration will be written.
#JSON_EC2="ec2-details.json"
# File into AMI configuration will be written.
JSON_AMI="ami-details.json"


#Create a Device Mapping
# 밑에 쓴것대로 device-mapping.json에 써라

# cat << EOF > device-mapping.json
# [
#     {
#         "DeviceName": "/dev/sda1",
#         "Ebs": {
#             "VolumeSize": 8,
#             "DeleteOnTermination": false,
#             "Encrypted": false
#         }
#     }
# ]
# EOF


# generate public key from private key
# ssh-keygen -f ./../$privateKey -y > _$privateKey.pub

#Launch an EC2 Instance
# 기존 보안그룹이 인바운드 ssh 연결을 허용한다고 가정 
# 그렇지 않으면 security group을 사용해야 한다.

# aws ec2 run-instances \
#     --region $REGION \
#     --image-id $AMI_ID_BASE \
#     --count 1 \
#     --block-device-mappings file://device-mapping.json \
#     --instance-type $TYPE \
#     --key-name $KEYPAIR \
#     >$JSON_EC2

# 위의 $KEYPAIR에 _$privateKey.pubs 이거 넣어도되나>?

#INSTANCE_ID=$(jq -r '.Instances[0].InstanceId' $JSON_EC2)

#dns 검색 
#Retrieving Public DNS Name

# aws ec2 wait instance-status-ok \
#     --region $REGION \
#     --instance-ids $INSTANCE_ID

# 위에 wait이 끝나면 ec2가 연결될 준비가 끝난것이다.

# #ec2의 전체 정보를 저장 
# aws ec2 describe-instances \
#     --region $REGION \
#     --instance-ids $INSTANCE_ID \
#     >$JSON_EC2

#EC2_DNS=$(jq -r '.Reservations[0].Instances[0].PublicDnsName' $JSON_EC2)


#installing software
#Next we’ll provision the instance via SSH. The StrictHostKeyChecking option just 
#prevents SSH from stopping to prompt you for confirmation.
#python docker 설치
#다른것 설치하고싶으면 아래 적으면 됨 

#ssh -o StrictHostKeyChecking=no ubuntu@$EC2_DNS << EOF

#sudo apt-get update -y
#sudo apt-get upgrade python3

#sudo apt-get install -y docker.io docker-compose
#EOF


#Create the AMI

# aws ec2 describe-images \
#     --region $REGION \
#     --filters "Name=name,Values=$AMI_NAME_TARGET" \
#     >$JSON_AMI

# #이름 중복검사를 통해 만약 있다면 등록을 취소한다.
# AMI_ID_TARGET=$(jq -r '.Images[0].ImageId' $JSON_AMI)

# if [ $AMI_ID_TARGET != "null" ]
# then
#    aws ec2 deregister-image --region $REGION --image-id $AMI_ID_TARGET
# fi


#이제 진짜 ami 생성 


#랜덤값 생성해서 넣기
AMI_NAME_TARGET=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)

aws ec2 create-image --region $REGION --instance-id $instanceId --no-reboot --name $AMI_NAME_TARGET >$JSON_AMI

#기존의 ami 삭제
aws ec2 deregister-image --region $REGION --image-id $latestAMI

#Terminate the EC2 Instance
#Finally we can terminate the EC2 instance weused to build the AMI.

#bash
#aws ec2 terminate-instances --region $REGION --instance-ids $INSTANCE_ID


#만들어진 ami id :

AMI_ID_TARGET=$(jq -r '.ImageId' $JSON_AMI)
echo $AMI_ID_TARGET

#만들어진 ami name, 그냥 name이랑 다름:
echo $AMI_NAME_TARGET



# custom ami를 활용해 ec2만들기
# aws ec2 run-instances \
# --region $REGION \
# --image-id $AMI_ID_TARGET \
# --count 1 \
# --instance-type $desc[2] \
# --key-name $KEYPAIR



#https://datawookie.dev/blog/2021/07/creating-an-ami-using-the-aws-cli/
