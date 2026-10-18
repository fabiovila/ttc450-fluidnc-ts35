<!-- Language switcher -->
**English** · [🇧🇷 Português](#português)

# `ts35` module source and reproducible build

The files in this folder are the `ts35` module from the community PR
[#1805](https://github.com/bdring/FluidNC/pull/1805), from the
`thcasssio/FluidNC` fork, branch `feat/ts35-display-module`, commit
`d93a72b2edc2902b5114128bedcf9f953afc16ec`.

- `TS35Module.cpp/.h` — FluidNC channel, pages, touch, jog, zero, control.
- `TS35DisplayDriver.cpp/.h` — ST7796 + ADS7843E driver on the shared SPI bus.
- `TS35Model.cpp/.h` — status-report parser and command builder.

The module registers itself at the end of `TS35Module.cpp`:

```cpp
ConfigurableModuleFactory::InstanceBuilder<TS35Module> registration("ts35");
```

`platformio.ini` already includes `FluidNC/esp32/*.cpp` in the ESP32 build, so
nothing needs to be added there to compile these files. The `ts35:` section is
documented in `FluidNC/docs/config_items.yaml` (the PR added its 35 items).

## Rebuild

```bash
git clone --depth 1 --branch feat/ts35-display-module \
  https://github.com/thcasssio/FluidNC.git
cd FluidNC

# FluidNC's stdfs shim does not compile with the GCC 14 toolchain pulled in by
# platform espressif32 7.x. Pin 6.12.0 (Arduino core 2.0.17 + GCC 8.4.0).
python3 - <<'PY'
p = "platformio.ini"
s = open(p).read()
s = s.replace(
    "platform = https://github.com/platformio/platform-espressif32.git",
    "platform = platformio/espressif32@6.12.0")
open(p, "w").write(s)
PY

pio run -e wifi
pio run -e wifi -t buildfs
```

Outputs:

```text
.pio/build/wifi/bootloader.bin
.pio/build/wifi/partitions.bin
.pio/build/wifi/firmware.bin
.pio/build/wifi/littlefs.bin
```

To get a LittleFS image that already contains the TTC450 configs, copy
`config/config_cnc_ts35.yaml` and `config/config_laser_ts35.yaml` into
`FluidNC/data/`, copy the CNC one to `FluidNC/data/config.yaml`, and run
`pio run -e wifi -t buildfs` again.

## Flash offsets

| Offset | File |
|---|---|
| `0x1000` | `bootloader.bin` |
| `0x8000` | `partitions.bin` |
| `0xe000` | `boot_app0.bin` |
| `0x10000` | `firmware.bin` |
| `0x3d0000` | `littlefs.bin` |

`boot_app0.bin` comes from the official FluidNC bundle
(`common/boot_app0.bin`).

## SPI limitation

The module uses FluidNC's single `spi:` section. On the DLC32 the LCD is on
`gpio.18/19/23` and the SD card is on `gpio.12/13/14/15`, so the SD card is
disabled when the panel is used. Supporting both would require a second SPI bus
in FluidNC (a code change outside this module).

---

## Português

Os arquivos desta pasta são o módulo `ts35` do PR comunitário
[#1805](https://github.com/bdring/FluidNC/pull/1805), do fork
`thcasssio/FluidNC`, branch `feat/ts35-display-module`, commit
`d93a72b2edc2902b5114128bedcf9f953afc16ec`.

- `TS35Module.cpp/.h` — canal FluidNC, páginas, toque, jog, zero, controle.
- `TS35DisplayDriver.cpp/.h` — driver ST7796 + ADS7843E no SPI compartilhado.
- `TS35Model.cpp/.h` — parser dos relatórios de status e montagem dos comandos.

O módulo se registra sozinho no fim do `TS35Module.cpp`:

```cpp
ConfigurableModuleFactory::InstanceBuilder<TS35Module> registration("ts35");
```

O `platformio.ini` já inclui `FluidNC/esp32/*.cpp` no build do ESP32, então não
é preciso adicionar nada para compilar esses arquivos. A seção `ts35:` é
documentada em `FluidNC/docs/config_items.yaml` (o PR adicionou os 35 itens).

### Recompilar

```bash
git clone --depth 1 --branch feat/ts35-display-module \
  https://github.com/thcasssio/FluidNC.git
cd FluidNC

# O stdfs do FluidNC não compila com o GCC 14 do platform espressif32 7.x.
# Pinamos o 6.12.0 (Arduino core 2.0.17 + GCC 8.4.0).
python3 - <<'PY'
p = "platformio.ini"
s = open(p).read()
s = s.replace(
    "platform = https://github.com/platformio/platform-espressif32.git",
    "platform = platformio/espressif32@6.12.0")
open(p, "w").write(s)
PY

pio run -e wifi
pio run -e wifi -t buildfs
```

Saídas:

```text
.pio/build/wifi/bootloader.bin
.pio/build/wifi/partitions.bin
.pio/build/wifi/firmware.bin
.pio/build/wifi/littlefs.bin
```

Para o LittleFS já com as configs da TTC450, copie `config/config_cnc_ts35.yaml`
e `config/config_laser_ts35.yaml` para `FluidNC/data/`, copie a CNC para
`FluidNC/data/config.yaml` e rode `pio run -e wifi -t buildfs` de novo.

### Endereços de flash

| Offset | Arquivo |
|---|---|
| `0x1000` | `bootloader.bin` |
| `0x8000` | `partitions.bin` |
| `0xe000` | `boot_app0.bin` |
| `0x10000` | `firmware.bin` |
| `0x3d0000` | `littlefs.bin` |

O `boot_app0.bin` é o do pacote oficial do FluidNC
(`common/boot_app0.bin`).

### Limitação de SPI

O módulo usa a seção `spi:` única do FluidNC. Na DLC32, o LCD está em
`gpio.18/19/23` e o cartão SD em `gpio.12/13/14/15`; por isso o SD fica
desativado quando a tela é usada. Para ter os dois seria necessário um segundo
barramento SPI no FluidNC (mudança de código fora deste módulo).
