# Safety and references

[← Back to README](../../README.md) · **English** · [🇧🇷 Português](../pt-BR/seguranca.md)

## Safety

- **Laser:** wear eye protection rated for the laser wavelength, use
  extraction/air assist, supervise the job and keep a fire extinguisher nearby.
  Never leave the laser running unattended.
- **Mode switching:** power the machine off before swapping the spindle cable
  for the laser. Never leave the laser module connected while milling.
- **500 W spindle:** speed is set only on the PSU potentiometer. Leave it at
  maximum; the software only switches it on/off through the relay.
- **EMI:** if WiFi drops during a job, test with the spindle off. If the drop
  stops, it is noise; use shielded cable, ferrite beads and a separate supply.
- **Backup:** keep the 8 MB dump and the config files. The dump is the only way
  to return to the original firmware with NVS/SPIFFS intact.
- **TS35 build:** not official. Test first with the motors disconnected and the
  laser off. The SD card is disabled in this build; touch starts disabled until
  calibration.

## References

- FluidNC — MKS DLC32 board:
  <http://wiki.fluidnc.com/en/hardware/3rd-party/MKS_DLC32>
- FluidNC — issue #759 (TS35 support):
  <https://github.com/bdring/FluidNC/issues/759>
- FluidNC — PR #1805 (experimental TS35 module):
  <https://github.com/bdring/FluidNC/pull/1805>
- FluidNC — WiFi:
  <http://wiki.fluidnc.com/en/features/wifi_bt>
- FluidNC — configuration:
  <http://wiki.fluidnc.com/en/config/overview>
- Diode Laser Wiki — TTC450:
  <https://diode-laser-wiki.com/documentation/twotrees-ttc450-cnc-machine/>
- TwoTrees — firmware upgrade:
  <https://wiki.twotrees3d.com/en/CNCEngravingMachine/TTC450/MotherboardFirmwareUpgrade>
- TwoTrees — switch to laser mode:
  <https://wiki.twotrees3d.com/en/CNCEngravingMachine/TTC450/Switch-to-laser-mode>
- MKS DLC32 — repository:
  <https://github.com/makerbase-mks/MKS-DLC32>
- MKS — issue #524 (WiFi lost after reboot):
  <https://github.com/makerbase-mks/MKS-DLC32/issues/524>
- Blog post on the `$ESP` procedure for the TTC450:
  <https://chrissearle.org/2025/03/02/ttc-450-wifi-configuration-and-ugs-connection/>
