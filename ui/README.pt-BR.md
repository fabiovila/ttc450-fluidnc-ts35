<!-- Seletor de idioma -->
[English](README.md) · **🇧🇷 Português**

# Interface web própria (TTC450)

Esta pasta contém a interface web que substitui a WebUI oficial (ESP3D) no
build FluidNC + TS35 da TTC450. A fonte editável é o
[`index.html`](index.html); o arquivo servido pela controladora é a versão
compactada, [`index.html.gz`](index.html.gz).

## Por que

A WebUI oficial não configura o WebSocket porque o `$I` do FluidNC não traz a
linha `[ESP...]` que ela espera; a porta 81 fica fechada e o Terminal/botões não
funcionam. O WebSocket do firmware, porém, funciona na **porta 80**:

- `ws://<ip-da-máquina>/` com subprotocolo `arduino`;
- recebe `currentID:N`, status `<...>` e `[GC:...]`;
- comandos: `/command?commandText=...&PAGEID=N`;
- consultas: `/command?plain=...`.

A página usa esse protocolo e não depende da WebUI oficial.

## Arquivos

| Arquivo | Enviar para o LittleFS? | Uso |
|---|---|---|
| `index.html.gz` | **Sim, na raiz** | Página publicada (já compactada) |
| `help-en.html` | **Sim, na raiz** | Manual em inglês (a aba Ajuda carrega este arquivo) |
| `macros.json` | Opcional | Macros prontas; se faltar, a página usa os padrões internos |
| `favicon.ico` | Opcional | Ícone da aba; 404 não quebra a página |
| `index.html` | Não | Fonte para editar; gere `index.html.gz` depois |
| `webui-original.html.gz` | Opcional | Backup da WebUI original; para restaurar, envie como `index.html.gz` |
| `README.md`, `README.pt-BR.md`, `COMECE-AQUI.txt`, `SHA256SUMS` | Não | Documentação e verificação |

Os **configs da máquina** (`config.yaml`, `config_cnc_ts35.yaml`,
`config_laser_ts35.yaml`) e os arquivos de laser (`*.nc`) são separados da
página web. Eles já vêm no `littlefs.bin` do build.

## Instalar ou atualizar pela WiFi

A página usa o endpoint `/files` do FluidNC. Troque `<ip-da-máquina>` pelo
endereço da placa (por exemplo `192.168.15.77`):

```bash
HOST=http://192.168.15.77

sz=$(wc -c < index.html.gz)
curl -F 'path=/' \
     -F "/index.html.gzS=$sz" \
     -F 'myfile[]=@index.html.gz;filename=/index.html.gz' \
     "$HOST/files"

sz=$(wc -c < help-en.html)
curl -F 'path=/' \
     -F "/help-en.htmlS=$sz" \
     -F 'myfile[]=@help-en.html;filename=/help-en.html' \
     "$HOST/files"
```

Arquivos opcionais:

```bash
sz=$(wc -c < macros.json)
curl -F 'path=/' -F "/macros.jsonS=$sz" \
     -F 'myfile[]=@macros.json;filename=/macros.json' "$HOST/files"

sz=$(wc -c < favicon.ico)
curl -F 'path=/' -F "/favicon.icoS=$sz" \
     -F 'myfile[]=@favicon.ico;filename=/favicon.ico' "$HOST/files"
```

Depois recarregue a página com **Ctrl+F5**. **Não** envie `index.html` no lugar
de `index.html.gz`.

Também dá para usar a WebUI oficial: **Files / LocalFS** → envie os mesmos
arquivos para `/`.

## Gerar o gzip novamente

Depois de editar `index.html`:

```bash
gzip -9 -c index.html > index.html.gz
sha256sum index.html index.html.gz help-en.html macros.json favicon.ico \
  webui-original.html.gz > SHA256SUMS
sha256sum -c SHA256SUMS
```

## Regerar a imagem LittleFS

Copie somente os arquivos publicados para a pasta `data/` do FluidNC e gere o
filesystem:

```bash
cp ui/index.html.gz ui/help-en.html ui/macros.json ui/favicon.ico \
   <FluidNC>/FluidNC/data/
cd <FluidNC>
pio run -e wifi -t buildfs
```

O build publicado já tem esses arquivos no `littlefs.bin`. O `buildfs` apaga o
`.pio/build/wifi/firmware.bin`, então compile a aplicação primeiro e copie o
`firmware.bin` para fora se estiver regerando os dois.

## Recursos

- Dashboard com DRO, WCO, feed/spindle, overrides, pinos, estado, WiFi,
  LittleFS, firmware, eventos e ações rápidas.
