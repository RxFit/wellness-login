# RxFit Wellness - iOS Wrapper Style Guide

Complete design system reference for building the native iOS wrapper app
to match the RxFit Wellness web platform exactly.

All hex and RGB values are computed directly from the CSS HSL tokens.

---

## Brand Identity

- **App Name:** RxFit Wellness
- **Tagline:** Industrial Athlete
- **Aesthetic:** Clinical Luxury — clean, minimal, high-end medical/wellness feel
- **Terminology:** Use "athlete" (never "participant" or "user")

---

## Color System

### Primary / Gold Accent

| Context    | HSL              | Hex       | RGB                    |
|------------|------------------|-----------|------------------------|
| Light mode | 43 80% 45%       | `#CF9B17` | 0.81, 0.61, 0.09      |
| Dark mode  | 43 80% 55%       | `#E8B430` | 0.91, 0.71, 0.19      |

### Backgrounds

| Token            | Mode  | HSL              | Hex       | RGB                    |
|------------------|-------|------------------|-----------|------------------------|
| background       | Light | 210 20% 98%      | `#F9FAFB` | 0.98, 0.98, 0.98      |
| background       | Dark  | 210 30% 7%       | `#0C1217` | 0.05, 0.07, 0.09      |
| card             | Light | 0 0% 100%        | `#FFFFFF` | 1.00, 1.00, 1.00      |
| card             | Dark  | 210 25% 9%       | `#11171D` | 0.07, 0.09, 0.11      |
| sidebar          | Light | 210 25% 95%      | `#EFF2F5` | 0.94, 0.95, 0.96      |
| sidebar          | Dark  | 210 35% 6%       | `#0A0F15` | 0.04, 0.06, 0.08      |
| popover          | Light | 0 0% 100%        | `#FFFFFF` | 1.00, 1.00, 1.00      |
| popover          | Dark  | 210 28% 10%      | `#121A21` | 0.07, 0.10, 0.13      |
| secondary        | Light | 210 15% 93%      | `#EAEDF0` | 0.92, 0.93, 0.94      |
| secondary        | Dark  | 210 18% 14%      | `#1D242A` | 0.11, 0.14, 0.17      |
| accent           | Light | 210 15% 93%      | `#EAEDF0` | 0.92, 0.93, 0.94      |
| accent           | Dark  | 210 18% 16%      | `#212930` | 0.13, 0.16, 0.19      |
| muted            | Light | 210 12% 94%      | `#ECEEF1` | 0.93, 0.93, 0.95      |
| muted            | Dark  | 210 16% 13%      | `#1C2228` | 0.11, 0.13, 0.16      |
| input            | Light | 210 15% 85%      | `#D2D7DD` | 0.82, 0.84, 0.87      |
| input            | Dark  | 210 18% 22%      | `#2E3842` | 0.18, 0.22, 0.26      |

### Text / Foreground Colors

| Token                  | Mode  | HSL              | Hex       | RGB                    |
|------------------------|-------|------------------|-----------|------------------------|
| foreground             | Light | 210 30% 12%      | `#151F28` | 0.08, 0.12, 0.16      |
| foreground             | Dark  | 200 15% 85%      | `#D3DBDE` | 0.83, 0.86, 0.87      |
| muted-foreground       | Light | 210 10% 45%      | `#67737E` | 0.41, 0.45, 0.50      |
| muted-foreground       | Dark  | 200 10% 50%      | `#73848C` | 0.45, 0.52, 0.55      |
| card-foreground        | Light | 210 30% 12%      | `#151F28` | 0.08, 0.12, 0.16      |
| card-foreground        | Dark  | 200 15% 85%      | `#D3DBDE` | 0.83, 0.86, 0.87      |
| secondary-foreground   | Light | 210 20% 30%      | `#3D4D5C` | 0.24, 0.30, 0.36      |
| secondary-foreground   | Dark  | 200 10% 78%      | `#BFC9CE` | 0.75, 0.79, 0.81      |
| sidebar-foreground     | Light | 210 20% 25%      | `#33404D` | 0.20, 0.25, 0.30      |
| sidebar-foreground     | Dark  | 200 10% 80%      | `#C7CED1` | 0.78, 0.81, 0.82      |
| primary-foreground     | Light | 0 0% 100%        | `#FFFFFF` | 1.00, 1.00, 1.00      |
| primary-foreground     | Dark  | 210 35% 6%       | `#0A0F15` | 0.04, 0.06, 0.08      |

