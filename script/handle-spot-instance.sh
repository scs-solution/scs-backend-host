#!/bin/bash
#target=$1 #aws instance id
#privateKey=$2 #ssh 접속 할 수 있는 비밀 키 
#desc=$3 #인프라 description name,endpoint,instances
#updateKey=$4 #handling 완료했을 떄 backend로 신호보내기

instanceId=$1 # 기존의 종료할 instanceid 
privateKey=$2 #ssh 접속 할 수 있는 비밀 키
instanceType=$3
amiId=$4
updateKey=$5


#기존의 생성된 ami id 
AMI_ID_TARGET=$(jq -r '.ImageId' $JSON_AMI)

REGION="ap-northeast-2"



#ebs id 불러오기

export ebsId=$(aws ec2 describe-volumes --filters Name=attachment.instance-id,Values=$instanceId --query 'Volumes[0].VolumeId' --output text)


#기존 ec2의 eip 불러오기
export eipAddress=$(aws ec2 describe-instances --instance-ids $instanceId --filter --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

#기존 ec2의 ebs snapshot 따기 
export ebsSnapshot=$(aws ec2 create-snapshot --volume-id $ebsId)


# ami통해 ec2 일반 인스턴스 생성

export newInstanceId=aws ec2 request-spot-instances    --spot-price 0.1  --instance-count 1     --type "one-time"   --launch-specification file://launch-specification.json >error.json




sleep 30

# 일반 인스턴스에 eip 붙이기

aws ec2 associate-address --instance-id $newInstanceId --public-ip $eipAddress

# 기존 spot instance 삭제, delete on termination false

aws ec2 terminate-instances --region $REGION --instance-ids $instanceId

# ebs를 통해 ec2 스팟 인스턴스 새로 생성

export spotInstanceId=$(aws ec2 request-spot-instances \
    --spot-price 0.1 \
    --instance-count 1 \
    --type one-time \
    --ImageId $ebsSnapshot \
    )

aws ec2 request-spot-instances    --spot-price 0.1  --instance-count 1     --type "one-time"   --launch-specification '{
  "ImageId": "'$amiId'",
  "InstanceType": "t2.micro",
  "Placement": {
        "AvailabilityZone": "ap-northeast-2a"
  }
}
'>spotinstance_information.json

export request_ids=$(jq '.SpotInstanceRequests[0].SpotInstanceRequestId' < spotinstance_information.json)

#request_ids에서 큰따옴표 안벗겨져서 큰따옴표 벗기기 
temp="${request_ids%\"}"
request_ids="${temp#\"}"
echo "$request_ids"

aws ec2 wait spot-instance-request-fulfilled  --spot-instance-request-ids $request_ids

export new_spotinstanceId=$(aws ec2 describe-spot-instance-requests --spot-instance-request-ids $request_ids --query 'SpotInstanceRequests[0].InstanceId')

#new_spotinstnaceId에서 큰따옴표 안벗겨져서 큰따옴표 벗기기 
temp="${new_spotinstanceId%\"}"
new_spotinstanceId="${temp#\"}"
echo $new_spotinstanceId


# 2분 정도 기다리기

sleep 120


#  일반 인스턴스에서 eip때고 스팟 인스턴스에 eip 붙이기


aws ec2 associate-address --instance-id $new_spotinstanceId --public-ip $eipAddress

# 일반 인스턴스 삭제

aws ec2 terminate-instances --instance-ids $newInstanceId

#################################################


# 새로만든 ec2 instance에 ebs 붙이기 
#aws ec2 attach-volume --volume-id $ebsSnapshot --instance-id $newInstanceId --device /dev/sdf

#기존 ec2 제거 



#새로만든 instance에 eip붙이기




#볼륨 탑재 해제
#Linux 인스턴스에서 다음 명령을 사용하여 /dev/sdh 디바이스의 탑재를 해제합니다.
# $umount -d /dev/sdh

#/Create an AMI/Create an Image-AMI and launch EC2

#Step1: Launch an EC2 Instance and save the instance ID into an environment variable

#instance_id=$(aws ec2 run-instances --image-id ami-55ef662f --instance-type t2.micro --key-name MyKeyPair1 --user-data file://userdata.txt  --query 'Instances[*].[InstanceId]' --output text )


#Step 2: Check the user data worked and the web server is running by typing the web server IP on a browser and verifying you see ÒHello WorldÓ

#Step 3: Create an image from that instance ID and save the image id to a variable image_id
#image_id=$(aws ec2 create-image --instance-id $instance_id --name "My server" --description "An AMI for my webserver" --query ImageId --output text)

#step 4: use that image to launch an instance
#aws ec2 run-instances --image-id $image_id --instance-type t2.micro --key-name MyKeyPair1   --query 'Instances[*].[InstanceId]' --output text 
#i-03c84ceb5391371b6

#Step 5: verify the web server is running by typing  the IP address on a browser

#https://github.com/ravsau/AWS-CLI-Commands/blob/master/Create%20an%20AMI/Create%20an%20Image-AMI%20and%20launch%20EC2.txt
