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
npx cap init "RxFit Wellness" com.rxfit.wellness --web-dir dist
npx cap add ios
npx cap sync ios
```

### 4. Copy Native Plugin Files
Copy the Swift HealthKit plugin into the Xcode project:
```bash
cp ios-plugins/RxFitHealthKit/*.swift ios/App/App/
cp ios-plugins/RxFitHealthKit/*.m ios/App/App/
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
6. Check "Clinical Health Records" if needed
7. Click **+ Capability** and add **Background Modes**
8. Check "Background fetch" and "Remote notifications"
9. Under **Build Settings**, set iOS Deployment Target to 16.0
10. Add the entitlements file under **Build Settings** > **Code Signing Entitlements**

### 7. Run on Device
Select your connected iPhone and press Run (Cmd+R).

> Note: HealthKit requires a physical device — it does not work in the Simulator.

## Project Structure
```
rxfit-wellness/
├── src/                          # Web source files (login screen UI)
│   ├── index.html                # Main HTML with login, HealthKit, and loading screens
│   ├── css/app.css               # Branded styling (dark theme, gold accents)
│   └── js/
│       ├── app.js                # Main app controller
│       ├── auth.js               # Authentication service
│       ├── healthkit.js          # HealthKit JS bridge service
│       └── screens.js            # Screen navigation manager
├── ios-plugins/RxFitHealthKit/   # Native Swift HealthKit plugin
│   ├── RxFitHealthKitPlugin.swift    # Capacitor plugin bridge
│   ├── RxFitHealthKitPlugin.m        # Objective-C bridge
│   └── HealthKitSyncManager.swift    # HealthKit query & sync logic
├── ios-config/                   # iOS project configuration files
│   ├── Info.plist                # App configuration with privacy descriptions
│   ├── RxFitWellness.entitlements    # HealthKit + background entitlements
│   ├── AppDelegate.swift         # App lifecycle + background observers
│   └── LaunchScreen.storyboard   # Branded launch screen
├── capacitor.config.ts           # Capacitor configuration
├── vite.config.js                # Vite build configuration
└── package.json                  # Dependencies
```

## API Endpoints Used
- `POST /api/auth/client-login` — Authentication
- `POST /api/healthkit/sync` — Sync HealthKit samples
- `GET /api/healthkit/status` — Check HealthKit connection status
- `POST /api/healthkit/disconnect` — Disconnect HealthKit

## HealthKit Data Types
All read-only — the app never writes to HealthKit:
- Heart Rate, Resting Heart Rate, HRV
- Step Count, Active/Basal Energy, Distance
- Body Mass, Body Fat %, SpO2, Respiratory Rate, VO2 Max
- Sleep Analysis (with stages: deep, REM, core, awake)
- Workouts

## Sync Strategy
1. **Initial sync**: Last 14 days on first HealthKit permission grant
2. **Foreground sync**: New data since last sync when app becomes active
3. **Background sync**: HKObserverQuery for heart rate, steps, and sleep
4. **Batch limit**: 5000 samples per API request
5. **Deduplication**: Based on startDate + sampleType
