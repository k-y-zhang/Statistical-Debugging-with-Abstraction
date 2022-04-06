#!/bin/bash

name='nostalgic_borg'
name='clever_mclean'
#
docker start $name
docker exec -it $name bash -c "cd $PWD;bash"
#
docker run -it --rm -v "$PWD:$PWD" -w "$PWD" ubuntu sudo chmod +666 -R .
#
echo "END"
