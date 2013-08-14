#!/bin/sh
# This shell install lastest version of puppet
# It's made to be runned as a vagrant provisionner
# ---------
# Currently only tested on Debian based systems

_install_pkglist ()
{
    case "${vm_os}" in
        "Debian"|"Ubuntu")
            DEB="puppetlabs-release-${distrib_codename}.deb"
            DEB_PROVIDES="/etc/apt/sources.list.d/puppetlabs.list"
            if [ ! -e $DEB_PROVIDES ]
            then
                wget -q http://apt.puppetlabs.com/$DEB
                sudo dpkg -i $DEB
            fi
            ;;
        "Redhat"|"CentOS")
            rpm -ivh http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-7.noarch.rpm
            ;;
        "Fedora")
            rpm -ivh http://yum.puppetlabs.com/fedora/f17/products/i386/puppetlabs-release-17-7.noarch.rpm
            ;;
        *)
            _error "OS unsupported by `basename $0 .sh`"
            ;;
    esac

}

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

test "`id -u`" = "0" || _error "you need to be root (Are you sure you are on a VM?)"

status_file=/tmp/`basename $0 .sh`_$$.status
log_file=/tmp/`basename $0 .sh`.log

((
_log "--------------------"
_log "Will upgrade (if necessary) puppet"

_vm_info
_install_pkglist
_update_pkglist
_install_pkg "puppet"
_log "Done"
_log "--------------------"
exit 0

) 2>&1; echo $? > ${status_file} ) | tee -a ${log_file}
exit_value=`cat ${status_file}`
rm -f ${status_file}
exit ${exit_value}

