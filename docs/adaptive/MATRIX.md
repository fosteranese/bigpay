# Adaptive UI/UX screenshot matrix

Captured matrix for BigPay. Buckets per `folder`/`breakpoint` rules in
`lib/ui/theme/Responsive.dart`. Landscape rotation on this host's iOS
Simulators is blocked at the environment level (see BLOCKERS.md); landscape
buckets shown are from the Android fold in book posture.

| Bucket              | File                         | px (W×H) | dp width | Source device / posture            |
|---------------------|------------------------------|----------|----------|------------------------------------|
| candybar-small      | candybar-small.png           | 1170×2532| 585      | iPhone 16e, portrait               |
| candybar-large      | candybar-large.png           | 1320×2868| 660      | iPhone 16 Pro Max, portrait        |
| foldable-phone      | foldable-phone.png           | 1080×2424| 540      | Pixel Fold, folded-phone posture    |
| foldable-book       | foldable-book.png            | 2152×2076| 883      | Pixel Fold, book posture            |
| foldable-full       | foldable-full.png            | 2152×2076| 883      | Pixel Fold, full (unconstrained)    |
| tablet-portrait     | tablet-portrait.png          | 1668×2420| 834      | iPad 11" (11-inch M4), portrait     |
| tablet-large-portrait| tablet-large-portrait.png   | 2064×2752| 1032     | iPad 13" landscape-mapped, portrait |
| tablet-landscape    | tablet-landscape.png         | 2152×2076| 883      | Android fold, book landscape        |

Not-yet-captured buckets (blocked at environment level — see BLOCKERS.md):
`wide` (≥1100dp landscape) and `landscape-short`/`landscape-short-phone`.

## How to refresh
Re-run the capture tooling (`opencode` + `uiux_screenshot`/`uiux_targets`
tools after plugin restart) on a host where iOS Simulator rotation is
functional, or extend `foldable-full` to a true ≥1100dp device.
