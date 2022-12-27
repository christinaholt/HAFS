#!/bin/bash -l

# Run the singularity command, passing it the environment variables that are relevant to the task.
set -x
script=$1
name=$2
script_args="${@:3}"

export PS4='+ $SECONDS + '

if [ ! $(which singularity) ] ; then
  export PATH=$PATH:/shared/singularity/bin
fi

env | grep hafs
env_vars+=' envir      
  WHERE_AM_I
  HOMEhafs
  USHhafs
  PYTHONPATH
  WORKhafs
  COMhafs
  CONFhafs
  HOLDVARS
  jlogfile'
env_str=''

for env_var in $env_vars; do
  export SINGULARITYENV_$env_var=$(echo ${!env_var})
done

export jlogfile=/opt/HAFS_OUTPUT/scrub/HAFS/log/jlogfile
unset WORKhafs
if [ $name == 'launch' ] ; then
    cmd="
      source /usr/share/lmod/lmod/init/bash && \
      source /opt/intel/oneapi/setvars.sh && \
      export PLATFORM=aws && \
      /opt/HAFS_OUTER/ush/rocoto_pre_job.sh && \
      python3.8 $script $script_args"
else

    cmd="
      source /usr/share/lmod/lmod/init/bash && \
      env && \
      $script"
fi
#      source /opt/intel/oneapi/setvars.sh && \

which mpirun

export FI_PROVIDER=efa
export I_MPI_DEBUG=4
export I_MPI_FABRICS=ofi
export I_MPI_OFI_PROVIDER=efa
export I_MPI_PIN_DOMAIN=omp
export KMP_AFFINITY=compact

srun -n 1 singularity exec \
  -B /lustre/HAFS_container:/opt/HAFS_OUTER \
  -B /lustre/HAFS_OUTPUT:/opt/HAFS_OUTPUT:rw \
  -B /lustre/data/HAFS_INPUT:/opt/HAFS_INPUT \
  -B /opt/intel/compilers_and_libraries_2020.2.254 \
  -B /usr/lib/x86_64-linux-gnu/modulecmd.tcl \
  /shared/HAFS_containers/axiom-hafs_inteloneapi-latest.sif \
  bash -c "$cmd"

