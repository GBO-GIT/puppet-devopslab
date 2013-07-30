puppet-devopslab
================

Prologism's' DevOps Lab run with puppet

# Description

This configuration is set to be runned by a puppet-manager.
Alternatively, it can be deploy by vagrant.


## Developpement
Please install local hook for pre-commit by running:

    ln -s ../../utils/pre-commit.sh ./.git/hooks/pre-commit

Before a commit, please run ./utils/check.sh

Prerequisites are:

- puppet
- puppet-lint

