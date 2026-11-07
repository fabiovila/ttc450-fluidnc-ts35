# Interface web própria

[← Voltar ao README](../../README.pt-BR.md) · **🇧🇷 Português** · [English](../en/webui.md)

O build FluidNC + TS35 da TTC450 inclui uma **WebUI própria e bilíngue** no
LittleFS. Ela substitui a WebUI oficial (ESP3D) e fala diretamente com o
WebSocket de console do FluidNC.

- Fonte: [`ui/index.html`](../../ui/index.html)
- Arquivo publicado: [`ui/index.html.gz`](../../ui/index.html.gz)
- Guia completo de arquivos e atualização: [`ui/README.pt-BR.md`](../../ui/README.pt-BR.md)

## Por que substituir a WebUI oficial

A WebUI oficial procura uma linha `[ESP...]` no relatório `$I` para descobrir a
porta do WebSocket. Neste build o FluidNC não imprime essa linha, então o
console da WebUI oficial tenta a porta 81 e falha. O WebSocket do firmware
funciona na **porta 80**:

```text
ws://<ip-da-máquina>/       subprotocolo: arduino
/command?commandText=...&PAGEID=N
/command?plain=...
/files
/updatefw
```

A página usa `location.host` (não tem IP fixo no código), então funciona com
DHCP, mDNS, modo AP e qualquer hostname. Não carrega CDN, analytics nem
credenciais.

## O que vem incluído

| Arquivo | Função |
|---|---|
| `index.html.gz` | Página servida em `/` |
| `help-en.html` | Manual em inglês carregado pela aba Ajuda |
| `macros.json` | Macros padrão opcionais |
| `favicon.ico` | Ícone da aba (opcional) |
| `index.html` | Fonte editável (não é servido) |
| `webui-original.html.gz` | Backup da WebUI original |
| `SHA256SUMS` | Checksums dos arquivos acima |

Só `index.html.gz` e `help-en.html` são obrigatórios. O `littlefs.bin` do build
já contém os dois, então uma gravação normal de firmware já sobe com a nova
interface.

## Recursos principais

- **Dashboard:** DRO, WCO, feed/spindle, overrides, entradas, estado da
  máquina, WiFi, uso do LittleFS, firmware, eventos e ações rápidas.
- **Controle:** jog, zero, home, unlock/clear alarm, desligar motores, MDI,
  overrides de feed/rapid e macros genéricas.
- **CNC:** relé do spindle, presets S12000/S6000, coolant, override do
  spindle, probe, macros CNC e diagnóstico.
- **Laser:** potências 1/5/10/25/50/100%, pulso, contínuo, OFF, teste de PWM,
  checklist e diagnóstico. Também explica o comportamento M3 (potência
  constante) vs M4 (potência dinâmica).
- **Gate de modo:** as páginas CNC e Laser ficam bloqueadas uma em relação à
  outra conforme a config ativa. A página Controle fica sempre disponível.
- **Arquivos:** navegar, enviar, baixar, ver, renomear, apagar, criar pastas,
  rodar `.nc` e escolher configs YAML. Arquivos de UI/config/macros são
  protegidos.
- **Configurações:** `$Settings/List` editável, WiFi, `$Config/Dump`,
  `$Firmware/Info`, OTA (somente mesmo build), reiniciar e relatórios.
- **Ajuda:** manual com 17 seções, índice, busca, glossário, comandos,
  referência de telas, modos CNC ↔ laser, M3/M4 e troubleshooting.

## Idioma

A página detecta `navigator.languages`: qualquer `pt-*` seleciona português;
caso contrário, inglês. O botão **EN/PT** no cabeçalho salva a escolha em
`localStorage`; `?lang=pt` ou `?lang=en` força o idioma para teste. O manual em
português fica embutido no `index.html`; o manual em inglês é o
`help-en.html`.

## Atualizar a página sem regravar o firmware

Use a página **Arquivos / LocalFS** da WebUI ou a API `/files`:

```bash
HOST=http://192.168.15.77

sz=$(wc -c < ui/index.html.gz)
curl -F 'path=/' \
     -F "/index.html.gzS=$sz" \
     -F 'myfile[]=@ui/index.html.gz;filename=/index.html.gz' \
     "$HOST/files"

sz=$(wc -c < ui/help-en.html)
curl -F 'path=/' \
     -F "/help-en.htmlS=$sz" \
     -F 'myfile[]=@ui/help-en.html;filename=/help-en.html' \
     "$HOST/files"
```

Recarregue com **Ctrl+F5**. Envie `index.html.gz`, nunca o `index.html`
descompactado.

## Regerar o `littlefs.bin`

```bash
cp ui/index.html.gz ui/help-en.html ui/macros.json ui/favicon.ico \
   <FluidNC>/FluidNC/data/
cd <FluidNC>
pio run -e wifi -t buildfs
```

O `buildfs` apaga o `.pio/build/wifi/firmware.bin`; compile a aplicação
primeiro e copie o `firmware.bin` para fora se estiver regerando os dois. Veja
[`source/BUILD.md`](../../source/BUILD.md).

## OTA e o botão de atualização

O handler de atualização web está presente neste build, então o envio de
firmware da UI usa `/updatefw`. Grave **somente** o `firmware.bin` deste mesmo
build TS35. Uma imagem do FluidNC oficial não tem o módulo `ts35` e deixa a
tela apagada.

## Restaurar a WebUI original

```bash
sz=$(wc -c < ui/webui-original.html.gz)
curl -F 'path=/' \
     -F "/index.html.gzS=$sz" \
     -F 'myfile[]=@ui/webui-original.html.gz;filename=/index.html.gz' \
     'http://192.168.15.77/files'
```

Recarregue com Ctrl+F5.

## Segurança

A página **não tem autenticação**, assim como a WebUI original do FluidNC.
Mantenha a controladora em rede local confiável e nunca a exponha diretamente à
internet. Ela não carrega scripts externos; os únicos links externos são de
documentação.

## Solução de problemas

- **A página abre, mas os dados não atualizam:** confira se o navegador
  consegue abrir `ws://<ip-da-máquina>/`; proxy ou página HTTPS pode bloquear
  WebSocket por mixed content.
- **Comandos `$` funcionam, mas G-code não:** G-code e jog passam pelo
  WebSocket; consultas `$` ainda podem funcionar por HTTP. Recarregue a página
  para obter um novo `PAGEID`.
- **Manual em inglês não aparece:** envie `help-en.html` para a raiz do
  LittleFS.
- **Banner de ConfigAlarm depois de um crash:** reinicie com `$Bye` ou pelo
  botão Reiniciar para carregar o YAML normal.
- **O laser não desliga:** a página não corta a alimentação sozinha; envie
  `M5` ou use o botão OFF. Fechar o navegador não desliga o laser.
