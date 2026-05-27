# Power Optimization Strategy: FireFly-Nano-Remote

This document outlines the strategy for maximizing both active battery life and standby duration for the remote controller.

## 1. Standby/Off Time (Deep Sleep)
The goal is to achieve the absolute minimum leakage current when the device is "off".

### Current State
- Uses `esp_deep_sleep_start()`.
- Disables battery probe via `Vext`.
- Sets most peripheral pins to `INPUT`.

### Proposed Optimizations
- **RTC GPIO Holding**: Instead of just `pinMode(INPUT)`, use `rtc_gpio_hold_en()` on all pins connected to external peripherals (LoRa, OLED, Vibro) to ensure they are locked in a state that prevents current leakage.
- **Full Peripheral Shutdown**: Ensure LoRa and OLED are explicitly put into their lowest power states before the ESP32 enters deep sleep.
- **Verify Pull-ups/downs**: Audit the hardware schematic to ensure no pins are pulling current through external resistors during sleep.

## 2. Active Runtime Optimization
The goal is to reduce the average current draw during operation without sacrificing responsiveness.

### CPU Optimization
- **Clock Frequency Scaling**: The ESP32 currently runs at 240MHz. Reducing the clock to 80MHz (the crystals' natural frequency) significantly reduces power consumption with negligible impact on the remote's logic.

### Radio Optimization (Dynamic Duty Cycle)
- **Active Rate**: Maintain 50ms transmission interval when the throttle is moved or the trigger is pressed.
- **Idle Rate**: Drop the transmission interval to 200ms-500ms when the remote is in `IDLE` state and no user interaction is detected.

### Display Optimization
- **Screen Timeout**: Implement a timeout (e.g., 30 seconds) that calls `display.powerOff()` while the remote remains active. This avoids the energy cost of a full reboot required by deep sleep.
- **Brightness/Contrast**: Evaluate if the SSD1306 contrast can be lowered based on ambient light or user settings.

## 3. Power Mode State Machine
To manage these transitions, a `PowerManager` will implement the following modes:

| Mode | CPU Clock | Radio Rate | Display | Condition |
| :--- | :--- | :--- | :--- | :--- |
| **Performance** | 240/160MHz | 50ms | ON | Active riding/Throttle movement |
| **Eco** | 80MHz | 200ms | Timeout | Stationary / No interaction |
| **Deep Sleep** | Off | Off | OFF | Long hold button / Sleep timeout |

---
*Last Updated: 2026-05-26*
