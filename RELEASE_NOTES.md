<!-- Language switcher -->
**English** · [🇧🇷 Português](#português)

# TTC450 FluidNC + TS35 — v1.0.1

Prebuilt **FluidNC** firmware with the community `ts35` display module for
**MKS DLC32 V2.1 (ESP32, 8 MB) + MKS TS35-R V2.0** (ST7796 LCD + ADS7843E
touch), as shipped in the **TwoTrees TTC450**.

> Not an official FluidNC release. The `ts35` module comes from
> [PR #1805](https://github.com/bdring/FluidNC/pull/1805), not merged upstream.

## Assets

| Asset | Purpose |
|---|---|
| `ttc450-ts35-firmware.zip` | Firmware images, checksums and build info in one archive |
| `ttc450-webui.zip` | Custom WebUI files (PT/EN), update guide and original-UI backup |
| `ttc450-ts35-8mb.bin` | Full 8 MB image — **MKS Laser Tool** |
| `ttc450-ts35-4mb.bin` | Full 4 MB image — **esptool** / scripts |
| `firmware.bin`, `bootloader.bin`, `partitions.bin`, `boot_app0.bin`, `littlefs.bin` | Individual parts |
| `SHA256SUMS` | Checksums |
| `BUILD-INFO.txt` | Toolchain / versions |

## What changed in v1.0.1

- **Custom bilingual WebUI (PT/EN)** preloaded in LittleFS. It replaces the
  stock ESP3D page and uses the FluidNC WebSocket on **port 80**
  (`ws://<host>/`, `arduino` subprotocol). It includes dashboard, jog,
  CNC/laser pages with a mode gate, files, settings, macros, camera/tablet
  helpers and a 17-section manual. Source and update guide: [`ui/`](ui/).
- **Hard limits are now recoverable.** Reaching a limit still stops the
  machine immediately, but FluidNC enters `State::Alarm` instead of
  `State::Critical`. Send `$X` (or **UNLOCK** on the TS35 / **Clear alarm** in
  the WebUI) and jog **away** from the switch. `HardStop`/E-stop still requires
  a deliberate reset. Patch: [`source/PATCHES.md`](source/PATCHES.md).
- LittleFS rebuilt with the new UI, configs and macros.
- Firmware rebuilt from the same `ts35` base commit with the hard-limit patch:
  **1,830,953 / 1,966,080 bytes (93.1%)**.
- Documentation updated in English and Portuguese, including the WebUI and the
  new limit behaviour.

## Highlights

- One firmware, two configs (`config_cnc.yaml` / `config_laser.yaml`), switched
  with `$Config/Filename=...` + `$Bye` — **no reflash, WiFi preserved**.
- TS35 panel support: DRO, JOG, ZERO, CTRL and INFO pages.
- Preloaded CNC and laser TS35 configs in LittleFS.
- Panel ships with **JOG, ZERO, UNLOCK and CLEAR ALARM** enabled; HOME and soft
  reset stay disabled. Set `controls_enabled: false` if the touch is off.
- Limit switches are **hard limits** with recoverable stop (`hard_limits: true`,
  `limit_neg_pin` / `limit_pos_pin`).

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
- **WebUI has no authentication** — local network only.
- OTA works, but only with `firmware.bin` from this same build.
- No automated tests; bench-tested upstream on the same board + panel.

## License

GPL-3.0-or-later. See [LICENSE](LICENSE) and [NOTICE.md](NOTICE.md).

---

## Português

# TTC450 FluidNC + TS35 — v1.0.1

Firmware **FluidNC** já compilado, com o módulo de tela `ts35` da comunidade,
para **MKS DLC32 V2.1 (ESP32, 8 MB) + MKS TS35-R V2.0** (LCD ST7796 + touch
ADS7843E), a combinação que vem na **TwoTrees TTC450**.

> Não é uma release oficial do FluidNC. O módulo `ts35` vem do
> [PR #1805](https://github.com/bdring/FluidNC/pull/1805), ainda não aceito no
> repositório principal.

## Assets

| Asset | Uso |
|---|---|
| `ttc450-ts35-firmware.zip` | Imagens de firmware, checksums e build info em um arquivo |
| `ttc450-webui.zip` | Arquivos da WebUI própria (PT/EN), guia e backup da UI original |
| `ttc450-ts35-8mb.bin` | Imagem completa de 8 MB — **MKS Laser Tool** |
| `ttc450-ts35-4mb.bin` | Imagem completa de 4 MB — **esptool** / scripts |
| `firmware.bin`, `bootloader.bin`, `partitions.bin`, `boot_app0.bin`, `littlefs.bin` | Partes individuais |
| `SHA256SUMS` | Checksums |
| `BUILD-INFO.txt` | Toolchain / versões |

## O que mudou na v1.0.1

- **WebUI própria e bilíngue (PT/EN)** já gravada no LittleFS. Substitui a
  página ESP3D oficial e usa o WebSocket do FluidNC na **porta 80**
  (`ws://<host>/`, subprotocolo `arduino`). Inclui dashboard, jog, páginas
  CNC/laser com gate de modo, arquivos, configurações, macros, câmera/tablet e
  manual de 17 seções. Fonte e guia: [`ui/`](ui/).
- **Fins de curso agora são recuperáveis.** Chegar no limite continua parando a
  máquina na hora, mas o FluidNC entra em `State::Alarm` em vez de
  `State::Critical`. Envie `$X` (ou **UNLOCK** na TS35 / **Clear alarm** na
  WebUI) e faça jog **para fora** do switch. `HardStop`/E-stop continua
  exigindo reset deliberado. Patch: [`source/PATCHES.md`](source/PATCHES.md).
- LittleFS regerado com a nova UI, configs e macros.
- Firmware recompilado a partir do mesmo commit base do `ts35`, com o patch de
  hard limit: **1.830.953 / 1.966.080 bytes (93,1%)**.
- Documentação atualizada em inglês e português, incluindo a WebUI e o novo
  comportamento dos limites.

## Destaques

- Um firmware, dois arquivos de config (`config_cnc.yaml` / `config_laser.yaml`),
  trocados com `$Config/Filename=...` + `$Bye` — **sem regravar, WiFi
  preservado**.
- Suporte à tela TS35: páginas DRO, JOG, ZERO, CTRL e INFO.
- Configs de CNC e laser com TS35 já gravadas no LittleFS.
- A tela já vem com **JOG, ZERO, UNLOCK e CLEAR ALARM** liberados; HOME e soft
  reset seguem desligados. Use `controls_enabled: false` se o toque estiver
  deslocado.
- Os fins de curso são **hard limits** com parada recuperável
  (`hard_limits: true`, `limit_neg_pin` / `limit_pos_pin`).

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
- **A WebUI não tem autenticação** — use só em rede local.
- A OTA funciona, mas só com `firmware.bin` deste mesmo build.
- Sem testes automatizados; testado em bancada no mesmo modelo de placa + tela.

## Licença

GPL-3.0-or-later. Veja [LICENSE](LICENSE) e [NOTICE.md](NOTICE.md).
