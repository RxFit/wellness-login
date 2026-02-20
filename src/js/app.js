import { AuthService } from './auth.js';
import { HealthKitService } from './healthkit.js';
import { ScreenManager } from './screens.js';

const API_BASE = 'https://app.rxfit.ai';

class RxFitApp {
  constructor() {
    this.auth = new AuthService(API_BASE);
    this.healthkit = new HealthKitService(API_BASE);
    this.screens = new ScreenManager();
    this.isNative = typeof window.Capacitor !== 'undefined' && window.Capacitor.isNativePlatform();
  }

  async init() {
    this.bindEvents();
    await this.checkExistingSession();
  }

  bindEvents() {
    const loginForm = document.getElementById('login-form');
    loginForm.addEventListener('submit', (e) => this.handleLogin(e));

    const connectBtn = document.getElementById('connect-healthkit-btn');
    connectBtn.addEventListener('click', () => this.handleHealthKitConnect());

    const skipBtn = document.getElementById('skip-healthkit-btn');
    skipBtn.addEventListener('click', () => this.loadWebApp());

    document.addEventListener('visibilitychange', () => {
      if (document.visibilityState === 'visible' && this.auth.isAuthenticated()) {
        this.healthkit.syncNewData();
      }
    });

    if (this.isNative && window.Capacitor?.Plugins?.RxFitHealthKit) {
      window.Capacitor.Plugins.RxFitHealthKit.addListener(
        'healthKitDataUpdated',
        () => {
          if (this.auth.isAuthenticated()) {
            this.healthkit.syncNewData();
          }
        }
      );
    }
  }

  async checkExistingSession() {
    const hasSession = await this.auth.checkSession();
    if (hasSession) {
      this.loadWebApp();
    } else {
      this.screens.show('login');
    }
  }

  async handleLogin(e) {
    e.preventDefault();
    const email = document.getElementById('email').value.trim();
    const password = document.getElementById('password').value;
    const errorEl = document.getElementById('error-message');
    const btn = document.getElementById('signin-btn');
    const btnText = btn.querySelector('.btn-text');
    const btnLoader = btn.querySelector('.btn-loader');

    errorEl.style.display = 'none';
    btn.disabled = true;
    btnText.style.display = 'none';
    btnLoader.style.display = 'inline-block';

    try {
      const result = await this.auth.login(email, password);
      if (result.success) {
        if (this.isNative && !this.healthkit.hasBeenPrompted()) {
          this.screens.show('healthkit');
        } else {
          this.loadWebApp();
        }
      } else {
        errorEl.textContent = result.error || 'Invalid email or password';
        errorEl.style.display = 'block';
      }
    } catch (err) {
      errorEl.textContent = 'Connection error. Please try again.';
      errorEl.style.display = 'block';
    } finally {
      btn.disabled = false;
      btnText.style.display = 'inline';
      btnLoader.style.display = 'none';
    }
  }

  async handleHealthKitConnect() {
    const btn = document.getElementById('connect-healthkit-btn');
    btn.disabled = true;
    btn.textContent = 'Connecting...';

    try {
      const granted = await this.healthkit.requestPermissions();
      this.healthkit.markAsPrompted();

      if (granted) {
        await this.healthkit.performInitialSync();
        this.healthkit.startBackgroundDelivery();
      }
    } catch (err) {
      console.error('HealthKit connection error:', err);
    }

    this.loadWebApp();
  }

  loadWebApp() {
    this.screens.show('loading');

    if (this.isNative) {
      setTimeout(() => {
        window.location.href = API_BASE;
      }, 1500);
    } else {
      const frame = document.getElementById('webview-frame');
      frame.src = API_BASE;
      frame.onload = () => {
        this.screens.show('webview');
      };
      setTimeout(() => {
        this.screens.show('webview');
      }, 5000);
    }
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const app = new RxFitApp();
  app.init();
});
