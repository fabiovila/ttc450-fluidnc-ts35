<!-- Seletor de idioma -->
[English](README.md) · **🇧🇷 Português**

# FluidNC + tela MKS TS35 para a TwoTrees TTC450

Firmware **FluidNC** já compilado, com suporte à tela **TS35** da comunidade,
para a **TwoTrees TTC450** (CNC/gravação a laser).

A TTC450 usa a controladora **MKS DLC32 V2.1** (ESP32, 8 MB de flash, WiFi
2,4 GHz) e a tela **MKS TS35-R V2.0** de 3,5" com touch resistivo (LCD ST7796 +
touch ADS7843E). O FluidNC oficial **não** suporta essa tela, porque ela é um
display SPI "burro", sem controlador próprio.

Este repositório empacota o módulo `ts35` da comunidade — enviado ao FluidNC
como [PR #1805](https://github.com/bdring/FluidNC/pull/1805) e testado
exatamente nessa combinação de placa e tela — em uma **imagem pronta para
gravar**, com configurações validadas, documentação bilíngue e a análise da
causa-raiz do problema de WiFi do firmware original.

> **Não é um build oficial do FluidNC.** O módulo `ts35` ainda não foi aceito
> no repositório principal. Grave com a máquina sem ferramenta e o laser
> desconectado. Guarde um backup completo da flash original.

---

## Por que isso existe

Dois problemas recorrentes na TTC450:

1. **Trocar entre CNC e laser exige regravar o firmware.** O procedimento
   oficial da TwoTrees apaga a flash inteira, incluindo a partição **NVS**,
   onde ficam SSID e senha do WiFi. Ou seja, toda troca zera o WiFi. Além
   disso, o firmware laser da TTC450 é de 2022 (V2.20) e tem bugs conhecidos de
   reconexão.
2. **O FluidNC, a evolução natural, não suporta a tela TS35.** Ele foi feito
   para a WebUI (celular/tablet/PC) e para pendants sem fio (M5Dial/CYD).

O FluidNC resolve (1) com **um firmware só e dois arquivos de configuração** —
`config_cnc.yaml` / `config_laser.yaml` — trocados com dois comandos e **sem
regravar**, então o WiFi continua configurado. Este repositório resolve (2)
entregando um firmware já compilado que inclui o módulo de tela `ts35`.

## O que tem de útil aqui

- **Firmware já compilado** para DLC32 V2.1 + TS35-R V2.0 — sem precisar
  montar toolchain: `firmware/ts35/ttc450-ts35-8mb.bin` (MKS Laser Tool) e
  `ttc450-ts35-4mb.bin` (esptool). Veja [`firmware/ts35`](firmware/ts35/).
- **Configs testadas** para CNC e laser, com e sem a tela TS35
  ([`config/`](config/)).
- **Guia de calibração do touch** (a tela é resistiva; precisa calibrar antes
  de habilitar os controles na tela).
- **Análise da causa-raiz** do WiFi do firmware original (NVS apagada) e um
  contorno com comandos `$ESP...` que funciona sem regravar.
- **Inventário completo** de hardware e pinagem da TTC450 + DLC32 V2.1.
- **Build reproduzível**: código-fonte, versão fixada do PlatformIO e os
  endereços exatos ([`source/BUILD.md`](source/BUILD.md)).
- **Assets de release** automáticos a cada tag `v*` via GitHub Actions.

## Início rápido (firmware TS35)

Faça o backup da flash original primeiro (a placa precisa estar ligada na
fonte de **24 V** — o USB sozinho não alimenta a DLC32):

```bash
./scripts/backup-flash.sh /dev/ttyUSB0
```

Grave o build TS35:

```bash
./scripts/flash-ts35.sh /dev/ttyUSB0
```

No Windows, use o **MKS Laser Tool → MKS ESP32 Download Tool** com
`firmware/ts35/ttc450-ts35-8mb.bin` e **flash size 8 MB** (mesmo procedimento
do firmware original).

Primeiro boot:

1. A tela deve mostrar `FLUIDNC TS35` / `STARTING` e depois a página **DRO**.
2. O FluidNC sobe em modo AP: rede **`FluidNC`**, senha **`12345678`**,
   `http://192.168.0.1/`.
3. Configure o WiFi da oficina:

   ```text
   $Sta/SSID=SUA_REDE
   $Sta/Password=SUA_SENHA
   $WiFi/Mode=STA>AP
   $Bye
   ```

4. A tela inicia em **modo somente leitura** (`controls_enabled: false`). Vá
   na página **INFO**, leia os valores raw do touch e calibre antes de
   habilitar os controles. Procedimento completo:
   [docs/pt-BR/firmware-ts35.md](docs/pt-BR/firmware-ts35.md) ·
   [docs/en/ts35-firmware.md](docs/en/ts35-firmware.md).

## Compatibilidade

| Item | Requisito |
|---|---|
| Máquina | TwoTrees TTC450 (ou qualquer máquina com a mesma placa/tela) |
| Controladora | **MKS DLC32 V2.1**, ESP32, **8 MB de flash** |
| Tela | **MKS TS35-R V2.0** — LCD ST7796 + touch ADS7843E |
| Alimentação | 24 V durante a gravação (o USB sozinho não basta) |
| Computador | Windows (MKS Laser Tool) ou Linux/macOS (esptool) |

**Não** funciona com outras telas (por exemplo revisões da TS35 com ILI9488)
nem com placas DLC32 de 4 MB.

## Limitações conhecidas

- O módulo `ts35` **não foi aceito** no FluidNC oficial; este é um build da
  comunidade.
- **O cartão SD fica desativado** no build TS35. A tela usa o SPI do LCD
  (`gpio.18/19/23`) e o FluidNC expõe uma única seção `spi:`, enquanto o SD da
  DLC32 está em outro barramento (`gpio.12/13/14/15`).
- A tela é resistiva e **precisa ser calibrada** em cada unidade.
- Atualização OTA deve usar somente imagens deste mesmo build; não misture com
  binários do FluidNC oficial.
- Sem testes automatizados. O PR original foi testado em bancada na mesma
  placa + tela, mas teste sempre com a máquina sem ferramenta.

## Estrutura do repositório

| Caminho | Conteúdo |
|---|---|
| [`firmware/ts35/`](firmware/ts35/) | Imagens de firmware prontas, checksums, informações de build |
| [`source/`](source/) | Código do módulo `ts35` + guia de build reproduzível |
| [`config/`](config/) | Configs YAML do FluidNC (CNC / laser, com / sem TS35) |
| [`scripts/`](scripts/) | Scripts de backup, gravação e empacotamento de release |
| [`docs/en/`](docs/en/) | Documentação em inglês |
| [`docs/pt-BR/`](docs/pt-BR/) | Documentação em português |

## Documentação

| Tema | Português | English |
|---|---|---|
| Inventário de hardware e pinagem | [hardware.md](docs/pt-BR/hardware.md) | [hardware.md](docs/en/hardware.md) |
| Firmware original e o bug do WiFi | [firmware-original.md](docs/pt-BR/firmware-original.md) | [stock-firmware.md](docs/en/stock-firmware.md) |
| FluidNC na TTC450 | [fluidnc.md](docs/pt-BR/fluidnc.md) | [fluidnc.md](docs/en/fluidnc.md) |
| Firmware TS35, gravação e touch | [firmware-ts35.md](docs/pt-BR/firmware-ts35.md) | [ts35-firmware.md](docs/en/ts35-firmware.md) |
| Segurança e referências | [seguranca.md](docs/pt-BR/seguranca.md) | [safety.md](docs/en/safety.md) |

## Créditos

- [FluidNC](https://github.com/bdring/FluidNC), de Mitch Bradley e da
  comunidade FluidNC — GPLv3.
- O módulo `ts35`: [FluidNC PR #1805](https://github.com/bdring/FluidNC/pull/1805),
  de [thcasssio](https://github.com/thcasssio) (branch
  `feat/ts35-display-module`).
- Configs base da TTC450: [Diode Laser Wiki](https://diode-laser-wiki.com/documentation/twotrees-ttc450-cnc-machine/).
- Referências do firmware original: wiki da TwoTrees, [MKS-DLC32](https://github.com/makerbase-mks/MKS-DLC32).

## Licença

O firmware, o diretório `source/` e qualquer material derivado do FluidNC estão
sob a **GNU General Public License v3.0 ou posterior** — veja [LICENSE](LICENSE).
A documentação e as configurações deste repositório são distribuídas nos mesmos
termos, salvo indicação em contrário.

## Aviso

Este software controla máquinas que podem causar ferimentos e incêndio. Use por
sua conta e risco. Trabalho com laser exige óculos adequados, exaustão e
supervisão. Mantenha sempre um backup completo da flash para poder voltar ao
firmware original.
