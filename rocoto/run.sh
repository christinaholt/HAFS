#/bin/bash -l

source /opt/intel/oneapi/setvars.sh
source ~/.bash_profile
source /shared/aws_scripts/hafs.env

rocotorun -w hafs-HAFS-AMD-18L-2021092400.xml -d hafs-HAFS-AMD-18L-2021092400.db
