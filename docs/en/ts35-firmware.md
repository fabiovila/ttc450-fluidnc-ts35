# TS35 firmware build — flash, first boot and touch calibration

[← Back to README](../../README.md) · **English** · [🇧🇷 Português](../pt-BR/firmware-ts35.md)

This is a **prebuilt FluidNC firmware with the community `ts35` display
module** for **MKS DLC32 V2.1 (ESP32, 8 MB) + MKS TS35-R V2.0**.

Base: FluidNC with the `ts35` module from
[PR #1805](https://github.com/bdring/FluidNC/pull/1805), which was bench-tested
on exactly this board + panel combination.

> **Not an official FluidNC build.** The `ts35` module has not been merged
> upstream. Test with the machine free of tooling and the laser disconnected.
> Keep a backup of the original flash.

## Files

| File | Purpose |
|---|---|
| `ttc450-ts35-8mb.bin` | Full 8 MB image; use with the **MKS Laser Tool** (same procedure as the stock firmware) |
| `ttc450-ts35-4mb.bin` | Full 4 MB image; use with **esptool** / Web Installer / scripts |
| `bootloader.bin` | Bootloader (offset `0x1000`) |
| `partitions.bin` | FluidNC partition table (offset `0x8000`) |
| `boot_app0.bin` | Boot selector (offset `0xe000`) |
| `firmware.bin` | FluidNC + TS35 application (offset `0x10000`) |
| `littlefs.bin` | LittleFS with WebUI + configs (offset `0x3d0000`) |
| `SHA256SUMS` | Checksums for all of the above |
| `BUILD-INFO.txt` | Toolchain, versions and build date |

Flash offsets and build details are also in
[`source/BUILD.md`](../../source/BUILD.md).

## What is preloaded

The LittleFS image already contains:

- `config.yaml` → a copy of the **CNC + TS35** config
- `config_cnc_ts35.yaml` → CNC/mill + panel
- `config_laser_ts35.yaml` → laser + panel

On first boot FluidNC uses `config.yaml` (CNC + TS35). To switch to laser:

```text
$Config/Filename=config_laser_ts35.yaml
$Bye
```

To go back to CNC, use `config.yaml` (the file active on first boot) or
`config_cnc_ts35.yaml` (a reference copy with the same content):

```text
$Config/Filename=config_cnc_ts35.yaml
$Bye
```

**Important:** edit the file that is currently active. If you never switched,
that is `config.yaml`. If you switched to `config_cnc_ts35.yaml`, edit that one.
Changes to one file do not affect the other until you switch configs.

**On this build, use only configs with `_ts35` in the name.** The
`config_cnc.yaml` / `config_laser.yaml` configs (without the `ts35` section) are
for stock FluidNC and leave the panel blank on this firmware.

## Flash

### Option 1 — MKS Laser Tool (Windows)

1. Open the MKS Laser Tool.
2. Choose **MKS ESP32 Download Tool**.
3. Select `ttc450-ts35-8mb.bin`.
4. Use the same SPI speed / flash size / baud you use for the stock firmware
   (flash size **8 MB**).
5. Click Start.

### Option 2 — repo script (Linux/macOS)

```bash
./scripts/flash-ts35.sh /dev/ttyUSB0
```

### Option 3 — manual esptool

```bash
esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 921600 erase_flash

esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 921600 \
  write_flash -z --flash-mode dio --flash-freq 80m --flash-size detect \
  0x0 firmware/ts35/ttc450-ts35-4mb.bin
```

The board must be powered from **24 V**; USB alone does not power the DLC32.

Back up the original flash first. On Windows you can use the `esptool.exe` from
the FluidNC bundle:

```bat
esptool.exe --chip esp32 --port COM3 --baud 460800 read_flash 0 0x800000 backup.bin
```

## First boot

1. The screen should show `FLUIDNC TS35` / `STARTING`, then the **DRO** page.
2. FluidNC starts in AP mode:
   - network: `FluidNC`
   - password: `12345678`
   - address: <http://192.168.0.1/>
3. Configure your workshop WiFi:

   ```text
   $Sta/SSID=YOUR_NETWORK
   $Sta/Password=YOUR_PASSWORD
   $WiFi/Mode=STA>AP
   $Bye
   ```

`STA>AP` tries to join your network and falls back to the `FluidNC` AP if it
fails. The IP appears on the console and in the router; the mDNS name is
`http://fluidnc.local/`.

## On-screen pages

- **DRO**: X/Y/Z position, state, feed, spindle, units.
- **JOG**: X/Y/Z buttons, step (0.01/0.1/1/10/100 mm) and speed
  (10/25/50/80/100%).
- **ZERO**: zero X/Y/Z/XYZ with `G10 L20 P0`.
- **CTRL**: Hold, Resume, Cancel Jog, feed/rapid overrides, Home, Unlock,
  Reset.
- **INFO**: raw touch coordinates, calibration, modal state, buffers, SD,
  counters.
- Alarm banner with an unlock button.

Home, zero, unlock and reset require **two taps** within 3 seconds.

## Touch calibration (important)

The build ships with `controls_enabled: false`: the panel shows state and DRO,
but **does not run jog, zero, homing or reset**. This is deliberate, because a
mis-calibrated tap could press the wrong button.

1. On the panel, tap the **INFO** tab.
2. Tap the four corners of the usable area and note the **raw X/Y** values shown
   on the INFO page.
3. In the **active** config file (on first boot, `config.yaml`; otherwise the
   `config_cnc_ts35.yaml`), set:

   ```yaml
   ts35:
     touch_x_min: ...
     touch_x_max: ...
     touch_y_min: ...
     touch_y_max: ...
   ```

4. If the axes are swapped or mirrored, adjust:

   ```yaml
   ts35:
     touch_swap_xy: true/false
     touch_invert_x: true/false
     touch_invert_y: true/false
   ```

5. Only after confirming that a tap lands on the intended button, set:

   ```yaml
   ts35:
     controls_enabled: true
   ```

6. To allow homing, unlock and reset from the panel:

   ```yaml
   ts35:
     allow_homing: true
     allow_unlock: true
     allow_soft_reset: true
     allow_alarm_clear: true
   ```

## Troubleshooting the display

- **Black screen but FluidNC comes up on WiFi:** try
  `backlight_active_low: false`; check the EXP1/EXP2 ribbon; lower
  `lcd_clock_hz` to `20000000`.
- **Inverted colors:** `invert_display: true`.
- **Noisy bands:** lower `lcd_clock_hz` to `20000000` or `10000000`.
- **Mirrored touch:** adjust `touch_invert_x` / `touch_invert_y`.
- **Swapped touch (X moves Y):** `touch_swap_xy: false`.
- **Touch does not register:** raise or lower `touch_pressure_threshold`, and
  check `touch_x_min/max`, `touch_y_min/max`.
- **Panel works but touch is offset:** recalibrate using the raw values from the
  INFO page.

## Limitation: SD card

The TS35 module uses the LCD SPI bus (`gpio.18/19/23`). The DLC32 has a second
SPI bus for the SD card (`gpio.12/13/14/15`), but FluidNC has only one `spi:`
section. In this build the panel works and the **SD card is disabled**. Use the
WebUI/LocalFS or the network to send files.

If you need both, a second SPI bus would have to be added to FluidNC (a code
change, not included in this module).

## OTA updates

The OTA `app1` partition is the same size as `app0` (1.8 MB) and this build fits
in it, so OTA works. However, **only flash images from this same build**. Do not
mix with stock FluidNC binaries — they lack the `ts35` module and the panel will
stay blank.

## Recovery

If something goes wrong, restore your 8 MB backup:

```bash
esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 460800 \
  write_flash 0x0 backup/ttc450-stock-YYYYMMDD-HHMMSS.bin
```

Or use the MKS Laser Tool with the original CNC/laser firmware.
