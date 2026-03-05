import { APP_VERSION } from './constants.js';

export class AuthService {
  constructor(apiBase) {
    this.apiBase = apiBase;
    this.authenticated = false;
    this.sessionKey = 'rxfit_session_active';
    this.rememberedEmailKey = 'rxfit_remembered_email';
    this.biometricServerKey = 'app.rxfit.ai';
  }

  async login(email, password) {
    try {
      const response = await fetch(`${this.apiBase}/api/auth/client-login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
        credentials: 'include',
      });

      if (response.ok) {
        this.authenticated = true;
        await this.saveSession();
        await this.saveRememberedEmail(email);
        return { success: true };
      }

      const data = await response.json().catch(() => ({}));
      return {
        success: false,
        error: data.message || data.error || 'Invalid email or password',
      };
    } catch (err) {
      console.error('Login error:', err);
      return { success: false, error: 'Unable to connect. Check your internet connection.' };
    }
  }

  async checkSession() {
    const hasLocal = await this.getSessionFlag();
    if (!hasLocal) return false;

    try {
      const response = await fetch(`${this.apiBase}/api/healthkit/status`, {
        credentials: 'include',
      });
      if (response.ok) {
        this.authenticated = true;
        return true;
      }
    } catch (e) {
      console.warn('Session check failed:', e);
    }

    await this.clearSession();
    return false;
  }

  isAuthenticated() {
    return this.authenticated;
  }

  getVersion() {
    return APP_VERSION;
  }

  async saveSession() {
    try {
      if (typeof window.Capacitor !== 'undefined' && window.Capacitor.Plugins?.Preferences) {
        await window.Capacitor.Plugins.Preferences.set({ key: this.sessionKey, value: 'true' });
      } else {
        localStorage.setItem(this.sessionKey, 'true');
      }
    } catch (e) {
      localStorage.setItem(this.sessionKey, 'true');
    }
  }

  async getSessionFlag() {
    try {
      if (typeof window.Capacitor !== 'undefined' && window.Capacitor.Plugins?.Preferences) {
        const result = await window.Capacitor.Plugins.Preferences.get({ key: this.sessionKey });
        return result.value === 'true';
      }
      return localStorage.getItem(this.sessionKey) === 'true';
    } catch (e) {
      return false;
    }
  }

  async clearSession() {
    this.authenticated = false;
    try {
      if (typeof window.Capacitor !== 'undefined' && window.Capacitor.Plugins?.Preferences) {
        await window.Capacitor.Plugins.Preferences.remove({ key: this.sessionKey });
      } else {
        localStorage.removeItem(this.sessionKey);
      }
    } catch (e) {
      try { localStorage.removeItem(this.sessionKey); } catch (ex) {}
    }
  }

  async logout() {
    await this.clearSession();
    await this.clearBiometricCredentials();
  }

  async saveRememberedEmail(email) {
    try {
      if (typeof window.Capacitor !== 'undefined' && window.Capacitor.Plugins?.Preferences) {
        await window.Capacitor.Plugins.Preferences.set({ key: this.rememberedEmailKey, value: email });
      } else {
        localStorage.setItem(this.rememberedEmailKey, email);
      }
    } catch (e) {
      try { localStorage.setItem(this.rememberedEmailKey, email); } catch (ex) {}
    }
  }

  async getRememberedEmail() {
    try {
      if (typeof window.Capacitor !== 'undefined' && window.Capacitor.Plugins?.Preferences) {
        const result = await window.Capacitor.Plugins.Preferences.get({ key: this.rememberedEmailKey });
        return result.value || '';
      }
      return localStorage.getItem(this.rememberedEmailKey) || '';
    } catch (e) {
      return '';
    }
  }

  async isBiometricAvailable() {
    if (typeof window.Capacitor === 'undefined' || !window.Capacitor.isNativePlatform()) {
      return { available: false };
    }

    try {
      const { NativeBiometric } = await import('@capgo/capacitor-native-biometric');
      const result = await NativeBiometric.isAvailable();
      if (!result.isAvailable) return { available: false };

      let label = 'Sign in with biometrics';
      if (result.biometryType === 1) label = 'Sign in with Touch ID';
      if (result.biometryType === 2) label = 'Sign in with Face ID';
      if (result.biometryType === 4) label = 'Sign in with Face ID';

      return { available: true, label };
    } catch (e) {
      console.warn('Biometric check failed:', e);
      return { available: false };
    }
  }

  async hasBiometricCredentials() {
    try {
      const { NativeBiometric } = await import('@capgo/capacitor-native-biometric');
      const credentials = await NativeBiometric.getCredentials({ server: this.biometricServerKey });
      return !!(credentials && credentials.username);
    } catch (e) {
      return false;
    }
  }

  async saveBiometricCredentials(email, password) {
    try {
      const { NativeBiometric } = await import('@capgo/capacitor-native-biometric');
      await NativeBiometric.setCredentials({
        username: email,
        password: password,
        server: this.biometricServerKey,
      });
    } catch (e) {
      console.warn('Failed to save biometric credentials:', e);
    }
  }

  async biometricLogin() {
    try {
      const { NativeBiometric } = await import('@capgo/capacitor-native-biometric');

      await NativeBiometric.verifyIdentity({
        reason: 'Sign in to RxFit Wellness',
        title: 'Authentication',
        maxAttempts: 3,
        useFallback: true,
      });

      const credentials = await NativeBiometric.getCredentials({
        server: this.biometricServerKey,
      });

      if (credentials && credentials.username && credentials.password) {
        return await this.login(credentials.username, credentials.password);
      }

      return { success: false, error: 'No saved credentials found.' };
    } catch (e) {
      if (e.code === 11 || e.message?.includes('cancel')) {
        return { success: false, error: 'cancelled' };
      }
      console.warn('Biometric login failed:', e);
      return { success: false, error: 'Biometric authentication failed.' };
    }
  }

  async clearBiometricCredentials() {
    try {
      const { NativeBiometric } = await import('@capgo/capacitor-native-biometric');
      await NativeBiometric.deleteCredentials({ server: this.biometricServerKey });
    } catch (e) {
      // ignore
    }
  }
}
