import { AuthService } from './auth.js';
import { HealthKitService } from './healthkit.js';
import { ScreenManager } from './screens.js';

const API_BASE = 'https://app.rxfit.ai';
const LOAD_TIMEOUT_MS = 15000;

class RxFitApp {
  constructor() {
    this.auth = new AuthService(API_BASE);
    this.healthkit = new HealthKitService(API_BASE);
    this.screens = new ScreenManager();
    this.isNative = typeof window.Capacitor !== 'undefined' && window.Capacitor.isNativePlatform();
    this.loadTimer = null;
    this.isOnline = true;
  }

  async init() {
    this.screens.show('splash');
    this.displayVersion();
    this.bindEvents();
    this.setupKeyboardHandling();
    this.setupNetworkMonitoring();
    await this.prefillRememberedEmail();
    await this.checkExistingSession();
  }

  displayVersion() {
    const versionEl = document.getElementById('app-version');
    if (versionEl) {
      versionEl.textContent = `v${this.auth.getVersion()}`;
    }
  }

  bindEvents() {
    const loginForm = document.getElementById('login-form');
    if (loginForm) loginForm.addEventListener('submit', (e) => this.handleLogin(e));

    const connectBtn = document.getElementById('connect-healthkit-btn');
    if (connectBtn) connectBtn.addEventListener('click', () => this.handleHealthKitConnect());

    const skipBtn = document.getElementById('skip-healthkit-btn');
    if (skipBtn) skipBtn.addEventListener('click', () => this.loadWebApp());

    const forgotLink = document.getElementById('forgot-password-link');
    if (forgotLink) forgotLink.addEventListener('click', (e) => this.handleForgotPassword(e));

    const retryBtn = document.getElementById('retry-btn');
    if (retryBtn) retryBtn.addEventListener('click', () => this.handleRetry());

    const backBtn = document.getElementById('back-to-login-btn');
    if (backBtn) backBtn.addEventListener('click', () => this.handleBackToLogin());

    const togglePassword = document.getElementById('toggle-password');
    if (togglePassword) togglePassword.addEventListener('click', () => this.togglePasswordVisibility());

    const biometricBtn = document.getElementById('biometric-btn');
    if (biometricBtn) biometricBtn.addEventListener('click', () => this.handleBiometricLogin());

    const openHealthSettingsBtn = document.getElementById('open-health-settings-btn');
    if (openHealthSettingsBtn) openHealthSettingsBtn.addEventListener('click', () => this.openHealthSettings());

    const skipDeniedBtn = document.getElementById('skip-denied-btn');
    if (skipDeniedBtn) skipDeniedBtn.addEventListener('click', () => this.loadWebApp());

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

  setupKeyboardHandling() {
    if (window.visualViewport) {
      window.visualViewport.addEventListener('resize', () => {
        const focused = document.activeElement;
        if (focused && (focused.tagName === 'INPUT' || focused.tagName === 'TEXTAREA')) {
          setTimeout(() => {
            focused.scrollIntoView({ behavior: 'smooth', block: 'center' });
          }, 100);
        }
      });
    }
  }

  setupNetworkMonitoring() {
    const updateOnlineStatus = (online) => {
      this.isOnline = online;
      const banner = document.getElementById('offline-banner');
      if (banner) {
        banner.style.display = online ? 'none' : 'flex';
      }
    };

    if (this.isNative && window.Capacitor?.Plugins?.Network) {
      window.Capacitor.Plugins.Network.getStatus().then((status) => {
        updateOnlineStatus(status.connected);
      }).catch(() => {});

      window.Capacitor.Plugins.Network.addListener('networkStatusChange', (status) => {
        updateOnlineStatus(status.connected);
      });
    } else {
      updateOnlineStatus(navigator.onLine);
      window.addEventListener('online', () => updateOnlineStatus(true));
      window.addEventListener('offline', () => updateOnlineStatus(false));
    }
  }

  async prefillRememberedEmail() {
    const email = await this.auth.getRememberedEmail();
    if (email) {
      const emailInput = document.getElementById('email');
      if (emailInput) {
        emailInput.value = email;
      }
    }
  }

  async setupBiometrics() {
    const bioResult = await this.auth.isBiometricAvailable();
    if (!bioResult.available) return;

    const hasCreds = await this.auth.hasBiometricCredentials();
    if (!hasCreds) return;

    const section = document.getElementById('biometric-section');
    const label = document.getElementById('biometric-label');
    if (section && label) {
      label.textContent = bioResult.label;
      section.style.display = 'block';
    }
  }

  async checkExistingSession() {
    const hasSession = await this.auth.checkSession();
    if (hasSession) {
      this.loadWebApp();
    } else {
      await this.setupBiometrics();
      this.screens.show('login');
    }
  }

  async triggerHaptic(style) {
    if (!this.isNative) return;
    try {
      const { Haptics, ImpactStyle, NotificationType } = await import('@capacitor/haptics');
      if (style === 'success') {
        await Haptics.notification({ type: NotificationType.Success });
      } else if (style === 'error') {
        await Haptics.notification({ type: NotificationType.Error });
      } else if (style === 'light') {
        await Haptics.impact({ style: ImpactStyle.Light });
      } else {
        await Haptics.impact({ style: ImpactStyle.Medium });
      }
    } catch (e) {
      // ignore
    }
  }

  async handleLogin(e) {
    e.preventDefault();

    if (!this.isOnline) {
      const errorEl = document.getElementById('error-message');
      if (errorEl) {
        errorEl.textContent = 'No internet connection. Please check your network and try again.';
        errorEl.style.display = 'block';
      }
      await this.triggerHaptic('error');
      return;
    }

    const emailEl = document.getElementById('email');
    const passwordEl = document.getElementById('password');
    const email = emailEl ? emailEl.value.trim() : '';
    const password = passwordEl ? passwordEl.value : '';
    const errorEl = document.getElementById('error-message');
    const btn = document.getElementById('signin-btn');
    const btnText = btn ? btn.querySelector('.btn-text') : null;
    const btnLoader = btn ? btn.querySelector('.btn-loader') : null;

    if (errorEl) errorEl.style.display = 'none';
    if (btn) btn.disabled = true;
    if (btnText) btnText.style.display = 'none';
    if (btnLoader) btnLoader.style.display = 'inline-block';

    try {
      const result = await this.auth.login(email, password);
      if (result.success) {
        await this.triggerHaptic('success');

        if (this.isNative) {
          await this.auth.saveBiometricCredentials(email, password);
        }

        if (this.isNative && !(await this.healthkit.hasBeenPrompted())) {
          this.screens.show('healthkit');
        } else {
          this.loadWebApp();
        }
      } else {
        await this.triggerHaptic('error');
        if (errorEl) {
          errorEl.textContent = result.error || 'Invalid email or password';
          errorEl.style.display = 'block';
        }
      }
    } catch (err) {
      await this.triggerHaptic('error');
      if (errorEl) {
        errorEl.textContent = 'Connection error. Please try again.';
        errorEl.style.display = 'block';
      }
    } finally {
      if (btn) {
        btn.disabled = false;
        if (btnText) btnText.style.display = 'inline';
        if (btnLoader) btnLoader.style.display = 'none';
      }
    }
  }

  async handleBiometricLogin() {
    if (!this.isOnline) {
      const errorEl = document.getElementById('error-message');
      if (errorEl) {
        errorEl.textContent = 'No internet connection. Please check your network and try again.';
        errorEl.style.display = 'block';
      }
      return;
    }

    const biometricBtn = document.getElementById('biometric-btn');
    if (biometricBtn) biometricBtn.disabled = true;

    try {
      const result = await this.auth.biometricLogin();
      if (result.success) {
        await this.triggerHaptic('success');

        if (this.isNative && !(await this.healthkit.hasBeenPrompted())) {
          this.screens.show('healthkit');
        } else {
          this.loadWebApp();
        }
      } else if (result.error !== 'cancelled') {
        await this.triggerHaptic('error');
        const errorEl = document.getElementById('error-message');
        if (errorEl) {
          errorEl.textContent = result.error;
          errorEl.style.display = 'block';
        }
      }
    } catch (err) {
      console.error('Biometric login error:', err);
    } finally {
      if (biometricBtn) biometricBtn.disabled = false;
    }
  }

  togglePasswordVisibility() {
    const passwordInput = document.getElementById('password');
    const eyeIcon = document.getElementById('eye-icon');
    const eyeOffIcon = document.getElementById('eye-off-icon');

    if (passwordInput.type === 'password') {
      passwordInput.type = 'text';
      eyeIcon.style.display = 'none';
      eyeOffIcon.style.display = 'block';
    } else {
      passwordInput.type = 'password';
      eyeIcon.style.display = 'block';
      eyeOffIcon.style.display = 'none';
    }
  }

  handleForgotPassword(e) {
    e.preventDefault();
    const resetUrl = `${API_BASE}/forgot-password`;

    if (this.isNative && window.Capacitor?.Plugins?.Browser) {
      window.Capacitor.Plugins.Browser.open({ url: resetUrl });
    } else {
      window.open(resetUrl, '_blank');
    }
  }

  async handleHealthKitConnect() {
    const btn = document.getElementById('connect-healthkit-btn');
    btn.disabled = true;
    btn.textContent = 'Connecting...';

    try {
      const granted = await this.healthkit.requestPermissions();
      await this.healthkit.markAsPrompted();

      if (granted) {
        await this.healthkit.performInitialSync();
        this.healthkit.startBackgroundDelivery();
        this.loadWebApp();
      } else {
        btn.disabled = false;
        btn.textContent = 'Enable Health Sync';
        this.screens.show('healthkitDenied');
      }
    } catch (err) {
      console.error('HealthKit connection error:', err);
      btn.disabled = false;
      btn.textContent = 'Enable Health Sync';
      this.screens.show('healthkitDenied');
    }
  }

  openHealthSettings() {
    if (this.isNative && window.Capacitor?.Plugins?.Browser) {
      window.Capacitor.Plugins.Browser.open({ url: 'x-apple-health://' });
    }
  }

  loadWebApp() {
    this.screens.show('loading');
    this.resetLoadingUI();

    if (this.isNative) {
      this.verifyServerThenNavigate();
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

  async verifyServerThenNavigate() {
    const controller = new AbortController();
    this.loadTimer = setTimeout(() => {
      controller.abort();
      this.showLoadingError();
    }, LOAD_TIMEOUT_MS);

    try {
      const response = await fetch(API_BASE, {
        method: 'GET',
        credentials: 'include',
        signal: controller.signal,
        redirect: 'follow',
      });
      this.clearLoadTimer();

      if (response.ok || response.status < 500) {
        window.location.href = API_BASE;
      } else {
        this.showLoadingError();
      }
    } catch (err) {
      if (err.name !== 'AbortError') {
        this.clearLoadTimer();
        this.showLoadingError();
      }
    }
  }

  resetLoadingUI() {
    const spinner = document.getElementById('loading-spinner');
    const text = document.getElementById('loading-text');
    const errorEl = document.getElementById('loading-error');

    if (spinner) spinner.style.display = 'flex';
    if (text) text.style.display = 'block';
    if (errorEl) errorEl.classList.remove('visible');
  }

  showLoadingError() {
    this.clearLoadTimer();

    const spinner = document.getElementById('loading-spinner');
    const text = document.getElementById('loading-text');
    const errorEl = document.getElementById('loading-error');

    if (spinner) spinner.style.display = 'none';
    if (text) text.style.display = 'none';
    if (errorEl) errorEl.classList.add('visible');
  }

  clearLoadTimer() {
    if (this.loadTimer) {
      clearTimeout(this.loadTimer);
      this.loadTimer = null;
    }
  }

  handleRetry() {
    this.loadWebApp();
  }

  async handleBackToLogin() {
    this.clearLoadTimer();
    await this.auth.logout();

    const frame = document.getElementById('webview-frame');
    if (frame) {
      frame.src = '';
    }

    this.screens.show('login');
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const app = new RxFitApp();
  app.init();
});
