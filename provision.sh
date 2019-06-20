#!/bin/sh

set -e 

set +x 

sudo systemctl disable apt-daily.timer
sudo systemctl disable apt-daily-upgrade.timer

sudo killall apt apt-get || echo "No apt-get process running"

if [ "$machinetype" = "backendMQ" ]
then 

cat << EOF

"#####################################################"
"In Backend provisioning Starting to install rabbitmq"
"#####################################################"

EOF

#These steps are from : https://www.rabbitmq.com/install-debian.html

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

	else
		echo "Skipping install of RabbitMQ as this is frontend machine"
fi 

python3 -V

cat << EOF

"##########################################"
"Installing PIP "
"##########################################"

EOF

sudo apt-get install python-pip -y

cat << EOF

"##########################################"
"Installing nameko "
"##########################################"

EOF

pip install nameko

cd /vagrant


if [ "$machinetype" = "backendMQ" ]
then 

cat << EOF

"##########################################"
"In backned: Starting BackEnd File service "
"##########################################"

EOF
set -x

# Copy config that runs Rabbit MQ on 7600 port and allow guest user access
cp /vagrant/rabbitmq.conf /etc/rabbitmq/rabbitmq.conf

cd /vagrant

rm -rf backendoutput.log || echo "No need to cleanup backendoutput"

# Restart Rabbit MQ to take new config 

sudo service rabbitmq-server restart
rabbitmqctl status

# Start Backend Micro service 
nameko run --config config.yml BackEnd > backendoutput.log 2>&1 &

echo "####### Done Starting BackEnd File service"
else
echo "Skipping starting of backend code - Starting of RabbitMQ and BackEnd microservice"	
fi



if [ "$machinetype" = "frontend" ]
then 
cat << EOF

"##########################################"
"In Frontend: Starting FrontEnd HTTP Server "
"##########################################"

EOF

echo "I am in "
pwd 
set -x

cd /vagrant
ps -ef | grep nameko

# Start frontend service 
rm -rf frontendoutput.log || echo "No need to cleanup frontendoutput"

echo "Running command : nameko run --config config.yml FrontEnd > frontendoutput.log 2>&1"

nameko run --config config.yml FrontEnd > frontendoutput.log 2>&1 &
sleep 5
ps -ef | grep nameko

echo "####### Done Starting FrontEnd HTTP/File service"
else
echo "Skipping starting of frontend code"	

fi 