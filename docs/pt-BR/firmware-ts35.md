# Firmware TS35 — gravação, primeiro boot e calibração do touch

[← Voltar ao README](../../README.pt-BR.md) · **🇧🇷 Português** · [English](../en/ts35-firmware.md)

Este é um **firmware FluidNC já compilado, com o módulo de tela `ts35` da
comunidade**, para **MKS DLC32 V2.1 (ESP32, 8 MB) + MKS TS35-R V2.0**.

Base: FluidNC com o módulo `ts35` do
[PR #1805](https://github.com/bdring/FluidNC/pull/1805), testado em bancada
exatamente nessa combinação de placa e tela.

> **Não é um build oficial do FluidNC.** O módulo `ts35` não foi aceito no
> repositório principal. Teste com a máquina sem ferramenta e o laser
> desconectado. Guarde um backup da flash original.

## Arquivos

| Arquivo | Uso |
|---|---|
| `ttc450-ts35-8mb.bin` | Imagem completa de 8 MB; use no **MKS Laser Tool** (mesmo procedimento do firmware original) |
| `ttc450-ts35-4mb.bin` | Imagem completa de 4 MB; use no **esptool** / Web Installer / scripts |
| `bootloader.bin` | Bootloader (offset `0x1000`) |
| `partitions.bin` | Tabela de partições FluidNC (offset `0x8000`) |
| `boot_app0.bin` | Boot selector (offset `0xe000`) |
| `firmware.bin` | Aplicação FluidNC + TS35 (offset `0x10000`) |
| `littlefs.bin` | LittleFS com WebUI + configs (offset `0x3d0000`) |
| `SHA256SUMS` | Checksums de todos os arquivos acima |
| `BUILD-INFO.txt` | Toolchain, versões e data do build |

Os endereços de gravação e os detalhes de build também estão em
[`source/BUILD.md`](../../source/BUILD.md).

## O que está pré-configurado

O LittleFS já contém:

- `config.yaml` → cópia da config **CNC + TS35**
- `config_cnc_ts35.yaml` → CNC/fresa + tela
- `config_laser_ts35.yaml` → laser + tela

No primeiro boot, o FluidNC usa `config.yaml` (CNC + TS35). Para trocar para
laser:

```text
$Config/Filename=config_laser_ts35.yaml
$Bye
```

Para voltar ao CNC, use `config.yaml` (o arquivo ativo no primeiro boot) ou
`config_cnc_ts35.yaml` (cópia de referência com o mesmo conteúdo):

```text
$Config/Filename=config_cnc_ts35.yaml
$Bye
```

**Importante:** edite o arquivo que está ativo. Se você nunca trocou, é o
`config.yaml`. Se trocou para `config_cnc_ts35.yaml`, edite esse. As mudanças em
um arquivo não afetam o outro até você trocar de config.

**Neste build, use somente as configs com `_ts35` no nome.** As configs
`config_cnc.yaml` / `config_laser.yaml` (sem a seção `ts35`) são para o FluidNC
oficial e deixam a tela apagada neste firmware.

## Gravação

### Opção 1 — MKS Laser Tool (Windows)

1. Abra o MKS Laser Tool.
2. Escolha **MKS ESP32 Download Tool**.
3. Selecione `ttc450-ts35-8mb.bin`.
4. Use as mesmas opções de SPI speed / flash size / baud que você usa para
   gravar o firmware original (flash size **8 MB**).
5. Clique em Start.

### Opção 2 — script do repositório (Linux/macOS)

```bash
./scripts/flash-ts35.sh /dev/ttyUSB0
```

### Opção 3 — esptool manual

```bash
esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 921600 erase_flash

esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 921600 \
  write_flash -z --flash-mode dio --flash-freq 80m --flash-size detect \
  0x0 firmware/ts35/ttc450-ts35-4mb.bin
```

A placa precisa estar alimentada com **24 V**; o USB sozinho não liga a DLC32.

Faça o backup da flash original antes. No Windows, use o `esptool.exe` do pacote
do FluidNC:

```bat
esptool.exe --chip esp32 --port COM3 --baud 460800 read_flash 0 0x800000 backup.bin
```

## Primeiro boot

1. A tela deve mostrar `FLUIDNC TS35` / `STARTING` e depois a página **DRO**.
2. O FluidNC sobe em modo AP:
   - rede: `FluidNC`
   - senha: `12345678`
   - endereço: <http://192.168.0.1/>
3. Configure o WiFi da oficina:

   ```text
   $Sta/SSID=SUA_REDE
   $Sta/Password=SUA_SENHA
   $WiFi/Mode=STA>AP
   $Bye
   ```

O modo `STA>AP` tenta entrar na sua rede e, se falhar, sobe o AP `FluidNC` como
fallback. O IP aparece no console e no roteador; o nome mDNS é
`http://fluidnc.local/`.

## Páginas da tela

- **DRO**: posição X/Y/Z, estado, feed, spindle, unidades.
- **JOG**: botões X/Y/Z, passo (0,01/0,1/1/10/100 mm) e velocidade
  (10/25/50/80/100%).
- **ZERO**: zera X/Y/Z/XYZ com `G10 L20 P0`.
- **CTRL**: Hold, Resume, Cancel Jog, overrides de feed/rapid, Home, Unlock,
  Reset.
- **INFO**: coordenadas raw do touch, calibração, estado modal, buffers, SD,
  contadores.
- Banner de alarme com botão de unlock.

Home, zero, unlock e reset pedem **dois toques** dentro de 3 segundos.

## Calibração do touch (importante)

Os configs do build usam `controls_enabled: true` com **JOG, ZERO, UNLOCK e
CLEAR ALARM** liberados. **HOME** e **soft reset** seguem desligados de
propósito. Antes de confiar que a tela move a máquina, confira se o toque cai
no botão certo; um touch descalibrado pode acionar o botão vizinho.

1. Na tela, toque na aba **INFO**.
2. Toque nos quatro cantos da área útil e anote os valores **raw X/Y** que
   aparecem na página INFO.
3. No arquivo **ativo** (no primeiro boot, `config.yaml`; senão, o
   `config_cnc_ts35.yaml`), ajuste:

   ```yaml
   ts35:
     touch_x_min: ...
     touch_x_max: ...
     touch_y_min: ...
     touch_y_max: ...
   ```

4. Se os eixos estiverem trocados ou espelhados, ajuste:

   ```yaml
   ts35:
     touch_swap_xy: true/false
     touch_invert_x: true/false
     touch_invert_y: true/false
   ```

5. Se o toque cair no botão errado, volte `controls_enabled` para `false`
   (somente leitura) e repita a calibração até acertar; depois volte para
   `true`:

   ```yaml
   ts35:
     controls_enabled: true   # false = painel somente leitura
   ```

6. Se quiser liberar home, unlock e reset pela tela:

   ```yaml
   ts35:
     allow_homing: true
     allow_unlock: true
     allow_soft_reset: true
     allow_alarm_clear: true
   ```

## Solução de problemas da tela

- **Tela preta, mas o FluidNC sobe na WiFi:** tente
  `backlight_active_low: false`; confira o cabo flat EXP1/EXP2; reduza
  `lcd_clock_hz` para `20000000`.
- **Cores invertidas:** `invert_display: true`.
- **Imagem com ruído/faixas:** reduza `lcd_clock_hz` para `20000000` ou
  `10000000`.
- **Toque espelhado:** ajuste `touch_invert_x` / `touch_invert_y`.
- **Toque trocado (X mexe no Y):** `touch_swap_xy: false`.
- **Toque não registra:** aumente ou reduza `touch_pressure_threshold`, e
  confira `touch_x_min/max`, `touch_y_min/max`.
- **A tela funciona, mas o toque está deslocado:** recalibre com os valores raw
  da página INFO.
- **A máquina liga em Alarm e o `$X` não limpa:** há um fim de curso acionado
  no boot. O FluidNC entra em `State::Critical` para hard limit e o `$X` só
  limpa `State::Alarm`, então use soft reset (Ctrl-X). Se o switch continuar
  pressionado o alarme volta, então primeiro afaste o eixo do batente na mão
  (os motores ficam desenergizados em Critical). Depois do homing o pull-off
  deixa a máquina fora dos switches; isso só acontece se você estacionar neles.
- **Erro "Ambiguous switch" no homing:** causado por `limit_all_pin`, que coloca
  o mesmo bit nas duas máscaras de limite. Use `limit_neg_pin` / `limit_pos_pin`
  por eixo, como nos configs do repo.

## Limitação: cartão SD

O módulo TS35 usa o barramento SPI do LCD (`gpio.18/19/23`). A DLC32 tem um
segundo SPI para o cartão SD (`gpio.12/13/14/15`), mas o FluidNC só tem uma
seção `spi:`. Neste build, a tela funciona e o **cartão SD fica desativado**.
Use a WebUI/LocalFS ou a rede para enviar arquivos.

Se você precisa dos dois, seria necessário adicionar um segundo barramento SPI
ao FluidNC (mudança de código, não incluída neste módulo).

## Atualização OTA

A partição OTA `app1` tem o mesmo tamanho da `app0` (1,8 MB) e este build cabe
nela, então a OTA funciona. Porém, **grave somente imagens deste mesmo build**.
Não misture com binários do FluidNC oficial — eles não têm o módulo `ts35` e a
tela fica apagada.

## Recuperação

Se algo der errado, restaure o backup de 8 MB:

```bash
esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 460800 \
  write_flash 0x0 backup/ttc450-stock-AAAAAMMDD-HHMMSS.bin
```

Ou use o MKS Laser Tool com o firmware original CNC/laser.
