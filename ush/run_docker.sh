#!/bin/bash

# Run the docker command, passing it the environment variables that are relevant to the task.
set -x
script=$1
name=$2
script_args="${@:2}"

export PS4='+ $SECONDS + '

if [ ! $(which docker) ] ; then
  set +x
  source /shared/aws_scripts/sing_install.sh
  set -x
  install_docker
fi
have_image=$(sudo docker images | grep -q axiom-hafs)
if [ ! $have_image ] ; then
  sudo service docker stop
  sudo cp /shared/docker_daemon_json /etc/docker/daemon.json 
  sudo sed -i s/NEW_PATH/$docker_path/ /etc/docker/daemon.json
  sudo mv /var/lib/docker /var/lib/docker.old
  sleep 15
  sudo service docker start
fi

have_image=$(sudo docker images | grep -q axiom-hafs)
#if [ ! $have_image ] ; then
#  sudo docker login -u christinaholt -p $(cat /shared/.docker_pwd)
#  sudo docker pull christinaholt/axiom-hafs:inteloneapi-latest
#fi

exit 1
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
  env_str+=" -e $env_var"
done

if [ $name == 'launch' ] ; then
    cmd="
      bash -c \"source /usr/share/lmod/lmod/init/bash && \
      source /opt/intel/oneapi/setvars.sh && \
      /opt/HAFS_OUTER/ush/rocoto_pre_job.sh && \
      $script $script_args \""
else
    cmd="
      bash -c \"source /usr/share/lmod/lmod/init/bash && \
      source /opt/intel/oneapi/setvars.sh && \
      ./$script\""
      for arg in $script_args ; do
        env_str+=" -e $arg"
      done
fi

sudo docker run \
  --cpus ${SLURM_NTASKS:-1} \
  ${env_str} \
  -e LOCAL_USER_ID=`id -u $USER` \
  -v /lustre/HAFS_container:/opt/HAFS_OUTER \
  -v /lustre/HAFS_OUTPUT:/opt/HAFS_OUTPUT \
  -v /lustre/data/HAFS_INPUT:/opt/HAFS_INPUT \
  -w /opt/HAFS/jobs \
  --rm \
  -it \
  --name $name \
  inteloneapi/hafs \
  $cmd

