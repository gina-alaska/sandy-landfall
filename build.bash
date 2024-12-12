#!/bin/bash -l
cd || exit 

VERSION=$(cat /__w/sandy-landfall/sandy-landfall/VERSION)-$(date +"%Y%m%d%H%M%S")
INSTALL_LOCATION="/opt/gina/"
LABEL="landfall"

echo "Version is " "$VERSION"

echo "$VERSION" > ~/build/VERSION.tmp

echo "Setting up Conda.."
rm -rf $INSTALL_LOCATION$LABEL-"$VERSION"

curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh -b -p "${HOME}/conda"
source "${HOME}/conda/etc/profile.d/conda.sh"

echo "Updating Conda.."
conda update -y -n base -c defaults conda
conda install -y -n base conda-libmamba-solver
conda config --set solver libmamba

echo "Starting conda process.."
conda config --add channels conda-forge
conda create -y -p $INSTALL_LOCATION$LABEL-"$VERSION" conda-pack gxx_linux-64 ruby=3.3.3
conda activate $INSTALL_LOCATION$LABEL-"$VERSION"

#echo "Conda setup."
echo "Installing ruby gems.."
export GEM_HOME="$INSTALL_LOCATION$LABEL-$VERSION/vendor/bundle"
export GEM_PATH="$INSTALL_LOCATION$LABEL-$VERSION:$INSTALL_LOCATION$LABEL-$VERSION/vendor/bundle"
export PATH=$PATH:$INSTALL_LOCATION$LABEL-$VERSION/vendor/bundle/bin

echo "Copying $LABEL to build area.."
cd /__w/sandy-landfall/sandy-landfall
cp -vr Gemfile  Gemfile.lock  README.md VERSION tools $INSTALL_LOCATION$LABEL-"$VERSION"
mkdir -p $INSTALL_LOCATION$LABEL-"$VERSION"/log

echo "Installing gems required for $LABEL.."
cd $INSTALL_LOCATION$LABEL-"$VERSION"
gem install bundler
which ruby
./bin/bundle install

echo "Done with  ruby gems.."

echo "Making package..."
cd ~/build 
SB_TARBALL="$LABEL-$VERSION.pre.tar.gz"
rm -f "$SB_TARBALL"
conda pack --ignore-editable-packages --ignore-missing-files -q --n-threads -1 --compress-level 0 -o "$SB_TARBALL"
rm -rf ~/build/$LABEL-"$VERSION"
mkdir  ~/build/$LABEL-"$VERSION"
cd ~/build/$LABEL-"$VERSION"
tar -xf ~/build/"$SB_TARBALL"
cd ~/build
cp build_log.txt $LABEL-"$VERSION"/
sudo dnf install -y lbzip2 xz
export BZIP2=" --best "
tar --use-compress-program=lbzip2 -cf $LABEL-"$VERSION".tar.bz2 $LABEL-"$VERSION"
tar --xz -cf $LABEL-"$VERSION".tar.xz $LABEL-"$VERSION"

