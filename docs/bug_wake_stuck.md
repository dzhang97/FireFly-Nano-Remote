# Bug Analysis: Remote Wake-up Stuck State

## Symptom
When pressing the power button to turn off/standby the remote, the device occasionally enters a "stuck" state where it fails to wake up. A hardware reset is required to restore operation.

## Root Cause Analysis

### 1. Misconception of Deep Sleep Execution Flow
In `src/remote/remote.cpp`, the `sleep()` function is written as if the CPU resumes execution directly after the sleep call:

```cpp
esp_deep_sleep_start();
// CPU will be reset here

// --- THE FOLLOWING CODE IS UNREACHABLE ---
detachInterrupt(digitalPinToInterrupt(PIN_BUTTON));
digitalWrite(LED, HIGH);
display.powerOn();
power = true;
```

**Technical Reality:** On the ESP32, `esp_deep_sleep_start()` triggers a full system reset upon wake-up. The processor starts again from the beginning of the `setup()` function. The logic meant to restore the display and `power` state at the end of the `sleep()` function is never executed.

### 2. Potential Boot-Loop / Race Condition
Because the device reboots on wake-up, the following sequence can occur:
1. User presses button $\rightarrow$ Device wakes up.
2. Device enters `setup()`.
3. `handleButtons()` is called in `loop()`.
4. If the user is still holding the button (which is common during a wake-up press), the `checkButton()` logic might register a `LONG_HOLD` or a `HOLD` event immediately.
5. This triggers another call to `sleep()`, putting the device back to sleep almost instantly.
6. To the user, the device appears "dead" or "stuck" because the screen never turns on or flickers for a millisecond.

### 3. Peripheral State Issues
The `sleep()` function modifies hardware pins to save power:
- `Vext` is set `HIGH` to disable the battery probe.
- OLED pins are set to `INPUT`.
- LoRa radio is shut down.

If these are not restored in the exact order required during the `setup()` phase, the hardware may enter an unstable state that requires a full hardware reset to clear.

## Proposed Solution

### Immediate Code Changes
- **Clean up `sleep()`**: Remove all code following `esp_deep_sleep_start()`.
- **Wake-up Detection**: Implement `esp_sleep_get_wakeup_cause()` in `setup()` to identify when the device has woken from deep sleep.
- **State Restoration**: Move the "wake-up" logic (powering on the display, resetting the `power` flag) into the `setup()` flow.
- **Improved Button Handling**: Ensure that the button state is properly cleared/debounced upon boot to prevent an immediate return to sleep.

### Long-term Reliability
- Move hardware initialization into a dedicated `HardwareManager` to ensure deterministic power-sequencing of `Vext` and the OLED during both cold and warm (wake) boots.
