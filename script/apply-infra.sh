#!/bin/bash
privateKey=$1
desc=$2

# replace exsists terraform
infraName=$(echo $desc | yq -oj eval . | jq '.name')

# download privateKey
aws s3api get-object --bucket scs-user-pks --key $privateKey $privateKey

# clone infra template
git clone https://github.com/scs-solution/scs-infra-template
cd scs-infra-template

# generate public key from private key
ssh-keygen -f ./../$privateKey -y > $private.pub

# download secret.tf
aws s3api get-object --bucket scs-config --key secret.tf secret.tf

# download tfstate.tf
aws s3api get-object --bucket scs-tfstate --key $infraName tfstate.tf

for row in $(echo $desc | yq -oj eval . | jq '.instances' | jq -r '.[] | @base64'); do
  _jq() {
   echo ${row} | base64 --decode | jq -r ${1}
  }

  instanceName=$(_jq '.name')
  instanceSpec=$(_jq '.instanceSpec')
  instanceType=$(_jq '.instanceType')

  # normal, spot, rds, redis
  cp $instanceType-template.tf instance-$instanceName.tf

  sed -i "s/%%keyname%%/${privateKey}/g; s/%%instancename%%/${infraName}#${instanceName}/g; s/%%instancespec%%/${instanceSpec}/g" instance-$instanceName.tf
done

# remove templates
rm *-template.tf

# apply
terraform apply -auto-approve

# upload tfstate.tf
aws s3api put-object --bucket scs-tfstate --key $infraName tfstate.tf

# get instance id

# remove template
cd ..
rm -rf scs-infra-template