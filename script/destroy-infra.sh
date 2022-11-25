#!/bin/bash
privateKey=$1
desc=$2
updateKey=$3

# replace exsists terraform
infraName=$(echo $desc | yq -oj eval . | jq -r '.name')

# download privateKey
aws s3api get-object --bucket scs-user-pks --key $privateKey.key $privateKey
chmod 700 $privateKey

# clone infra template
git clone https://github.com/scs-solution/scs-infra-template $infraName
cd $infraName

# generate public key from private key
ssh-keygen -f ./../$privateKey -y > _$privateKey.pub

# download secret.tf
aws s3api get-object --bucket scs-config --key secret.tf secret.tf

# download tfstate.tf
aws s3api get-object --bucket scs-tfstate --key $infraName terraform.tfstate

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

# remove templates
rm *-template.tf

# remove provider.tf
rm provider.tf

# init
terraform init

# destroy
terraform destroy -auto-approve

# sync with backend database
cd ..
python3 ./script/sync-infra-db.py "${infraName}" "${infraName}/terraform.tfstate" "${updateKey}"

# remove template
rm -rf $infraName

# remove key
rm $privateKey