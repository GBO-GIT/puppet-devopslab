#!/bin/sh
# Locally apply puppet configuration

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

. ${curdir}/functions.sh || exit 1

cd ${curdir}/../hieradata 2>/dev/null || cd /etc/puppet/hieradata 2>/dev/null || _error "Cannot find hieradata directory"
hieradata_dir=`pwd`
cd ${curdir}/../manifests 2>/dev/null || _error "Cannot find manifests directory"
manifests_dir=`pwd`
cd ${curdir}/../modules 2>/dev/null || cd ${curdir}/../modules-0 2>/dev/null || _error "Cannot find modules directory"
modules_dir=`pwd`
cd ${initdir}


which puppet 2>&1 >/dev/null || ${curdir}/upgrade_puppet.sh

if [ `puppet --version | cut -d. -f1` -lt 3 ]
then
    _error "Please upgrade to puppet v3 by running upgrade_puppet.sh"
fi

_log "Hieradata: ${hieradata_dir}"
_log "Modules  : ${modules_dir}"
_log "Manifests: ${manifests_dir}"

puppet apply \
  --hiera_config "${hieradata_dir}"/hiera.yaml \
  --modulepath "/etc/puppet/modules:${modules_dir}" \
  --detailed-exitcodes \
  --verbose \
  "${manifests_dir}"/site.pp

