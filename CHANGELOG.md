## 0.0.1

Initial release.

- Floating, capsule-shaped Liquid Glass bottom bar with a drop-in
  `NavigationBar`-style API (`items` / `selectedIndex` / `onDestinationSelected`,
  plus a `.legacy` Cupertino-style alias).
- Dual-path rendering: a hand-rolled GLSL refraction shader on Impeller
  (`ImageFilter.shader`) with an automatic `BackdropFilter` fallback.
- Scroll-to-minimize with four behaviors (`automatic`, `never`, `onScrollDown`,
  `onScrollUp`).
- Spring-driven selection pill with velocity-based stretch.
- Optional bottom accessory shelf (`expanded` ↔ `inline`) and a search tab that
  morphs the capsule into a text field.
- Accessibility: Reduce Motion, Increase Contrast, reduce-transparency, text
  scaling and `Semantics`.
- Fully tunable via `LiquidGlassSettings`; example app with a settings
  playground and per-feature demos.