- **Controle** (genérico, funciona nos dois modos): jog, zero, home, clear
  alarm, motores off, MDI, overrides de feed/rapid e macros genéricas.
- **CNC** (exclusivo do modo CNC): spindle/relé, S12000/S6000, coolant,
  override do spindle, probe, macros CNC e diagnóstico (PWM, speed map,
  `off_on_alarm`, hard/soft limits, MaxSpindleSpeed).
- **Laser** (exclusivo do modo laser): potências 1/5/10/25/50/100%, pulso,
  contínuo, OFF, diagnóstico, checklist e teste de PWM 50%. Os botões usam
  `G1 F100 M3 S...` via `$LocalFS/Run`; **M3 sozinho é zerado no modo laser**
  (é por isso que o LightBurn funciona e um `M3 S50` isolado não).
  **Toggle M3 fixo / M4 dinâmico:** M3 é potência constante; M4 é potência
  proporcional à velocidade e precisa de movimento (o pulso M4 faz uma linha
  curta em X; "ligar contínuo" em M4 é bloqueado).
- **Ordem e gate:** menu **Dashboard → Controle → CNC → Laser → Arquivos →
  Configurações → Console → Macros → Câmera → Tablet → Ajuda → Sobre**. No modo
  laser, a página CNC inteira fica `inert`/bloqueada; no modo CNC, a Laser
  inteira. O Controle nunca é bloqueado. A troca fica no Dashboard (Modo da
  máquina) ou no gate. Macros têm campo de modo; arquivos/console avisam; M5
  sempre permitido.
- **Ajuda/manual wiki** com 17 seções, índice, busca, glossário, comandos,
  telas, modos CNC ↔ laser, M3/M4 e troubleshooting; botão Imprimir. Manual EN
  separado (`help-en.html`) e UI bilíngue com detecção pelo navegador.
- Arquivos: pastas, upload, download, ver, renomear, apagar, rodar `.nc`, usar
  YAML como config; configs/UI/macros protegidos.
- Configurações: `$Settings/List` editável, WiFi, `$Config/Dump`,
  `$Firmware/Info`, OTA (somente mesmo build), reiniciar, relatórios e
  preferências.
- Console, macros, câmera, tablet e sobre.

## Idioma (i18n)

- Detecção: `navigator.languages` — se houver qualquer `pt-*`, usa **português**;
  caso contrário, **inglês**. A escolha fica em `localStorage` (`ttc450.lang`).
- Botão discreto **EN/PT** no header; clique alterna e salva. `?lang=pt` ou
  `?lang=en` na URL força o idioma (útil para testar).
- Todos os textos estáticos e dinâmicos da UI passam por um dicionário PT→EN +
  `MutationObserver` (toasts, confirmações, settings, macros, arquivos etc.).
- O manual PT fica embutido no `index.html`; o manual EN é **`help-en.html`** e é
  carregado na aba Ajuda quando o idioma é inglês. Se o arquivo faltar, ele cai
  no manual PT.
- Ao publicar, envie `help-en.html` junto com `index.html.gz`.

## ConfigAlarm

Se o último reset foi um **panic**, o FluidNC sobe com `Default (Test Drive)` e
`State 10 (ConfigAlarm)`. Nesse estado o G-code é bloqueado (`M3`/`M5` não
executam). Um reboot limpo (`$Bye`/botão Reiniciar) carrega o YAML normal. A UI
mostra um banner com botão de reinício.

## Restaurar a WebUI original

```bash
sz=$(wc -c < webui-original.html.gz)
curl -F 'path=/' \
     -F "/index.html.gzS=$sz" \
     -F 'myfile[]=@webui-original.html.gz;filename=/index.html.gz' \
     'http://192.168.15.77/files'
```

Recarregue com Ctrl+F5.

## Segurança

Esta página **não tem autenticação**. Use somente em rede local confiável e
nunca exponha a controladora diretamente à internet. Ela não carrega scripts de
CDN, analytics nem credenciais; os únicos links externos são a documentação do
FluidNC, da TwoTrees e do Diode Laser Wiki.

## Limitações

- A página não substitui um sender de G-code para trabalhos grandes; use
  LightBurn/LaserGRBL e mande o `.nc`.
- O laser continua ligado até um `M5`; fechar a página não desliga.
- `off_on_alarm` está `false` na config laser atual; um alarme não corta o laser
  automaticamente. O botão DESLIGAR é a proteção imediata.
- Overrides usam caracteres de tempo real; o firmware pode registrar um erro no
  console, mas o override muda.
- A troca CNC/laser reinicia o controlador, mas não troca o cabo físico.

## Checksums

```bash
sha256sum -c SHA256SUMS
```
