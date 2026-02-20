export class AuthService {
  constructor(apiBase) {
    this.apiBase = apiBase;
    this.authenticated = false;
    this.sessionKey = 'rxfit_session_active';
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
  }
}
