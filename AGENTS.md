# BigPay — agent notes

- **Native-only app.** Do not plan web or macOS targets: `tflite_flutter`
  (KYC `dart:ffi`) has no web build, and `dart:io` is used in
  `main.remote.dart`, `app.util.dart`, `response.util.dart`. Anything web is
  out of scope and will waste a build.
- **UI/UX work = load the `uiux` skill**
  (`.opencode/skills/uiux/SKILL.md`). It defines the device matrix, the
  adaptive conventions, and the verification commands for this machine.
- Adaptive primitives are documented in `lib/ui/theme/ADAPTIVE.md`.
  Use `Breakpoints`, `context.responsive<T>()`, `BoundedContent`,
  `MasterDetailLayout` — never magic numbers.
- Screenshot tools come from the project plugin
  (`.opencode/plugin/adaptive-ux.ts`):
  `uiux_targets` (what's booted), `uiux_screenshot {bucket}`,
  `bucket: "all"` for the full matrix → `/tmp/bigpay-uiux/`.
- **Restart required:** skills/plugins under `.opencode/` load at startup;
  after editing them, ask the user to restart opencode.
- Tests: `flutter test` currently has 6 failing tests
  (`service_form_test.dart`, `message_util_test.dart`) caused by test
  harnesses pumping `MaterialApp` without `AppLocalizations.delegate` —
  unrelated to app code until fixed.