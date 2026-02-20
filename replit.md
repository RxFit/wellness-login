# RxFit Wellness iOS App

## Overview
iOS Capacitor wrapper app for the RxFit Wellness platform (https://app.rxfit.ai). This is a B2B2C wellness coaching platform for Industrial Athletes. The app provides a native iOS shell with HealthKit integration that wraps the existing web application.

## Current State
- **Phase**: MVP Complete - Ready for Xcode build
- **Last Updated**: 2026-02-20

## Architecture

### Tech Stack
- **Web Layer**: Vanilla HTML/CSS/JS with Vite bundler
- **Native Bridge**: Capacitor 8 (iOS)
- **Native Plugin**: Custom Swift HealthKit plugin
- **Target**: iOS 16.0+
- **Bundle ID**: com.rxfit.wellness

### Project Structure
```
rxfit-wellness/
├── src/                          # Web source files (login screen UI)
│   ├── index.html                # Main HTML with all screens
│   ├── css/app.css               # Branded dark theme styling
│   └── js/
│       ├── app.js                # Main app controller & lifecycle
│       ├── auth.js               # Authentication service (cookie-based)
│       ├── healthkit.js          # HealthKit JS bridge service
│       └── screens.js            # Screen navigation manager
├── ios-plugins/RxFitHealthKit/   # Native Swift HealthKit plugin
│   ├── RxFitHealthKitPlugin.swift    # Capacitor plugin bridge
│   ├── RxFitHealthKitPlugin.m        # Objective-C bridge macro
│   └── HealthKitSyncManager.swift    # HealthKit query & data formatting
├── ios-config/                   # iOS configuration files
│   ├── Info.plist                # App config + privacy descriptions
│   ├── RxFitWellness.entitlements    # HealthKit + background capabilities
│   ├── AppDelegate.swift         # App lifecycle + HK observer queries
│   └── LaunchScreen.storyboard   # Branded launch screen
├── capacitor.config.ts           # Capacitor config (points to app.rxfit.ai)
├── vite.config.js                # Vite dev server config
├── SETUP_GUIDE.md                # Full Xcode setup instructions
└── package.json
```

### App Flow
1. Launch screen (dark branded splash)
2. Check for existing session cookie
3. If no session: show login screen -> POST to /api/auth/client-login
4. If new user on iOS: show HealthKit permission screen
5. Load https://app.rxfit.ai in WKWebView with session cookie
6. Sync HealthKit data on foreground and via background delivery

### API Endpoints
- `POST /api/auth/client-login` — Email/password auth
- `POST /api/healthkit/sync` — Send HealthKit samples (max 5000/batch)
- `GET /api/healthkit/status` — Check HealthKit connection
- `POST /api/healthkit/disconnect` — Disconnect HealthKit

### Branding
- Background: #1a1f2e (dark blue-grey)
- Accent: #c8a04a (gold/amber)
- Text: white
- Font: Inter

## Recent Changes
- 2026-02-20: Initial project setup with full Capacitor iOS app structure
- 2026-02-20: Created branded login screen, HealthKit onboarding screen, loading screen
- 2026-02-20: Built custom Swift HealthKit plugin with all 12+ data types
- 2026-02-20: Configured iOS Info.plist, entitlements, AppDelegate, launch screen

## User Preferences
- No preferences recorded yet

## Development Notes
- The web layer (src/) serves as the Capacitor web dir for the login/onboarding screens
- Once authenticated, Capacitor redirects to the live web app at app.rxfit.ai
- HealthKit plugin is in ios-plugins/ and must be copied into Xcode project manually
- iOS config files are in ios-config/ and must be copied after `cap add ios`
- See SETUP_GUIDE.md for complete Xcode build instructions
