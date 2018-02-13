# sandy-landfall

A tool that manages the conveyor for the NRT stack.  This brings in newly captured data into the NRT processing system.  Data arrives on the landfall system. 

This package is installed on the NRT stack's `landfall` system.  This is managed via Chef in the [sandy/cookbooks/sandy_app](https://github.alaska.edu/gina-cookbooks/sandy/tree/master/cookbooks/sandy_app) `recipe[sandy::landfall]`.

Landfall GitHub: [github.com/gina-alaska/sandy-landfall](https://github.com/gina-alaska/sandy-landfall) 

## building & uploading

This package is managed as a [habitat](https://habitat.sh) package. After an update to landfall you can rebuild the package like so:

```
hab pkg build .
hab pkg upload
```

That will put it up in [bldr.habitat.sh - /uafgina/sandy-landfall](https://bldr.habitat.sh/#/pkgs/uafgina/sandy-landfall/latest) in the `unstable` channel. You can promote it from `unstable` to `stable` in the web GUI or command line if needed. See the [sandy/cookbooks/sandy_app/README.md](https://github.alaska.edu/gina-cookbooks/sandy/blob/master/cookbooks/sandy_app/README.md) for more details on how it is managed in test and prod.