### Border Colors

| Token            | Mode  | HSL              | Hex       | RGB                    |
|------------------|-------|------------------|-----------|------------------------|
| border           | Light | 210 15% 88%      | `#DCE0E5` | 0.86, 0.88, 0.90      |
| border           | Dark  | 210 20% 15%      | `#1F262E` | 0.12, 0.15, 0.18      |
| card-border      | Light | 210 15% 90%      | `#E2E6E9` | 0.89, 0.90, 0.92      |
| card-border      | Dark  | 210 20% 14%      | `#1D242B` | 0.11, 0.14, 0.17      |
| sidebar-border   | Light | 210 15% 88%      | `#DCE0E5` | 0.86, 0.88, 0.90      |
| sidebar-border   | Dark  | 210 25% 12%      | `#171E26` | 0.09, 0.12, 0.15      |

### Destructive / Error

| Context    | HSL              | Hex       | RGB                    |
|------------|------------------|-----------|------------------------|
| Light mode | 0 72% 51%        | `#DC2828` | 0.86, 0.16, 0.16      |
| Dark mode  | 30 90% 50%       | `#F2800D` | 0.95, 0.50, 0.05      |

### Focus Ring

| Context    | HSL              | Hex       | Notes                  |
|------------|------------------|-----------|------------------------|
| Light mode | 43 80% 45%       | `#CF9B17` | Same as primary gold   |
| Dark mode  | 43 80% 55%       | `#E8B430` | Same as primary gold   |

### Engagement / Status Colors

| Name      | Hex       | RGB                    | Usage                  |
|-----------|-----------|------------------------|------------------------|
| Green     | `#3B9A5C` | 0.23, 0.60, 0.36      | Good / active status   |
| Yellow    | `#E6A935` | 0.90, 0.66, 0.21      | Warning / moderate     |
| Red       | `#D94040` | 0.85, 0.25, 0.25      | Critical / inactive    |

### Heart Rate Zone Colors

| Zone   | Name     | Hex       | RGB                    |
|--------|----------|-----------|------------------------|
| Zone 1 | Recovery | `#9CA3AF` | 0.61, 0.64, 0.69      |
| Zone 2 | Fat Burn | `#3B82F6` | 0.23, 0.51, 0.96      |
| Zone 3 | Cardio   | `#F97316` | 0.98, 0.45, 0.09      |
| Zone 4 | Peak     | `#EF4444` | 0.94, 0.27, 0.27      |

### Chart / Data Visualization Colors

| Token    | Light HSL        | Light Hex | Dark HSL         | Dark Hex  |
|----------|------------------|-----------|------------------|-----------|
| chart-1  | 43 80% 45%       | `#CF9B17` | 43 80% 55%       | `#E8B430` |
| chart-2  | 180 60% 35%      | `#248F8F` | 180 60% 45%      | `#2EB8B8` |
| chart-3  | 120 50% 35%      | `#2D862D` | 120 50% 45%      | `#39AC39` |
| chart-4  | 15 80% 50%       | `#E64D19` | 30 90% 55%       | `#F48C25` |
| chart-5  | 260 50% 45%      | `#6039AC` | 260 50% 55%      | `#7953C6` |

---

## Typography

### Font Families

| Role       | Font               | Fallbacks                              |
|------------|--------------------|----------------------------------------|
| Body       | **Inter**          | Helvetica Neue, Arial, sans-serif      |
| Headers    | **JetBrains Mono** | Fira Code, SF Mono, Menlo, monospace   |

Bundle both fonts in the iOS app for an exact match. Available from Google Fonts.

