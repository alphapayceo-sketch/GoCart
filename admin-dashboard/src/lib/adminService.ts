import { apiClient } from '@/lib/apiClient';

export const adminService = {
  // Stats
  getStats: (token: string) => apiClient.get('/admin/stats', token),

  // Users
  getUsers: (token: string) => apiClient.get('/admin/users', token),
  updateUserRole: (userId: string, role: string, token: string) =>
    apiClient.patch(`/admin/users/${userId}/role`, { role }, token),
  updateUserStatus: (userId: string, status: string, token: string) =>
    apiClient.patch(`/admin/users/${userId}/status`, { status }, token),

  // Merchants
  getMerchants: (token: string) => apiClient.get('/admin/merchants', token),
  updateMerchantStatus: (merchantId: string, status: string, token: string) =>
    apiClient.patch(`/admin/merchants/${merchantId}/status`, { status }, token),

  // Categories
  getAdminCategories: (token: string) => apiClient.get('/admin/categories', token),
  createCategory: (data: any, token: string) =>
    apiClient.post('/admin/categories', data, token),
  updateCategory: (id: string, data: any, token: string) =>
    apiClient.put(`/admin/categories/${id}`, data, token),
  deleteCategory: (id: string, token: string) =>
    apiClient.delete(`/admin/categories/${id}`, token),

  // Products
  getAdminProducts: (token: string) => apiClient.get('/admin/products', token),
  createProduct: (data: any, token: string) =>
    apiClient.post('/admin/products', data, token),
  updateProduct: (id: string, data: any, token: string) =>
    apiClient.put(`/admin/products/${id}`, data, token),
  deleteProduct: (id: string, token: string) =>
    apiClient.delete(`/admin/products/${id}`, token),

  // Orders
  getOrders: (token: string) => apiClient.get('/admin/orders', token),

  // Operations
  getOperations: (token: string) => apiClient.get('/admin/operations', token),
  updateShipmentStatus: (id: string, status: string, token: string) =>
    apiClient.patch(`/admin/operations/shipments/${id}/status`, { status }, token),
  processRefund: (id: string, data?: any, token?: string) =>
    apiClient.patch(`/admin/operations/returns/${id}/refund`, data, token),
  updateSettlementStatus: (id: string, status: string, token: string) =>
    apiClient.patch(`/admin/operations/settlements/${id}/status`, { status }, token),
  resolveFraudFlag: (id: string, token: string) =>
    apiClient.patch(`/admin/operations/fraud-flags/${id}/resolve`, {}, token),

  // Payments
  getTransactions: (token: string) => apiClient.get('/admin/payments/transactions', token),
  reconcileTransaction: (id: string, token: string, notes?: string) =>
    apiClient.patch(`/admin/payments/transactions/${id}/reconcile`, { notes }, token),
  getWebhookQueue: (token: string) => apiClient.get('/admin/payments/webhooks/queue', token),
  retryWebhook: (id: string, token: string) =>
    apiClient.post(`/admin/payments/webhooks/${id}/retry`, {}, token),
  getDisputes: (token: string) => apiClient.get('/admin/payments/disputes', token),
  updateDisputeStatus: (id: string, status: string, token: string, resolutionDetails?: string, settlementAmount?: number) =>
    apiClient.patch(`/admin/payments/disputes/${id}/status`, { status, resolutionDetails, settlementAmount }, token),
  getPaymentAnalytics: (token: string) => apiClient.get('/admin/payments/analytics', token),
};
