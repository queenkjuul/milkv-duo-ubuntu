# Linux 7.0 for Milk-V Duo S RISC-V

This directory contains:

- `patches/`, all of the patches that are applied to my kernel tree, in `git am` format, mostly pulled from LKML but some work of my own
- submodule link to my kernel tree, where all of the patches have already been applied on top of the Linux 7.0 base
- `milkv-$BOARD_defconfig` - kernel configurations used in my own personal Milk-V Duo projects - this is a very heavy kernel, with support for practically every USB and IIO device imaginable. You may want to pare it down.
- Debian packaging files used to publish kernel packages to my [Ubuntu PPA](https://launchpad.net/~queenkjuul/+archive/ubuntu/milkv-duos), for use with my [Ubuntu SD card images](../readme.md)

## What the patches cover

These are a pretty comprehensive set of patches that enable all of the Milk-V Duo hardware with the exception of the multimedia features (VIP) and TPU:

- Full bidirectional USB - either Gadget mode or Host mode
- Built-in Ethernet
- All PWM channels
- SPI, I2C, and UART verified working (though without DMA)
- Built-In Audio device drivers
- ALSA full-duplex sound card definition works out-of-the-box on Duo S
- Duo S AIC8800 WiFi + BT available as an out-of-tree module

## Building your Own DEB Package for My Ubuntu Images

If you want to use my userspace images for Ubuntu 24.04, and thus install your kernel via `apt` or my [provided SD build scripts](../readme.md), then make your changes and take note:

- Run `ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- make menuconfig` or similar from the `linux` directory to configure your kernel
- copy your `.config` to `milkv-duos_defconfig` before building, or else it will be ignored
- from this directory, run `debuild -ariscv64 -b -us -uc` to build a binary package, or `debuild -S -sa -us -uc` to build a source package.

This builds a headers package and a binary package, which installs kernels to `/boot/vmlinuz-$KERNELRELEASE`, and automatically sets up `boot.sd` fallback images and runs `depmod` and `u-boot-update` after installation/upgrade. If you don't want all that, move on to...

## Building your own DEB package for Generic Debian-Based Distros

Enter the linux directory, run:
  `ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- make menuconfig`

to set up your config, then apply any patches/make any changes, then run:
  `ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- make Image dtbs modules`

Then run:
  `ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- make bindeb-pkg`

If you're using my FSBL builds, you probably want to use u-boot-menu and ensure you run u-boot-update after installing the kernel package.

## Applying my patches to a mainline kernel build

1. Clone the kernel somewhere
2. `cd` to the kernel directory
3. `git am /path/to/milkv-linux/patches/*.patch`
4. Configure/build the kernel like normal
