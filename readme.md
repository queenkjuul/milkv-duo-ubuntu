# Ubuntu and Mainline Linux on the Milk-V Duo S/256M RISC-V

Full-featured, general-purpose Ubuntu 24.04 distribution for Milk-V Duo S and Duo 256M SBCs, built on the latest mainline 7.0 Linux kernel. Now with **Arduino!***

For a more stripped-down, DIY system, take a look at [my work on building Alpine images](https://github.com/SeimoDev/cv1812h-linux-6.18-port) which use my same mainline Linux patchset (if you want).

<img width="1280" height="836" alt="image" src="https://github.com/user-attachments/assets/6a2d1765-dc41-4cb2-b000-97cf976d3f32" />

*The Duo 64M model has insufficient memory to run Ubuntu, as `apt` requires more memory than is available. I do have a Duo 64M, though, so I will still publish kernel configuration and device trees for it eventually.*

See [the Sophgo Linux Wiki](https://github.com/sophgo/linux/wiki) for a general state of the kernel support - as many pending patches have been applied to this distribution as is possible. See [Missing Features](#missing-features) for details.

[*Arduino support is minimal, see the Arduino section below](#arduino-support)

---

**AI Disclosure**

I am a software engineer, with extensive Linux experience, but I am new to the world of embedded computing. I have used AI extensively in this project, primarily for debugging, packaging, and generating sample configuration files, but also to a limited extent for generating code. There are small portions of purely AI generated code in this repo - specifically, the code which writes the WiFi enable pin register in `aic8800_bsp.c`, and similar code in `duos-usb-switch` for writing the USB host pin register. This code required applying concepts which are foreign to me, so my choices were largely "let the AI do it" or "live without it" - and with USB and WiFi, I was not willing to live without it.

**This project's documentation is to remain 100% human-written under all circumstances. AI is exclusively for assisting with _code_.**

`Assisted-By: Gemini:3-fast, Gemini:3.1-pro`

---

- [Ubuntu and Mainline Linux on the Milk-V Duo S/256M RISC-V](#ubuntu-and-mainline-linux-on-the-milk-v-duo-s256m-risc-v)
  - [Pre-Built Image Downloads](#pre-built-image-downloads)
  - [What this is](#what-this-is)
  - [Features](#features)
  - [Missing Features](#missing-features)
  - [Using the System](#using-the-system)
    - [Default Password](#default-password)
    - [First Boot](#first-boot)
    - [USB](#usb)
    - [Additional Information](#additional-information)
    - [Pin Configuration](#pin-configuration)
      - [`duo-pinmux` CLI tool from Milk-V](#duo-pinmux-cli-tool-from-milk-v)
      - [Additional Information](#additional-information-1)
    - [WiFi + BT](#wifi--bt)
      - [Additional Information](#additional-information-2)
    - [Bootloader](#bootloader)
      - [Additional Information](#additional-information-3)
    - [Arduino Support](#arduino-support)
      - [Setup Instructions](#setup-instructions)
      - [Arduino Feature Support Matrix](#arduino-feature-support-matrix)
  - [Building and Customizing](#building-and-customizing)
  - [Stretch Goals](#stretch-goals)
  - [Manifesto](#manifesto)
  - [Credits](#credits)

## Pre-Built Image Downloads

<https://github.com/queenkjuul/milkv-duo-ubuntu/releases>

## What this is

This is a monorepo set up with git submodules to pull in:

- Linux 7.0 with all necessary Milk-V Duo S and 256M patches
- Prebuilt vendor bootloader image and applicable patches
- Scripts for cross-building .deb packages:
  - Linux 7.0
  - Wireless drivers
  - Userspace scripts for setting USB operating mode
  - Userspace scripts for setting up wireless hardware
  - Milk-V `duo-pinmux` tool
  - [bluetui](https://github.com/pythops/bluetui) and [impala](https://github.com/pythops/impala) for managing wireless hardware
- [`genimage` for building the SD image](https://github.com/pengutronix/genimage)
- Scripts for generating an Ubuntu 24.04 userspace rootfs

Packages are hosted on Ubuntu PPAs:

- <https://launchpad.net/~queenkjuul/+archive/ubuntu/milkv-duos>
- <https://launchpad.net/~queenkjuul/+archive/ubuntu/milkv-duo256m>

## Features

- 3 user-selectable USB modes:
  - USB Host: Use the USB A port to access peripheral devices
  - USB Serial (ACM): Connect to a PC with USB-C and log in over serial
  - USB Network (CDC-NCM) [formerly RNDIS]: Connect to a PC with USB-C and log in over SSH or otherwise access via network protocols
- Modern Linux 7.0 mainline kernel (with minor device tree and driver patches)
- Modern Ubuntu 24.04 userspace
- Full USB Gadget support
- Full USB Host support
- Support for Duo Ethernet
- Working Wifi (at least 2.4GHz, 5GHz untested)
- Working Bluetooth
- I2S Audio driver + Built-In Analog Audio
- Automatic root partition expansion on first boot
- SPI, I2C, UART, PWM all tested working
- Device Tree Overlay support
- [Partial Arduino support](#arduino-support)

## Missing Features

- ~~Wifi (not mainlined, investigating vendor drivers)~~ nah bb wifi works now :sunglasses:
- ~~Bluetooth~~ (same as wifi) :sunglasses:
- ~~Software reboot (system hangs waiting for hardware reset button)~~ nah we got this now :)
- MIPI / CSI (Camera interface)
- TPU support
- Multimedia support (VIP)
- SPI NOR / NAND Flash - I only have SD-based Duo boards to test with.
- SPI and UART complain about DMA. DMA works for I2S/Audio, but not for SPI/UART. Can't work out why not.
- USB mode switching has to be done via a hacky userspace script - the mainline USB drivers won't do dual-role correctly
- [Full Arduino support](#arduino-support)

## Using the System

In general, [this portion of the Milk-V docs also applies to this distribution](https://milkv.io/docs/duo/getting-started/setup) except for a couple things:

- [Setting the USB gadget IP address is different](#changing-the-usb-gadget-ip-address)
- My build scripts automatically expand the root partition on first boot
- My `milkv-wifi-setup` tool automatically fixes the WiFi MAC address

### Default Password

User:     `root`
Password: `milkv`

### First Boot

The first boot can take ~2 minutes as the system generates SSH keys and expands the root partition to the full size of the SD card. Subsequent boots will be much faster.

### USB

USB drivers are built into the kernel. The `milkv-usb-duos` package contains userspace scripts for switching modes and a systemd unit for setting modes at boot time.

The system is set up for USB CDC NCM by default. This is the modern equivalent of RNDIS; it configures the board as a "USB Ethernet Gadget" and allows you to talk to the board via SSH over USB:

`ssh root@192.168.42.1`

This is the same as the Milk-V default, so you [can use their docs to get set up](https://milkv.io/docs/duo/getting-started/setup), [except for changing the USB IP](#changing-the-usb-gadget-ip-address).

You can switch to Host Mode (USB-A) with:

`milkv-usb-mode host` and then reboot. There are systemd services that handle the initialization. If you disable those, use `milkv-usb-init` to set things up after boot.

### Additional Information

See [The Wiki](https://github.com/queenkjuul/milkv-duo-ubuntu/wiki/USB) for additional iformation on USB.

### Pin Configuration

#### `duo-pinmux` CLI tool from Milk-V

`duo-pinmux`, as provided by Milk-V, is also included in the system image. You can use it to reconfigure pins - all of the Duo S's hardware is exposed to the kernel via the device tree, but some of it may not work until you set the pins correctly. For example, to use `I2C4` via pins `B20` and `B21`, you must set pins `B20` and `B21` appropriately with `duo-pinmux`. After that, the `/dev/i2c-*` devices will work (you may need to `modprobe i2c-dev` first). Note that just because the `/dev/*` node appears, doesn't mean it works - you need to set the pins correctly. Only `/dev/ttyS0` (the boot console) and `/dev/ttyS4` (the bluetooth UART) are guaranteed to work at boot.

#### Additional Information

See [the wiki](https://github.com/queenkjuul/milkv-duo-ubuntu/wiki/Pin-Configuration) for more information on setting pin configuration.

### WiFi + BT

There are 5 packages relevant to wireless on the Duo S:

- `milkv-wireless-duos`: Userspace scripts and systemd units to enable wireless hardware (technically optional)
- `aic8800-milkv-firmware`: Vendor firmware binary blobs (required)
- `aic8800-milkv-modules-duos`: Kernel modules for the `linux-image-milkv-duos` kernel (default kernel for this setup) (required)
- [`extras/impala`](https://github.com/pythops/impala): an easy-to-use TUI for setting up WiFi connections (optional, third-party)
- [`extras/bluetui`](https://github.com/pythops/bluetui): an easy-to-use TUI for setting up Bluetooth connections (optional, third-party)

All are installed by default. Wifi and Bluetooth are both enabled by default. Disable one or the other with:

```sh
systemctl disable milkv-wifi
systemctl disable milkv-bluetooth
```

You can run `milkv-wifi-setup` to set up a wireless network connection.

#### Additional Information

See [the wiki](https://github.com/queenkjuul/milkv-duo-ubuntu/wiki/WiFi-+-BT) for more information.

### Bootloader

The system is set up with `/boot` on the root ext4 filesystem (`mmcblk0p3`), and `mmcblk0p1` mounted to `/boot/vendor`.

`/boot/vendor` contains two files:

- `fip.bin`: vendor-supplied bootloader, modified for "distroboot" - this loads a simple boot menu listing installed kernels, and loads everything it needs from the root ext4 filesystem
- `boot.sd`: this is a "FIT image" which contains an embedded kernel and device tree. This is provided as a failsafe, and can be ran with `run sdboot` at the U-Boot prompt.

U-Boot supports the ethernet port, and distroboot supports network booting, and it does appear to work (ethernet initializes, and it fetches an address from DHCP, and it attempts to fetch a file from TFTP, but I don't have TFTP set up to test further). You still need an SD card with the modified `fip.bin` in the device for this to work.

#### Additional Information

See [the wiki](https://github.com/queenkjuul/milkv-duo-ubuntu/wiki/Bootloader) for mor information.

### Arduino Support

This distribution's Linux kernel supports the pending Remoteproc and Mailbox drivers for the sg200x chips. This means that Linux is capable of uploading firmware to the "little core" and booting it. Unfortunately, there are issues getting all of the hardware working completely. GPIO-based proofs-of-concept do work, though, so you can toggle LEDs to your heart's content.

#### Setup Instructions

Be sure to see [the wiki](https://github.com/queenkjuul/milkv-duo-ubuntu/wiki/Arduino) for setup instructions and important notes.

#### Arduino Feature Support Matrix

| Feature | Duo 256M            | Duo S               |
| ------- | ------------------- | ------------------- |
| GPIO    | Works! :sunglasses: | Works! :sunglasses: |
| UART    | Known Broken :sob:  | Untested            |
| I2C     | Untested            | Untested (I2C4 only)|
| SPI     | Untested            | Unsupported         |
| PWM     | Untested            | Works! :sunglasses: |
| ADC     | Untested            | Unsupported         |
| Mailbox | Known Broken :sob:  | Known Broken :sob:  |

## Building and Customizing

See [the wiki](https://github.com/queenkjuul/milkv-duo-ubuntu/wiki/Building-the-System)

## Stretch Goals

- ~~Device tree overlay management package: a tool to compile + add to u-boot + update u-boot, with source and examples~~ oh no baby, we did it :sunglasses:
- ~~Arduino firmware support: ideally, the board shows up as an IP firwmare target for the Arduino IDE, but I'd settle for a shell tool to easily move firmware to `/lib/firmrware/cvirtos.elf` and then restart the little core.~~ oh honey, we did that too :grin:

## Manifesto

Look, far as I'm concerned, the Duo S kicks the shit out of the Pi Zero. HDMI Smaychdeemeye. Ubuntu Server on the Duo S is where it's at. I love the other Duos too, no shade, the S is just like, what I always wished the Zero was. Wifi, ethernet, USB (**C**, even!), built-in analog audio; this thing rocks, it deserves an easy-to-use, modern, hit-the-ground-running Ubuntu image. I'm really happy with how the mainline kernel runs with an Ubuntu system on the Duo. I'm really happy that you can one-click upload Arduino sketches. I'm really happy that so many Sophgo drivers have been mainlined that this project is possible, and I can support nearly all of the board's features. 

I am anxiously watching [this project to get the NPU running on mainline Linux](https://github.com/SeimoDev/cv1812h-linux-6.18-port) and may myself yet embark on a misguided attempt to get other parts of the vendor code running (the H265 codec being the holy grail for me) but I cannot make any promises.

## Credits

By far the most useful reference reference was [Fishwaldo's `sophgo-sg200x-debian` project](https://github.com/Fishwaldo/sophgo-sg200x-debian). This was pretty invaluable.

Credits below this line are from the original README.md of the repo I forked ([credit to ambraglow too, of course](https://github.com/ambraglow/milkv-duo-ubuntu)), so I don't give it my personal approval, but I will leave it here for visibility. The old instructions below will likely be removed, though; my scripts are only loosely similar.

![great friend julie](https://github.com/tvlad1234) *[different julie :)]*
![rootfs guide for risc-v](https://github.com/carlosedp/riscv-bringup/blob/master/Ubuntu-Rootfs-Guide.md)
![DO NOT THE CAT!!!](https://github.com/Mnux9)

---
