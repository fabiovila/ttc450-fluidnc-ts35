# FluidNC na TTC450

[← Voltar ao README](../../README.pt-BR.md) · **🇧🇷 Português** · [English](../en/fluidnc.md)

## O FluidNC serve na TTC450?

**Sim.** A MKS DLC32 V2.1 é uma placa oficialmente suportada, e já existem
configurações prontas para a TTC450 (as deste repositório são baseadas nelas).

### O que funciona

- 3 eixos X/Y/Z com os mesmos drivers A4988 e 800 steps/mm.
- Fins de curso X/Y/Z e entrada de probe.
- Cartão microSD (quando a tela TS35 **não** está habilitada).
- Laser na porta TTL (`gpio.32`).
- Relé do spindle na porta CNC (`gpio.32` no modo CNC).
- WiFi com **STA + AP de fallback** (`STA>AP`), reconexão automática,
  `fluidnc.local` (mDNS), WebUI, Telnet, WebSocket.
- Atualização OTA.
- **Dois arquivos de config**: `config_cnc.yaml` e `config_laser.yaml`,
  trocados com `$Config/Filename=...` + `$Bye`, sem regravar firmware.
- Macros, homing, overrides, etc.

### O que não funciona

- **A tela TS35 no FluidNC oficial.** O FluidNC não suporta as telas que vêm
  com a DLC32. Os desenvolvedores já disseram várias vezes que não vão
  suportar (issue #759): é um painel SPI "burro", sem controlador próprio, e o
  código da MKS é grande e específico dessa placa. O FluidNC prefere displays
  com controlador integrado, ligados por UART ou sem fio.
- **Pendant oficial**: M5Dial ou CYD Dial, que são sem fio. Não é plug-and-play
  na DLC32, mas é o caminho suportado para ter controle físico.

### E a tela?

Existe um PR experimental no FluidNC — o **#1805** (agosto/2026) — que adiciona
um módulo `ts35`:

- Testado em bancada em **MKS DLC32 V2.1 + TS35-R V2.0** (ST7796 + ADS7843E).
- Páginas: DRO, JOG, ZERO, CONTROL e INFO.
- **Não foi aceito** no FluidNC oficial.
- A tela usa o barramento SPI do LCD (`gpio.18/19/23/25/26/27/33`), enquanto o
  cartão SD usa outro SPI (`gpio.12/13/14/15`). O FluidNC tem uma única seção
  `spi:`, então usar a tela significa abrir mão do SD (ou adaptar o FluidNC).
- Só funciona se a tela for exatamente **TS35-R V2.0 (ST7796 + ADS7843E)**.

Este repositório traz um **firmware já compilado** para essa combinação exata —
veja [Firmware TS35, gravação e touch](firmware-ts35.md). Os configs liberam
JOG, ZERO, UNLOCK e CLEAR ALARM na tela, mas mantêm HOME e soft reset
desligados; se o toque estiver descalibrado, use `controls_enabled: false`.

Para identificar uma tela, abra a caixa de controle e veja a etiqueta/traseira
do display. Procure "TS35-R V2.0" ou os chips **ST7796** (LCD) e **ADS7843E**
(touch). O nome `H35` do firmware original só indica "tela de 3,5 polegadas" e
não identifica o controlador.

## Matriz de decisão

| Opção | Vantagens | Desvantagens |
|---|---|---|
| **Continuar no firmware MKS** e só consertar o WiFi | Grátis, mantém a tela, mantém o fluxo atual | Precisa regravar e reconfigurar o WiFi a cada troca; firmware laser antigo; bugs de reconexão |
| **FluidNC + WebUI no celular/tablet** | WiFi estável, um firmware só, troca CNC/laser por config, OTA, macros | Perde a tela TS35; precisa de celular/tablet/PC por perto |
| **FluidNC + build TS35 já compilado** (este repo) | Mantém a tela e ganha o FluidNC; imagens prontas e configs pré-carregadas | Não oficial; só TS35-R V2.0; **cartão SD desativado**; sem testes automatizados |
| **FluidNC + pendant M5Dial/CYD** | Controle físico oficial, sem fio, suportado | Custo extra; não é a tela original |

## Passo a passo para migrar

### 1. Backup primeiro

A placa precisa estar ligada na fonte de **24 V** (o USB sozinho não alimenta a
DLC32). Conecte o USB e rode:

```bash
./scripts/backup-flash.sh /dev/ttyUSB0
```

Ou, manualmente:

```bash
python3 -m esptool --chip esp32 --port /dev/ttyUSB0 --baud 460800 \
  read_flash 0x000000 0x800000 backup/ttc450-stock.bin
```

Guarde o `.bin` e o checksum. Ele contém firmware, NVS e SPIFFS originais.

Anote também:

- versão da placa (deve ser **V2.1**);
- posição dos cabos dos motores e fins de curso (fotos);
- os valores de `$$` no firmware original, principalmente `$100`, `$101`,
  `$102`, `$110`, `$111`, `$112`, `$120`, `$121`, `$122`.

### 2. Gravar o FluidNC

**Opção A — Web Installer (mais fácil, Chrome/Edge):**

1. Abra <https://installer.fluidnc.com/>.
2. Conecte a placa com 24 V + USB.
3. Escolha **FluidNC → ESP32 → WiFi**.
4. Se pedir, entre em boot mode (segure BOOT, aperte EN/RST e solte).
5. Instale.

> Isso instala o **FluidNC oficial, sem suporte à TS35**. Use só se não precisar
> da tela.

**Opção B — script deste repositório (Linux/macOS):**

```bash
./scripts/flash-fluidnc.sh /dev/ttyUSB0
```

O script baixa o FluidNC v4.1.1, apaga a flash e grava bootloader, tabela de
partições, app e LittleFS. Confirme a porta (`/dev/ttyUSB0` ou `/dev/ttyACM0`).

**Opção C — Windows, pelo pacote oficial:**

1. Baixe `fluidnc-v4.1.1-win64.zip` em
   <https://github.com/bdring/FluidNC/releases>.
2. Extraia.
3. Rode `erase.bat`.
4. Rode `install-wifi.bat`.

**Opção D — build TS35 já compilado (este repo):**

Use esta opção se quiser manter o LCD funcionando. O build já está compilado em
`firmware/ts35/` e as configs já estão no LittleFS.

```bash
./scripts/flash-ts35.sh /dev/ttyUSB0
```

No Windows, use o MKS Laser Tool com `firmware/ts35/ttc450-ts35-8mb.bin`
(mesmo procedimento do firmware original, flash size 8 MB). Leia
[firmware-ts35.md](firmware-ts35.md) antes: a tela inicia em modo somente
leitura e o **cartão SD fica desativado** nesse build.

### 3. Primeiro acesso

1. A placa sobe em modo AP: rede **`FluidNC`**, senha **`12345678`**, endereço
   **`http://192.168.0.1/`**.
2. Abra a WebUI.
3. Envie os dois arquivos para o **LocalFS**:
   - `config/config_cnc.yaml`
   - `config/config_laser.yaml`

   Se usou o **build TS35**, pule este passo: as configs `config_cnc_ts35.yaml`
   e `config_laser_ts35.yaml` já estão gravadas no LittleFS, e o `config.yaml`
   já aponta para CNC + TS35.

4. No console (aba Terminal da WebUI ou FluidTerm), escolha o modo CNC:

   ```text
   $Config/Filename=config_cnc.yaml
   $Bye
   ```

5. Configure o WiFi da oficina:

   ```text
   $Sta/SSID=SUA_REDE
   $Sta/Password=SUA_SENHA
   $WiFi/Mode=STA>AP
   $Bye
   ```

O modo `STA>AP` tenta entrar na sua rede e, se não conseguir, sobe o AP
`FluidNC` como fallback. O IP aparece no console e no roteador; o nome mDNS é
`http://fluidnc.local/`.

### 4. Testes com a máquina

Com a máquina livre e sem ferramenta:

```text
$I                 # versão, placa, modo WiFi
$$                 # configurações (compatibilidade GRBL)
$H                 # homing (Z primeiro, depois X/Y)
$Limits            # estado dos fins de curso
$J=G91 G21 X10 F500
$J=G91 G21 X-10 F500
```

- Confira se X/Y se movem na direção certa. Se não, inverta o `:low` do
  `direction_pin` no YAML.
- Confira o probe com `G38.2 Z-80 F100` (cuidado, a ponta desce).
- Confira o relé do spindle: `M3 S12000` liga, `M5` desliga. O relé de 24 V
  fecha acima de ~12 V; use sempre `S12000` para ligar com segurança.
- Confira o laser: `M3 S10` (potência baixa), `M5`. Nunca ligue o laser sem
  óculos e sem conhecer o foco.

### 5. Trocar entre CNC e laser

```text
$Config/Filename=config_laser.yaml
$Bye
```

e, para voltar:

```text
$Config/Filename=config_cnc.yaml
$Bye
```

A troca de config **não** troca o cabo físico. Desligue a máquina antes de
desconectar o spindle e conectar o módulo laser na porta **TTL de 3 pinos**
(S-TTL-V), ou vice-versa. O `gpio.32` é o mesmo, mas a porta e o nível de
tensão são diferentes.

Se estiver usando o **build TS35**, troque entre `config_laser_ts35.yaml` e
`config_cnc_ts35.yaml` (ou `config.yaml`, a cópia CNC ativa no primeiro boot).
As configs sem `_ts35` deixam a tela apagada nesse firmware.

## Arquivos de configuração deste repositório

| Arquivo | Uso |
|---|---|
| `config/config_cnc.yaml` | Modo CNC/fresa: spindle por relé na porta CNC, `S0`–`S12000` |
| `config/config_laser.yaml` | Modo laser: TTL 0–5 V, `S0`–`S1000` |
| `config/config_cnc_ts35.yaml` | CNC/fresa + tela TS35 (SPI do LCD; SD desativado) |
| `config/config_laser_ts35.yaml` | Laser + tela TS35 (SPI do LCD; SD desativado) |

As configs **sem** TS35 passam no validador oficial do FluidNC v4.1.1:

```text
OK: config_cnc.yaml
OK: config_laser.yaml
```

As configs com TS35 usam a seção `ts35` do PR #1805. O validador oficial ainda
não conhece essa seção, então os campos foram conferidos contra os
`handler.item()` do módulo e o firmware foi compilado com sucesso
(`Flash: 93,1%`, 1.830.957 de 1.966.080 bytes).

Observações:

- `idle_ms` está em **255 ms** (a config pública usava 25 ms). 25 ms desliga os
  motores quase imediatamente e o Z pode cair entre comandos. Volte para 25 se
  preferir o comportamento original.
- `max_travel_mm` usa **460 mm** (área oficial da TTC450). A config pública
  usava 450; com `soft_limits: false` isso não limita o movimento.
- `PWM` (CNC) e `Laser` são seções de spindle diferentes. O `gpio.32` é o
  mesmo; a diferença é a porta física e a escala.
- O WiFi **não** fica no YAML. No FluidNC ele é configurado por comandos
  `$Sta/...`, `$AP/...` e `$WiFi/Mode=...`.
