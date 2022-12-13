
infraName=$1
instanceId=$2
newInstanceId=$3
privateIp=$4
requestId=$5

aws s3api get-object --bucket scs-tfstate --key $infraName terraform.tfstate

## Modfiy RequestId
jq '(.resources[] | select(.name=="'${infraName}'-'${instanceId}'")).instances[0].attributes.id = "'${requestId}'"' terraform.tfstate > terraform.tfstate

## Modify InstanceId
jq '(.resources[] | select(.name=="'${infraName}'-'${instanceId}'")).instances[0].attributes.spot_instance_id = "'${newInstanceId}'"' terraform.tfstate > terraform.tfstate

## Modify Private Ip
jq '(.resources[] | select(.name=="'${infraName}'-'${instanceId}'")).instances[0].attributes.private_ip = "'${privateIp}'"' terraform.tfstate > terraform.tfstate

## Modfiy eip InstanceId
jq '(.resources[] | select(.name=="eip-'${infraName}'-'${instanceId}'")).instances[0].attributes.instance = "'${newInstanceId}'"' terraform.tfstate > terraform.tfstate


aws s3api put-object --bucket scs-tfstate --key $infraName --body terraform.tfstate