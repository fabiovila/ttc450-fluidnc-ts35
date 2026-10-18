# Notices and third-party credits

This repository packages and documents community work. The items below keep
their original authors and licenses.

## FluidNC

- Project: **FluidNC** — <https://github.com/bdring/FluidNC>
- Authors: Mitch Bradley and the FluidNC contributors.
- License: **GNU GPL v3.0 or later** (see [`LICENSE`](LICENSE)).

Everything under [`firmware/`](firmware/) and [`source/`](source/) is built
from, or derived from, FluidNC and is distributed under the same license. The
corresponding source is included in [`source/`](source/) and
[`source/BUILD.md`](source/BUILD.md) documents how to regenerate it.

## TS35 display module

- Origin: **FluidNC PR #1805** — <https://github.com/bdring/FluidNC/pull/1805>
- Fork/branch: `thcasssio/FluidNC`, `feat/ts35-display-module`,
  commit `d93a72b2edc2902b5114128bedcf9f953afc16ec`.
- Author: [thcasssio](https://github.com/thcasssio).
- License: GPLv3, as part of FluidNC.

Files: `source/TS35Module.{cpp,h}`, `source/TS35DisplayDriver.{cpp,h}`,
`source/TS35Model.{cpp,h}`.

## Base TTC450 configuration

- Origin: **Diode Laser Wiki** —
  <https://diode-laser-wiki.com/documentation/twotrees-ttc450-cnc-machine/>
- The `config/config_cnc.yaml` and `config/config_laser.yaml` files are adapted
  from the publicly available TTC450 FluidNC configuration.

## Toolchain and libraries

- Espressif ESP32 Arduino core, PlatformIO, LittleFS, esptool — used to build
  and flash the firmware; each keeps its own license.

## Trademarks

TwoTrees, MKS and FluidNC are trademarks of their respective owners. This
project is not affiliated with or endorsed by any of them.
