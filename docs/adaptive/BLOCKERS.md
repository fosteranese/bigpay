# Rotational blockers — environment, not app

Goal: produce all 9 adaptive buckets; 8 of 9 captured (see MATRIX.md). The two
missing buckets (`wide` ≥1100dp in landscape, phone landscape-short) are
**unreachable with the tooling available on this host**. This file documents
the evidence so future agents don't repeat the investigation.

## iOS Simulator cannot rotate on this host
- AppleScript/AX: `Rotate Left`/`Rotate Right` menu items are
  `AXEnabled=false` **even on the bare home screen** (single booted, main
  window). Testing every level of AX (window menu → `Orientation` submenu →
  direct AXPress on `Rotate Left/Right`) yields no rotation; framebuffer
  never exceeds portrait.
- No CLI: `xcrun simctl io` has **no rotate command**. `simctl io
  screenConfig geometry` rejects every landscape mode
  (`No mode found with scale factor... / No mode found that supports...`).
- The app side is NOT the blocker: `Info.plist` already declares all 4
  orientations on all iOS targets, `lib/app_setup.dart` no longer locks
  portrait (unlock is intentional and verified live via screenshot dims:
  candybar-small 1170×2532 → portrait, but the lock line is gone).

## Android ceiling
- Android fold (emulator-5554) in book posture gives **883dp** landscape —
  tablet-landscape, but not ≥1100 (wide).
- Android XL (emulator-5556) caps at 997dp landscape — still <1100 (wide).
- No short-height phone landscape exists on the available emulators.

## Honest consequence
`wide` requires ≥1100dp in landscape → only reachable on iPad 13 landscape
(1376dp) or a wide desktop window. `landscape-short` requires a short phone
landscape. Neither can be produced on this host. Deliver the 8/9 matrix; the
remaining 2 are deterministic host limitations, not app defects.

## What WOULD unblock
- A Mac with a functional iOS Simulator rotation, OR
- A physical iPad in the test pool, OR
- XCUITest `XCUIDevice.orientation` on CI (device, not simulator).
