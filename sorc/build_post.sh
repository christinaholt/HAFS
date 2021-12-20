#!/bin/bash
set -eux
source ./machine-setup.sh > /dev/null 2>&1
cwd=`pwd`

export RT_MACHINE=$target
cd hafs_post.fd/tests
./compile_upp.sh

exit
