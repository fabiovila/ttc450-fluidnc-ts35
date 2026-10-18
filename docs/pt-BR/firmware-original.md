# Firmware original e o bug do WiFi no modo laser

[← Voltar ao README](../../README.pt-BR.md) · **🇧🇷 Português** · [English](../en/stock-firmware.md)

## Inventário do firmware original

| Modo | Arquivo | Versão / data | Tamanho do app |
|---|---|---|---|
| CNC | `V2.3.0_H35_2023080501_N_CNC_TTC450.bin` | V2.3 (8M.H35.20230803) | ~1,97 MB |
| Laser | `V2.20_H35_2022_1101_N_ZX_002.bin` | V2.20 (8M.H35.20221101) | ~1,70 MB |

As duas imagens têm **8 MB** e a mesma tabela de partições:

| Partição | Offset | Tamanho |
|---|---|---|
| `nvs` | `0x9000` | 20 KB |
| `otadata` | `0xe000` | 8 KB |
| `app0` | `0x10000` | **7 MB** |
| `spiffs` | `0x710000` | 0,88 MB |

Consequência: o app ocupa só ~2 MB, mas a partição tem 7 MB. É por isso que o
firmware MKS consegue carregar a interface gráfica da tela e a WebUI juntos. O
FluidNC usa uma tabela de partições de 4 MB (app de 1,8 MB + LittleFS), que
cabe tranquilo nos 8 MB.

Downloads oficiais:

- CNC: <https://wiki.twotrees3d.com/yingwen/450/cnc-firmware.zip>
- Laser: <https://wiki.twotrees3d.com/yingwen/450/laser-firmware.zip>
- Configs FluidNC prontas (Diode Laser Wiki): <https://diode-laser-wiki.com/wp-content/uploads/2024/02/TTC450_FluidNC.zip>

## Por que o WiFi do modo laser falha

### Causa principal

O roteiro oficial da TwoTrees para trocar para o modo laser é:

1. remover a tela e a tampa;
2. ligar o cabo do laser na porta **S-TTL-V**;
3. abrir o **MKS Laser Tool**;
4. **apagar o firmware**;
5. gravar o firmware laser;
6. importar a configuração no LaserGRBL.

O passo 4 apaga a flash inteira — incluindo a partição **NVS**, que é
exatamente onde o firmware guarda SSID, senha e modo do WiFi. Em outras
palavras: **toda troca de firmware zera o WiFi**. Além disso, o firmware laser
antigo (V2.20 / 2022) ainda tem o bug conhecido de não reconectar sozinho após
o boot.

Isso não é teoria: nos dois arquivos `.bin` oficiais, a região da NVS
(`0x9000`–`0xDFFF`) está **toda em `0xFF`**. O MKS Laser Tool grava o arquivo
de 8 MB inteiro, então ele sobrescreve a NVS com `0xFF` a cada gravação.

### Causas secundárias

- **Rede de 5 GHz**: o ESP32 só trabalha em 2,4 GHz. Se o celular/PC está em
  uma rede 5 GHz, ele não vê a placa.
- **Teclado da tela**: a tela de WiFi da TS35 não tem todos os caracteres; se a
  senha tem símbolos, pode ser impossível digitá-la.
- **EMI**: o spindle de 500 W e a fonte do laser geram ruído. O WiFi pode cair
  durante o trabalho mesmo com a configuração certa. Cabo blindado, ferrite e
  separação das fontes ajudam.
- **IP**: no modo AP o endereço é **192.168.4.1** (SSID tipo `MKS_DLC32`, senha
  `12345678`). No modo STA, o IP aparece na tela ou no roteador.

### Contorno rápido no firmware original (sem regravar)

Conecte por USB (com a máquina ligada nos 24 V), abra o console do UGS, Candle,
LaserGRBL ou FluidTerm e envie, **uma linha por vez**, esperando cada reinício
terminar:

```text
$ESP444=RESTART
$ESP115=ON
$ESP100=SUA_REDE
$ESP101=SUA_SENHA
$ESP110=STA
$ESP444=RESTART
$ESP115=ON
```

Depois pegue o IP na tela ou no roteador. O **MKS Laser Tool → WiFi
Configuration Tool** faz o mesmo por interface gráfica.

Isso resolve o momento, mas **não resolve a troca de firmware**: na próxima
gravação a NVS é apagada de novo. É remendo, não solução.

## A solução de verdade

Use um firmware único com arquivos de configuração alternáveis, para que nada
precise ser apagado ao trocar de modo. O FluidNC faz exatamente isso — veja
[FluidNC na TTC450](fluidnc.md).
