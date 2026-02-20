import { nativeFetch } from './http.js';

export class AuthService {
  constructor(apiBase) {
    this.apiBase = apiBase;
    this.authenticated = false;
    this.sessionKey = 'rxfit_session_active';
  }

  async login(email, password) {
    try {
      const response = await nativeFetch(`${this.apiBase}/api/auth/client-login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      });

      if (response.ok) {
        this.authenticated = true;
        this.saveSession();
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
    const hasLocal = this.getSessionFlag();
    if (!hasLocal) return false;

    try {
      const response = await nativeFetch(`${this.apiBase}/api/healthkit/status`);
      if (response.ok) {
        this.authenticated = true;
        return true;
      }
    } catch (e) {
      console.warn('Session check failed:', e);
    }

    this.clearSession();
    return false;
  }

  isAuthenticated() {
    return this.authenticated;
  }

  saveSession() {
    try {
      if (typeof window.Capacitor !== 'undefined' && window.Capacitor.Plugins?.Preferences) {
        window.Capacitor.Plugins.Preferences.set({ key: this.sessionKey, value: 'true' });
      } else {
        localStorage.setItem(this.sessionKey, 'true');
      }
    } catch (e) {
      localStorage.setItem(this.sessionKey, 'true');
    }
  }

  getSessionFlag() {
    try {
      if (typeof window.Capacitor !== 'undefined' && window.Capacitor.Plugins?.Preferences) {
        return true;
      }
      return localStorage.getItem(this.sessionKey) === 'true';
    } catch (e) {
      return false;
    }
  }

  clearSession() {
    this.authenticated = false;
    try {
      localStorage.removeItem(this.sessionKey);
    } catch (e) {}
  }

  logout() {
    this.clearSession();
  }
}
