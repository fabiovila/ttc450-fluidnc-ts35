# Running FluidNC on the TTC450

[← Back to README](../../README.md) · **English** · [🇧🇷 Português](../pt-BR/fluidnc.md)

## Does FluidNC support the TTC450?

**Yes.** The MKS DLC32 V2.1 is an officially supported board, and ready-made
TTC450 configurations already exist (the ones in this repo are based on them).

### What works

- 3 axes X/Y/Z with the same A4988 drivers and 800 steps/mm.
- X/Y/Z limit switches and probe input.
- microSD card (when the TS35 panel is **not** enabled).
- Laser on the TTL port (`gpio.32`).
- Spindle relay on the CNC port (`gpio.32` in CNC mode).
- WiFi with **STA + AP fallback** (`STA>AP`), automatic reconnect,
  `fluidnc.local` (mDNS), WebUI, Telnet, WebSocket.
- OTA updates.
- **Two config files**: `config_cnc.yaml` and `config_laser.yaml`, switched
  with `$Config/Filename=...` + `$Bye`, with no reflash.
- Macros, homing, overrides, etc.

### What does not work

- **The TS35 panel on stock FluidNC.** FluidNC does not support the panels
  that ship with the DLC32. The maintainers have said more than once that they
  will not (issue #759): it is a "dumb" SPI panel with no controller of its
  own, and MKS's code is large and board-specific. FluidNC prefers displays
  with an integrated controller, over UART or wireless.
- **Official pendant**: M5Dial or CYD Dial, which are wireless. Not
  plug-and-play on the DLC32, but it is the supported path for physical
  controls.

### So what about the panel?

Upstream FluidNC has an experimental PR — **#1805** (August 2026) — that adds a
`ts35` module:

- Bench-tested on **MKS DLC32 V2.1 + TS35-R V2.0** (ST7796 + ADS7843E).
- Pages: DRO, JOG, ZERO, CONTROL and INFO.
- **Not merged** into upstream FluidNC.
- The panel uses the LCD SPI bus (`gpio.18/19/23/25/26/27/33`), while the SD
  card uses a second SPI bus (`gpio.12/13/14/15`). FluidNC has a single `spi:`
  section, so using the panel means giving up the SD card (or patching FluidNC).
- Only works if the panel is exactly **TS35-R V2.0 (ST7796 + ADS7843E)**.

This repository ships a **prebuilt firmware** for that exact combination — see
[TS35 firmware, flash & touch](ts35-firmware.md). The shipped configs enable
JOG, ZERO, UNLOCK and CLEAR ALARM on the panel, but keep HOME and soft reset
disabled; if the touch is mis-calibrated, set `controls_enabled: false`.

To identify a panel, open the control box and check the label/back of the
display. Look for "TS35-R V2.0" or the **ST7796** (LCD) and **ADS7843E**
(touch) chips. The stock firmware's `H35` name only means "3.5-inch panel" and
does not identify the controller.

## Decision matrix

| Option | Pros | Cons |
|---|---|---|
| **Stay on the stock MKS firmware** and just fix WiFi | Free, keeps the panel, keeps the current workflow | Must reflash and reconfigure WiFi on every switch; old laser firmware; reconnect bugs |
| **FluidNC + WebUI on phone/tablet** | Stable WiFi, one firmware, CNC/laser switching by config, OTA, macros | Loses the TS35 panel; needs a phone/tablet/PC nearby |
| **FluidNC + prebuilt TS35 build** (this repo) | Keeps the panel and gains FluidNC; prebuilt images and preloaded configs | Not official; TS35-R V2.0 only; **SD card disabled**; no automated tests |
| **FluidNC + M5Dial/CYD pendant** | Official, wireless, supported physical controls | Extra cost; not the original panel |

## Migration step by step

### 1. Back up first

The board must be powered from **24 V** (USB alone does not power the DLC32).
Connect USB and run:

```bash
./scripts/backup-flash.sh /dev/ttyUSB0
```

Or manually:

```bash
python3 -m esptool --chip esp32 --port /dev/ttyUSB0 --baud 460800 \
  read_flash 0x000000 0x800000 backup/ttc450-stock.bin
```

Keep the `.bin` and its checksum. It contains the original firmware, NVS and
SPIFFS.

Also note:

- board version (should be **V2.1**);
- motor and limit-switch cable positions (take photos);
- the original `$$` values, especially `$100`, `$101`, `$102`, `$110`, `$111`,
  `$112`, `$120`, `$121`, `$122`.

### 2. Flash FluidNC

**Option A — Web Installer (easiest, Chrome/Edge):**

1. Open <https://installer.fluidnc.com/>.
2. Connect the board with 24 V + USB.
3. Choose **FluidNC → ESP32 → WiFi**.
4. If asked, enter boot mode (hold BOOT, press EN/RST, release).
5. Install.

> This installs **stock FluidNC without TS35 support**. Use it only if you do
> not need the panel.

**Option B — repo script (Linux/macOS):**

```bash
./scripts/flash-fluidnc.sh /dev/ttyUSB0
```

It downloads FluidNC v4.1.1, erases the flash and writes bootloader, partition
table, app and LittleFS. Confirm the port (`/dev/ttyUSB0` or `/dev/ttyACM0`).

**Option C — Windows, official bundle:**

1. Download `fluidnc-v4.1.1-win64.zip` from
   <https://github.com/bdring/FluidNC/releases>.
2. Extract it.
3. Run `erase.bat`.
4. Run `install-wifi.bat`.

**Option D — prebuilt TS35 build (this repo):**

Use this if you want to keep the panel. The build is already compiled in
`firmware/ts35/` and the configs are already in LittleFS.

```bash
./scripts/flash-ts35.sh /dev/ttyUSB0
```

On Windows, use the MKS Laser Tool with `firmware/ts35/ttc450-ts35-8mb.bin`
(same procedure as the stock firmware, flash size 8 MB). Read
[ts35-firmware.md](ts35-firmware.md) first: the panel starts read-only and the
**SD card is disabled** in this build.

### 3. First access

1. The board starts in AP mode: network **`FluidNC`**, password
   **`12345678`**, address **`http://192.168.0.1/`**.
2. Open the WebUI.
3. Upload the configs to **LocalFS**:
   - `config/config_cnc.yaml`
   - `config/config_laser.yaml`

   If you flashed the **TS35 build**, skip this step: the configs
   `config_cnc_ts35.yaml` and `config_laser_ts35.yaml` are already in LittleFS,
   and `config.yaml` already points to CNC + TS35.

4. In the console (WebUI Terminal tab or FluidTerm), select CNC mode:

   ```text
   $Config/Filename=config_cnc.yaml
   $Bye
   ```

5. Configure the workshop WiFi:

   ```text
   $Sta/SSID=YOUR_NETWORK
   $Sta/Password=YOUR_PASSWORD
   $WiFi/Mode=STA>AP
   $Bye
   ```

`STA>AP` tries to join your network and, if it fails, raises the `FluidNC` AP as
a fallback. The IP appears on the console and in the router; the mDNS name is
`http://fluidnc.local/`.

### 4. Machine tests

With the machine free of tooling:

```text
$I                 # version, board, WiFi mode
$$                 # settings (GRBL compatibility)
$H                 # homing (Z first, then X/Y)
$Limits            # limit switch state
$J=G91 G21 X10 F500
$J=G91 G21 X-10 F500
```

- Check that X/Y move in the right direction. If not, invert the `:low` on the
  `direction_pin` in the YAML.
- Check the probe with `G38.2 Z-80 F100` (careful, the tip moves down).
- Check the spindle relay: `M3 S12000` turns on, `M5` off. The 24 V relay closes
  above ~12 V; always use `S12000` to switch on reliably.
- Check the laser: `M3 S10` (low power), `M5`. Never turn the laser on without
  eye protection and knowing the focus.

### 5. Switching between CNC and laser

```text
$Config/Filename=config_laser.yaml
$Bye
```

and back:

```text
$Config/Filename=config_cnc.yaml
$Bye
```

Switching config does **not** swap the physical cable. Power the machine off,
disconnect the spindle and connect the laser module to the **3-pin TTL port**
(S-TTL-V), or vice versa. `gpio.32` is the same, but the port and voltage level
differ.

If you are using the **TS35 build**, switch between `config_laser_ts35.yaml` and
`config_cnc_ts35.yaml` (or `config.yaml`, the active CNC copy on first boot).
Configs without `_ts35` leave the panel blank on that firmware.

## Config files in this repo

| File | Purpose |
|---|---|
| `config/config_cnc.yaml` | CNC/mill mode: spindle relay on the CNC port, `S0`–`S12000` |
| `config/config_laser.yaml` | Laser mode: TTL 0–5 V, `S0`–`S1000` |
| `config/config_cnc_ts35.yaml` | CNC/mill + TS35 panel (LCD SPI; SD disabled) |
| `config/config_laser_ts35.yaml` | Laser + TS35 panel (LCD SPI; SD disabled) |

The configs **without** TS35 pass the official FluidNC v4.1.1 validator:

```text
OK: config_cnc.yaml
OK: config_laser.yaml
```

The TS35 configs use the `ts35` section from PR #1805. The official validator
does not know that section yet, so the fields were checked against the module's
`handler.item()` names and the firmware compiled successfully
(`Flash: 93.1%`, 1,830,957 of 1,966,080 bytes).

Notes:

- `idle_ms` is set to **255 ms** (the public config used 25 ms). 25 ms disables
  the motors almost immediately and Z can drop between commands. Change it back
  to 25 if you prefer the original behaviour.
- `max_travel_mm` uses **460 mm** (official TTC450 area). The public config used
  450; with `soft_limits: false` this does not limit motion.
- `PWM` (CNC) and `Laser` are different spindle sections. `gpio.32` is the
  same; the difference is the physical port and the scale.
- **WiFi is not in the YAML.** In FluidNC it is configured with `$Sta/...`,
  `$AP/...` and `$WiFi/Mode=...` commands.
