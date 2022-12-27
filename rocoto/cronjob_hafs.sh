#!/bin/sh
set -x
date

# NOAA WCOSS Dell Phase3
#HOMEhafs=/gpfs/dell2/emc/modeling/noscrub/${USER}/save/HAFS
#dev="-s sites/wcoss_dell_p3.ent -f"
#PYTHON3=/usrx/local/prod/packages/python/3.6.3/bin/python3

# NOAA WCOSS Cray
#HOMEhafs=/gpfs/hps3/emc/hwrf/noscrub/${USER}/save/HAFS
#dev="-s sites/wcoss_cray.ent -f"
#PYTHON3=/opt/intel/intelpython3/bin/python3

# NOAA RDHPCS Jet
#HOMEhafs=/mnt/lfs4/HFIP/hwrfv3/${USER}/HAFS
#dev="-s sites/xjet.ent -f"
#PYTHON3=/apps/intel/intelpython3/bin/python3

# MSU Orion
# HOMEhafs=/work/noaa/hwrf/save/${USER}/HAFS
# dev="-s sites/orion.ent -f"
# PYTHON3=/apps/intel-2020/intel-2020/intelpython3/bin/python3

# NOAA RDHPCS Hera
#HOMEhafs=/scratch1/NCEPDEV/hwrf/save/${USER}/HAFS
#dev="-s sites/hera.ent -f"
#PYTHON3=/apps/intel/intelpython3/bin/python3

HOMEhafs=/lustre/HAFS-AMD
dev="-s sites/aws.ent -f"
PYTHON3=/usr/bin/python3

cd ${HOMEhafs}/rocoto

EXPT=$(basename ${HOMEhafs})

#===============================================================================
# Here are some simple examples, more examples can be seen in cronjob_hafs_rt.sh

# Run all cycles of a storm
#${PYTHON3} ./run_hafs.py ${dev} 2020 13L HISTORY config.EXPT=${EXPT} # Laura

# Run specified cycles of a storm
#${PYTHON3} ./run_hafs.py ${dev} 2020082506-2020082512 13L HISTORY \
#   config.EXPT=${EXPT} config.SUBEXPT=${EXPT} # Laura

# Run one cycle of a storm
# ${PYTHON3} ./run_hafs.py -t ${dev} 2020082512 13L HISTORY config.EXPT=${EXPT}
# SAM 18L 
 ${PYTHON3} ./run_hafs.py -t ${dev} 2021092400 18L HISTORY config.EXPT=${EXPT}
# ${HOMEhafs}/parm/examples/hafs_regional_C96s1n4_180x180.conf
# ${PYTHON3} ./run_hafs.py -t ${dev} 2021081600 06L HISTORY config.EXPT=${EXPT}
# ${HOMEhafs}/parm/examples/hafs_regional_C96s1n4_180x180.conf

#===============================================================================

date

echo 'cronjob done'
