#!/bin/bash

set -eux

nargv=$#

inorogexist=0

if [ $nargv -eq 6 ];  then  # lat-lon grid
  lonb=$1
  latb=$2
  outdir=$3
  script_dir=$4
  is_latlon=1
  orogfile="none"
  hist_dir=$5
  TMPDIR=$6
  workdir=$TMPDIR/latlon/orog/latlon_${lonb}x${latb}
elif [ $nargv -eq 7 ]; then  # cubed-sphere grid
  res=$1 
  lonb=$1
  latb=$1
  tile=$2
  griddir=$3
  outdir=$4
  script_dir=$5
  is_latlon=0
  orogfile="none"
  hist_dir=$6
  TMPDIR=$7
  workdir=$TMPDIR/C${res}/orog/tile$tile
elif [ $nargv -eq 8 ]; then  # input your own orography files
  res=$1 
  lonb=$1
  latb=$1
  tile=$2
  griddir=$3
  outdir=$4
  is_latlon=0
  inputorog=$5
  script_dir=$6
  orogfile=$inputorog
  inorogexist=1
  hist_dir=$7
  TMPDIR=$8
  workdir=$TMPDIR/C${res}/orog/tile$tile
else
  echo "Number of arguments must be 7 or 8 for cubic sphere grid and 6 for lat-lon grid"
  echo "Usage for cubic sphere grid: $0 resolution tile griddir outdir script_dir hist_dir TMPDIR"
  exit 1
fi

indir=$hist_dir
#executable=$exec_dir/orog.x
executable=${OROGEXEC:-$exec_dir/hafs_orog.x}
if [ ! -s $executable ]; then
  echo "executable does not exist"
  #exit 1 
fi

if [ ! -s $workdir ]; then mkdir -p $workdir ;fi
if [ ! -s $outdir ]; then mkdir -p $outdir ;fi

#jcap is for Gaussian grid
#jcap=`expr $latb - 2 `
jcap=0
NF1=0
NF2=0
mtnres=1
efac=0
blat=0
NR=0

if [ $is_latlon -eq 1 ]; then
  OUTGRID="none"
else
  OUTGRID="C${res}_grid.tile${tile}.nc"
fi

# Make Orograraphy
echo "OUTGRID = $OUTGRID"
echo "workdir = $workdir"
echo "outdir = $outdir"
echo "indir = $indir"

cd $workdir

cp ${indir}/thirty.second.antarctic.new.bin fort.15
cp ${indir}/landcover30.fixed .
#  uncomment next line to use the old gtopo30 data.
#   cp ${indir}/gtopo30_gg.fine.nh  fort.235
#  use gmted2020 data.
cp ${indir}/gmted2010.30sec.int  fort.235
if [ $inorogexist -eq 1 ]; then
   cp $inputorog .
fi   
     
if [ $is_latlon -eq 0 ]; then
   cp ${griddir}/$OUTGRID .
fi
#cp $executable .

echo  $mtnres $lonb $latb $jcap $NR $NF1 $NF2 $efac $blat > INPS
echo $OUTGRID >> INPS
echo $orogfile >> INPS
cat INPS

module purge

#export I_MPI_OFI_LIBRARY_INTERNAL=0
#export FI_PROVIDER=efa
export I_MPI_DEBUG=5
#export I_MPI_FABRICS=ofi
#export I_MPI_OFI_PROVIDER=efa
#export I_MPI_PIN_DOMAIN=omp
#export KMP_AFFINITY=compact
export SLURM_EXPORT_ENV=ALL
export I_MPI_PMI_LIBRARY=/opt/slurm/lib/libpmi.so


# module load libfabric-aws/1.13.2amzn1.0 && \

pre_cmd="source /opt/intel/oneapi/setvars.sh --force && \
source /usr/share/lmod/lmod/init/bash && \
module use /usr/share/modules/modulefiles && \
module use /opt/HAFS/modulefiles && \
module load modulefile.hafs.aws && \
module use /opt/HAFS/sorc/hafs_utils.fd/modulefiles && \
module load build.aws.intel && \
module use /opt/intel/compilers_and_libraries_2020.2.254/linux/mpi/intel64/modulefiles/ && \
module load intelmpi && \
ulimit -s unlimited && \
cd ${workdir/lustre/opt} && "

eval "$APRUNO '$pre_cmd $executable < INPS'"
#$APRUNO $pre_cmd $executable < INPS

if [ $? -ne 0 ]; then
  echo "ERROR in running $executable "
  exit 1
else
  if [ $is_latlon -eq 1 ]; then
     outfile=oro.${lonb}x${latb}.nc
  else
     outfile=oro.C${res}.tile${tile}.nc
  fi

  mv ./out.oro.nc $outdir/$outfile
  echo "file $outdir/$outfile is created"
  echo "Successfully running $executable "
  exit 0
fi

exit
