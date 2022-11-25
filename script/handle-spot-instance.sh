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


# ami를 활용해 ec2만들기
aws ec2 run-instances \
--region $REGION \
--image-id $AMI_ID_TARGET \
--count 1 \
--instance-type $instanceType \
--key-name $privateKey

#기존의 ec2의 ebs 뽑기 





# replace exsists terraform
#infraName=$(echo $desc | yq -oj eval . | jq -r '.name')

# download privateKey
#aws s3api get-object --bucket scs-user-pks --key $privateKey.key $privateKey
#chmod 700 $privateKey

# clone infra template
#git clone https://github.com/scs-solution/scs-infra-template $infraName
#cd $infraName

# generate public key from private key
#ssh-keygen -f ./../$privateKey -y > _$privateKey.pub

# download secret.tf
#aws s3api get-object --bucket scs-config --key secret.tf secret.tf

# download tfstate.tf
#aws s3api get-object --bucket scs-tfstate --key $infraName terraform.tfstate

#for row in $(echo $desc | yq -oj eval . | jq '.instances' | jq -r '.[] | @base64'); do
##  _jq() {
 #  echo ${row} | base64 --decode | jq -r ${1}
#  }

#  instanceName=$(_jq '.name')
#  instanceSpec=$(_jq '.instanceSpec')
#  instanceType=$(_jq '.instanceType')

  # normal, spot, rds, redis
#  cp $instanceType-template.tf instance-$instanceName.tf

##  sed -i "s/%%keyname%%/_${privateKey}/g; s/%%instancename%%/${infraName}-${instanceName}/g; s/%%instancespec%%/${instanceSpec}/g" instance-$instanceName.tf
#done

# remove templates
#rm *-template.tf

# remove provider.tf
#rm provider.tf

# init
#terraform init

# apply
#terraform apply -auto-approve

# upload tfstate.tf
#aws s3api put-object --bucket scs-tfstate --key $infraName --body terraform.tfstate

# get instance id
#echo "aws_spot_instance_request.${infraName}-${instanceName}.public_ip" | terraform console

# sync with backend database



# remove template
#rm -rf $infraName

# remove key
#rm $privateKey



#볼륨 탑재 해제
#Linux 인스턴스에서 다음 명령을 사용하여 /dev/sdh 디바이스의 탑재를 해제합니다.
# $umount -d /dev/sdh

#/Create an AMI/Create an Image-AMI and launch EC2

#Step1: Launch an EC2 Instance and save the instance ID into an environment variable

instance_id=$(aws ec2 run-instances --image-id ami-55ef662f --instance-type t2.micro --key-name MyKeyPair1 --user-data file://userdata.txt  --query 'Instances[*].[InstanceId]' --output text )


#Step 2: Check the user data worked and the web server is running by typing the web server IP on a browser and verifying you see ÒHello WorldÓ

#Step 3: Create an image from that instance ID and save the image id to a variable image_id
image_id=$(aws ec2 create-image --instance-id $instance_id --name "My server" --description "An AMI for my webserver" --query ImageId --output text)

#step 4: use that image to launch an instance
aws ec2 run-instances --image-id $image_id --instance-type t2.micro --key-name MyKeyPair1   --query 'Instances[*].[InstanceId]' --output text 
i-03c84ceb5391371b6

#Step 5: verify the web server is running by typing  the IP address on a browser

#https://github.com/ravsau/AWS-CLI-Commands/blob/master/Create%20an%20AMI/Create%20an%20Image-AMI%20and%20launch%20EC2.txt