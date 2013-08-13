#!/bin/sh
# Check the validity of the puppet project excluding submodules
#
# Prerequisites:
#   gem install puppet-lint puppet
#

TARGET=$0
initdir=`pwd`
if [ -L ${TARGET} ]
then
    LINK=`ls -l $0`
    TARGET=`echo ${LINK} |  sed 's/^.* -> //'`
    cd `dirname $0` && cd `dirname ${TARGET}`
else
    cd `dirname $0`
fi
curdir=`pwd`
cd ${initdir}

. ${curdir}/functions.sh || exit 1
topdir=`getProjectDir`

echo "Project directory is ${topdir}"

syntax_is_bad=0
which puppet-lint 2>&1 1>/dev/null
if [ $? -eq 0 ]
then
    echo "### Checking puppet syntax ###"
    for file in `find ${topdir} -type f | grep -E '\.(pp|erb)'`
    do
        if [ -f $file ]
        then
            isInSubmodule "${file}"
            if [ $? -eq 1 ]
            then
                lint ${file}
                if [ $? -ne 0 ]
                then
                    syntax_is_bad=1
                else
                    echo "$file looks good"
                fi
            fi
        fi
    done
else
    echo "Warning: no puppet-lint, no check"
fi
echo ""

which puppet 2>&1 1>/dev/null
if [ $? -eq 0 ]
then
    echo "### Checking if puppet manifests are valid ###"
    for file in `find ${topdir} -type f | grep -E '\.(pp|erb)'`
    do
        if [ -f $file ]
        then
            isInSubmodule "${file}"
            if [ $? -eq 1 ]
            then
                validate $file
                if [ $? -ne 0 ]
                then
                    echo "ERROR: puppet parser failed at: $file"
                    syntax_is_bad=1
                else
                    echo "OK: $file looks valid"
                fi
            fi
        fi
    done
else
    echo "Warning: no puppet, no check"
fi
echo ""
if [ $syntax_is_bad -eq 1 ]
then
    echo "FATAL: Syntax is bad. See above errors"
    exit 1
else
    echo "Everything looks good."
fi

echo ""
echo "### Checking for security credentials ###"
for file in `find ${topdir} -type f | grep 'Vagrantfile'`
do
    if [ -f $file ]
    then
        isInSubmodule "${file}"
        if [ $? -eq 1 ]
        then
            if [ -n "`grep 'access_key_id' $file | sed -e 's/^.*=[ ]*["]*\([^"]*\)["]*.*$/\1/' | grep -v 'YOUR KEY' | grep -v '$aws_access_key_id'`" ]
            then
                echo "ERROR: unsecured access_key_id at: $file"
                syntax_is_bad=1
            fi
            if [ -n "`grep 'secret_access_key' $file | sed -e 's/^.*=[ ]*"\([^"]*\)".*$/\1/' | grep -v 'YOUR SECRET KEY' | grep -v '$aws_secret_access_key'`" ]
            then
                echo "ERROR: unsecured secret_access_key at: $file"
                syntax_is_bad=1
            fi
            if [ -n "`grep 'private_key_path' $file | sed -e 's/^.*=[ ]*"\([^"]*\)".*$/\1/' | grep -v 'YOUR LOCAL KEY FILE' | grep -v '$ssh_private_key_path'`" ]
            then
                echo "ERROR: unsecured private_key_path at: $file"
                syntax_is_bad=1
            fi
        fi
    fi
done
echo ""

if [ $syntax_is_bad -eq 1 ]
then
    echo "FATAL: Don't put any credentials in your files"
    echo "Bailing"
    exit 1
else
    echo "No credentials detected => OK"
fi

echo ""
echo "### Trim files ###"
for file in `find ${topdir} -type f | grep -E 'Vagrantfile|\.(erb|pp|sh|md|yaml|json)'`
do
    if [ -f $file ]
    then
        isInSubmodule "${file}"
        if [ $? -eq 1 ]
        then
            has_trailing_space "$file"
            if [ $? -eq 1 ]
            then
                echo "INFO: Remove trailing spaces from $file"
                trim $file
            fi
        fi
    fi
done
exit 0

