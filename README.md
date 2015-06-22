# siren - systemd-nspawn container builder

siren is a tiny and really fast (<3 overlayfs) tool for building OS containers for use with systemd-nspawn and machinectl.

To create a new container, unpack any base container image to /var/lib/siren/base_container_name (or build it like arch/build.sh does, but this usually requires distro-specific package manager) and run (as root)

```sh
./siren new my_container base_container_name
```

You can start it with:
```sh
machinectl start my_container
# or
systemctl start systemd-nspawn@my_container
# or
systemd-nspawn -b -M my_container
```

Yes, this is boring. But there's more! Siren includes a ```./siren build``` command, which works like ```docker build``` - and executes build instructions written in a build.sh file, with syntax inspired by Dockerfiles.

## Example: nginx

### build.sh
```sh
#!/bin/sh
. `dirname $0`/siren # Required boilerplate.

FROM arch # Base image name - here we depend on /var/lib/siren/arch

ID nginx $base_version # Our name and version. $base_version is base image's version.

RUN pacman -S --noconfirm nginx # RUN a command in the container.
rm -Rf $root/etc/nginx # remove useless, distribution-provided config
cp -R etc/nginx $root/etc/nginx # add our config (from the directory containing build.sh)

ENABLE nginx # ENABLE nginx.service in the container.
```

### Command line
```sh
./siren build
machinectl start nginx
```

You can access all the container's files in /var/lib/machines/nginx. You can also access only the files that were added/modified in comparison to the base image - in /var/lib/siren/nginx.

To separate files installed in the build process from the files added later, while the container was running, simply create new container before running the app:
```sh
./siren build
./siren new nginx0 nginx
machinectl start nginx0
```

This way, /var/lib/siren/nginx will contain nginx binaries and configuration, and /var/lib/siren/nginx0 all the logs and other runtime files.

## How it works
The only magical thing in siren is the way we compose image layers using overlayfs. For each built image, we create new var-lib-machines-imagename.mount and var-lib-machines-imagename.automount systemd units, and enable the second one. This way, systemd automatically mounts overlayfs at /var/lib/machines/imagename when somebody tries to access it, for example by starting a siren-built container. And this way, you don't need siren anywhere in the process of running containers, it's role is finished after the container is built.

It's also quite easy to merge all the layers and create a big image that does not require overlayfs, but it requires copying (and is therefore slow + takes lots of disk space) and destroys the pretty separation between base image files and container runtime files. So why would anybody do that?

## License
MIT license.

## Requirements
* Linux 4.0 (overlayfs with multiple read-only layers)
* systemd 220 (219 has NAT support for containers, required for internet access when running (but not building) containers)
* NO btrfs (Non-empty directory removal is bugged on overlayfs over btrfs. Use a good fs instead - eg. ext4.)
* sysctl net.ipv4.ip_forward=1 (I don't know if it's always required, but on my local PC containers can't access internet without it)
