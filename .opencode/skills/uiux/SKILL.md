---
name: uiux
description: BigPay adaptive UI/UX work — responsive layouts, breakpoints, foldables (book/full/phone mode), tablet, big/wide screens, landscape-short heights, light/dark and text-scale verification. Use when the user asks about responsive design, adaptive layouts, screen sizes, foldables, hinge, tablet, breakpoints, "adapt on all screen sides", or visual verification across form factors.
---

# BigPay Adaptive UI/UX

A banking app that must sit correctly on candybar phones (320–430dp), tablets,
foldables (phone mode, book/half-open, full), and wide/big screens — in both
themes and under text scaling, without depending on device *type*. Every layout
choice flows from the width breakpoints and hinge-aware primitives below; there
is **no web target** (the app is native Android/iOS and its native services —
tflite-driven KYC face capture, Udid, libphonenumber, pinned TLS — don't compile
for the web). Testing uses simulators/emulators only.

## The adaptive runtime (all pre-built — use, don't reinvent)

| Concern | Where | What it gives you |
| --- | --- | --- |
| Breakpoints | `lib/ui/theme/responsive.dart` | `Breakpoints` 600 / 840 / 1100 |
| Bucket flags | same file, `ResponsiveContext` | `isCompact`, `isMedium`, `isExpanded`, `isWide`, `isTabletOrLarger`, `isShortHeight`, `isLandscapePhone` |
| Width-driven values | same | `responsive<T>(compact: …)` , `responsiveSpacing`, `gutter` |
| Content width cap | same, `BoundedContent` / `contentCapWidth` | caps 640/720 beyond phone width, centers |
| Hinge / folds | `lib/ui/theme/foldable.dart`, `FoldableContext` | `isBookMode`, `hingeBounds`, `usesSplitView`, `isInsideSplitPane` |
| Master/detail split | `MasterDetailLayout` in same file | pane split across hinge or wide screen |
| Nav forms | `main_shell.dart`, `bottom_nav_bar.dart`, `side_nav_rail.dart` | bottom pill nav <600dp, side rail ≥600dp |

Key API notes:

- `Breakpoints`: `medium = 600` (tablet portrait / unfolded foldable),
  `expanded = 840` (tablet landscape / desktop-ish), `wide = 1100` (sidebar +
  master + detail in one row). All checks are **width-based**, never
  `Platform.isTablet`/`isPhone` — a landscape phone and a small tablet must land
  in the same bucket.
- `BoundedContent` caps `640` (medium) / `720` (expanded) and centers. Default
  treats book mode like any wide screen (centered across the whole window) —
  do **not** reach for `avoidHinge: true`; it's reserved and currently unused.
- `MasterDetailLayout(master:, detail:, masterWidth: 400)`: no-op on phone or
  medium screens, and when `detail == null` (nothing selected). Splits across a
  real hinge in book mode else a fixed-width master pane when `isWide`.
  `context.isInsideSplitPane` is true inside a pane — a modal/sheet opened from
  the detail pane must not re-apply hinge-avoidance.
- `gutter` (20/28/36) and `responsiveSpacing` (halves on short heights) are the
  only spacing sources for layout edges — never raw EdgeInsets numbers for
  page gutters.
- Short-height handling: `isShortHeight` (height <500dp) compresses vertical
  rhythm and keeps CTAs reachable; `isLandscapePhone` narrows that further.
  Landscape phone is a first-class bucket, not a tablet.

## Form-factor matrix (this machine)

| Bucket | Target | Approx logical width | Breakpoint bucket |
| --- | --- | --- | --- |
| Candybar small | iPhone 16e · Pixel_4a_API_UpsideDownCake (393dp) | ~375–393 | compact |
| Candybar large | iPhone 16 Pro Max · Pixel_9_Pro_XL | ~412–430 | compact |
| Foldable · folded (phone) | `Pixel_9_Pro_Fold` + `adb emu fold` | ~443 | compact |
| Foldable · book (half-open) | `Pixel_9_Pro_Fold` bookmark posture (toolbar) | hinge splits ~2×~426 | compact panes via `MasterDetailLayout` |
| Foldable · full | `Pixel_9_Pro_Fold` unfolded | ~852 | expanded (≥840) |
| Tablet portrait | iPad 11" / 13" · Android 10" tablet AVD | 768–810 | medium |
| Tablet landscape | iPad 13" landscape | ~1366 | >wide |
| Wide / big screen | iPad Pro 13" landscape (largest available) | ≥1100 | wide |
| Landscape-short | rotate any phone (`adb emu rotate 90` / Simulator Device→Rotate) | width>600, height<500 | short-height |

