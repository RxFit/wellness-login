# RxFit Wellness iOS App - Setup Guide

## Prerequisites
- macOS with Xcode 15+ installed
- Apple Developer account
- Node.js 20+
- CocoaPods

## Quick Start

### 1. Install Dependencies
```bash
npm install
```

### 2. Build Web Assets
```bash
npm run build
```

### 3. Initialize Capacitor iOS
```bash
npx cap add ios
npx cap sync ios
```

### 4. Copy Native Plugin Files
Copy the Swift HealthKit plugin into the Xcode project:
```bash
cp ios-plugins/RxFitHealthKit/RxFitHealthKitPlugin.swift ios/App/App/
cp ios-plugins/RxFitHealthKit/RxFitHealthKitPlugin.m ios/App/App/
cp ios-plugins/RxFitHealthKit/HealthKitSyncManager.swift ios/App/App/
cp ios-plugins/RxFitHealthKit/UIColor+RxFit.swift ios/App/App/
```

### 5. Copy iOS Configuration Files
```bash
cp ios-config/Info.plist ios/App/App/Info.plist
cp ios-config/RxFitWellness.entitlements ios/App/App/RxFitWellness.entitlements
cp ios-config/AppDelegate.swift ios/App/App/AppDelegate.swift
cp ios-config/LaunchScreen.storyboard ios/App/App/LaunchScreen.storyboard
```

### 6. Set Up App Icon
Copy the AppIcon asset catalog into the Xcode project:
```bash
cp app-icon/icon-1024.png ios-config/AppIcon.appiconset/icon-1024.png
cp -r ios-config/AppIcon.appiconset ios/App/App/Assets.xcassets/AppIcon.appiconset
```
Then in Xcode, verify the icon appears under Assets.xcassets > AppIcon.

### 7. Xcode Configuration
Open the project in Xcode:
```bash
npx cap open ios
```

Then in Xcode:
1. Select the **App** target
2. Go to **Signing & Capabilities**
3. Set Team to your Apple Developer account
4. Set Bundle Identifier to `com.rxfit.wellness`
5. Click **+ Capability** and add **HealthKit**
6. Under HealthKit, make sure only "Background Delivery" is checked (do NOT check Clinical Health Records)
7. Click **+ Capability** and add **Background Modes**
8. Check "Background fetch" only
9. Under **Build Settings**, set iOS Deployment Target to 16.0
10. Under **Build Settings** > **Code Signing Entitlements**, point to `App/RxFitWellness.entitlements`

### 8. Sync After Config Changes
After copying files, run sync again to ensure Capacitor picks up changes:
```bash
npx cap sync ios
```

### 9. Run on Device
Select your connected iPhone and press Run (Cmd+R).

> **Important**: HealthKit and Face ID/Touch ID require a physical device — they do not work in the Simulator.
> Login, UI, and basic navigation can be tested in the Simulator.

## Project Structure
```
rxfit-wellness/
├── src/                          # Web source files
│   ├── index.html                # Main HTML with all screens (splash, login, healthkit, loading)
│   ├── privacy-policy.html       # Privacy policy page (required for App Store)
│   ├── css/app.css               # Clinical Luxury dark theme styling
│   └── js/
│       ├── app.js                # Main app controller & lifecycle
│       ├── auth.js               # Authentication + biometric login + remember me
│       ├── healthkit.js          # HealthKit JS bridge service
│       └── screens.js            # Screen navigation manager
├── ios-plugins/RxFitHealthKit/   # Native Swift HealthKit plugin
│   ├── RxFitHealthKitPlugin.swift    # Capacitor plugin bridge
│   ├── RxFitHealthKitPlugin.m        # Objective-C bridge macro
│   ├── HealthKitSyncManager.swift    # HealthKit query & sync logic
│   └── UIColor+RxFit.swift           # UIColor extension with brand palette
├── ios-config/                   # iOS project configuration files
│   ├── Info.plist                # App config + privacy descriptions + Face ID + WKAppBoundDomains
│   ├── RxFitWellness.entitlements    # HealthKit + background delivery entitlements
│   ├── AppDelegate.swift         # App lifecycle + background fetch + session expiry detection
│   ├── LaunchScreen.storyboard   # Branded launch screen
│   └── AppIcon.appiconset/       # App icon asset catalog
│       └── Contents.json         # Icon set configuration
├── app-icon/icon-1024.png        # Source app icon (1024x1024)
├── capacitor.config.ts           # Capacitor config (CapacitorHttp + CapacitorCookies enabled)
├── vite.config.js                # Vite build configuration
├── APP_STORE_DESCRIPTION.md      # App Store listing text and review notes
└── package.json                  # Dependencies
```

