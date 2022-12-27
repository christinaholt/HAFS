#!/bin/bash
#SBATCH --job-name=hafs_atm_prep_18L_2021092400
#SBATCH -o /lustre/HAFS_OUTPUT/scrub/HAFS/2021092400/18L/hafs_atm_prep.log
##SBATCH --qos=misccomp
#SBATCH --nodes=1-1
#SBATCH --tasks-per-node=72
#SBATCH -t 00:30:00
#SBATCH --partition=misccomp
#SBATCH --comment=b748f69e2b366e2c70102df4bb47620c
export TOTAL_TASKS='12'
export NCTSK='6'
export OMP_THREADS='6'
export envir='prod'
export WHERE_AM_I='aws'
export HOMEhafs='/lustre/HAFS'
export USHhafs='/lustre/HAFS/ush'
export PYTHONPATH='/lustre/HAFS/ush'
export WORKhafs='/lustre/HAFS_OUTPUT/scrub/HAFS/2021092400/18L'
export COMhafs='/lustre/HAFS_OUTPUT/scrub/HAFS/com/2021092400/18L'
export CONFhafs='/lustre/HAFS_OUTPUT/scrub/HAFS/com/2021092400/18L/storm1.conf'
export HOLDVARS='/lustre/HAFS_OUTPUT/scrub/HAFS/com/2021092400/18L/storm1.holdvars.txt'
export jlogfile='/lustre/HAFS_OUTPUT/scrub/HAFS/log/jlogfile'
/lustre/HAFS/jobs/JHAFS_ATM_PREP
