# RxFit Wellness iOS App

## Overview
iOS Capacitor wrapper app for the RxFit Wellness platform (https://app.rxfit.ai). This is a B2B2C wellness coaching platform for Industrial Athletes. The app provides a native iOS shell with HealthKit integration that wraps the existing web application.

## Current State
- **Phase**: App Store ready — all audit issues resolved
- **Last Updated**: 2026-03-05

## Architecture

### Tech Stack
- **Web Layer**: Vanilla HTML/CSS/JS with Vite bundler
- **Native Bridge**: Capacitor 8 (iOS)
- **Native Plugins**: Custom Swift HealthKit plugin, @capgo/capacitor-native-biometric (Face ID/Touch ID)
- **Capacitor Plugins**: @capacitor/haptics, @capacitor/browser, @capacitor/network, @capacitor/preferences
- **Target**: iOS 16.0+
- **Bundle ID**: com.rxfit.wellness

### Project Structure
```
rxfit-wellness/
├── src/                          # Web source files
│   ├── index.html                # Main HTML with splash, login, healthkit, loading screens
│   ├── privacy-policy.html       # Privacy policy page (required for App Store)
│   ├── css/app.css               # Clinical Luxury dark theme styling
│   └── js/
│       ├── app.js                # Main app controller & lifecycle
│       ├── auth.js               # Auth service + biometrics + remember me
│       ├── constants.js          # Shared constants (APP_VERSION)
│       ├── healthkit.js          # HealthKit JS bridge service
│       └── screens.js            # Screen navigation manager
├── ios-plugins/RxFitHealthKit/   # Native Swift HealthKit plugin
│   ├── RxFitHealthKitPlugin.swift    # Capacitor plugin bridge
│   ├── RxFitHealthKitPlugin.m        # Objective-C bridge macro
│   ├── HealthKitSyncManager.swift    # HealthKit query & data formatting
│   └── UIColor+RxFit.swift           # UIColor extension with full brand palette
├── ios-config/                   # iOS configuration files
│   ├── Info.plist                # App config + privacy descriptions + Face ID + WKAppBoundDomains
│   ├── RxFitWellness.entitlements    # HealthKit + background capabilities
│   ├── AppDelegate.swift         # App lifecycle + background fetch + session expiry
│   ├── LaunchScreen.storyboard   # Branded launch screen
│   └── AppIcon.appiconset/       # App icon asset catalog with Contents.json
├── app-icon/icon-1024.png        # Source app icon (1024x1024)
├── capacitor.config.ts           # Capacitor config
├── vite.config.js                # Vite dev server config
├── SETUP_GUIDE.md                # Full Xcode setup instructions
├── APP_STORE_DESCRIPTION.md      # App Store listing text and review notes
└── package.json
```

### App Flow
1. Splash screen (branded logo + spinner while checking session)
2. Check for existing session cookie
3. If no session: show login screen with biometric option (if available)
4. Login via email/password or Face ID/Touch ID
5. If new user on iOS: show HealthKit permission screen
6. Verify server reachability, then load https://app.rxfit.ai
7. Sync HealthKit data on foreground and via background delivery
8. Session expiry detected at native level, returns to login

### API Endpoints
- `POST /api/auth/client-login` — Email/password auth
- `POST /api/healthkit/sync` — Send HealthKit samples (max 5000/batch)
- `GET /api/healthkit/status` — Check HealthKit connection / session validity
- `POST /api/healthkit/disconnect` — Disconnect HealthKit

### Design System — "F1 Clinical Luxury"
- **Aesthetic**: F1-inspired high-performance engineering meets clinical wellness — deep matte blacks, sharp brutalist edges, champagne gold accents
- **Background (dark)**: #050505 (deep matte black, no blue tint)
- **Card (dark)**: #121212
- **Input (dark)**: #1A1A1A
- **Gold accent**: #C5A059 (muted champagne gold)
- **Clinical white (CTA)**: #F8F8F6 (egg white for primary buttons)
- **Text foreground**: #E0E0E0
- **Text muted**: #6B6B6B
- **Border (dark)**: #2A2A2A
- **Body font**: Inter (geometric sans-serif)
- **Heading font**: JetBrains Mono (monospaced, telemetry feel)
- **Border radius**: 0px — sharp brutalist edges, no rounding
- **Shadows**: None
- **Background pattern**: Subtle engineering grid lines at 2% opacity, 40px spacing
- **Primary button**: Egg white bg (#F8F8F6) with black text; hover inverts to black bg, gold border, white text

## Recent Changes
- 2026-02-20: Initial project setup with full Capacitor iOS app structure
- 2026-02-20: Created branded login screen, HealthKit onboarding screen, loading screen
- 2026-02-20: Built custom Swift HealthKit plugin with all 12+ data types
- 2026-02-20: Configured iOS Info.plist, entitlements, AppDelegate, launch screen
- 2026-02-20: Updated design to match exact Clinical Luxury style guide from web app
- 2026-02-20: Added UIColor+RxFit.swift extension with complete brand color palette
- 2026-02-20: Fixed cookie/session sync, ISO8601 parsing, removed health-records entitlement
- 2026-02-20: Added keyboard scroll handling for small iPhone screens
- 2026-02-20: Added "Forgot password?" link (opens in system browser via @capacitor/browser)
- 2026-02-20: Added loading failure recovery with retry button and back-to-login option
- 2026-02-20: Added session expiry detection (native AppDelegate level, checks on foreground)
- 2026-02-20: Increased all input/button touch targets to 48px (Apple HIG minimum 44px)
- 2026-02-20: Added privacy policy page for App Store compliance
- 2026-02-20: Added AppIcon asset catalog with Contents.json
- 2026-02-20: Added offline detection with banner (Capacitor Network plugin)
- 2026-02-20: Added splash screen for smooth session-check transition
- 2026-02-20: Added haptic feedback on login success/error (@capacitor/haptics)
- 2026-02-20: Added version display in login footer (v1.0.0)
- 2026-02-20: Added password visibility toggle (show/hide eye icon)
- 2026-02-20: Added remember me (email pre-fill from last login)
- 2026-02-20: Added Face ID / Touch ID biometric login (@capgo/capacitor-native-biometric)
- 2026-02-20: Added NSFaceIDUsageDescription to Info.plist
- 2026-02-20: Added login helper text ("Sign in with the account you created on app.rxfit.ai")
- 2026-02-20: Added HealthKit denial recovery screen with numbered steps and Settings deep-link
- 2026-02-20: Fixed footer overlap — changed from absolute positioning to normal document flow
- 2026-02-20: Optimized favicon from 2.2MB to ~6KB (64x64px), kept full-size for apple-touch-icon
- 2026-02-20: Updated all screens (splash, loading, HealthKit, denied) to use RK badge logo consistently
- 2026-02-20: Reviewed privacy policy — confirmed App Store compliant, no changes needed
- 2026-02-20: **Pre-App Store audit completed — 7 issues fixed:**
  - CRITICAL: Removed dev test login bypass (test@rxfit.ai/test123) from auth.js
  - CRITICAL: Migrated healthkit.js state (prompted, lastSync) from localStorage to Capacitor Preferences
  - HIGH: Aligned @capacitor/cli to v8.1.0 (was 7.x, mismatched core/ios 8.x)
  - HIGH: Removed NSHealthUpdateUsageDescription from Info.plist (app is read-only)
  - MEDIUM: Added null guards for all DOM queries in app.js bindEvents/handlers
  - MEDIUM: Safe unwrapped force-unwrapped URLs in AppDelegate.swift
  - MEDIUM: Fixed invalid URL scheme "RxFit Wellness" → "rxfitwellness" in capacitor.config.ts
- 2026-03-03: **F1 Clinical Luxury aesthetic overhaul:**
  - Backgrounds shifted from blue-tinted darks to pure matte blacks (#050505, #121212)
  - Gold accent changed from bright #E8B430 to muted champagne #C5A059
  - All border-radius set to 0px (sharp brutalist edges)
  - Primary buttons now egg white (#F8F8F6) with black text, hover inverts to black/gold
  - Added subtle engineering grid background (2% opacity, 40px spacing)
  - Updated UIColor+RxFit.swift with new palette (no blue tint, pure grays)
  - Updated LaunchScreen.storyboard colors and removed corner radius
  - Updated privacy-policy.html inline styles to match
  - Updated theme-color meta tag to #050505
- 2026-03-05: **Final App Store audit — 5 remaining issues fixed:**
  - Expanded HealthKit background delivery from 3 to all 14 data types with observer queries
  - Added "I've Enabled It — Check Again" re-check button on HealthKit denied screen
  - Added NSHealthUpdateUsageDescription to Info.plist (required even for read-only apps)
  - Added 'processing' to UIBackgroundModes in Info.plist
  - Created shared version constant (src/js/constants.js) — removed hardcoded '1.0.0' from auth.js and healthkit.js

## User Preferences
- Design aesthetic: "F1 Clinical Luxury" — F1-inspired high-performance engineering meets clinical wellness
- Terminology: Use "athlete" (never "participant" or "user")
- Full style guide reference: attached_assets/ios-wrapper-style-guide_1771547350951.md

## Development Notes
- The web layer (src/) serves as the Capacitor web dir for the login/onboarding screens
- Once authenticated, Capacitor navigates to the live web app at app.rxfit.ai
- HealthKit plugin is in ios-plugins/ and must be copied into Xcode project manually
- iOS config files are in ios-config/ and must be copied after `cap add ios`
- Biometric credentials stored in iOS Keychain via @capgo/capacitor-native-biometric
- Privacy policy at src/privacy-policy.html — URL needed for App Store Connect
- See SETUP_GUIDE.md for complete Xcode build instructions