### Font Weights Used

| Weight Value | Usage                              |
|-------------|-------------------------------------|
| 300         | Decorative / subtle labels          |
| 400         | Body text                           |
| 500         | Emphasized body, section labels     |
| 600         | Sub-headers, card titles            |
| 700         | Main headers, stat values           |

### Letter Spacing

| Context               | Value      |
|-----------------------|------------|
| Body text              | 0.02em     |
| Headers (h1-h6)       | 0.05em     |
| Section labels         | 0.12em     |
| HUD labels             | 0.20em     |
| Stat unit labels       | 0.10-0.15em |

### Text Utility Classes (from CSS)

```
.section-label:
  font: JetBrains Mono, 11px, weight 500
  transform: uppercase
  letter-spacing: 0.12em
  color: muted-foreground

.hud-label:
  font: JetBrains Mono, 9px
  transform: uppercase
  letter-spacing: 0.20em
  color: muted-foreground

.hud-glow (dark mode):
  text-shadow: 0 0 8px hsl(43 80% 55% / 0.4)

.hud-glow (light mode):
  text-shadow: 0 0 6px hsl(43 80% 45% / 0.25)
```

### Text Sizing Scale

| Size (px) | Size (pt iOS) | Usage                        |
|-----------|---------------|------------------------------|
| 9px       | 9pt           | HUD labels, micro labels     |
| 10px      | 10pt          | Stat labels, unit labels     |
| 11px      | 11pt          | Section labels               |
| 12px      | 12pt          | Secondary info, timestamps   |
| 14px      | 14pt          | Body small, descriptions     |
| 16px      | 16pt          | Default body text            |
| 18px      | 18pt          | Card titles                  |
| 20px      | 20pt          | Stat values, emphasis text   |
| 24px      | 24pt          | Page headers                 |
| 30px      | 30pt          | Hero text                    |

### Text Patterns Used in App

```
Section markers:   "// RECOVERY & LONGEVITY"
                   JetBrains Mono, 9px, uppercase, tracking 0.25em, muted foreground, medium weight

Stat labels:       "WEIGHT", "RHR", "STEPS"
                   10px, uppercase, tracking 0.15em, muted foreground

Stat values:       "225.0", "72", "--"
                   20px, bold, foreground color

Unit labels:       "LBS", "BPM", "KCAL"
                   10px, uppercase, tracking 0.10em, muted foreground
```

---

## Spacing & Layout

### Base Spacing Unit

`0.25rem` (4px) — all spacing is multiples of this unit.

| Multiplier | Value  | Usage                              |
|------------|--------|------------------------------------|
| 1          | 4px    | Tight gaps, icon margins           |
| 2          | 8px    | Inner padding, compact spacing     |
| 3          | 12px   | Standard gap between small items   |
| 4          | 16px   | Standard padding, card gaps        |
| 5          | 20px   | Section spacing                    |
| 6          | 24px   | Card inner padding                 |
| 8          | 32px   | Section gaps                       |
| 10         | 40px   | Large section separators           |

### Border Radius

| Element   | Radius   |
|-----------|----------|
| Default   | 4px (0.25rem) |
| Buttons   | 4px      |
| Cards     | 4px      |
| Inputs    | 4px      |
| Badges    | 4px      |
| Avatars   | Full circle (50%) |

**Key rule:** Almost everything uses the same 4px radius. No large rounded corners except circles (avatars, radial gauges).

### Shadows

Light mode uses subtle shadows. Dark mode uses no shadows (all values set to 0 opacity).

```
Light mode shadow-sm: 0px 1px 3px rgba(0,0,0,0.06), 0px 1px 2px -1px rgba(0,0,0,0.06)
Light mode shadow-md: 0px 4px 6px -1px rgba(0,0,0,0.07), 0px 2px 4px -2px rgba(0,0,0,0.05)
Dark mode: No shadows (all 0 opacity)
```

---

## Component Patterns

### Buttons

