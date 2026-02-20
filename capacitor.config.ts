import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.rxfit.wellness',
  appName: 'RxFit Wellness',
  webDir: 'dist',
  ios: {
    contentInset: 'automatic',
    backgroundColor: '#0C1217',
    scheme: 'RxFit Wellness',
    preferredContentMode: 'mobile',
  },
  plugins: {
    Preferences: {
      group: 'com.rxfit.wellness',
    },
  },
};

export default config;
