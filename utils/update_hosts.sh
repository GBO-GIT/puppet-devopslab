#!/bin/sh
# This shell change /etc/hosts with values parsed from a Vagrantfile ($1)
# It's made to be runned as a vagrant provisionner
# ---------
# Currently only tested on Debian based systems


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


vagrant_file=$1
test "`id -u`" = "0" || _error "you need to be root (Are you sure you are on a VM?)"
test -f $vagrant_file || _error "Can't find your Vagrantfile."

status_file=/tmp/`basename $0 .sh`_$$.status
log_file=/tmp/`basename $0 .sh`.log
network_file=/tmp/network_`basename $0 .sh`_$$.txt
augeas_file=/tmp/augeas_$$.tmp
((
_log "--------------------"
_log "Will update (if necessary) /etc/hosts"

_vm_info
_update_pkglist

case "${vm_os}" in
    "Redhat"|"CentOS"|"Fedora")
        _install_pkg "augeas"
        ;;
    *)
        _install_pkg "augeas-tools"
        ;;
esac

# Parsing of Vagrantfile
grep -E '\.vm.box[ =]' ${vagrant_file} | grep -vE '^[ \t]*#' | tr -d ' ' | tr -d '\r' | sort | cut -d= -f2 | tr -d '"' > /tmp/box_$$.tmp
grep -E '\.vm.hostname[ =]' ${vagrant_file} | grep -vE '^[ \t]*#' | tr -d ' ' | tr -d '\r' | sort | cut -d= -f2 | tr -d '"' > /tmp/hostname_$$.tmp
grep -E '\.vm.network .*ip:' ${vagrant_file} | grep -vE '^[ \t]*#' | tr -d ' ' | tr -d '\r' | sort | sed 's/^.*ip:"*\([0-9\.]*\).*$/\1/' > /tmp/ip_$$.tmp
paste -d\; /tmp/box_$$.tmp /tmp/ip_$$.tmp /tmp/hostname_$$.tmp > ${network_file}
rm /tmp/box_$$.tmp /tmp/ip_$$.tmp /tmp/hostname_$$.tmp

_log "updating /etc/hosts with"
cat ${network_file}

rm -f ${augeas_file}
maxID=`augtool match /files/etc/hosts/* | tail -n1 | sed 's/^[^0-9]*\([0-9]*\).*$/\1/'`
cat ${network_file} | while read network_host
do
    network_box_name=`echo ${network_host} | cut -d\; -f1`
    network_ip=`echo ${network_host} | cut -d\; -f2`
    network_hostname=`echo ${network_host} | cut -d\; -f3`
    network_hostname_short=`echo ${network_hostname} | cut -d. -f1`
    if [ -n "${network_ip}" ]
    then
        iID=`augtool match /files/etc/hosts/*/ipaddr ${network_ip} | cut -d/ -f5`
        if [ "${iID}" = "" ]
        then
            iID=`expr ${maxID} + 1`
            maxID=${iID}
        fi
        echo "set /files/etc/hosts/${iID}/ipaddr ${network_ip}" >> ${augeas_file}
        echo "set /files/etc/hosts/${iID}/canonical ${network_hostname_short}" >> ${augeas_file}
        echo "set /files/etc/hosts/${iID}/alias[1] ${network_box_name}" >> ${augeas_file}
        if [ "${network_hostname}" != "${network_hostname_short}" ]
        then
         echo "set /files/etc/hosts/${iID}/alias[2] ${network_hostname}" >> ${augeas_file}
        fi
    fi
done
augtool -b -s < ${augeas_file}

_log "Done"
_log "--------------------"
exit 0

) 2>&1; echo $? > ${status_file} ) | tee -a ${log_file}
exit_value=`cat ${status_file}`
rm -f ${status_file} ${augeas_file} ${network_file}
exit ${exit_value}

