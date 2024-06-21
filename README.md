
# Klipper Mod for Creality K1 (Max)

This is an *unofficial* mod to run Moonraker, custom Klipper, Mainsail & Fluidd on the Creality K1 (Max) printers and unlock the full power of open source software.

Klipper Mod for the K1 is designed to be fully removable and not break any functions of the stock software.

The mod is adapted for the K1 from the great work done by the [Flashforge Mod Project](https://github.com/xblax/flashforge_ad5m_klipper_mod).

> [!CAUTION]
> *If you want to install this mod to your K1 (Max) then be aware that you risk losing your warranty or damaging the printer. Proceed at your own risk if you want to try this mod!*

*This mod is currently in alpha.* Many features are implemented already but they need to be tested thoroughly and polished.

> [!CAUTION]
> *This mod currently breaks PRTouch and expects users to replace it with a probe (Eddy, BLTouch, Microprobe)*

## Feature Overview

- [Klipper](https://www.klipper3d.org/) ‒ with improved configuration and default macros
- [Moonraker](https://github.com/Arksine/moonraker) on port 7125
- [Mainsail](https://docs.mainsail.xyz/) on port 4000
- [Fluidd](https://docs.fluidd.xyz/) on port 4001
- [Guppyscreen](https://github.com/ballaswag/guppyscreen) ‒ preview build variant
- Camera streaming via [ustreamer](https://github.com/pikvm/ustreamer) on port 8080
- [Moonraker-timelapse](https://github.com/mainsail-crew/moonraker-timelapse) support
- Network access: WiFi WPA Supplicant
- [Buildroot](https://buildroot.org/) 2024.02.2 compared to stock 2020.02.1 (4 years newer)
- SSH root access. Login: `root`, Password: `guppy`
- Automatic USB flash drive mounting
- "Dual boot" with stock K1 software

## Guppy Mod vs K1 Stock
| Guppy Mod | Stock |
|-----------|-------|
| Mainline Klipper | Creality Klipper |
| Buildroot 2024 | Buildroot 2020 |
| Python 3.11.8  | Python 3.8.2 |
| ustreamer  | mjpeg-streamer |
| Guppy Screen | Creality display-server |
| Open source | Source?
| No bloatware | Creality services |
| More performant * | ?? |


\* Python 3.11.8 is *FASTER* than 3.8.2 (Faster Klipper/Moonraker). Since Guppy Mod also do not install any bloated software, it uses significantly less memory by default. On a fresh boot, Guppy Mod shows 36% used System memory in fluidd compared to 46% used by stock.

## Roadmap

- [KlipperScreen](https://klipperscreen.readthedocs.io/en/latest/) ‒ separate build variant
- Network access: Ethernet LAN (K1 Max) [iwd](https://iwd.wiki.kernel.org/)
- LCD backlight

All features of the mod run directly on the printer built-in system (X2000E). No additional hardware is required.

## Getting Started

Download test latest [Release Build](https://github.com/ballaswag/creality_k1_klipper_mod/releases) and read through the documentation for [Installation](docs/INSTALL.md). Also make yourself familiar with the [Uninstall](docs/UNINSTALL.md) methods, to get rid of the mod if you don't like it.

The Klipper Mod for K1 (Max) is currently provided in only one variant: 

- Alpha Guppy Screen variant for a more ligthweight UI on the limited hardware of the K1/Max. If you encounter any issues that could be caused by resource exhaustion (mostly system RAM), please check if the issue also occurs with the default stock.

You are welcome to participate int the [GitHub Discussions](https://github.com/ballaswag/creality_k1_klipper_mod/discussions) or open a new [Issue](https://github.com/ballaswag/creality_k1_klipper_mod/issues) if you find any bugs.

## Configuring a Probe

This mod currently abandons PRTouch and expects a probe to configured. By default, it uses the BTT Eddy probe configuration. Microprobe and BLTouch configurations are also available and can be enabled/disabled by editting `printer.cfg`. For probe that requires calibration, follow their respective manual to complete the initial collabration.

### BTT Eddy Guide

Follow the [K1 BTT Eddy Guide](https://ballaswag.github.io/blog/creality-k1-btt-eddy-guide/) to configure the Eddy using this mod.
- Mod now supports flashing the BTT Eddy right from the K1.

Mainline currently does not support temperature calibration. For detail BTT Eddy setup refer to their work-in-progress [guide](https://github.com/bigtreetech/Eddy).

## Documentation

Due to the alpha stage of Klipper Mod the documentation is not fully-completed. The documentation is split into several topics:

- [Install](docs/INSTALL.md): How to install Klipper Mod
- [Uninstall](docs/UNINSTALL.md): Uninstall Klipper Mod
- [Linux Environment](docs/LINUX.md): Klipper Mod Linux environment
- [Guppy Screen](docs/GUPPY_SCREEN.md)
- [Camera](docs/CAMERA.md)
- [USB](docs/USB.md)
- [Build Instructions](docs/BUILDING.md)

## Credits

- [K1-Klipper](https://github.com/K1-Klipper) - first K1 klipper mainline
- [Cryoz](https://github.com/cryoz) - mcu flash
- [pellcorp](https://github.com/pellcorp) - Simple AF K1
