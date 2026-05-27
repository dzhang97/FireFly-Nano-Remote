# Project Cleanup & Safety Roadmap: FireFly-Nano-Remote

This document tracks the necessary cleanup, safety enhancements, and architectural improvements for the FireFly-Nano-Remote project.

## 🔴 High Priority: Safety & Reliability
- [ ] **Concurrency & Race Conditions (ESP32)**
  - Implement mutexes or atomic variables for globals accessed by both Core 0 (Radio) and Core 1 (UI/System).
  - Specifically target: `state`, `throttle`, `telemetry`, and `remPacket`.
- [ ] **Failsafe Audit**
  - Verify the `timeoutMax` and `failCount > 10` logic.
  - Ensure that the `STOPPING` state (Emergency Brake) is triggered deterministically upon signal loss.
- [ ] **Packet Integrity**
  - Move beyond simple `CRC8` if necessary; implement sequence numbering to prevent replay of old packets.
  - Apply `__attribute__((packed))` to all communication structs (`RemotePacket`, `ReceiverPacket`, `TelemetryPacket`, `ConfigPacket`) to prevent compiler padding issues.
- [ ] **Deterministic State Machine**
  - Replace scattered state changes with a centralized `transitionTo(AppState newState)` function to validate legal transitions.

## 🟡 Medium Priority: Code Quality & Technical Debt
- [x] **Remove Non-Heltec Hardware Support**
  - Removed all board definitions for Feather and TTGO.
  - Stripped `#ifdef ARDUINO_SAMD_ZERO` and `#ifdef ESP32` conditional guards to make Heltec the default.
  - Updated `platformio.ini` to target only `Remote_Heltec_v2` and `Receiver_Heltec_v2`.
  - Verified build success for both targets.
- [ ] **Remove "Zombie" Code**
  - Delete all large blocks of commented-out functions (e.g., `sleep2`, `speedControl`, old EEPROM logic).
- [ ] **Hardware Abstraction Layer (HAL)**
  - Refactor `#ifdef ESP32` and `#ifdef ARDUINO_SAMD_ZERO` blocks into a separate HAL.
  - Decouple application logic from chip-specific radio and pin implementations.
- [ ] **Fixed-Point Arithmetic**
  - Convert float-based telemetry (volts, km/h) to fixed-point (milli-volts, cents of km/h) to avoid precision/rounding errors across platforms.
- [ ] **Power Management Refactor**
  - Move the complex manual pin-toggling in the `sleep()` function into a dedicated `PowerManager` class.
- [ ] **Brownout Response**
  - Update the brownout ISR to trigger a safe motor stop rather than just lighting an LED.

## 🟢 Low Priority: UI & UX
- [ ] **Menu Navigation**
  - Replace the `currentMenu += 0.25` hack with a proper timer-based scrolling mechanism.
- [ ] **UI Consistency**
  - Review and consolidate the use of fonts (`fontMicro`, `fontDesc`, `fontDigital`) for a more cohesive look.
- [ ] **Documentation**
  - Update `README.md` and Wiki to reflect the updated safety features and hardware requirements.

---
*Last Updated: 2026-05-26*