Book mode's hinge (`DisplayFeature` with `postureHalfOpened`) is delivered by the
emulator's fold slider, **not** by `adb emu fold` (that's fully closed). To
verify `isBookMode`/`hingeBounds` code paths, set the half-open posture in the
Pixel 9 Pro Fold emulator's Extensions → fold control.

## Conventions (non-negotiable)

- Theme only: `AppColors`, `AppGradients`, `Spacing` (`xs 4 … xxxl 32`), and the
  `context.*` typography extension (`display1`, `header1`, `smallDetails`, …) in
  `lib/ui/theme/app_typography.dart`. No raw `Color(0xFF…)`, pixel sizes, or
  image asset paths inline — use `SvgImages`/`JpgImages` and tokens.
- No hardcoded text in widgets — all labels, tooltips, and placeholders come
  from `AppLocalizations.of(context)!` (ARB). Text scale is clamp-capped at
  1.3 in `app.dart`; verify layouts still hold at 1.3.
- Use `context.*` styles on a widget that sits on a gradient/photo; when a
  `context.*` style derives from `onSurface`, override with an explicit token
  (e.g. `AppColors.white` on the wallet card).
- Don't recreate `ValueNotifier`s/controllers in `build` — a `ValueNotifier` on
  a StatelessWidget (e.g. the wallet-card eye toggle) resets whenever the parent
  rebuilds and can't be disposed; hoist or convert to stateful.
- Content stays inside `BoundedContent` — nothing stretches edge-to-edge past
  ~720dp unless it's a deliberately full-bleed hero.

## Verification workflow

1. Boot the target for the bucket you're checking:
   - iOS: `xcrun simctl boot <udid>` (iPhone 16e, iPad 11"/13" M4); launch with
     `flutter run -d <udid>` or the ios-simulator MCP.
   - Android: `flutter emulators --launch Pixel_9_Pro_Fold` /
     `Pixel_9_Pro_XL`, or `emulator -avd <name>`; `adb wait-for-device`.
   - Fold postures: `adb emu fold` / `adb emu unfold` (scriptable); half-open
     book mode via the emulator fold control (manual) for `isBookMode` paths.
   - Rotation: `adb emu rotate 90` (Android); iOS via Simulator menu
     Device → Rotate (no simctl CLI).
2. Dark mode: `xcrun simctl ui booted appearance dark` (iOS) ·
   `adb shell cmd uimode night yes` (Android). Text scale 1.3:
   `adb shell settings put system font_scale 1.3`; on iOS set in the
   Simulator Settings app.
3. Screenshot each bucket: `xcrun simctl io booted screenshot /tmp/uiux.png`
   (iOS) · `adb exec-out screencap -p > /tmp/uiux.png` (Android). Inspect the
   image; also grab `adb shell wm size` to confirm the logical width.
4. Check per bucket (checklist):
   - Compact: bottom pill nav; single-column; `BoundedContent` no-op;
     CTAs on-screen; no horizontal overflow.
   - Medium/Expanded: side rail nav (≥600); content centered+capped; gutters
     grow.
   - Wide: sidebar + master + detail coexist; no overlap with `MasterDetailLayout`.
   - Book mode: panes split across the hinge, hinge gap painted, no content
     under the seam; modals stay inside their pane.
   - Folded/full: layouts identical to equivalent-width regular screens.
   - Landscape-short: vertical rhythm compressed, CTA reachable, no app-bar
     subtitle overflow.
   - All buckets × light/dark × text-scale 1.3: no overflow, no clipped labels.
5. Use the `adaptive-ux` plugin (`uiux_screenshot <bucket>` /
   `uiux_matrix`) to capture a bucket or the whole matrix in one call.

## Known responsive landmines (from code review)

- `context.display1` → `onSurface` (near-black in light): force `AppColors.white`
  on gradient cards.
- Any fix that changes colors/sizes on a card must not reset the eye-toggle
  `ValueNotifier` state.
- Don't split pages on `isWide` before the user has selected an item —
  `MasterDetailLayout`'s `detail == null` guard exists for exactly this.