# Stock firmware and the laser-mode WiFi bug

[← Back to README](../../README.md) · **English** · [🇧🇷 Português](../pt-BR/firmware-original.md)

## Stock firmware inventory

| Mode | File | Version / date | App size |
|---|---|---|---|
| CNC | `V2.3.0_H35_2023080501_N_CNC_TTC450.bin` | V2.3 (8M.H35.20230803) | ~1.97 MB |
| Laser | `V2.20_H35_2022_1101_N_ZX_002.bin` | V2.20 (8M.H35.20221101) | ~1.70 MB |

Both images are **8 MB** and share the same partition table:

| Partition | Offset | Size |
|---|---|---|
| `nvs` | `0x9000` | 20 KB |
| `otadata` | `0xe000` | 8 KB |
| `app0` | `0x10000` | **7 MB** |
| `spiffs` | `0x710000` | 0.88 MB |

Consequence: the app only uses ~2 MB while the partition is 7 MB. That is why
the MKS firmware can fit the graphical UI and the WebUI together. FluidNC uses
a 4 MB layout (1.8 MB app + LittleFS), which fits comfortably in the 8 MB
flash.

Official downloads:

- CNC: <https://wiki.twotrees3d.com/yingwen/450/cnc-firmware.zip>
- Laser: <https://wiki.twotrees3d.com/yingwen/450/laser-firmware.zip>
- Ready-made FluidNC configs (Diode Laser Wiki): <https://diode-laser-wiki.com/wp-content/uploads/2024/02/TTC450_FluidNC.zip>

## Why laser-mode WiFi fails

### Root cause

The official TwoTrees procedure to switch to laser mode is:

1. remove the panel and the cover;
2. connect the laser cable to the **S-TTL-V** port;
3. open the **MKS Laser Tool**;
4. **erase the firmware**;
5. flash the laser firmware;
6. import the settings into LaserGRBL.

Step 4 erases the whole flash — including the **NVS** partition, which is
exactly where the firmware stores the WiFi SSID, password and mode. In other
words, **every firmware switch wipes the WiFi**. On top of that, the old laser
firmware (V2.20 / 2022) still has the known bug of not reconnecting on its own
after boot.

This is not theoretical: in both official `.bin` files the NVS region
(`0x9000`–`0xDFFF`) is **entirely `0xFF`**. The MKS Laser Tool writes the whole
8 MB image, so it overwrites the NVS with `0xFF` on every flash.

### Secondary causes

- **5 GHz network**: the ESP32 only works on 2.4 GHz. If your phone/PC is on a
  5 GHz network, it will not see the board.
- **On-screen keyboard**: the TS35 WiFi screen is missing characters; passwords
  with symbols may be impossible to type.
- **EMI**: a 500 W spindle and the laser PSU generate noise. WiFi can drop
  during a job even with correct settings. Shielded cables, ferrite beads and
  separating the power supplies help.
- **IP address**: in AP mode the address is **192.168.4.1** (SSID like
  `MKS_DLC32`, password `12345678`). In STA mode the IP appears on the screen
  or in the router.

### Quick workaround on the stock firmware (no reflash)

Connect over USB (with the machine powered from 24 V), open the console of UGS,
Candle, LaserGRBL or FluidTerm and send, **one line at a time**, waiting for
each restart to finish:

```text
$ESP444=RESTART
$ESP115=ON
$ESP100=YOUR_NETWORK
$ESP101=YOUR_PASSWORD
$ESP110=STA
$ESP444=RESTART
$ESP115=ON
```

Then read the IP from the screen or the router. The **MKS Laser Tool → WiFi
Configuration Tool** does the same thing through a GUI.

This fixes the moment, but **not the firmware switching**: the next flash
erases the NVS again. It is a patch, not a solution.

## The real fix

Use a single firmware with switchable config files, so nothing needs to be
erased on mode change. FluidNC does exactly that — see
[Running FluidNC on the TTC450](fluidnc.md).
