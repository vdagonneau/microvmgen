# A micro-VM generator based on buildroot

## What is it?

This project allows you to generate a disk image for a minimal system based on the Linux hardened kernel, systemd and minimal busybox utilities.

It was originally created to experiment with buildroot and secure boot with systemd.

## Getting started

```
# We'll start by cloning this repo
git clone https://github.com/vdagonneau/microvmgen

# We then download the latest release of buildroot and unpack it
curl https://buildroot.org/downloads/buildroot-2021.11-rc1.tar.bz2 | tar xf

# We configure buildroot with this repo
cd buildroot-2021.11-rc1

BR2_EXTERNAL=../microvmgen make microvm_defconfig

# And we start building the toolchain and then the system
# BEWARE: this step might take a really long time to complete 
# Feel free to adjust the jobs parameter to best suit your system

make -j 24

```

qemu-system-x86_64 -machine type=pc-q35-6.0,accel=kvm -smp 2 -nographic -serial mon:stdio -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.secboot.fd -drive if=pflash,format=raw,file=OVMF_VARS_4M.snakeoil.fd -drive file=disk.img,if=virtio,format=raw -device virtio-net,netdev=vmnic -netdev user,id=vmnic,hostfwd=tcp::2222-:22
