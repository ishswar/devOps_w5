# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.


  config.vm.define "backendMQ" do |backendMQ|
    backendMQ.vm.box = "xenial64_pshah_v2"
    backendMQ.vm.network "private_network" , ip: "192.168.33.76"
    backendMQ.vm.hostname = "backendMQ"
    backendMQ.vm.provision "shell", path: "provision.sh" ,env: {"machinetype" => "backendMQ"}
    backendMQ.vm.network "forwarded_port", guest: 7600 , host: 7600
    #
    backendMQ.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
  
    # Customize the amount of memory on the VM:
      vb.memory = "1024"
    end
  end 

  config.vm.define "frontend" do |frontend|
    frontend.vm.box = "xenial64_pshah_v2"
    frontend.vm.network "private_network" , ip: "192.168.33.86"
    frontend.vm.hostname = "frontend"
    frontend.vm.provision "shell", path: "provision.sh" ,env: {"machinetype" => "frontend"}
    frontend.vm.network "forwarded_port", guest: 8000 , host: 8090
    #
    frontend.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
  
    # Customize the amount of memory on the VM:
      vb.memory = "1024"
    end
  end

  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
