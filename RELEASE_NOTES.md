<!-- Language switcher -->
**English** · [🇧🇷 Português](#português)

# TTC450 FluidNC + TS35 — v1.0.0

Prebuilt **FluidNC** firmware with the community `ts35` display module for
**MKS DLC32 V2.1 (ESP32, 8 MB) + MKS TS35-R V2.0** (ST7796 LCD + ADS7843E
touch), as shipped in the **TwoTrees TTC450**.

> Not an official FluidNC release. The `ts35` module comes from
> [PR #1805](https://github.com/bdring/FluidNC/pull/1805), not merged upstream.

## Assets

| Asset | Purpose |
|---|---|
| `ttc450-ts35-firmware.zip` | Everything below in one archive |
| `ttc450-ts35-8mb.bin` | Full 8 MB image — **MKS Laser Tool** |
| `ttc450-ts35-4mb.bin` | Full 4 MB image — **esptool** / scripts |
| `firmware.bin`, `bootloader.bin`, `partitions.bin`, `boot_app0.bin`, `littlefs.bin` | Individual parts |
| `SHA256SUMS` | Checksums |

## Highlights

- One firmware, two configs (`config_cnc.yaml` / `config_laser.yaml`), switched
  with `$Config/Filename=...` + `$Bye` — **no reflash, WiFi preserved**.
- TS35 panel support: DRO, JOG, ZERO, CTRL and INFO pages.
- Preloaded CNC and laser TS35 configs in LittleFS.
- Touch panel starts **read-only** (`controls_enabled: false`) until calibrated.

## Flashing

1. Back up the stock flash first (board powered from 24 V):
   `./scripts/backup-flash.sh /dev/ttyUSB0`
2. Linux/macOS: `./scripts/flash-ts35.sh /dev/ttyUSB0`
3. Windows: MKS Laser Tool → MKS ESP32 Download Tool → `ttc450-ts35-8mb.bin`,
   flash size **8 MB**.

Full instructions: [docs/en/ts35-firmware.md](docs/en/ts35-firmware.md).

## Known limitations

- **SD card disabled** — the panel and the SD card use separate SPI buses and
  FluidNC exposes a single `spi:` section.
- **Touch calibration required** per unit.
- OTA works, but only with images from this same build.
- No automated tests; bench-tested upstream on the same board + panel.

## License

GPL-3.0-or-later. See [LICENSE](LICENSE) and [NOTICE.md](NOTICE.md).

---

## Português

# TTC450 FluidNC + TS35 — v1.0.0

Firmware **FluidNC** já compilado, com o módulo de tela `ts35` da comunidade,
para **MKS DLC32 V2.1 (ESP32, 8 MB) + MKS TS35-R V2.0** (LCD ST7796 + touch
ADS7843E), a combinação que vem na **TwoTrees TTC450**.

> Não é uma release oficial do FluidNC. O módulo `ts35` vem do
> [PR #1805](https://github.com/bdring/FluidNC/pull/1805), ainda não aceito no
> repositório principal.

## Destaques

- Um firmware, dois arquivos de config (`config_cnc.yaml` / `config_laser.yaml`),
  trocados com `$Config/Filename=...` + `$Bye` — **sem regravar, WiFi
  preservado**.
- Suporte à tela TS35: páginas DRO, JOG, ZERO, CTRL e INFO.
- Configs de CNC e laser com TS35 já gravadas no LittleFS.
- A tela inicia em **modo somente leitura** (`controls_enabled: false`) até ser
  calibrada.

## Gravação

1. Faça o backup da flash original (placa ligada nos 24 V):
   `./scripts/backup-flash.sh /dev/ttyUSB0`
2. Linux/macOS: `./scripts/flash-ts35.sh /dev/ttyUSB0`
3. Windows: MKS Laser Tool → MKS ESP32 Download Tool → `ttc450-ts35-8mb.bin`,
   flash size **8 MB**.

Instruções completas: [docs/pt-BR/firmware-ts35.md](docs/pt-BR/firmware-ts35.md).

## Limitações conhecidas

- **Cartão SD desativado** — a tela e o cartão SD usam barramentos SPI
  diferentes e o FluidNC expõe uma única seção `spi:`.
- **Calibração do touch** necessária em cada unidade.
- A OTA funciona, mas só com imagens deste mesmo build.
- Sem testes automatizados; testado em bancada no mesmo modelo de placa + tela.

## Licença

GPL-3.0-or-later. Veja [LICENSE](LICENSE) e [NOTICE.md](NOTICE.md).
