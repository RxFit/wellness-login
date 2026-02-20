export class ScreenManager {
  constructor() {
    this.screens = {
      login: document.getElementById('login-screen'),
      healthkit: document.getElementById('healthkit-screen'),
      loading: document.getElementById('loading-screen'),
      webview: document.getElementById('webview-screen'),
    };
    this.currentScreen = 'login';
  }

  show(screenName) {
    Object.values(this.screens).forEach((screen) => {
      screen.classList.remove('active');
    });

    const target = this.screens[screenName];
    if (target) {
      target.classList.add('active');
      this.currentScreen = screenName;
    }
  }

  getCurrent() {
    return this.currentScreen;
  }
}
