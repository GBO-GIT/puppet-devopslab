#!/bin/sh
# This shell force permanently the hostname of the machine with $1
# It's made to be runned as a vagrant provisionner
# ---------
# Currently only tested on Debian based systems

_update_hostname ()
{
    test -z $1 && _error "Hostname is empty"
    case "${vm_os}" in
        "Debian"|"Ubuntu")
            echo $1 > /etc/hostname
            hostname $1
            ;;
        "Redhat"|"CentOS"|"Fedora")
            cp /etc/sysconfig/network /etc/sysconfig/network.postinstall.backup
            sed 's#^HOSTNAME=.*$#HOSTNAME='"$1"'#' /etc/sysconfig/network.postinstall.backup > /etc/sysconfig/network
            hostname $1
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

status_file=/tmp/force_hostname_$$.status
log_file=/tmp/force_hostname.log
((
_log "--------------------"
_log "Will force (if necessary) hostname"

vm_os=`lsb_release -is 2>/dev/null`
DISTRIB_CODENAME=`lsb_release --codename --short 2>/dev/null`
vm_current_hostname=`hostname`
vm_hostname=$1

if [ "${vm_hostname}" != "${vm_current_hostname}" ]
then
    _log "updating hostname"
    _update_hostname ${vm_hostname}
else
    _log "Not necessary"
fi

_log "Done"
_log "--------------------"
exit 0

) 2>&1; echo $? > ${status_file} ) | tee -a ${log_file}
exit_value=`cat ${status_file}`
rm -f ${status_file}
exit ${exit_value}