| Variant     | Background          | Text                 | Border              |
|-------------|---------------------|----------------------|---------------------|
| Primary     | Gold primary        | primary-foreground   | Slightly shifted    |
| Secondary   | secondary bg        | secondary-foreground | Slightly shifted    |
| Ghost       | Transparent         | foreground           | None                |
| Outline     | Transparent         | foreground           | border color        |
| Destructive | destructive         | white                | Slightly shifted    |

**Button heights:**
- Default: 36px min-height
- Small: 32px
- Large: 40px
- Icon: 36px x 36px square

### Cards

- Background: card token
- Border: card-border token
- Border radius: 4px
- Padding: 16-24px
- No heavy drop shadows

### Input Fields

- Height: 36px
- Border: input token border
- Border radius: 4px
- Background: transparent (light) / input token (dark)
- Padding: 8px 12px
- Focus ring: gold (ring token)

### Badges / Status Pills

- Border radius: 4px
- Padding: 2px 8px
- Font size: 12px
- Compact height (smaller than buttons)

### Navigation Sidebar

- Width: 320px (20rem), collapses to 64px (4rem) icon-only
- Background: sidebar token
- Active item: sidebar-accent background
- Active indicator: gold sidebar-primary color

---

## iOS-Specific: Login & Onboarding Screens

Use the **dark mode palette** for native screens — it matches the brand's
premium clinical luxury feel.

### Login Screen

```
Background:     #0C1217 (background dark)
Logo:           RxFit AI logo, centered, gold/white
Title:          "RxFit Wellness" — JetBrains Mono, 30pt, bold, #D3DBDE
Subtitle:       "Industrial Athlete" — Inter, 14pt, medium, #73848C (muted dark)

Email input:    Full width, #11171D bg (card dark), #D3DBDE text, #E8B430 focus ring
Password input: Full width, matching style

Login button:   Full width, #E8B430 bg (gold dark), #0A0F15 text, 4px radius
                "Sign In" — Inter, 16pt, semi-bold

Divider:        "or" with horizontal lines, #73848C color

Alt login:      "Continue with Replit" — outline style, #1F262E border, #D3DBDE text

Footer link:    "Create Account" — #E8B430 text (gold dark), Inter, 14pt
```

### Onboarding / HealthKit Permissions Screen

```
Background:     #0C1217

Icon:           Apple Health icon or heart icon, #E8B430 gold, 48pt

Title:          "Connect Apple Health" — JetBrains Mono, 24pt, #D3DBDE
Description:    "Sync your health data for personalized coaching insights"
                Inter, 16pt, #73848C, centered, max 280px wide

Benefits list:  Checkmark icons in #E8B430 gold, #D3DBDE text, Inter 14pt
                - "Heart rate & HRV tracking"
                - "Sleep quality analysis"
                - "VO2 Max & respiratory monitoring"
                - "Automatic workout detection"

Allow button:   Full width, #E8B430 bg, #0A0F15 text, "Enable Health Sync"
Skip button:    Full width, transparent, #73848C text, "Set Up Later"

Spacing:        32px between sections, 12px between list items
```

### Goal Selection Screen

```
Background:     #0C1217

Title:          "Select Your Primary Focus" — JetBrains Mono, 24pt, #D3DBDE

Cards:          #11171D bg (card dark), #1D242B border, 4px radius, 16px padding
                Full width, stacked vertically, 12px gap

Focus options:
  - Aesthetics
  - Nutrition
  - Body Composition
  - Longevity
  - Lifestyle

Each card:      Icon (#E8B430 gold) + Focus name (#D3DBDE, 16pt, semi-bold)
Selected state: #E8B430 border, subtle gold bg tint

Continue btn:   Full width, #E8B430 bg, #0A0F15 text, "Get Started"
```

---

## iOS-Specific: WebView Configuration

After login/onboarding, load the main app via WebView.

