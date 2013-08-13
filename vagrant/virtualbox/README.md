Vagrantfile for virtualbox
================

# Description

This vagrantfile can deploy a virtualbox instance.

# Prerequisites

 - vagrant >= v1.2.6

# Deploying
## vagrant up

This command creates and provisions the instance.

If the instance is stopped, it doesn't restart it.

    vagrant up {box}

## vagrant provision

This command provisions again the instance.

    vagrant provision {box}

## vagrant ssh

This command connects you on the running instance.

    vagrant ssh {box}

## vagrant halt

This command stops the running instance.

## vagrant destroy

This command terminates the instance and destroy the files.

    vagrant destroy {box}

