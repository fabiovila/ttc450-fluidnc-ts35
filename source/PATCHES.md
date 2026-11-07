<!-- Language switcher -->
**English** · [🇧🇷 Português](#português)

# Patches applied to the `ts35` build

The prebuilt firmware in [`firmware/ts35/`](../firmware/ts35/) is not just the
upstream `ts35` module. It also contains the small patch below, applied on top
of `thcasssio/FluidNC`, branch `feat/ts35-display-module`, commit
`d93a72b2edc2902b5114128bedcf9f953afc16ec`.

## `0001-hard-limits-recoverable.patch`

**Problem:** stock FluidNC treats a hard limit like an emergency stop. It sets
`State::Critical`, the motors are disabled and `$X` cannot clear it. To move the
axis off the switch you have to power-cycle or soft-reset, and if the switch is
still pressed the alarm returns.

**Behaviour wanted:** reach the limit, stop immediately, but still be able to
unlock and jog away — the classic Grbl behaviour.

**Change:** `protocol_do_alarm()` now sets `State::Alarm` for
`ExecAlarm::HardLimit` instead of `State::Critical`. `HardStop` (E-stop /
fault input) remains `Critical`; `SoftLimit` also remains `Critical` in this
patch.

```diff
-    if (lastAlarm == ExecAlarm::HardLimit || lastAlarm == ExecAlarm::HardStop) {
+    if (lastAlarm == ExecAlarm::HardLimit) {
+        // Hard limits are recoverable: stop the machine, but use State::Alarm
+        // (not Critical) so $X / the panel's unlock can clear it and the
+        // operator can jog away from the switch, as in classic Grbl.
+        protocol_disable_steppers();
+        Homing::set_all_axes_unhomed();
+        set_state(State::Alarm);
+        alarm_msg(lastAlarm);
+        return;
+    }
+    if (lastAlarm == ExecAlarm::HardStop) {
         protocol_disable_steppers();
         Homing::set_all_axes_unhomed();
         set_state(State::Critical);  // Set system alarm state
```

Apply from the FluidNC repository root (the parent of `FluidNC/`):

```bash
git apply /path/to/ttc450/source/patches/0001-hard-limits-recoverable.patch
```

Or patch it by hand in `FluidNC/src/Protocol.cpp`, around line 487.

After a hard limit:

1. The machine stops and enters `Alarm`.
2. Send `$X` (or use **UNLOCK** on the TS35 panel / **Clear alarm** in the
   WebUI).
3. Jog **away** from the switch. Moving further into the switch triggers a new
   hard-limit alarm.
4. Re-home before running a job.

`HardStop`, the E-stop input and `SoftLimit` are intentionally unchanged. An
E-stop must require a deliberate reset.

## PlatformIO pin

`platformio.ini` is also changed from the unpinned git URL to
`platformio/espressif32@6.12.0`. FluidNC's `stdfs` shim does not compile with
the GCC 14 toolchain pulled by platform version 7.x; 6.12.0 provides Arduino
core 2.0.17 and GCC 8.4.0.

```diff
 [common_esp32]
 extends = common_esp32_base
-platform = https://github.com/platformio/platform-espressif32.git
+platform = platformio/espressif32@6.12.0
```

## Build result

```text
PlatformIO env: wifi
Flash: 1,830,953 / 1,966,080 bytes (93.1%)
RAM:   82,112 / 327,680 bytes (25.1%)
```

The exact commands are in [`BUILD.md`](BUILD.md).

---

## Português

# Patches aplicados ao build `ts35`

O firmware pré-compilado em [`firmware/ts35/`](../firmware/ts35/) não é apenas o
módulo `ts35` original. Ele também contém o patch abaixo, aplicado sobre
`thcasssio/FluidNC`, branch `feat/ts35-display-module`, commit
`d93a72b2edc2902b5114128bedcf9f953afc16ec`.

## `0001-hard-limits-recoverable.patch`

**Problema:** o FluidNC original trata fim de curso como parada de
emergência. Ele entra em `State::Critical`, desliga os motores e o `$X` não
limpa o alarme. Para tirar o eixo do switch é preciso desligar/ligar ou fazer
soft reset, e se o switch continuar pressionado o alarme volta.

**Comportamento desejado:** chegar no limite, parar na hora, mas ainda poder
destravar e voltar — o comportamento clássico do Grbl.

**Mudança:** `protocol_do_alarm()` agora usa `State::Alarm` para
`ExecAlarm::HardLimit` em vez de `State::Critical`. O `HardStop` (E-stop /
entrada de falha) continua `Critical`; o `SoftLimit` também continua `Critical`
neste patch.

```diff
-    if (lastAlarm == ExecAlarm::HardLimit || lastAlarm == ExecAlarm::HardStop) {
+    if (lastAlarm == ExecAlarm::HardLimit) {
+        // Hard limits are recoverable: stop the machine, but use State::Alarm
+        // (not Critical) so $X / the panel's unlock can clear it and the
+        // operator can jog away from the switch, as in classic Grbl.
+        protocol_disable_steppers();
+        Homing::set_all_axes_unhomed();
+        set_state(State::Alarm);
+        alarm_msg(lastAlarm);
+        return;
+    }
+    if (lastAlarm == ExecAlarm::HardStop) {
         protocol_disable_steppers();
         Homing::set_all_axes_unhomed();
         set_state(State::Critical);  // Set system alarm state
```

Aplique a partir da raiz do repositório FluidNC (a pasta que contém `FluidNC/`):

```bash
git apply /caminho/para/ttc450/source/patches/0001-hard-limits-recoverable.patch
```

Ou edite à mão o `FluidNC/src/Protocol.cpp`, por volta da linha 487.

Depois de um fim de curso:

1. A máquina para e entra em `Alarm`.
2. Envie `$X` (ou use **UNLOCK** na tela TS35 / **Clear alarm** na WebUI).
3. Faça jog **para fora** do switch. Ir mais para dentro aciona um novo alarme
   de hard limit.
4. Faça homing antes de rodar um trabalho.

`HardStop`, a entrada de E-stop e `SoftLimit` ficam de propósito como estavam.
Um E-stop precisa exigir reset deliberado.

## Pin do PlatformIO

O `platformio.ini` também muda a URL git sem versão fixa para
`platformio/espressif32@6.12.0`. O `stdfs` do FluidNC não compila com o GCC 14
do platform 7.x; o 6.12.0 traz Arduino core 2.0.17 e GCC 8.4.0.

```diff
 [common_esp32]
 extends = common_esp32_base
-platform = https://github.com/platformio/platform-espressif32.git
+platform = platformio/espressif32@6.12.0
```

## Resultado do build

```text
PlatformIO env: wifi
Flash: 1.830.953 / 1.966.080 bytes (93,1%)
RAM:   82.112 / 327.680 bytes (25,1%)
```

Os comandos exatos estão em [`BUILD.md`](BUILD.md).
