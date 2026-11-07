# Custom web interface

[← Back to README](../../README.md) · **English** · [🇧🇷 Português](../pt-BR/interface-web.md)

The TTC450 FluidNC + TS35 build ships a **custom bilingual WebUI** in
LittleFS. It replaces the stock ESP3D WebUI and talks directly to the FluidNC
console WebSocket.

- Source: [`ui/index.html`](../../ui/index.html)
- Published file: [`ui/index.html.gz`](../../ui/index.html.gz)
- Full file/update guide: [`ui/README.md`](../../ui/README.md)

## Why replace the stock WebUI

The stock WebUI expects an `[ESP...]` line in the `$I` report to discover the
WebSocket port. This FluidNC build does not print that line, so the stock
console connects to port 81 and fails. The firmware WebSocket works on
**port 80**:

```text
ws://<machine-ip>/          subprotocol: arduino
/command?commandText=...&PAGEID=N
/command?plain=...
/files
/updatefw
```

The custom page uses `location.host` (no hard-coded machine IP in the code),
so it works with DHCP, mDNS, AP mode and any hostname. It has no external CDN
dependencies, analytics or credentials.

## What is included

| File | Role |
|---|---|
| `index.html.gz` | Page served at `/` |
| `help-en.html` | English manual loaded by the Help tab |
| `macros.json` | Optional default macros |
| `favicon.ico` | Optional tab icon |
| `index.html` | Editable source (not served) |
| `webui-original.html.gz` | Backup of the original WebUI |
| `SHA256SUMS` | Checksums for the files above |

Only `index.html.gz` and `help-en.html` are required. The shipped
`littlefs.bin` already contains them, so a normal firmware flash has the new
UI immediately.

## Main features

- **Dashboard:** DRO, WCO, feed/spindle, overrides, inputs, machine state,
  WiFi, LittleFS usage, firmware info, event log and quick actions.
- **Control:** jog, zero, home, unlock/clear alarm, motor disable, MDI,
  feed/rapid overrides and generic macros.
- **CNC:** spindle relay, S12000/S6000 presets, coolant, spindle override,
  probe, CNC macros and diagnostics.
- **Laser:** 1/5/10/25/50/100% power, pulse, continuous, OFF, PWM test,
  checklist and diagnostics. It also explains the M3 (constant power) vs M4
  (dynamic power) behaviour.
- **Mode gate:** CNC and Laser pages are mutually locked according to the
  active config. The Control page always stays available.
- **Files:** browse, upload, download, view, rename, delete, create folders,
  run `.nc`, and select YAML configs. UI/config/macro files are protected.
- **Settings:** editable `$Settings/List`, WiFi, `$Config/Dump`,
  `$Firmware/Info`, OTA (same build only), restart and reports.
- **Help:** 17-section manual with index, search, glossary, commands, screen
  reference, CNC ↔ laser modes, M3/M4 and troubleshooting.

## Language

The page detects `navigator.languages`: any `pt-*` selects Portuguese,
otherwise English. The **EN/PT** button in the header stores the choice in
`localStorage`; `?lang=pt` or `?lang=en` forces it for testing. The Portuguese
manual is embedded in `index.html`; the English manual is `help-en.html`.

## Update the page without reflashing

Use the WebUI **Files / LocalFS** page or the `/files` API:

```bash
HOST=http://192.168.15.77

sz=$(wc -c < ui/index.html.gz)
curl -F 'path=/' \
     -F "/index.html.gzS=$sz" \
     -F 'myfile[]=@ui/index.html.gz;filename=/index.html.gz' \
     "$HOST/files"

sz=$(wc -c < ui/help-en.html)
curl -F 'path=/' \
     -F "/help-en.htmlS=$sz" \
     -F 'myfile[]=@ui/help-en.html;filename=/help-en.html' \
     "$HOST/files"
```

Reload with **Ctrl+F5**. Upload `index.html.gz`, never the uncompressed
`index.html`.

## Rebuild `littlefs.bin`

```bash
cp ui/index.html.gz ui/help-en.html ui/macros.json ui/favicon.ico \
   <FluidNC>/FluidNC/data/
cd <FluidNC>
pio run -e wifi -t buildfs
```

`buildfs` deletes `.pio/build/wifi/firmware.bin`; build the application first
and copy `firmware.bin` aside if you are rebuilding both. See
[`source/BUILD.md`](../../source/BUILD.md).

## OTA and the update button

The web update handler is present in this build, so the UI's firmware upload
uses `/updatefw`. Flash **only** `firmware.bin` from this same TS35 build. An
upstream FluidNC image has no `ts35` module and leaves the panel blank.

## Restore the original WebUI

```bash
sz=$(wc -c < ui/webui-original.html.gz)
curl -F 'path=/' \
     -F "/index.html.gzS=$sz" \
     -F 'myfile[]=@ui/webui-original.html.gz;filename=/index.html.gz' \
     'http://192.168.15.77/files'
```

Reload with Ctrl+F5.

## Security

The page has **no authentication**, like the stock FluidNC WebUI. Keep the
controller on a trusted local network and never expose it directly to the
internet. It does not load external scripts; the only external links are
documentation sites.

## Troubleshooting

- **Page loads but live data does not update:** check that the browser can open
  `ws://<machine-ip>/`; a proxy or HTTPS page can block mixed-content
  WebSocket connections.
- **Commands work but G-code does not:** G-code and jog go through the
  WebSocket; `$` queries can still work over HTTP. Reload the page to get a new
  `PAGEID`.
- **English manual missing:** upload `help-en.html` to the LittleFS root.
- **ConfigAlarm banner after a crash:** restart with `$Bye` or the Restart
  button so the normal YAML is loaded.
- **Laser stays on:** the page cannot cut power by itself; send `M5` or press
  the OFF button. Closing the browser does not turn the laser off.
