# devOps_w5
Microservices and Vagrant

## Overview 

A little bit about backend: (In this VM) Backend is comprised of Rabbit MQ and Nameko microservice. This microservice implements one RPC method that reads a file ( filename is passed as input to the method ) and sends back the content of the file as return data for this RPC call. Python microservice connects to Rabbit MQ over port 7600.

Backend VM also has a bunch of file in /vagrant/files folder named a.txt, b.txt, c.txt, and d.txt. 

About frontend:(In this VM) There is also a microserver running that implemented using nameko as well. It starts a simple HTTP Server. If it gets a GET call then it expects file name to be passed as input parameter ( part of URI ) - once it gets a file name it makes an RPC call to backend service (RPC call over port 7600) and asks it to get content of the file. The backend will send data back if it finds a file matching with input if not it will send back an error. The HTTP server will send that data back to the requester.   

We test Frontend using cURL tool - see below for sample output.

### Over all archetecutre 

![alt text](Vagrant-DevOps.png)

### Provisioner script 

``` BASH 
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
cp /vagrant/rabbitmq.conf /etc/rabbitmq/rabbitmq.conf

cd /vagrant

rm -rf backendoutput.log || echo "No need to cleanup backendoutput"
sudo service rabbitmq-server restart
rabbitmqctl status

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
rm -rf frontendoutput.log || echo "No need to cleanup frontendoutput"

echo "Running command : nameko run --config config.yml FrontEnd > frontendoutput.log 2>&1"

nameko run --config config.yml FrontEnd > frontendoutput.log 2>&1 &
sleep 5
ps -ef | grep nameko

echo "####### Done Starting FrontEnd HTTP/File service"
else
echo "Skipping starting of frontend code"	

fi 

```
### Back-end Python microservice (using nameko) - on request it will read file that was part of input 

``` PYTHON

# BackEnd.py

from nameko.rpc import rpc
import sys
import os

class BackEndService:
	name = "backEnd_service"

	@rpc
	def getFileContents(self, name):
			print(sys.version) 
			try:
				file = open(os.path.join("files",name), "r")
				filetext = file.read()
			except:
				 filetext = "~Error-File: "+name+" NotFound"
			
			return filetext


```

### Front-end Python microservice (using nameko) - Starts HTTP Server and based on request parameter it will ask backed service to get file

``` PYTHON

# FrontEnd.py

from nameko.standalone.rpc import ClusterRpcProxy
from nameko.web.handlers import http

config = {
    'AMQP_URI': "amqp://guest:guest@192.168.33.76:7600//"  # e.g. "pyamqp://guest:guest@localhost"
}

#n.rpc.greeting_service.hello

class HttpService:
	name = "http_service"

	@http('GET', '/get/<string:value>')
	def get_method(self, request, value):
		print("Input is "+ value)
		with ClusterRpcProxy(config) as cluster_rpc:
			rest = cluster_rpc.backEnd_service.getFileContents(value)
			print("File Content of file testfile1.text: \n###############################################\n"+ rest + "\n####################################################")
			if rest.startswith( '~' ):
			 return 404, "File "+ value + " NOT_FOUND"
			else:
			 return rest


```

### Output showing HTTP GET (via cURL) of various files and non-existent file 

``` SHELL

  ~ ➜  ~ curl -i localhost:8090/get/a.txt
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
Content-Length: 514
Date: Wed, 19 Jun 2019 21:37:40 GMT

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec id ipsum nec sapien mattis commodo et at nulla. Proin semper blandit varius. Etiam congue est sit amet magna hendrerit, luctus euismod mi tempor. Suspendisse scelerisque aliquam tellus non fringilla. Maecenas laoreet sed nulla id fermentum. Aliquam sed neque eget lorem malesuada aliquam. Nullam rhoncus lectus eu enim egestas consectetur. Aenean at nunc nec orci ultricies scelerisque vel vel nulla. Maecenas iaculis ante sed neque consequat dictum.



➜  ~ curl -i localhost:8090/get/b.txt
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
Content-Length: 643
Date: Wed, 19 Jun 2019 21:37:43 GMT

Nunc ultricies tempus purus non vulputate. Quisque pretium rutrum velit, eu porttitor lorem elementum id. Maecenas vulputate lobortis libero, eget luctus erat consequat sed. Duis sodales ullamcorper elit, sed ultrices eros eleifend a. Nulla hendrerit leo at orci commodo pulvinar. Nunc ultrices aliquam turpis, quis hendrerit felis. Pellentesque tristique, sapien sit amet condimentum tempor, neque metus viverra leo, sit amet volutpat metus massa vitae lorem. Nunc suscipit tristique massa. Pellentesque dignissim justo id eros commodo ultricies. Cras sed nunc dictum, laoreet felis vel, imperdiet elit. Cras placerat feugiat sem at maximus.


➜  ~ curl -i localhost:8090/get/c.txt
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
Content-Length: 822
Date: Wed, 19 Jun 2019 21:37:45 GMT

Phasellus leo erat, consectetur at velit quis, ultrices suscipit nisi. Sed tortor nisl, dapibus id vulputate id, mollis nec ex. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed nec est dolor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam erat volutpat. Suspendisse laoreet lobortis arcu, in mollis ex aliquam at. Aenean feugiat metus eget nisi interdum, nec vestibulum dolor sagittis. Mauris fringilla efficitur tincidunt. Nunc convallis venenatis sodales. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Praesent in elit a orci facilisis imperdiet a at libero. Aliquam diam ante, consectetur ultrices pulvinar auctor, dapibus ultrices augue. Morbi lorem elit, vestibulum sit amet nulla non, pulvinar dapibus sem.


➜  ~ curl -i localhost:8090/get/d.txt
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
Content-Length: 793
Date: Wed, 19 Jun 2019 21:37:48 GMT

Sed pharetra mauris quis sapien ornare, eget fringilla est sodales. Donec vitae pellentesque dolor, et fermentum erat. Nullam rutrum diam ac posuere condimentum. Aenean sit amet interdum sem. Morbi faucibus ipsum eget felis vulputate suscipit. Nulla facilisi. Nullam interdum ligula in nunc vestibulum, eget vulputate felis finibus. Proin sed lobortis turpis.

Quisque eleifend quam nec laoreet interdum. Vestibulum accumsan tristique efficitur. Vestibulum scelerisque nec nisi vitae vulputate. Praesent ultricies dignissim nibh, nec egestas quam facilisis nec. Phasellus ligula erat, elementum vitae volutpat in, pellentesque at nulla. Aliquam consectetur condimentum varius. Etiam maximus sapien dui, non tempus sem volutpat id. Praesent leo nibh, laoreet eget porta non, tincidunt at enim.


➜  ~ curl -i localhost:8090/get/foo.txt
HTTP/1.1 404 NOT FOUND
Content-Type: text/plain; charset=utf-8
Content-Length: 22
Date: Wed, 19 Jun 2019 21:37:52 GMT

File foo.txt NOT_FOUND%
```