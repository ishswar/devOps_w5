#!/bin/sh

set -e 

set +x 

sudo systemctl disable apt-daily.timer
sudo systemctl disable apt-daily-upgrade.timer

sudo killall apt apt-get || echo "No apt-get process running"

sudo apt-key adv --keyserver "hkps.pool.sks-keyservers.net" --recv-keys 
wget -O - "https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc" | sudo apt-key add -
sudo apt-get install apt-transport-https
lsb_release -a

sudo tee /etc/apt/sources.list.d/bintray.erlang.list <<EOF
deb https://dl.bintray.com/rabbitmq/debian xenial erlang-21.x
EOF

sudo apt-get update -y

sudo apt-get install -y erlang-base \
                        erlang-asn1 erlang-crypto erlang-eldap  erlang-inets \
                        erlang-mnesia erlang-os-mon erlang-parsetools erlang-public-key \
                        erlang-runtime-tools erlang-snmp erlang-ssl \
                        erlang-syntax-tools  erlang-tools erlang-xmerl



wget -O - "https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey" | sudo apt-key add -

## Install RabbitMQ signing key
sudo apt-key adv --keyserver "hkps.pool.sks-keyservers.net" --recv-keys "0x6B73A36E6026DFCA"

## Install apt HTTPS transport
sudo apt-get install apt-transport-https

## Add Bintray repositories that provision latest RabbitMQ and Erlang 21.x releases
sudo tee /etc/apt/sources.list.d/bintray.rabbitmq.list <<EOF
deb https://dl.bintray.com/rabbitmq-erlang/debian xenial erlang-21.x
deb https://dl.bintray.com/rabbitmq/debian xenial main
EOF

## Update package indices
sudo apt-get update -y

## Install rabbitmq-server and its dependencies
sudo apt-get install rabbitmq-server -y --fix-missing

sudo rabbitmqctl status

python3 -V

sudo apt-get install python-pip -y

pip install nameko

cd /vagrant

cp /vagrant/rabbitmq.conf /etc/rabbitmq/rabbitmq.conf

sudo service rabbitmq-server restart

nameko run --config config.yml BackEnd & 

python FrontEnd.py  