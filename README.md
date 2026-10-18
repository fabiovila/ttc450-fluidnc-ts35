<!-- Language switcher -->
**English** · [🇧🇷 Português](README.pt-BR.md)

# FluidNC + MKS TS35 touchscreen for the TwoTrees TTC450

Prebuilt **FluidNC** firmware with community **TS35** display support for the
**TwoTrees TTC450** CNC/laser engraver.

The TTC450 ships with an **MKS DLC32 V2.1** controller (ESP32, 8 MB flash,
2.4 GHz WiFi) and a **MKS TS35-R V2.0** 3.5" resistive touch panel
(ST7796 LCD + ADS7843E touch). Upstream FluidNC does **not** support that
panel, because it is a "dumb" SPI display with no controller of its own.

This repository packages the community `ts35` module — submitted upstream as
[FluidNC PR #1805](https://github.com/bdring/FluidNC/pull/1805) and tested on
exactly this board + panel combination — into a **ready-to-flash image**, with
tested configurations, bilingual documentation and the root-cause analysis of
the stock firmware's WiFi problem.

> **Not an official FluidNC build.** The `ts35` module is not merged upstream
> yet. Flash it with the machine free of tooling and the laser disconnected.
> Keep a full backup of the original flash.

---

## Why this exists

Two recurring problems with the TTC450:

1. **Switching CNC ⇄ laser requires reflashing the firmware.** The official
   TwoTrees procedure erases the whole flash, which also erases the **NVS**
   partition where the WiFi SSID/password live. So every switch resets WiFi.
   On top of that, the TTC450 laser firmware is from 2022 (V2.20) and has
   known WiFi reconnect bugs.
2. **FluidNC, the natural upgrade, refuses the TS35 panel.** It targets the
   WebUI and wireless pendants (M5Dial/CYD) instead.

FluidNC fixes (1) by using **one firmware with two config files** —
`config_cnc.yaml` / `config_laser.yaml` — switched with two commands and **no
reflash**, so WiFi survives. This repo fixes (2) by shipping a prebuilt
firmware that includes the `ts35` display module.

## Highlights

- **Prebuilt firmware** for DLC32 V2.1 + TS35-R V2.0 — no toolchain needed:
  `firmware/ts35/ttc450-ts35-8mb.bin` (MKS Laser Tool) and
  `ttc450-ts35-4mb.bin` (esptool). See [`firmware/ts35`](firmware/ts35/).
- **Tested configs** for CNC and laser, with and without the TS35 panel
  ([`config/`](config/)).
- **Touch calibration guide** (the panel is raw resistitive; it needs
  calibration before enabling on-screen controls).
- **Root-cause analysis** of the stock firmware WiFi bug (erased NVS) and a
  `$ESP...` workaround that works without reflashing.
- **Full hardware/pinout inventory** of the TTC450 + DLC32 V2.1.
- **Reproducible build**: source files, the PlatformIO platform pin and the
  exact offsets ([`source/BUILD.md`](source/BUILD.md)).
- **Release assets** via GitHub Actions on every `v*` tag.

## Quick start (TS35 firmware)

Back up the original flash first (the board must be powered from its 24 V
supply — USB alone does not power the DLC32):

```bash
./scripts/backup-flash.sh /dev/ttyUSB0
```

Flash the TS35 build:

```bash
./scripts/flash-ts35.sh /dev/ttyUSB0
```

On Windows, use the **MKS Laser Tool → MKS ESP32 Download Tool** with
`firmware/ts35/ttc450-ts35-8mb.bin` and **flash size 8 MB** (same procedure as
the original firmware).

First boot:

1. The screen should show `FLUIDNC TS35` / `STARTING`, then the **DRO** page.
2. FluidNC starts in AP mode: network **`FluidNC`**, password **`12345678`**,
   `http://192.168.0.1/`.
3. Configure your workshop WiFi:

   ```text
   $Sta/SSID=YOUR_NETWORK
   $Sta/Password=YOUR_PASSWORD
   $WiFi/Mode=STA>AP
   $Bye
   ```

4. The touchscreen starts in **read-only mode** (`controls_enabled: false`).
   Go to the **INFO** page, read the raw touch values and calibrate before
   enabling controls. Full procedure:
   [docs/en/ts35-firmware.md](docs/en/ts35-firmware.md) ·
   [docs/pt-BR/firmware-ts35.md](docs/pt-BR/firmware-ts35.md).

## Compatibility

| Item | Requirement |
|---|---|
| Machine | TwoTrees TTC450 (or any machine with the same board/panel) |
| Controller | **MKS DLC32 V2.1**, ESP32, **8 MB flash** |
| Panel | **MKS TS35-R V2.0** — ST7796 LCD + ADS7843E touch |
| Power | 24 V while flashing (USB alone is not enough) |
| Host | Windows (MKS Laser Tool) or Linux/macOS (esptool) |

It will **not** work with other panels (e.g. ILI9488-based TS35 revisions) or
with 4 MB DLC32 boards.

## Known limitations

- The `ts35` module is **not merged upstream**; this is a community build.
- **The SD card is disabled** in the TS35 build. The panel uses the LCD SPI
  bus (`gpio.18/19/23`) and FluidNC exposes only one `spi:` section, while the
  DLC32 SD card is on a second bus (`gpio.12/13/14/15`).
- The touch panel is resistive and **must be calibrated** per unit.
- OTA updates must use images from this same build; do not mix with upstream
  FluidNC binaries.
- No automated tests. The upstream PR was bench-tested on the same board +
  panel, but always test with the machine free of tooling.

## Repository layout

| Path | Contents |
|---|---|
| [`firmware/ts35/`](firmware/ts35/) | Prebuilt firmware images, checksums, build info |
| [`source/`](source/) | `ts35` module source + reproducible build guide |
| [`config/`](config/) | FluidNC YAML configs (CNC / laser, with / without TS35) |
| [`scripts/`](scripts/) | Backup and flash scripts, release packaging |
| [`docs/en/`](docs/en/) | Documentation in English |
| [`docs/pt-BR/`](docs/pt-BR/) | Documentação em português |

## Documentation

| Topic | English | Português |
|---|---|---|
| Hardware inventory & pinout | [hardware.md](docs/en/hardware.md) | [hardware.md](docs/pt-BR/hardware.md) |
| Stock firmware & the WiFi bug | [stock-firmware.md](docs/en/stock-firmware.md) | [firmware-original.md](docs/pt-BR/firmware-original.md) |
| Running FluidNC on the TTC450 | [fluidnc.md](docs/en/fluidnc.md) | [fluidnc.md](docs/pt-BR/fluidnc.md) |
| TS35 firmware, flash & touch | [ts35-firmware.md](docs/en/ts35-firmware.md) | [firmware-ts35.md](docs/pt-BR/firmware-ts35.md) |
| Safety & references | [safety.md](docs/en/safety.md) | [seguranca.md](docs/pt-BR/seguranca.md) |

## Credits

- [FluidNC](https://github.com/bdring/FluidNC) by Mitch Bradley and the
  FluidNC community — GPLv3.
- The `ts35` module: [FluidNC PR #1805](https://github.com/bdring/FluidNC/pull/1805)
  by [thcasssio](https://github.com/thcasssio) (branch
  `feat/ts35-display-module`).
- Base TTC450 configs: [Diode Laser Wiki](https://diode-laser-wiki.com/documentation/twotrees-ttc450-cnc-machine/).
- Stock firmware references: TwoTrees wiki, [MKS-DLC32](https://github.com/makerbase-mks/MKS-DLC32).

## License

The firmware, `source/` and any FluidNC-derived material are licensed under the
**GNU General Public License v3.0 or later** — see [LICENSE](LICENSE).
Documentation and configuration files in this repository are released under
the same terms unless stated otherwise.

## Disclaimer

This software controls machinery that can cause injury and fire. Use at your
own risk. Laser work requires appropriate eye protection, ventilation and
supervision. Always keep a full flash backup so you can return to the stock
firmware.
