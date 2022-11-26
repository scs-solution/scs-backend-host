#!/bin/bash
sudo yum install -y yum-utils docker golang

sudo service docker start

sudo docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=8080:8080 \
  --detach=true \
  --name=cadvisor \
  --privileged \
  --device=/dev/kmsg \
  gcr.io/cadvisor/cadvisor:v0.36.0

sudo pip3 install webssh
sudo nohup wssh --origin='http://www.rollrat.com' &

wget https://github.com/scs-solution/scs-packet-capturer/releases/download/0/scs-packet-capturer
chmox +x scs-packet-capturer
sudo nohup ./scs-packet-capturer &