```swift
let appURL = URL(string: "https://app.rxfit.ai")!

// Status bar: Light content (white text) — matches dark nav
// Safe area: Respect safe areas, extend backgrounds edge-to-edge
// Navigation bar: Hidden (web app has its own)
// Tab bar: Hidden (web app has its own sidebar)
// Pull-to-refresh tint: #E8B430 (gold)
// Loading indicator: Gold activity indicator on #0C1217 background
```

---

## Swift Color Extension (Copy-Paste Ready)

```swift
import UIKit

extension UIColor {
    struct RxFit {
        // MARK: - Primary / Gold
        static let gold = UIColor(red: 0.81, green: 0.61, blue: 0.09, alpha: 1.0)        // Light: 43 80% 45%
        static let goldDark = UIColor(red: 0.91, green: 0.71, blue: 0.19, alpha: 1.0)     // Dark: 43 80% 55%

        // MARK: - Backgrounds
        static let backgroundLight = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)  // 210 20% 98%
        static let backgroundDark = UIColor(red: 0.05, green: 0.07, blue: 0.09, alpha: 1.0)   // 210 30% 7%
        static let cardLight = UIColor.white                                                     // 0 0% 100%
        static let cardDark = UIColor(red: 0.07, green: 0.09, blue: 0.11, alpha: 1.0)          // 210 25% 9%
        static let sidebarLight = UIColor(red: 0.94, green: 0.95, blue: 0.96, alpha: 1.0)      // 210 25% 95%
        static let sidebarDark = UIColor(red: 0.04, green: 0.06, blue: 0.08, alpha: 1.0)       // 210 35% 6%
        static let popoverDark = UIColor(red: 0.07, green: 0.10, blue: 0.13, alpha: 1.0)       // 210 28% 10%
        static let secondaryLight = UIColor(red: 0.92, green: 0.93, blue: 0.94, alpha: 1.0)    // 210 15% 93%
        static let secondaryDark = UIColor(red: 0.11, green: 0.14, blue: 0.17, alpha: 1.0)     // 210 18% 14%
        static let accentLight = UIColor(red: 0.92, green: 0.93, blue: 0.94, alpha: 1.0)       // 210 15% 93%
        static let accentDark = UIColor(red: 0.13, green: 0.16, blue: 0.19, alpha: 1.0)        // 210 18% 16%
        static let inputDark = UIColor(red: 0.18, green: 0.22, blue: 0.26, alpha: 1.0)         // 210 18% 22%

        // MARK: - Text / Foreground
        static let foregroundLight = UIColor(red: 0.08, green: 0.12, blue: 0.16, alpha: 1.0)   // 210 30% 12%
        static let foregroundDark = UIColor(red: 0.83, green: 0.86, blue: 0.87, alpha: 1.0)    // 200 15% 85%
        static let mutedFgLight = UIColor(red: 0.41, green: 0.45, blue: 0.50, alpha: 1.0)      // 210 10% 45%
        static let mutedFgDark = UIColor(red: 0.45, green: 0.52, blue: 0.55, alpha: 1.0)       // 200 10% 50%
        static let sidebarFgLight = UIColor(red: 0.20, green: 0.25, blue: 0.30, alpha: 1.0)    // 210 20% 25%
        static let sidebarFgDark = UIColor(red: 0.78, green: 0.81, blue: 0.82, alpha: 1.0)     // 200 10% 80%
        static let secondaryFgLight = UIColor(red: 0.24, green: 0.30, blue: 0.36, alpha: 1.0)  // 210 20% 30%
        static let secondaryFgDark = UIColor(red: 0.75, green: 0.79, blue: 0.81, alpha: 1.0)   // 200 10% 78%
        static let primaryFgLight = UIColor.white                                                // 0 0% 100%
        static let primaryFgDark = UIColor(red: 0.04, green: 0.06, blue: 0.08, alpha: 1.0)     // 210 35% 6%

        // MARK: - Borders
        static let borderLight = UIColor(red: 0.86, green: 0.88, blue: 0.90, alpha: 1.0)       // 210 15% 88%
        static let borderDark = UIColor(red: 0.12, green: 0.15, blue: 0.18, alpha: 1.0)        // 210 20% 15%
        static let cardBorderLight = UIColor(red: 0.89, green: 0.90, blue: 0.92, alpha: 1.0)   // 210 15% 90%
        static let cardBorderDark = UIColor(red: 0.11, green: 0.14, blue: 0.17, alpha: 1.0)    // 210 20% 14%
        static let sidebarBorderDark = UIColor(red: 0.09, green: 0.12, blue: 0.15, alpha: 1.0) // 210 25% 12%

        // MARK: - Destructive
        static let destructiveLight = UIColor(red: 0.86, green: 0.16, blue: 0.16, alpha: 1.0)  // 0 72% 51%
        static let destructiveDark = UIColor(red: 0.95, green: 0.50, blue: 0.05, alpha: 1.0)   // 30 90% 50%

        // MARK: - Engagement / Status
        static let statusGreen = UIColor(red: 0.23, green: 0.60, blue: 0.36, alpha: 1.0)       // #3B9A5C
        static let statusYellow = UIColor(red: 0.90, green: 0.66, blue: 0.21, alpha: 1.0)      // #E6A935
        static let statusRed = UIColor(red: 0.85, green: 0.25, blue: 0.25, alpha: 1.0)         // #D94040

        // MARK: - HR Zones
        static let zoneRecovery = UIColor(red: 0.61, green: 0.64, blue: 0.69, alpha: 1.0)      // #9CA3AF
        static let zoneFatBurn = UIColor(red: 0.23, green: 0.51, blue: 0.96, alpha: 1.0)       // #3B82F6
        static let zoneCardio = UIColor(red: 0.98, green: 0.45, blue: 0.09, alpha: 1.0)        // #F97316
        static let zonePeak = UIColor(red: 0.94, green: 0.27, blue: 0.27, alpha: 1.0)          // #EF4444

        // MARK: - Chart Colors (Light Mode)
        static let chart1Light = gold                                                             // 43 80% 45%
        static let chart2Light = UIColor(red: 0.14, green: 0.56, blue: 0.56, alpha: 1.0)       // 180 60% 35%
        static let chart3Light = UIColor(red: 0.17, green: 0.52, blue: 0.17, alpha: 1.0)       // 120 50% 35%
        static let chart4Light = UIColor(red: 0.90, green: 0.30, blue: 0.10, alpha: 1.0)       // 15 80% 50%
        static let chart5Light = UIColor(red: 0.37, green: 0.23, blue: 0.68, alpha: 1.0)       // 260 50% 45%

        // MARK: - Chart Colors (Dark Mode)
        static let chart1Dark = goldDark                                                          // 43 80% 55%
        static let chart2Dark = UIColor(red: 0.18, green: 0.72, blue: 0.72, alpha: 1.0)        // 180 60% 45%
        static let chart3Dark = UIColor(red: 0.23, green: 0.68, blue: 0.23, alpha: 1.0)        // 120 50% 45%
        static let chart4Dark = UIColor(red: 0.96, green: 0.55, blue: 0.15, alpha: 1.0)        // 30 90% 55%
        static let chart5Dark = UIColor(red: 0.47, green: 0.33, blue: 0.78, alpha: 1.0)        // 260 50% 55%
    }
}
```

