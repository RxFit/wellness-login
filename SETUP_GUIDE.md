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

### 6. Xcode Configuration
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

### 7. Sync After Config Changes
After copying files, run sync again to ensure Capacitor picks up changes:
```bash
npx cap sync ios
```

### 8. Run on Device
Select your connected iPhone and press Run (Cmd+R).

> **Important**: HealthKit requires a physical device — it does not work in the Simulator.
> Login and basic UI can be tested in the Simulator.

## Project Structure
```
rxfit-wellness/
├── src/                          # Web source files (login screen UI)
│   ├── index.html                # Main HTML with login, HealthKit, and loading screens
│   ├── css/app.css               # Clinical Luxury dark theme styling
│   └── js/
│       ├── app.js                # Main app controller & lifecycle
│       ├── auth.js               # Authentication service (cookie-based)
│       ├── healthkit.js          # HealthKit JS bridge service
│       └── screens.js            # Screen navigation manager
├── ios-plugins/RxFitHealthKit/   # Native Swift HealthKit plugin
│   ├── RxFitHealthKitPlugin.swift    # Capacitor plugin bridge
│   ├── RxFitHealthKitPlugin.m        # Objective-C bridge macro
│   ├── HealthKitSyncManager.swift    # HealthKit query & sync logic
│   └── UIColor+RxFit.swift           # UIColor extension with brand palette
├── ios-config/                   # iOS project configuration files
│   ├── Info.plist                # App config with privacy descriptions + WKAppBoundDomains
│   ├── RxFitWellness.entitlements    # HealthKit + background delivery entitlements
│   ├── AppDelegate.swift         # App lifecycle + background fetch with HealthKit check
│   └── LaunchScreen.storyboard   # Branded launch screen
├── capacitor.config.ts           # Capacitor config (CapacitorHttp + CapacitorCookies enabled)
├── vite.config.js                # Vite build configuration
├── APP_STORE_DESCRIPTION.md      # App Store listing text and review notes
├── app-icon/icon-1024.png        # App Store icon (1024x1024)
└── package.json                  # Dependencies
```

## How Authentication Works
1. The app uses Capacitor's native HTTP plugin (`CapacitorHttp`) to make login requests
2. This bypasses browser CORS restrictions on iOS
3. Capacitor's cookie plugin (`CapacitorCookies`) automatically syncs session cookies between the native HTTP layer and WKWebView
4. When navigating to `app.rxfit.ai` after login, the session cookie is already present in the web view
5. `WKAppBoundDomains` in Info.plist ensures cookie persistence for `app.rxfit.ai`

## API Endpoints Used
- `POST /api/auth/client-login` — Authentication
- `POST /api/healthkit/sync` — Sync HealthKit samples (max 5000 per batch)
- `GET /api/healthkit/status` — Check HealthKit connection status
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

### App rejected by Apple
- Review notes in APP_STORE_DESCRIPTION.md explain HealthKit justification
- Provide demo login credentials in App Store Connect review notes
- Ensure privacy policy URL is set before submission
