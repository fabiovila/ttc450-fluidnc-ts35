<!-- Language switcher -->
**English** · [🇧🇷 Português](README.pt-BR.md)

# Custom WebUI for the TTC450

This folder contains the custom web interface that replaces the stock ESP3D
WebUI in the TTC450 FluidNC + TS35 build. The editable source is
[`index.html`](index.html); the file served by the controller is the gzip
version, [`index.html.gz`](index.html.gz).

## Why a custom WebUI

The stock WebUI cannot configure the FluidNC console WebSocket in this build:
it looks for an `[ESP...]` line in `$I` and never finds the port. The firmware
WebSocket itself works on **port 80**:

- `ws://<machine-ip>/` with the `arduino` subprotocol;
- receives `currentID:N`, status lines `<...>` and `[GC:...]`;
- commands: `/command?commandText=...&PAGEID=N`;
- queries: `/command?plain=...`.

The custom page uses that protocol directly and does not depend on the stock
WebUI.

## Files

| File | Upload to LittleFS? | Purpose |
|---|---|---|
| `index.html.gz` | **Yes, root** | Published page (already compressed) |
| `help-en.html` | **Yes, root** | English manual loaded by the Help tab |
| `macros.json` | Optional | Default macros; the page uses built-in defaults if missing |
| `favicon.ico` | Optional | Browser tab icon |
| `index.html` | No | Editable source; generate `index.html.gz` after changes |
| `webui-original.html.gz` | Optional | Backup of the original WebUI; restore it as `index.html.gz` |
| `README.md`, `README.pt-BR.md`, `COMECE-AQUI.txt`, `SHA256SUMS` | No | Documentation and verification |

The machine configs (`config.yaml`, `config_cnc_ts35.yaml`,
`config_laser_ts35.yaml`) and laser jobs (`*.nc`) are separate from the web
page. They are already preloaded in the shipped `littlefs.bin`.

## Install or update over WiFi

The page uses the FluidNC `/files` upload endpoint. Replace `<machine-ip>` with
the board address (for example `192.168.15.77`):

```bash
HOST=http://192.168.15.77

sz=$(wc -c < index.html.gz)
curl -F 'path=/' \
     -F "/index.html.gzS=$sz" \
     -F 'myfile[]=@index.html.gz;filename=/index.html.gz' \
     "$HOST/files"

sz=$(wc -c < help-en.html)
curl -F 'path=/' \
     -F "/help-en.htmlS=$sz" \
     -F 'myfile[]=@help-en.html;filename=/help-en.html' \
     "$HOST/files"
```

Optional files:

```bash
sz=$(wc -c < macros.json)
curl -F 'path=/' -F "/macros.jsonS=$sz" \
     -F 'myfile[]=@macros.json;filename=/macros.json' "$HOST/files"

sz=$(wc -c < favicon.ico)
curl -F 'path=/' -F "/favicon.icoS=$sz" \
     -F 'myfile[]=@favicon.ico;filename=/favicon.ico' "$HOST/files"
```

Reload the page with **Ctrl+F5** after uploading. Do **not** upload
`index.html` in place of `index.html.gz`.

You can also use the stock WebUI: **Files / LocalFS** → upload the same files
to `/`.

## Rebuild the gzip file

After editing `index.html`:

```bash
gzip -9 -c index.html > index.html.gz
sha256sum index.html index.html.gz help-en.html macros.json favicon.ico \
  webui-original.html.gz > SHA256SUMS
sha256sum -c SHA256SUMS
```

## Rebuild the LittleFS image

Copy only the published files into FluidNC's `data/` directory, then build the
filesystem:

```bash
cp ui/index.html.gz ui/help-en.html ui/macros.json ui/favicon.ico \
   <FluidNC>/FluidNC/data/
cd <FluidNC>
pio run -e wifi -t buildfs
```

The shipped build already has these files in `littlefs.bin`. `buildfs`
overwrites `.pio/build/wifi/firmware.bin`, so build the application first and
copy it aside if you are rebuilding both.

## Features

- **Dashboard:** DRO, WCO, feed/spindle, overrides, pin states, machine state,
  WiFi, LittleFS, firmware, event log and quick actions.
