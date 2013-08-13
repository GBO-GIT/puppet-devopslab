puppet-devopslab
================

Prologism's' DevOps Lab run with puppet

# Description

This configuration is set to be runned by a puppet-manager.

Alternatively, it can be deployed:

 - by vagrant (see vagrant chapter)
 - manually (see utils chapter)

# Prerequisites
Prerequisites on your VM are:

 - puppet >= v3.2.3
 - hiera >= v1.2.1

With vagrant, prerequisites on your host machine are:

 - vagrant >= v1.2.6
 - vagrant-aws >= v1.2.2 (if deploying on amazon)

# Deploying
## With vagrant and virtualbox

    cd vagrant/virtualbox
    # Launch VM
    vagrant up {box}
    # Deploy changes on a launched VM
    vagrant provision {box}

## With vagrant and amazon

    cd vagrant/aws
    # Launch VM
    vagrant up {box} --provider=aws
    # Deploy changes on a launched VM
    vagrant provision {box}

## With utils
The current whole project must be stored inside your VM.

This can only work if the hostname of your VM matches the expected hostname in puppet's manifests.

    cd utils
    ./puppet_apply.sh

# Development
Please install local hook for pre-commit by running:

    ln -s ../../utils/pre-commit.sh ./.git/hooks/pre-commit

Before a commit, please run ./utils/check.sh

Prerequisites on your development machine are:

- puppet
- puppet-lint

