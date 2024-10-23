#!/bin/bash
cd 

VERSION=$(cat ~/build/VERSION)

echo "Version is " $VERSION

echo "Setting up Conda.."

#wget -q https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh
mkdir -p $HOME/anaconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/anaconda/miniconda.sh
bash ~/anaconda/miniconda.sh -b -u -p ~/anaconda
~/anaconda/bin/conda init bash
. ~/.bashrc


#conda activate /opt/gina/sandy-utils-$VERSION


#conda create -p /opt/gina/sandy-utils-$VERSION gdal
#conda activate /opt/gina/sandy-utils-$VERSION
#conda config --add channels conda-forge
#conda install ruby=2.6.5
#conda install libffi
#conda install pkg-config
#conda install gxx_linux-64
