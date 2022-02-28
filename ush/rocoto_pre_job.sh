#! /bin/bash
sudo ln -sf /bin/bash /bin/sh
set -x -u -e
date
. $USHhafs/hafs_pre_job.sh.inc
exec "$@"
