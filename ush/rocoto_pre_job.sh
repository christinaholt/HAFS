#! /bin/bash
#sudo ln -sf /bin/bash /bin/sh
set -x -u -e
date

if [ ! -d $USHhafs ] ; then
  fp=$(readlink -f "${BASH_SOURCE[0]}")
  USHhafs=$( dirname "$(readlink -f "$fp" )")
fi

. $USHhafs/hafs_pre_job.sh.inc
exec "$@"
