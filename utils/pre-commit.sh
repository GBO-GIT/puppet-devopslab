#!/bin/sh
# pre-commit git hook to check the validity of a puppet manifest
# It also ensure no AWS credentials are sent in git repository
#
# Prerequisites:
#   gem install puppet-lint puppet
#
# Install:
#  ln -s /path/to/repo/hooks/pre-commit.sh /path/to/repo/.git/hooks/pre-comit

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

syntax_is_bad=0
which puppet-lint 2>&1 1>/dev/null
if [ $? -eq 0 ]
then
    echo "### Checking puppet syntax ###"
    for file in `git diff --name-only --cached | grep -E '\.(pp|erb)'`
    do
        # Only check new/modified files
        if [ -f $file ]
        then
            lint $file

            if [ $? -ne 0 ]
            then
                syntax_is_bad=1
            else
                echo "$file looks good"
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
    for file in `git diff --name-only --cached | grep -E '\.(pp|erb)'`
    do
        if [ -f $file ]
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
    done
else
    echo "Warning: no puppet, no check"
fi
echo ""

if [ $syntax_is_bad -eq 1 ]
then
    echo "FATAL: Syntax is bad. See above errors"
    echo "Bailing"
    exit 1
else
    echo "Everything looks good."
fi

echo ""
echo "### Trim files ###"
for file in `git diff --name-only --cached | grep -E 'Vagrantfile|\.(erb|pp|sh|md|yaml|json)'`
do
    if [ -f $file ]
    then
        has_trailing_space $file
        if [ $? -eq 1 ]
        then
            echo "INFO: Remove trailing space from $file"
            syntax_is_bad=1
            trim $file
        fi
    fi
done
echo ""

if [ $syntax_is_bad -eq 1 ]
then
    echo "FATAL: Some files have been trimed. Please add them and commit again."
    echo "Bailing"
    exit 1
else
    echo "Trim is good"
fi
exit 0

