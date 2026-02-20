export class ScreenManager {
  constructor() {
    this.screens = {
      splash: document.getElementById('splash-screen'),
      login: document.getElementById('login-screen'),
      healthkit: document.getElementById('healthkit-screen'),
      loading: document.getElementById('loading-screen'),
      webview: document.getElementById('webview-screen'),
    };
    this.currentScreen = 'splash';
  }

  show(screenName) {
    Object.values(this.screens).forEach((screen) => {
      if (screen) screen.classList.remove('active');
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
