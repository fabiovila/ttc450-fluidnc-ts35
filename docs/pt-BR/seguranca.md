# Segurança e referências

[← Voltar ao README](../../README.pt-BR.md) · **🇧🇷 Português** · [English](../en/safety.md)

## Segurança

- **Laser:** use óculos adequados ao comprimento de onda, exaustão/ar
  assistido, supervisão e extintor por perto. Nunca deixe o laser ligado
  sozinho.
- **Troca de modo:** desligue a máquina antes de trocar o cabo do spindle pelo
  do laser. Nunca deixe o módulo laser conectado enquanto estiver fresando.
- **Spindle 500 W:** a velocidade é ajustada só no potenciômetro da fonte.
  Deixe no máximo; o software só liga/desliga via relé.
- **EMI:** se o WiFi cair durante o trabalho, teste com o spindle desligado. Se
  parar de cair, o problema é ruído; use cabo blindado, ferrite e fonte
  separada.
- **Backup:** guarde o dump de 8 MB e os arquivos de config. O dump é a única
  forma de voltar ao firmware original com NVS/SPIFFS intactos.
- **Build TS35:** não é oficial. Teste primeiro com os motores desconectados e o
  laser desligado. O cartão SD fica desativado nesse build; o toque começa
  desabilitado até a calibração.

## Referências

- FluidNC — placa MKS DLC32:
  <http://wiki.fluidnc.com/en/hardware/3rd-party/MKS_DLC32>
- FluidNC — issue #759 (suporte a TS35):
  <https://github.com/bdring/FluidNC/issues/759>
- FluidNC — PR #1805 (módulo TS35 experimental):
  <https://github.com/bdring/FluidNC/pull/1805>
- FluidNC — WiFi:
  <http://wiki.fluidnc.com/en/features/wifi_bt>
- FluidNC — configuração:
  <http://wiki.fluidnc.com/en/config/overview>
- Diode Laser Wiki — TTC450:
  <https://diode-laser-wiki.com/documentation/twotrees-ttc450-cnc-machine/>
- TwoTrees — upgrade de firmware:
  <https://wiki.twotrees3d.com/en/CNCEngravingMachine/TTC450/MotherboardFirmwareUpgrade>
- TwoTrees — troca para o modo laser:
  <https://wiki.twotrees3d.com/en/CNCEngravingMachine/TTC450/Switch-to-laser-mode>
- MKS DLC32 — repositório:
  <https://github.com/makerbase-mks/MKS-DLC32>
- MKS — issue #524 (WiFi some após reboot):
  <https://github.com/makerbase-mks/MKS-DLC32/issues/524>
- Blog com o passo a passo `$ESP` na TTC450:
  <https://chrissearle.org/2025/03/02/ttc-450-wifi-configuration-and-ugs-connection/>
