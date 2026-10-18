# Hardware inventory — TwoTrees TTC450 + MKS DLC32 V2.1

[← Back to README](../../README.md) · **English** · [🇧🇷 Português](../pt-BR/hardware.md)

Compiled from the stock firmware images, the MKS DLC32 V2.1 documentation, the
TwoTrees wiki and the public TTC450 FluidNC configs.

## Controller

| Item | Specification |
|---|---|
| Controller | **MKS DLC32 V2.1** (inside the TTC450 control box) |
| MCU | **ESP32-WROOM-32U**, dual-core 240 MHz, 520 KB SRAM |
| Flash | **8 MB** (8192 KB) |
| WiFi | 2.4 GHz b/g/n only (cannot see 5 GHz networks); Bluetooth 4.2 (not simultaneous with WiFi) |
| USB | **CH340** serial converter; the board is **not powered over USB** |
| Power | 12–24 V, 5 A, 5.5 × 2.1 mm DC jack, 10 A fuse |
| Stepper drivers | 3 × **A4988** in sockets (X, Y, Z) + 1 spare socket (**A**) |
| Microstepping | DIP-switch selectable; default 1/16 |
| Motors | NEMA 17, T8 lead screw with 4 mm pitch → **800 steps/mm** (`$100`–`$102` = 800) |
| Limit switches | X = `gpio.36`, Y = `gpio.35`, Z = `gpio.34` (inputs, 3-pin JST XH) |
| Probe / touch plate | `gpio.22` (2.5 mm JST SM) |
| Laser port | **TTL 3-pin**: V = Vin (12/24 V), G = GND, S = PWM **0–5 V**, 1–10 kHz |
| CNC / spindle port | **2-pin**: GND + PWM **0–12/24 V**, up to 2 A |
| 500 W spindle | Switched by **relay**; speed is **not** software-controlled (only the PSU potentiometer) |
| Display | **TS35 / TS35-R** 3.5" 480×320, resistive touch, direct SPI (no on-panel controller) |
| microSD | SPI bus (`gpio.12/13/14/15`) |
| I2C | `gpio.0` (SDA) / `gpio.4` (SCL) |
| Work area | **460 × 460 × 80 mm** |
| Driver Vref | ~0.96 V (verify with a multimeter) |

## DLC32 V2.1 pinout (TTC450)

| Function | Pin |
|---|---|
| X step / dir | `I2SO.1` / `I2SO.2` |
| Y step / dir | `I2SO.5` / `I2SO.6` |
| Z step / dir | `I2SO.3` / `I2SO.4` |
| Shared enable | `I2SO.0` |
| I2S (BCK / WS / DATA) | `gpio.16` / `gpio.17` / `gpio.21` |
| SD SPI | MISO `gpio.12`, MOSI `gpio.13`, SCK `gpio.14`, CS `gpio.15` |
| LCD SPI | SCK `gpio.18`, MISO `gpio.19`, MOSI `gpio.23` |
| LCD CS / DC / RST / backlight | `gpio.25` / `gpio.33` / `gpio.27` / `gpio.5` |
| Touch CS | `gpio.26` |
| Laser / spindle PWM | `gpio.32` |
| Probe | `gpio.22` |
| Limit switches | X `gpio.36`, Y `gpio.35`, Z `gpio.34` |

## Notes

- The **LCD and the SD card use different SPI buses** on the DLC32. Because
  FluidNC exposes a single `spi:` section, enabling the TS35 panel disables the
  SD card. See the [TS35 firmware doc](ts35-firmware.md).
- The panel data sheet calls the backlight pin `LCD_EN`; on some revisions the
  backlight is active-low, on others active-high. The TS35 module exposes
  `backlight_active_low` for that.
- The **A4988 drivers are socketed**, so they can be replaced or upgraded, but
  the stock Vref is conservative; adjust only if you know what you are doing.

## References

- TwoTrees TTC450 wiki — <https://wiki.twotrees3d.com/>
- MKS DLC32 repository — <https://github.com/makerbase-mks/MKS-DLC32>
- FluidNC DLC32 page — <http://wiki.fluidnc.com/en/hardware/3rd-party/MKS_DLC32>
- Diode Laser Wiki TTC450 page — <https://diode-laser-wiki.com/documentation/twotrees-ttc450-cnc-machine/>
