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

![alt text](foo?raw=true)
