# Web Design Tokens — Platform Deviations

This document records deviations between the Android (Jetpack Compose) design tokens and the CSS/Tailwind web equivalents where a direct 1:1 mapping is not possible.

## 1. Elevation → Box Shadow

**Android**: Uses `elevation` in dp which triggers the platform's native shadow rendering (ambient + key light, respecting view shape and z-ordering).

**Web**: CSS has no concept of elevation-based shadows. We approximate using `box-shadow` with layered values tuned to visually match the Android rendering at each level:

| Android Token | Android Value | CSS Approximation |
|---|---|---|
| `Elevation.none` | 0.dp | `none` |
| `Elevation.low` | 1.dp | `0 1px 2px 0 rgba(15,23,42,0.05)` |
| `Elevation.medium` | 4.dp | `0 4px 6px -1px rgba(15,23,42,0.07), 0 2px 4px -2px rgba(15,23,42,0.05)` |
| `Elevation.high` | 8.dp | `0 8px 16px -4px rgba(15,23,42,0.10), 0 4px 6px -2px rgba(15,23,42,0.05)` |
| `Elevation.overlay` | 16.dp | `0 16px 32px -8px rgba(15,23,42,0.15), 0 8px 16px -4px rgba(15,23,42,0.08)` |

Shadow color uses Royal Navy (`#0F172A`) at low opacity to maintain brand consistency rather than pure black.

## 2. RoundedCornerShape(50) → border-radius: 9999px

**Android**: `RoundedCornerShape(50)` uses a percentage (50%) which creates a pill shape relative to the element's dimensions.

**Web**: CSS `border-radius: 50%` creates an ellipse on non-square elements. The standard web pattern for pill shapes is `border-radius: 9999px` which achieves the same visual result regardless of element dimensions.

## 3. Font Units: sp → rem

**Android**: Uses `sp` (scale-independent pixels) which respects the user's system font size preference.

**Web**: Uses `rem` which respects the root font size (typically 16px by default). Both scale with user accessibility settings, making this a functionally equivalent mapping. The conversion is 1:1 when the base is 16 (16sp = 1rem at default browser settings).

## 4. Spacing Units: dp → rem

**Android**: Uses `dp` (density-independent pixels) for layout spacing. 1dp = 1 physical pixel at 160dpi.

**Web**: Uses `rem` for spacing. At the standard 16px root font size, 16dp = 1rem. This maintains proportional spacing across screen densities, similar to how dp works on Android.

## 5. Font Family

**Android**: Uses `FontFamily.SansSerif` which resolves to the system default (Roboto on most Android devices).

**Web**: Specifies `Inter` as the primary font and `Outfit` for display text, with system-ui fallbacks. These are Google Fonts that closely match the geometric sans-serif aesthetic of Roboto while being optimized for web rendering. Both fonts must be loaded via `@font-face` or Google Fonts CDN.

## 6. Letter Spacing

**Android**: Specifies letter spacing in `sp` units (e.g., `-0.5.sp`).

**Web**: Converted to `rem` using the same 16sp = 1rem ratio. CSS `letter-spacing` applies uniformly to all characters, which is functionally identical to Android's implementation.

## 7. Haptic Feedback

**Android**: Supports `HapticFeedbackType` for tactile responses on button presses and interactions.

**Web**: No direct equivalent. The Web Vibration API (`navigator.vibrate()`) exists but has limited browser support and is not a true haptic equivalent. This token is omitted from web tokens entirely.

## 8. Transitions / Motion

**Android**: Uses Material 3 motion curves and `animateAsState` composables with spring/tween specifications.

**Web**: Approximated with CSS `transition` using `ease` timing function. For more complex animations, consider using Framer Motion or CSS `@keyframes` with cubic-bezier curves matching Material 3 motion specs:
- Standard: `cubic-bezier(0.2, 0, 0, 1)`
- Emphasized: `cubic-bezier(0.2, 0, 0, 1)`
- Decelerate: `cubic-bezier(0, 0, 0, 1)`

## Summary

All **color values** are numerically identical across platforms (hex values match exactly). **Spacing** and **typography** values are functionally equivalent via the dp/sp → rem conversion. The primary deviations are in **elevation rendering** (shadow approximation) and **platform-specific features** (haptics, native motion curves) that have no CSS equivalent.
