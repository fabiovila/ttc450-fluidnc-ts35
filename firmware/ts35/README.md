<!-- Language switcher -->
**English** · [🇧🇷 Português](#português)

# Prebuilt firmware — FluidNC + TS35

Ready-to-flash build for **MKS DLC32 V2.1 (ESP32, 8 MB) + MKS TS35-R V2.0**.

| File | Purpose |
|---|---|
| `ttc450-ts35-8mb.bin` | Full 8 MB image — **MKS Laser Tool** |
| `ttc450-ts35-4mb.bin` | Full 4 MB image — **esptool** / scripts |
| `bootloader.bin` | Bootloader — `0x1000` |
| `partitions.bin` | Partition table — `0x8000` |
| `boot_app0.bin` | Boot selector — `0xe000` |
| `firmware.bin` | App — `0x10000` |
| `littlefs.bin` | WebUI + configs — `0x3d0000` |
| `SHA256SUMS` | Checksums |
| `BUILD-INFO.txt` | Toolchain / versions |

Full instructions: [../../docs/en/ts35-firmware.md](../../docs/en/ts35-firmware.md).

Custom WebUI: [../../ui/README.md](../../ui/README.md) ·
[../../docs/en/webui.md](../../docs/en/webui.md).

Quick flash (Linux/macOS): `../../scripts/flash-ts35.sh /dev/ttyUSB0`.

> Not an official FluidNC build. The SD card is disabled in this build. The
> shipped configs enable the panel controls; calibrate the touch before
> trusting JOG/ZERO. Hard limits are recoverable: the machine stops, then
> `$X` / UNLOCK lets you jog away.

---

## Português

Build pronto para gravar em **MKS DLC32 V2.1 (ESP32, 8 MB) + MKS TS35-R V2.0**.

| Arquivo | Uso |
|---|---|
| `ttc450-ts35-8mb.bin` | Imagem completa de 8 MB — **MKS Laser Tool** |
| `ttc450-ts35-4mb.bin` | Imagem completa de 4 MB — **esptool** / scripts |
| `bootloader.bin` | Bootloader — `0x1000` |
| `partitions.bin` | Tabela de partições — `0x8000` |
| `boot_app0.bin` | Boot selector — `0xe000` |
| `firmware.bin` | App — `0x10000` |
| `littlefs.bin` | WebUI + configs — `0x3d0000` |
| `SHA256SUMS` | Checksums |
| `BUILD-INFO.txt` | Toolchain / versões |

Instruções completas: [../../docs/pt-BR/firmware-ts35.md](../../docs/pt-BR/firmware-ts35.md).

WebUI própria: [../../ui/README.pt-BR.md](../../ui/README.pt-BR.md) ·
[../../docs/pt-BR/interface-web.md](../../docs/pt-BR/interface-web.md).

Gravação rápida (Linux/macOS): `../../scripts/flash-ts35.sh /dev/ttyUSB0`.

> Não é um build oficial do FluidNC. Neste build o cartão SD fica desativado.
> Os configs publicados liberam os controles da tela; calibre o touch antes de
> confiar no JOG/ZERO. Os fins de curso são recuperáveis: a máquina para e o
> `$X` / UNLOCK permite voltar.
