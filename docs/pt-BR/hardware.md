# Inventário de hardware — TwoTrees TTC450 + MKS DLC32 V2.1

[← Voltar ao README](../../README.pt-BR.md) · **🇧🇷 Português** · [English](../en/hardware.md)

Levantamento feito a partir das imagens do firmware original, da documentação
da MKS DLC32 V2.1, do wiki da TwoTrees e das configurações públicas do FluidNC
para a TTC450.

## Controladora

| Item | Especificação |
|---|---|
| Controladora | **MKS DLC32 V2.1** (dentro da caixa de controle da TTC450) |
| MCU | **ESP32-WROOM-32U**, dual-core 240 MHz, 520 KB SRAM |
| Flash | **8 MB** (8192 KB) |
| WiFi | somente 2,4 GHz b/g/n (não vê redes de 5 GHz); Bluetooth 4.2 (não usa WiFi e BT ao mesmo tempo) |
| USB | conversor **CH340**; a placa **não é alimentada pelo USB** |
| Alimentação | 12–24 V, 5 A, conector DC 5,5 × 2,1 mm, fusível de 10 A |
| Drivers de passo | 3 × **A4988** em soquete (X, Y, Z) + 1 soquete livre (**A**) |
| Microstep | selecionável por DIP switch; padrão 1/16 |
| Motores | NEMA 17, fuso T8 passo 4 mm → **800 steps/mm** (`$100`–`$102` = 800) |
| Fins de curso | X = `gpio.36`, Y = `gpio.35`, Z = `gpio.34` (entradas, JST XH 3 pinos) |
| Probe / touch plate | `gpio.22` (JST SM 2,5) |
| Porta laser | **TTL 3 pinos**: V = Vin (12/24 V), G = GND, S = PWM **0–5 V**, 1–10 kHz |
| Porta CNC / spindle | **2 pinos**: GND + PWM **0–12/24 V**, até 2 A |
| Spindle 500 W | ligado por **relé**; a rotação **não** é controlada por software (só o potenciômetro da fonte) |
| Tela | **TS35 / TS35-R** 3,5" 480×320, touch resistivo, SPI direto (sem controlador próprio) |
| microSD | barramento SPI (`gpio.12/13/14/15`) |
| I2C | `gpio.0` (SDA) / `gpio.4` (SCL) |
| Área de trabalho | **460 × 460 × 80 mm** |
| Vref dos drivers | ~0,96 V (conferir com multímetro) |

## Pinagem da DLC32 V2.1 (TTC450)

| Função | Pino |
|---|---|
| X step / dir | `I2SO.1` / `I2SO.2` |
| Y step / dir | `I2SO.5` / `I2SO.6` |
| Z step / dir | `I2SO.3` / `I2SO.4` |
| Enable compartilhado | `I2SO.0` |
| I2S (BCK / WS / DATA) | `gpio.16` / `gpio.17` / `gpio.21` |
| SD SPI | MISO `gpio.12`, MOSI `gpio.13`, SCK `gpio.14`, CS `gpio.15` |
| LCD SPI | SCK `gpio.18`, MISO `gpio.19`, MOSI `gpio.23` |
| LCD CS / DC / RST / backlight | `gpio.25` / `gpio.33` / `gpio.27` / `gpio.5` |
| Touch CS | `gpio.26` |
| Laser / spindle PWM | `gpio.32` |
| Probe | `gpio.22` |
| Fins de curso | X `gpio.36`, Y `gpio.35`, Z `gpio.34` |

## Observações

- O **LCD e o cartão SD usam barramentos SPI diferentes** na DLC32. Como o
  FluidNC expõe uma única seção `spi:`, habilitar a tela TS35 desativa o cartão
  SD. Veja [firmware-ts35.md](firmware-ts35.md).
- O datasheet da tela chama o pino do backlight de `LCD_EN`; em algumas
  revisões o backlight é ativo em nível baixo, em outras em nível alto. O
  módulo TS35 expõe a opção `backlight_active_low` para isso.
- Os **drivers A4988 são em soquete**, então podem ser trocados ou
  atualizados, mas o Vref de fábrica é conservador; ajuste apenas se souber o
  que está fazendo.

## Referências

- Wiki da TwoTrees TTC450 — <https://wiki.twotrees3d.com/>
- Repositório da MKS DLC32 — <https://github.com/makerbase-mks/MKS-DLC32>
- Página da DLC32 no FluidNC — <http://wiki.fluidnc.com/en/hardware/3rd-party/MKS_DLC32>
- Página da TTC450 no Diode Laser Wiki — <https://diode-laser-wiki.com/documentation/twotrees-ttc450-cnc-machine/>
