# sandy-landfall

A tool that brings in newly captured data into the NRT processing system.  Data arrives on the landfall system. 

This package is installed on the NRT stack's `landfall` system.  This is managed via Chef in the [sandy/cookbooks/sandy_app](https://github.alaska.edu/gina-cookbooks/sandy/tree/master/cookbooks/sandy_app) `recipe[sandy::landfall]`.

Landfall GitHub: [github.com/gina-alaska/sandy-landfall](https://github.com/gina-alaska/sandy-landfall) 

## building & uploading

This package is managed as a tar.gz package build with conda pack.  It used to use habitat. 

build it like: 

```
vagrant up build
vagrant ssh build
cd build
./build.bash
scp (package).bz2 (package).xz ginauser@bigdipper.alaska.edu:/home/ginauser/bs4/gina-packages/nrt
```
## How it works

1. Data is Pushed from the receiving stations to the Landfall VM.
2. [incron](https://github.com/ar-/incron) notices the new data, and runs the "arrival" script that is part of this package
   1. The arrival script copies data to the NRT stack
   2. Then informs the NRT stack the new data exists (path, platform, and date)

![alt text](https://github.com/gina-alaska/sandy-landfall/blob/main/images/NRT%20Landfall%20Drawing.png?raw=true)

The incron config should look like this:
```
/home/processing/raw/uaf5/	IN_MOVED_TO	/opt/gina/landfall-(version)/tools/arrival $@/$#
```
