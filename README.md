# Alpine Openstack Virtual Machine

This project helps creating an [Alpine] based Openstack image.
It uses The [alpine-make-vm-image] script to build a disk image in QCOW2 format.

This image can then be uploaded to an openstack project with the following
command:

```console
> openstack --os-cloud mycloud image create --disk-format qcow2 --file alpine-openstack.qcow2 alpine-openstack
```

And a corresponding server can be created with:

```console
openstack --os-cloud mycloud server create --key-name mykey --image alpine-openstack --flavor myflavor alpine
```
<!-- MARKDOWN LINKS & IMAGES -->

[alpine]: https://alpinelinux.org/
[alpine-make-vm-image]: https://github.com/alpinelinux/alpine-make-vm-image
