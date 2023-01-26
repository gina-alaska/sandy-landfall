#!/bin/bash -l
cd || exit 

VERSION=$(cat ~/build/VERSION)-$(date +"%Y%m%d%H%M%S")
INSTALL_LOCATION="/opt/gina/"
LABEL="landfall"

echo "Version is " "$VERSION"

echo "$VERSION" > ~/build/VERSION.tmp

echo "Setting up Conda.."
rm -rf $INSTALL_LOCATION$LABEL-"$VERSION"

echo "Updating Conda.."
conda update -n base -c defaults conda

echo "Starting conda process.."
conda config --add channels conda-forge
conda create -y -p $INSTALL_LOCATION$LABEL-"$VERSION" conda-pack gxx_linux-64 openssl ruby=2.3.3
conda activate $INSTALL_LOCATION$LABEL-"$VERSION"

#echo "Conda setup."
echo "Installing ruby gems.."
export GEM_HOME="$INSTALL_LOCATION$LABEL-$VERSION/vendor/bundle"
export GEM_PATH="$INSTALL_LOCATION$LABEL-$VERSION:$INSTALL_LOCATION$LABEL-$VERSION/vendor/bundle"
export PATH=$PATH:$INSTALL_LOCATION$LABEL-$VERSION/vendor/bundle/bin



echo "setting ld library path.."
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$INSTALL_LOCATION$LABEL-$VERSION/lib

echo "Copying $LABEL to build area.."
cd ~/build 
cp -vr .conveyor  Gemfile  Gemfile.lock  README.md VERSION  workers start.bash $INSTALL_LOCATION$LABEL-"$VERSION"

echo "Installing gems required for $LABEL.."
cd $INSTALL_LOCATION$LABEL-"$VERSION"
gem install bundler -v 2.3.26
bundle install --deployment

echo "Done with  ruby gems.."

echo "Additional Environment Setting.."
echo export VERSION="$VERSION" > $INSTALL_LOCATION$LABEL-"$VERSION"/env.sh
echo source $INSTALL_LOCATION$LABEL-"$VERSION"/bin/activate >> $INSTALL_LOCATION$LABEL-"$VERSION"/env.sh
echo export GEM_HOME="$INSTALL_LOCATION$LABEL-$VERSION/vendor/bundle" >> $INSTALL_LOCATION$LABEL-"$VERSION"/env.sh 
echo export GEM_PATH="$INSTALL_LOCATION$LABEL-$VERSION:$INSTALL_LOCATION$LABEL-$VERSION/vendor/bundle:$INSTALL_LOCATION$LABEL-$VERSION/vendor/bundle/ruby/2.3.0/"  >> $INSTALL_LOCATION$LABEL-"$VERSION"/env.sh
echo export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$INSTALL_LOCATION$LABEL-"$VERSION"/lib >> $INSTALL_LOCATION$LABEL-"$VERSION"/env.sh
echo export PATH=\$PATH:$INSTALL_LOCATION$LABEL-"$VERSION"/processing-utils/bin >> $INSTALL_LOCATION$LABEL-"$VERSION"/env.sh


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
tar --bzip2 -cf $LABEL-"$VERSION".tar.bz2 $LABEL-"$VERSION"
