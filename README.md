# A micro-VM generator based on buildroot

## What is it?

This project allows you to generate a disk image for a minimal system based on the Linux hardened kernel, systemd and minimal busybox utilities.

It was originally created to experiment with buildroot and secure boot with systemd.

## Getting started

```shell
# We'll start by cloning this repo
git clone --recurse-submodules https://github.com/vdagonneau/microvmgen

# We then download the latest release of buildroot and unpack it
curl https://buildroot.org/downloads/buildroot-2021.11-rc1.tar.bz2 | tar xj

# We configure buildroot with this repo
cd buildroot-2021.11-rc1
BR2_EXTERNAL=../microvmgen make microvm_defconfig

# And we start building the toolchain and then the system
# BEWARE: this step might take a really long time to complete 
# Feel free to adjust the jobs parameter to best suit your system
make -j 24

```

## Running the generated image

In order to run the generated image you will need a UEFI firmware image as well as a pre-initialized UEFI NVRAM image.

Both these files are generally available on most Linux distros in a package called edk2-ovmf. As the NVRAM image is going to be written to by the virtual machine, it needs to be copied before being used.

cp /usr/share/OVMF/OVMF_VARS_4M.fd OVMF_VARS_4M.fd
qemu-system-x86_64 -machine type=pc-q35-6.0,accel=kvm -smp 2 -nographic -serial mon:stdio -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.secboot.fd -drive if=pflash,format=raw,file=OVMF_VARS_4M.fd -drive file=output/images/disk.img,if=virtio,format=raw
