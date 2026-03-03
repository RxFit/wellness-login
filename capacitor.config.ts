import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.rxfit.wellness',
  appName: 'RxFit Wellness',
  webDir: 'dist',
  ios: {
    contentInset: 'automatic',
    backgroundColor: '#050505',
    scheme: 'rxfitwellness',
    preferredContentMode: 'mobile',
    allowsLinkPreview: false,
    limitsNavigationsToAppBoundDomains: true,
  },
  server: {
    allowNavigation: ['app.rxfit.ai', '*.rxfit.ai'],
  },
  plugins: {
    CapacitorHttp: {
      enabled: true,
    },
    CapacitorCookies: {
      enabled: true,
    },
    Preferences: {
      group: 'com.rxfit.wellness',
    },
  },
};

export default config;
