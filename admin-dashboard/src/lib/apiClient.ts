import { API_BASE_URL } from '@/config/api';

interface RequestOptions extends RequestInit {
  token?: string;
}

async function apiCall(
  endpoint: string,
  options: RequestOptions = {}
): Promise<any> {
  const { token, ...fetchOptions } = options;
  const url = `${API_BASE_URL}${endpoint}`;

  const headers = new Headers(fetchOptions.headers || {});
  headers.set('Content-Type', 'application/json');

  if (token) {
    headers.set('Authorization', `Bearer ${token}`);
  }

  const response = await fetch(url, {
    ...fetchOptions,
    headers,
  });

  if (!response.ok) {
    if (response.status === 401) {
      // Handle unauthorized - clear token and redirect to login
      if (typeof window !== 'undefined') {
        localStorage.removeItem('admin_token');
        window.location.href = '/login';
      }
    }
    const error = await response.json().catch(() => ({ message: `HTTP ${response.status}` }));
    throw new Error(error.message || `API Error: ${response.status}`);
  }

  return response.json();
}

export const apiClient = {
  get: (endpoint: string, token?: string) =>
    apiCall(endpoint, { method: 'GET', token }),

  post: (endpoint: string, data?: any, token?: string) =>
    apiCall(endpoint, { method: 'POST', body: JSON.stringify(data), token }),

  patch: (endpoint: string, data?: any, token?: string) =>
    apiCall(endpoint, { method: 'PATCH', body: JSON.stringify(data), token }),

  put: (endpoint: string, data?: any, token?: string) =>
    apiCall(endpoint, { method: 'PUT', body: JSON.stringify(data), token }),

  delete: (endpoint: string, token?: string) =>
    apiCall(endpoint, { method: 'DELETE', token }),
};
