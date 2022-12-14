#!/bin/bash -l
cd || exit 

VERSION=$(cat ~/build/VERSION)-$(date +"%Y%m%d%H%M%S")
INSTALL_LOCATION="/opt/gina"
LABEL="landfall"

echo "Version is " "$VERSION"

echo "$VERSION" > ~/build/VERSION.tmp

echo "Setting up Conda.."
rm -rf $INSTALL_LOCATION$LABEL-"$VERSION"
conda config --add channels conda-forge
conda create -y -p $INSTALL_LOCATION$LABEL-"$VERSION" gdal ruby=2.6.5 libffi pkg-config gxx_linux-64 conda-pack git lftp
conda activate $INSTALL_LOCATION$LABEL-"$VERSION"

#echo "Conda setup."
echo "Installing ruby gems.."
export GEM_HOME="$INSTALL_LOCATION$LABEL-$VERSION/vendor/bundle"
export GEM_PATH="$INSTALL_LOCATION$LABEL-$VERSION:$INSTALL_LOCATION$LABEL-$VERSION/vendor/bundle"



echo "setting ld library path.."
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$INSTALL_LOCATION$LABEL-$VERSION/lib

echo "Copying $LABEL to build area.."
cd ~/build || exit
cp -rv lib/processing_framework* $INSTALL_LOCATION$LABEL-"$VERSION"/lib/
cp -rv config $INSTALL_LOCATION$LABEL-"$VERSION"/config
cp -v  Gemfile Gemfile.lock config README.md VERSION CHANGELOG.md  notes.md LICENSE Rakefile $INSTALL_LOCATION$LABEL-"$VERSION"
mkdir -p $INSTALL_LOCATION$LABEL-"$VERSION"/tools
./build_bin_stubs.rb bin/*

chmod a+rx $INSTALL_LOCATION$LABEL-"$VERSION"/tools/*

echo "Installing gems required for $LABEL.."
cd $INSTALL_LOCATION$LABEL-"$VERSION || exit" || exit
bundle install --deployment
echo "Done with  ruby gems.."

echo "Additional Environment Setting.."
echo export VERSION="$VERSION" > $INSTALL_LOCATION$LABEL-"$VERSION"/env.sh
echo source $INSTALL_LOCATION$LABEL-"$VERSION"/bin/activate >> $INSTALL_LOCATION$LABEL-"$VERSION"/env.sh
echo export GEM_HOME="$INSTALL_LOCATION$LABEL-$VERSION/vendor/bundle" >> $INSTALL_LOCATION$LABEL-"$VERSION"/env.sh 
echo export GEM_PATH="$INSTALL_LOCATION$LABEL-$VERSION:$INSTALL_LOCATION$LABEL-$VERSION/vendor/bundle"  >> $INSTALL_LOCATION$LABEL-"$VERSION"/env.sh
echo export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$INSTALL_LOCATION$LABEL-"$VERSION"/lib >> $INSTALL_LOCATION$LABEL-"$VERSION"/env.sh
echo export PATH=\$PATH:$INSTALL_LOCATION$LABEL-"$VERSION"/processing-utils/bin >> $INSTALL_LOCATION$LABEL-"$VERSION"/env.sh


echo "Making package..."
cd ~/build || exit
SB_TARBALL="$LABEL-$VERSION.pre.tar.gz"
rm  "$SB_TARBALL"
conda pack -q --n-threads -1 --compress-level 0 -o "$SB_TARBALL"
rm -rf ~/build/$LABEL-"$VERSION"
mkdir  ~/build/$LABEL-"$VERSION"
cd ~/build/$LABEL-"$VERSION || exit" || exit
tar -xf ~/build/"$SB_TARBALL"
cd ~/build || exit
cp build_log.txt $LABEL-"$VERSION"/
tar --bzip2 -cf $LABEL-"$VERSION".tar.bz2 $LABEL-"$VERSION"