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

## Incron
The incron config should look like this:
```
/home/processing/raw/uaf5/	IN_MOVED_TO	/opt/gina/landfall-(version)/tools/arrival $@/$#
```
## Log file
There is a log file named /opt/gina/landfall-(version)/log/ingest.log that should log all passes as they come in, and any errors that occur.

```
[processing@nrt-landfall-test-0002 ~]$ tail  /opt/gina/landfall-(version)/log/ingest.log 
INFO: Done Pass{Satellite:noaa20@2024-10-23T21:55:00+00:00:/home/processing/raw/uaf5//JPSS1.20241023.215516.dat} at 2024-10-23 22:10:08 +0000
INFO: Starting Pass{Satellite:metop-b@2024-10-23T22:19:00+00:00:/home/processing/raw/uaf5//tp2024297221959.METOP-B.dat} at 2024-10-23 22:23:13 +0000
INFO: Done Pass{Satellite:metop-b@2024-10-23T22:19:00+00:00:/home/processing/raw/uaf5//tp2024297221959.METOP-B.dat} at 2024-10-23 22:23:14 +0000
INFO: Starting Pass{Satellite:noaa18@2024-10-23T22:22:00+00:00:/home/processing/raw/uaf5//NOAA18.20241023.222253.hrpt} at 2024-10-23 22:36:47 +0000
INFO: Done Pass{Satellite:noaa18@2024-10-23T22:22:00+00:00:/home/processing/raw/uaf5//NOAA18.20241023.222253.hrpt} at 2024-10-23 22:36:49 +0000
```
