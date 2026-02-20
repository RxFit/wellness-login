function isNativeCapacitor() {
  return typeof window.Capacitor !== 'undefined' && window.Capacitor.isNativePlatform();
}

function getCapacitorHttp() {
  if (isNativeCapacitor() && window.Capacitor.Plugins?.CapacitorHttp) {
    return window.Capacitor.Plugins.CapacitorHttp;
  }
  return null;
}

export async function nativeFetch(url, options = {}) {
  const capHttp = getCapacitorHttp();

  if (capHttp) {
    const method = (options.method || 'GET').toUpperCase();
    const request = {
      url,
      method,
      headers: options.headers || {},
      webFetchExtra: { credentials: 'include' },
    };

    if (options.body && typeof options.body === 'string') {
      request.data = JSON.parse(options.body);
    }

    const response = await capHttp.request(request);

    return {
      ok: response.status >= 200 && response.status < 300,
      status: response.status,
      json: async () => (typeof response.data === 'string' ? JSON.parse(response.data) : response.data),
      text: async () => (typeof response.data === 'string' ? response.data : JSON.stringify(response.data)),
    };
  }

  return fetch(url, { ...options, credentials: 'include' });
}
