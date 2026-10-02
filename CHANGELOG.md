# Changelog

## 1.2.0 - 2026-10-02

### Added

- `ToastyTheme`, a `ThemeExtension` that styles toasts per light/dark theme with typed `success` / `error` / `warning` / `info` / `custom` fields (and `ToastyTheme.all`).
- `ToastyTheme.builder` and `ToastData` to restyle every toast state with one builder, no `.custom` needed.
- `position` argument on `FlutterToasty.info/success/warning/error`.
- `llms.txt` for coding agents, and a refreshed README and example docs.
- The example app now shows every toast type, all six positions, light/dark theming and a custom builder.

### Changed

- Stacked toasts: older toasts now show as cards peeking out behind the newest one, whatever their height. Their content appears when they reach the front.
- `FlutterToasty.custom` no longer forces `bottomCenter` over the position configured in `ToastyOptions`.
- `ToastyOptions.itemOptions` is deprecated in favor of `ToastyTheme`; a partial map is now merged with the defaults instead of replacing them.
- `ToastyProvider` reconfigures when its `options` or `maxToasts` change.
- Toasts already on screen update live when the theme (mode or `ToastyTheme`) changes.
- The Flutter SDK constraint no longer has an upper bound.
- Updated `flutter_svg` to ^2.3.0.

### Fixed

- Toasts that were shorter than the one in front were completely hidden behind it.
- `onClose` now runs exactly once however a toast ends. Before, it only ran for `dismissAll` and `maxToasts` eviction, not for auto dismiss, the close button, a tap or `dismiss(id)`.
- The toast listener was never removed when `ToastyProvider` was disposed.
- Performance: each toast is wrapped in a `RepaintBoundary`, and `dismiss` skips unknown ids.

## 1.1.0 - 2026-03-18

- Fixed an issue with toasts not showing in certain contexts by improving overlay state handling and context inheritance.
- Updated documentation with new examples and troubleshooting tips.

## 1.0.3 - 2026-03-04

- Added support for center icon alignment in toasts

## 1.0.2 - 2026-03-03

- Added support for custom shapes for toasts
- Improvements

## 1.0.1 - 2026-02-28

- Updated docs

## 1.0.0 - 2026-02-27

- Initial release of Flutter Toasty, a customizable toast library for Flutter applications.
