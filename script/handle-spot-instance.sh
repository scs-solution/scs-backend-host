#!/bin/bash
#target=$1 #aws instance id
#privateKey=$2 #ssh 접속 할 수 있는 비밀 키 
#desc=$3 #인프라 description name,endpoint,instances
#updateKey=$4 #handling 완료했을 떄 backend로 신호보내기

instanceId=$1 # 기존의 종료할 instanceid 
privateKey=$2 #ssh 접속 할 수 있는 비밀 키 
desc=$3 #인프라 description name,endpoint,instances

#기존의 생성된 ami id 
AMI_ID_TARGET=$(jq -r '.ImageId' $JSON_AMI)

REGION="ap-northeast-2"


for row in $(echo $desc | yq -oj eval . | jq '.instances' | jq -r '.[] | @base64'); do
  _jq() {
   echo ${row} | base64 --decode | jq -r ${1}
  }

  instanceName=$(_jq '.name')
  instanceSpec=$(_jq '.instanceSpec')
  instanceType=$(_jq '.instanceType')

  # normal, spot, rds, redis
  cp $instanceType-template.tf instance-$instanceName.tf

  sed -i "s/%%keyname%%/_${privateKey}/g; s/%%instancename%%/${infraName}-${instanceName}/g; s/%%instancespec%%/${instanceSpec}/g" instance-$instanceName.tf
done




#ebs id 불러오기

export ebsId=$(aws ec2 describe-volumes --filters Name=attachment.instance-id,Values=$instanceId --query 'Volumes[0].VolumeId' --output text)


#기존 ec2의 eip 불러오기
export eipAddress=$(aws ec2 describe-instances --instance-ids $instanceId --filter --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

#기존 ec2의 ebs snapshot 따기 
export ebsSnapshot=$(aws ec2 create-snapshot --volume-id $ebsId)



# ami를 활용해 새로운 ec2만들기
export newInstanceId=$(aws ec2 run-instances \
--region $REGION \
--image-id $AMI_ID_TARGET \
--count 1 \
--instance-type $instanceType \
--key-name $privateKey  --query 'Instances[0].InstanceId' --output text)

# 새로만든 ec2 instance에 ebs 붙이기 
aws ec2 attach-volume --volume-id $ebsSnapshot --instance-id $newInstanceId --device /dev/sdf

#기존 ec2 제거 

aws ec2 terminate-instances --region $REGION --instance-ids $instanceId

#새로만든 instance에 eip붙이기

aws ec2 associate-address --instance-id $newInstanceId --public-ip $eipAddress


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