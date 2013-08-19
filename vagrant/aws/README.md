Vagrantfile for amazon aws
================

# Description

This vagrantfile can deploy an aws instance.

Please, DO NOT put any secret credentials in this file.

Secrets (and so personnal) informations must be initialized in a 'aws.yaml' file, stored in current directory (check 'aws.yaml.example').

# Prerequisites

 - vagrant >= v1.2.6
 - vagrant-aws >= v1.2.2

# Deploying
## vagrant up

This command creates and provisions the instance.

If the instance is stopped, it doesn't restart it.

    vagrant up {box} --provider=aws

## vagrant provision

This command provisions again the instance.

    vagrant provision {box}

## vagrant ssh

This command connects you on the running instance.

Be sure to correctly set the variable _$ssh_private_key_path_ to locate your private key corresponding to the amazon keypair.

    vagrant ssh {box}

## vagrant halt

This command is not currently supported.

## vagrant destroy

This command terminates the instance.

    vagrant destroy {box}

# Amazon specific
## Setting the hostname

Setting a hostname in Vagrantfile doesn't work on Amazon. That's why we use the provision shell _force___hostname.sh_:

    lab_devops.vm.provision :shell do |s|
      s.inline = "sh /tmp/vagrant-puppet/utils/force_hostname.sh $1"
      s.args = lab_devops.vm.hostname
    end

## Shared folders are not shared

Share folders are synchronised from your devel machine to the virtual instance.

Modifications on the instance are not automatically reported in your local folders.

## No network configuration

Network configuration is not supported.