---

## SwiftUI Color Extension (Copy-Paste Ready)

```swift
import SwiftUI

extension Color {
    struct RxFit {
        // Primary
        static let gold = Color(red: 0.81, green: 0.61, blue: 0.09)              // Light
        static let goldDark = Color(red: 0.91, green: 0.71, blue: 0.19)          // Dark

        // Backgrounds
        static let backgroundLight = Color(red: 0.98, green: 0.98, blue: 0.98)
        static let backgroundDark = Color(red: 0.05, green: 0.07, blue: 0.09)
        static let cardLight = Color.white
        static let cardDark = Color(red: 0.07, green: 0.09, blue: 0.11)
        static let sidebarLight = Color(red: 0.94, green: 0.95, blue: 0.96)
        static let sidebarDark = Color(red: 0.04, green: 0.06, blue: 0.08)
        static let secondaryLight = Color(red: 0.92, green: 0.93, blue: 0.94)
        static let secondaryDark = Color(red: 0.11, green: 0.14, blue: 0.17)
        static let accentLight = Color(red: 0.92, green: 0.93, blue: 0.94)
        static let accentDark = Color(red: 0.13, green: 0.16, blue: 0.19)
        static let inputDark = Color(red: 0.18, green: 0.22, blue: 0.26)

        // Text
        static let foregroundLight = Color(red: 0.08, green: 0.12, blue: 0.16)
        static let foregroundDark = Color(red: 0.83, green: 0.86, blue: 0.87)
        static let mutedFgLight = Color(red: 0.41, green: 0.45, blue: 0.50)
        static let mutedFgDark = Color(red: 0.45, green: 0.52, blue: 0.55)
        static let sidebarFgLight = Color(red: 0.20, green: 0.25, blue: 0.30)
        static let sidebarFgDark = Color(red: 0.78, green: 0.81, blue: 0.82)
        static let primaryFgDark = Color(red: 0.04, green: 0.06, blue: 0.08)

        // Borders
        static let borderLight = Color(red: 0.86, green: 0.88, blue: 0.90)
        static let borderDark = Color(red: 0.12, green: 0.15, blue: 0.18)
        static let cardBorderLight = Color(red: 0.89, green: 0.90, blue: 0.92)
        static let cardBorderDark = Color(red: 0.11, green: 0.14, blue: 0.17)

        // Destructive
        static let destructiveLight = Color(red: 0.86, green: 0.16, blue: 0.16)
        static let destructiveDark = Color(red: 0.95, green: 0.50, blue: 0.05)

        // Status
        static let statusGreen = Color(red: 0.23, green: 0.60, blue: 0.36)
        static let statusYellow = Color(red: 0.90, green: 0.66, blue: 0.21)
        static let statusRed = Color(red: 0.85, green: 0.25, blue: 0.25)

        // HR Zones
        static let zoneRecovery = Color(red: 0.61, green: 0.64, blue: 0.69)
        static let zoneFatBurn = Color(red: 0.23, green: 0.51, blue: 0.96)
        static let zoneCardio = Color(red: 0.98, green: 0.45, blue: 0.09)
        static let zonePeak = Color(red: 0.94, green: 0.27, blue: 0.27)

        // Charts (Light)
        static let chart1Light = gold
        static let chart2Light = Color(red: 0.14, green: 0.56, blue: 0.56)
        static let chart3Light = Color(red: 0.17, green: 0.52, blue: 0.17)
        static let chart4Light = Color(red: 0.90, green: 0.30, blue: 0.10)
        static let chart5Light = Color(red: 0.37, green: 0.23, blue: 0.68)

        // Charts (Dark)
        static let chart1Dark = goldDark
        static let chart2Dark = Color(red: 0.18, green: 0.72, blue: 0.72)
        static let chart3Dark = Color(red: 0.23, green: 0.68, blue: 0.23)
        static let chart4Dark = Color(red: 0.96, green: 0.55, blue: 0.15)
        static let chart5Dark = Color(red: 0.47, green: 0.33, blue: 0.78)
    }
}
```

---

## Key Design Rules Summary

1. **Border radius is always 4px** except for perfect circles (avatars)
2. **No shadows in dark mode** — flat design; minimal shadows in light mode only
3. **Three text hierarchy levels:** foreground (default), muted-foreground (secondary), 9px labels (tertiary)
4. **Headers use monospace** (JetBrains Mono), body uses sans-serif (Inter)
5. **Section markers** use `//` prefix: `"// RECOVERY & LONGEVITY"`
6. **Uppercase tracking** on labels and category markers (0.12-0.20em)
7. **Gold is the only accent color** — everything else is neutral blue-grey
8. **Interactive elements** use subtle elevation on hover/press, not color changes
9. **Cards never nest inside cards**
10. **Consistent spacing** — 16px standard padding, 24px generous padding
