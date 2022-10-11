#!/bin/bash
id=$1
keyfilename=$2
presignedurl=$3

ssh-keygen -t rsa -b 4096 -C "${id}" -f "${keyfilename}" -N ""

curl ${presignedurl} --upload-file ${keyfilename} --header "X-Amz-ACL: private"

rm ${keyfilename} ${keyfilename}.pub