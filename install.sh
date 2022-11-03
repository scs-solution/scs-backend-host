sudo pip3 install gunicorn flask requests

sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
sudo yum -y install jq

sudo wget https://github.com/mikefarah/yq/releases/download/v4.28.1/yq_linux_amd64 -O /usr/bin/yq &&\
    sudo chmod +x /usr/bin/yq