- **Control** (works in CNC and laser modes): jog, zero, home, unlock/clear
  alarm, motor disable, MDI, feed/rapid overrides and generic macros.
- **CNC** (CNC mode only): spindle relay, S12000/S6000, coolant, spindle
  override, probe, CNC macros and diagnostics (PWM, speed map,
  `off_on_alarm`, hard/soft limits, MaxSpindleSpeed).
- **Laser** (laser mode only): 1/5/10/25/50/100% power, pulse, continuous,
  OFF, diagnostics and a 50% PWM test. The buttons use `G1 F100 M3 S...` via
  `$LocalFS/Run`; a bare `M3` is zeroed in laser mode, which is why LightBurn
  works while an isolated `M3 S50` does not.
  **M3 fixed / M4 dynamic:** M3 is constant power; M4 is proportional to speed
  and needs motion (the M4 pulse draws a short X line; "continuous" in M4 is
  blocked on purpose).
- **Mode gate:** menu order is Dashboard → Control → CNC → Laser → Files →
  Settings → Console → Macros → Camera → Tablet → Help → About. In laser mode
  the entire CNC page is `inert`/locked; in CNC mode the Laser page is locked.
  Control is never locked. Switch modes on the Dashboard or in the gate.
  Macros have a mode field; Files/Console show warnings; M5 is always allowed.
- **Help/manual:** 17 sections with index, search, glossary, commands, screens,
  CNC ↔ laser modes, M3/M4 and troubleshooting, plus a Print button. English
  manual is `help-en.html`; the UI itself is bilingual.
- **Files:** folders, upload, download, view, rename, delete, run `.nc`, use
  YAML as config; configs/UI/macros are protected.
- **Settings:** editable `$Settings/List`, WiFi, `$Config/Dump`,
  `$Firmware/Info`, OTA (same build only), restart, reports and preferences.
- Console, macros, camera, tablet and About.

## Language (i18n)

- Detection: `navigator.languages`; any `pt-*` selects **Portuguese**,
  otherwise **English**. The choice is stored in `localStorage`
  (`ttc450.lang`).
- A small **EN/PT** button in the header toggles and saves the language.
  `?lang=pt` or `?lang=en` in the URL forces it.
- Static and dynamic UI strings go through a PT→EN dictionary plus a
  `MutationObserver` (toasts, confirmations, settings, macros, files etc.).
- The Portuguese manual is embedded in `index.html`; the English manual is
  `help-en.html` and is loaded by the Help tab. If it is missing, the page
  falls back to the Portuguese manual.
- When publishing, upload `help-en.html` together with `index.html.gz`.

## ConfigAlarm

If the last reset was a **panic**, FluidNC boots with `Default (Test Drive)`
and `State 10 (ConfigAlarm)`. G-code is blocked in that state (`M3`/`M5` do not
run). A clean reboot (`$Bye` or the Restart button) loads the normal YAML. The
UI shows a banner with a restart button.

## Restore the original WebUI

```bash
sz=$(wc -c < webui-original.html.gz)
curl -F 'path=/' \
     -F "/index.html.gzS=$sz" \
     -F 'myfile[]=@webui-original.html.gz;filename=/index.html.gz' \
     "http://192.168.15.77/files"
```

Reload with Ctrl+F5.

## Security

This page has **no authentication**. Use it only on a trusted local network and
never expose the controller directly to the internet. It contains no external
CDN scripts, analytics or credentials; the only external links are the FluidNC,
TwoTrees and Diode Laser Wiki documentation sites.

## Limitations

- The page is not a replacement for a G-code sender for large jobs; use
  LightBurn/LaserGRBL and send the `.nc` file.
- The laser stays on until an `M5`; closing the browser does not turn it off.
- `off_on_alarm` is `false` in the current laser config, so an alarm does not
  cut the laser automatically. The OFF button is the immediate protection.
- Overrides use realtime characters; the firmware may log an error in the
  console, but the override still changes.
- Switching CNC/laser restarts the controller but does not change the physical
  cable.

## Checksums

```bash
sha256sum -c SHA256SUMS
```
