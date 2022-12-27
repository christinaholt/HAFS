#!/bin/bash

set -eux

nargv=$#
if [ $nargv -ne 3 -a $nargv -ne 6 -a $nargv -ne 12 ]; then 
   echo "number of arguments must be 3 (regular cubic sphere grid), 6 (stretched grid) or 12 (nested grid)"
   echo "Usage for regular cubic sphere grid: "
   echo "  $0 resolution out_dir script_dir"
   echo "Usage for Stretched grid: "
   echo "  $0 resolution out_dir stetch_fac target_lon target_lat script_dir"
   echo "Usage for Nested grid: "
   echo "  $0 resolution out_dir stetch_fac target_lon target_lat refine_ratio istart_nest jstart_nest iend_nest jend_nest halo script_dir"
   exit 1
fi

APRUN=${APRUN:-time}
export res=$1 
export outdir=$2
if [ ! -s $outdir ]; then  mkdir -p $outdir ;fi

nx=`expr $res \* 2 `
cd $outdir

echo CRH
which mpirun

if [ $nargv -eq 3 ]; then
  export ntiles=6
  export script_dir=$3
  #export executable=$exec_dir/make_hgrid
  export executable=${MAKEHGRIDEXEC:-$exec_dir/hafs_make_hgrid.x}
  if [ ! -s $executable ]; then
    echo "executable does not exist"
    #exit 1 
  fi
  $APRUNS $executable --grid_type gnomonic_ed --nlon $nx --grid_name C${res}_grid

elif  [ $nargv -eq 6 ]; then
  export stretch_fac=$3
  export target_lon=$4
  export target_lat=$5
  export script_dir=$6
  export ntiles=6
  #export executable=$exec_dir/make_hgrid
  export executable=${MAKEHGRIDEXEC:-$exec_dir/hafs_make_hgrid.x}
  if [ ! -s $executable ]; then
    echo "executable does not exist"
    #exit 1 
  fi
  $APRUNS $executable --grid_type gnomonic_ed --nlon $nx --grid_name C${res}_grid --do_schmidt --stretch_factor ${stretch_fac} --target_lon ${target_lon} --target_lat ${target_lat} 

elif  [ $nargv -eq 12 ]; then
  export stretch_fac=$3
  export target_lon=$4
  export target_lat=$5
  export refine_ratio=$6
  export istart_nest=$7
  export jstart_nest=$8
  export iend_nest=$9
  export jend_nest=${10}
  export halo=${11}
  export script_dir=${12}
  if  [ $gtype = regional ]; then
   export ntiles=1
  else
   export ntiles=7
  fi
  #export executable=$exec_dir/make_hgrid
  export executable=${MAKEHGRIDEXEC:-$exec_dir/hafs_make_hgrid.x}
  if [ ! -s $executable ]; then
    echo "executable does not exist"
    #exit 1 
  fi
source /shared/apps/lmod/lmod/init/bash
module purge
export FI_PROVIDER=efa
export I_MPI_DEBUG=4
export I_MPI_FABRICS=ofi
export I_MPI_OFI_PROVIDER=efa
export I_MPI_PIN_DOMAIN=omp
export KMP_AFFINITY=compact
  which mpirun



pre_cmd="source /opt/intel/oneapi/setvars.sh --force && \
source /usr/share/lmod/lmod/init/bash && \
typeset -f module && \
echo \$LMOD_CMD && \
module use /opt/HAFS/modulefiles && \
module load modulefile.hafs.aws && \
module use /opt/HAFS/sorc/hafs_utils.fd/modulefiles && \
module load build.aws.intel && \
cd ${outdir/lustre/opt} && \\"

cmd="$pre_cmd
${executable} --grid_type gnomonic_ed --nlon 1536 --grid_name C768_grid --do_schmidt --stretch_factor 1.0001 --target_lon -45.1 --target_lat 15.0 --nest_grid --parent_tile 6 --refine_ratio 4 --istart_nest 125 --jstart_nest 225 --iend_nest 1410 --jend_nest 1310 --halo 3 --great_circle_algorithm"

run_me="srun singularity exec -B /lustre/HAFS_sing_exe:/opt/HAFS_OUTER -B ${outdir}:${outdir/lustre/opt}:rw -B /lustre/data/HAFS_INPUT:/opt/HAFS_INPUT -B /opt/intel/compilers_and_libraries_2020.2.254 -B /usr/lib/x86_64-linux-gnu/modulecmd.tcl -B /lustre/fix/hafs-20210520-fix/fix /shared/HAFS_containers/axiom-hafs_inteloneapi-latest.sif bash -c "
#  $APRUNS $executable --grid_type gnomonic_ed --nlon $nx --grid_name C${res}_grid --do_schmidt --stretch_factor ${stretch_fac} --target_lon ${target_lon} --target_lat ${target_lat} \
#     --nest_grid --parent_tile 6 --refine_ratio $refine_ratio --istart_nest $istart_nest --jstart_nest $jstart_nest --iend_nest $iend_nest --jend_nest $jend_nest --halo $halo --great_circle_algorithm \'

#eval $run_me 

eval "$APRUNS '$cmd'"


fi

if [ $? -ne 0 ]; then
  echo "ERROR in running create C$res grid without halo "
  exit 1
fi

#---------------------------------------------------------------------------------------
#export executable=$exec_dir/make_solo_mosaic
export executable=${MAKEMOSAICEXEC:-$exec_dir/hafs_make_solo_mosaic.x}
if [ ! -s $executable ]; then
  echo "executable does not exist"
  #exit 1 
fi

if [ $ntiles -eq 6 ]; then
  $APRUNS $executable --num_tiles $ntiles --dir $outdir --mosaic C${res}_mosaic --tile_file C${res}_grid.tile1.nc,C${res}_grid.tile2.nc,C${res}_grid.tile3.nc,C${res}_grid.tile4.nc,C${res}_grid.tile5.nc,C${res}_grid.tile6.nc

elif [ $ntiles -eq 7 ]; then
  $APRUNS $executable --num_tiles $ntiles --dir $outdir --mosaic C${res}_mosaic --tile_file C${res}_grid.tile1.nc,C${res}_grid.tile2.nc,C${res}_grid.tile3.nc,C${res}_grid.tile4.nc,C${res}_grid.tile5.nc,C${res}_grid.tile6.nc,C${res}_grid.tile7.nc    

  $APRUNS $executable --num_tiles 6 --dir $outdir --mosaic C${res}_coarse_mosaic --tile_file C${res}_grid.tile1.nc,C${res}_grid.tile2.nc,C${res}_grid.tile3.nc,C${res}_grid.tile4.nc,C${res}_grid.tile5.nc,C${res}_grid.tile6.nc



#
#special case for the regional grid. For now we have only 1 tile and it is tile 7
#
elif [ $ntiles -eq 1 ];then
#  $APRUNS $executable --num_tiles $ntiles --dir $outdir --mosaic C${res}_mosaic --tile_file C${res}_grid.tile7.nc

cmd="$pre_cmd
$executable --num_tiles 1 --dir ${outdir/lustre/opt} --mosaic C${res}_mosaic --tile_file C${res}_grid.tile7.nc" 

eval "$APRUNS '$cmd'"
fi

exit


