#!/usr/bin/bash -l
path=$(dirname $(readlink -f $BASH_SOURCE))
cd $path
. ./env.sh 
./vendor/bundle/ruby/2.3.0/gems/gina-conveyor-1.0.1/bin/conveyor

#This is just here for troubleshooting.
sleep 10

