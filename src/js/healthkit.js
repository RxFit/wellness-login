export class HealthKitService {
  constructor(apiBase) {
    this.apiBase = apiBase;
    this.promptedKey = 'rxfit_hk_prompted';
    this.lastSyncKey = 'rxfit_hk_last_sync';
    this.batchSize = 5000;
  }

  isNative() {
    return typeof window.Capacitor !== 'undefined' && window.Capacitor.isNativePlatform();
  }

  getPlugin() {
    if (this.isNative() && window.Capacitor.Plugins?.RxFitHealthKit) {
      return window.Capacitor.Plugins.RxFitHealthKit;
    }
    return null;
  }

  hasBeenPrompted() {
    return localStorage.getItem(this.promptedKey) === 'true';
  }

  markAsPrompted() {
    localStorage.setItem(this.promptedKey, 'true');
  }

  async requestPermissions() {
    const plugin = this.getPlugin();
    if (!plugin) {
      console.log('HealthKit plugin not available (not on iOS)');
      return false;
    }

    try {
      const result = await plugin.requestAuthorization();
      return result.granted;
    } catch (err) {
      console.error('HealthKit authorization error:', err);
      return false;
    }
  }

  async performInitialSync() {
    const plugin = this.getPlugin();
    if (!plugin) return;

    try {
      const fourteenDaysAgo = new Date();
      fourteenDaysAgo.setDate(fourteenDaysAgo.getDate() - 14);

      const result = await plugin.queryAllSamples({
        startDate: fourteenDaysAgo.toISOString(),
        endDate: new Date().toISOString(),
      });

      if (result.samples && result.samples.length > 0) {
        await this.sendSamples(result.samples, result.deviceInfo);
      }

      this.updateLastSyncDate();
    } catch (err) {
      console.error('Initial sync error:', err);
    }
  }

  async syncNewData() {
    const plugin = this.getPlugin();
    if (!plugin) return;

    const lastSync = this.getLastSyncDate();
    if (!lastSync) {
      await this.performInitialSync();
      return;
    }

    try {
      const result = await plugin.queryAllSamples({
        startDate: lastSync,
        endDate: new Date().toISOString(),
      });

      if (result.samples && result.samples.length > 0) {
        await this.sendSamples(result.samples, result.deviceInfo);
      }

      this.updateLastSyncDate();
    } catch (err) {
      console.error('Sync error:', err);
    }
  }

  async sendSamples(samples, deviceInfo) {
    const batches = [];
    for (let i = 0; i < samples.length; i += this.batchSize) {
      batches.push(samples.slice(i, i + this.batchSize));
    }

    for (const batch of batches) {
      try {
        const response = await fetch(`${this.apiBase}/api/healthkit/sync`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          credentials: 'include',
          body: JSON.stringify({
            samples: batch,
            deviceInfo: deviceInfo || {
              model: 'Unknown',
              systemVersion: 'Unknown',
              appVersion: '1.0.0',
            },
          }),
        });

        if (!response.ok) {
          console.error('Sync batch failed:', response.status);
        }
      } catch (err) {
        console.error('Sync batch error:', err);
      }
    }
  }

  startBackgroundDelivery() {
    const plugin = this.getPlugin();
    if (!plugin) return;

    try {
      plugin.enableBackgroundDelivery();
    } catch (err) {
      console.error('Background delivery setup error:', err);
    }
  }

  async checkStatus() {
    try {
      const response = await fetch(`${this.apiBase}/api/healthkit/status`, {
        credentials: 'include',
      });
      if (response.ok) {
        return await response.json();
      }
    } catch (err) {
      console.error('Status check error:', err);
    }
    return { connected: false, lastSyncAt: null };
  }

  async disconnect() {
    try {
      await fetch(`${this.apiBase}/api/healthkit/disconnect`, {
        method: 'POST',
        credentials: 'include',
      });
    } catch (err) {
      console.error('Disconnect error:', err);
    }
  }

  getLastSyncDate() {
    return localStorage.getItem(this.lastSyncKey);
  }

  updateLastSyncDate() {
    localStorage.setItem(this.lastSyncKey, new Date().toISOString());
  }
}
