#!/bin/sh
# Functions library
#
# Prerequisites:
#   gem install puppet-lint puppet
#

getProjectDir()
{
    initdir=`pwd`
    curdir=${initdir}
    while [ ! -d "${curdir}/.git" -a "${curdir}" != "/" ]
    do
        cd ..
        curdir=`pwd`
    done
    if [ -d "${curdir}/.git" ]
    then
        echo "${curdir}"
    fi
    cd "${initdir}"
}

isInSubmodule()
{
    if [ -f "${topdir}/.gitmodules" ]
    then
        reldir=`echo $1 | sed "s#${topdir}/##"`
        ignored_path=`grep "path" "${topdir}/.gitmodules" | cut -d' ' -f3`
        for path in ${ignored_path}
        do
            gotcha=`echo ${reldir} | sed "s#${path}#GOTCHA#" | grep "GOTCHA"`
            if [ -n "${gotcha}" ]
            then
                return 0
            fi
        done
        return 1
    else
        return 0
    fi
}


lint ()
{
    puppet-lint \
        --no-80chars-check \
        --no-autoloader_layout-check \
        --no-nested_classes_or_defines-check \
        --no-only_variable_string-check \
        --no-2sp_soft_tabs-check \
        --with-filename $1
    return $?
}

validate ()
{
    puppet parser validate $1
}