## How Authentication Works
1. The app shows a splash screen while checking for an existing session
2. If no session, the login screen appears with email pre-filled (if previously used)
3. Athletes can sign in with email/password or Face ID/Touch ID (after first login)
4. Login uses Capacitor's native HTTP plugin (`CapacitorHttp`) to bypass CORS
5. `CapacitorCookies` syncs session cookies between native HTTP and WKWebView
6. On successful login, credentials are saved to iOS Keychain for biometric login
7. `WKAppBoundDomains` in Info.plist ensures cookie persistence for `app.rxfit.ai`

## Features
- **Biometric Login**: Face ID / Touch ID using `@capgo/capacitor-native-biometric` with iOS Keychain credential storage
- **Remember Me**: Email auto-filled from last successful login
- **Haptic Feedback**: Success/error haptics on login via `@capacitor/haptics`
- **Offline Detection**: Network status monitoring with offline banner via `@capacitor/network`
- **Password Visibility Toggle**: Show/hide password with eye icon
- **Forgot Password**: Opens reset page in system browser via `@capacitor/browser`
- **Loading Recovery**: Server check before navigation, retry button and back-to-login on failure
- **Session Expiry**: Native-level detection in AppDelegate returns to login on 401/403
- **Privacy Policy**: In-app privacy policy page at /privacy-policy.html
- **Version Display**: App version shown in login footer for support reference

## API Endpoints Used
- `POST /api/auth/client-login` — Authentication
- `POST /api/healthkit/sync` — Sync HealthKit samples (max 5000 per batch)
- `GET /api/healthkit/status` — Check HealthKit connection status / session validity
- `POST /api/healthkit/disconnect` — Disconnect HealthKit

## HealthKit Data Types
All read-only — the app never writes to HealthKit:
- Heart Rate, Resting Heart Rate, HRV (SDNN)
- Step Count, Active/Basal Energy Burned, Distance Walking/Running
- Body Mass, Body Fat %, SpO2, Respiratory Rate, VO2 Max
- Sleep Analysis (with stages: deep, REM, core, awake)
- Workouts (with activity type, duration, energy, distance)

## Sync Strategy
1. **Initial sync**: Last 14 days on first HealthKit permission grant
2. **Foreground sync**: New data since last sync when app becomes active
3. **Background sync**: HKObserverQuery for heart rate, steps, and sleep (hourly)
4. **Background fetch**: AppDelegate checks for new HealthKit data during iOS background fetch
5. **Batch limit**: 5000 samples per API request

## App Store Submission Checklist
1. Set privacy policy URL in App Store Connect (use the hosted privacy-policy.html or your own URL)
2. Provide demo login credentials in App Store Connect review notes
3. Set the App Icon in the asset catalog
4. Ensure HealthKit capability is added in Signing & Capabilities
5. Add Face ID usage description in Info.plist (already included)
6. Submit with App Store description from APP_STORE_DESCRIPTION.md

## Troubleshooting

### Login not working
- Verify `app.rxfit.ai` is in `WKAppBoundDomains` in Info.plist
- Check that both `CapacitorHttp` and `CapacitorCookies` are enabled in capacitor.config.ts
- Ensure `limitsNavigationsToAppBoundDomains` is true in the iOS config
- Check Safari Web Inspector for console errors (connect iPhone to Mac, open Safari > Develop menu)

### HealthKit not syncing
- Must test on a physical device (not Simulator)
- Check that HealthKit capability is added in Xcode Signing & Capabilities
- Verify the entitlements file is referenced in Build Settings
- Check that the user granted HealthKit permissions in iOS Settings > Privacy > Health

### Face ID / Touch ID not showing
- Must test on a physical device with biometrics enrolled
- The biometric option only appears after the first successful email/password login
- Verify `NSFaceIDUsageDescription` exists in Info.plist

### App rejected by Apple
- Review notes in APP_STORE_DESCRIPTION.md explain HealthKit justification
- Provide demo login credentials in App Store Connect review notes
- Ensure privacy policy URL is set before submission
- Make sure you describe why each HealthKit data type is needed
