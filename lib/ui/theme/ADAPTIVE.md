# Adaptive layout cheat-sheet (BigPay)

All adaptive logic lives in `lib/ui/theme/responsive.dart` and
`lib/ui/theme/foldable.dart`. **Keyed off viewport width, not device type.**
Use these — never `LayoutBuilder` with magic numbers.

## Breakpoints (`Breakpoints`)
| name    | value | means                                              |
| ------- | ----- | -------------------------------------------------- |
| medium  | 600   | tablet portrait / unfolded foldable                |
| expanded| 840   | tablet landscape / desktop                         |
| wide    | 1100  | sidebar + master + detail all on screen            |

## Width classes (`BuildContext` extension)
| getter            | condition                       |
| ----------------- | ------------------------------- |
| `isCompact`       | width < 600                    |
| `isMedium`        | 600 ≤ width < 840              |
| `isExpanded`      | width ≥ 840                    |
| `isWide`          | width ≥ 1100                   |
| `isTabletOrLarger`| width ≥ 600 (drives nav)       |
| `isShortHeight`   | height < 500 (landscape phone) |
| `isLandscapePhone`| short height AND width < 900   |

## Layout helpers
- `responsive<T>(compact:, medium:, expanded:)` — per-bucket value.
- `responsiveSpacing(...)` — same, but halves on `isShortHeight`.
- `context.gutter` — outer padding, scales 20 / 28 / 36.
- `contentCapWidth(context, {avoidHinge})` — expose when you can't wrap a
  `BoundedContent` (e.g. bottom sheets).
- `BoundedContent` — caps content: 640 in compact, 720 medium+, centered.
  `avoidHinge: true` is only for full-window surfaces in book mode; content
  already inside a `MasterDetailLayout` pane must NOT re-confine.
- Foldable: `context.isBookMode`, `context.usesSplitView`,
  `context.isInsideSplitPane`, `MasterDetailLayout(masterWidth: 400)`.

## Nav form (MainShell)
- width < 600 → bottom pill nav.
- width ≥ 600 → `SideNavRail`.

## Must / must-not
- Theme tokens only: `AppColors`, `AppTheme`, `context.*` text styles,
  `Spacing` (xs 4 … xxxl 32). No raw `Color(...)` or ad-hoc sizes.
- L10n via `AppLocalizations` — never hard-code text.
- Text scale must fit `debugDumpSemantics` at 1.0 AND 1.3; verify with the
  `uiux` skill (`.opencode/skills/uiux/SKILL.md`).
- Mind the traps: stateless widgets holding `ValueNotifier`, `currentUser!`,
  unformatted long amounts, and content hidden behind a closed-hinge overlap.