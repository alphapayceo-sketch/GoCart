'use client';

import { useEffect, useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { adminService } from '@/lib/adminService';

export default function PaymentsPage() {
  const { token } = useAuth();
  const [transactions, setTransactions] = useState<any[]>([]);
  const [webhooks, setWebhooks] = useState<any[]>([]);
  const [disputes, setDisputes] = useState<any[]>([]);
  const [analytics, setAnalytics] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    if (!token) return;
    loadData();
  }, [token]);

  const loadData = async () => {
    try {
      setLoading(true);
      const [txData, webhookData, disputeData, analyticsData] = await Promise.all([
        adminService.getTransactions(token!),
        adminService.getWebhookQueue(token!),
        adminService.getDisputes(token!),
        adminService.getPaymentAnalytics(token!),
      ]);

      setTransactions(txData.transactions || []);
      setWebhooks(webhookData.deadLetters || []);
      setDisputes(disputeData.disputes || []);
      setAnalytics(analyticsData.analytics || analyticsData);
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleRetry = async (id: string) => {
    try {
      await adminService.retryWebhook(id, token!);
      await loadData();
    } catch (err: any) {
      setError(err.message);
    }
  };

  const handleReconcile = async (id: string) => {
    try {
      await adminService.reconcileTransaction(id, token!, 'Marked reconciled through admin dashboard');
      await loadData();
    } catch (err: any) {
      setError(err.message);
    }
  };

  const handleDisputeStatus = async (id: string, status: string) => {
    try {
      await adminService.updateDisputeStatus(id, status, token!);
      await loadData();
    } catch (err: any) {
      setError(err.message);
    }
  };

  if (loading) return <div className="text-center py-10">Loading payments...</div>;

  return (
    <div className="space-y-8">
      <h1 className="text-3xl font-bold text-gray-900">Payment Operations</h1>

      {error && (
        <div className="rounded-md bg-red-50 p-4">
          <p className="text-sm font-medium text-red-800">{error}</p>
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white p-5 rounded shadow">
          <div className="text-sm text-gray-500">Revenue</div>
          <div className="text-2xl font-bold">${Number(analytics?.total_revenue || 0).toFixed(2)}</div>
        </div>
        <div className="bg-white p-5 rounded shadow">
          <div className="text-sm text-gray-500">Transactions</div>
          <div className="text-2xl font-bold">{analytics?.total_transactions || 0}</div>
        </div>
        <div className="bg-white p-5 rounded shadow">
          <div className="text-sm text-gray-500">Chargebacks</div>
          <div className="text-2xl font-bold">{analytics?.total_chargebacks || 0}</div>
        </div>
        <div className="bg-white p-5 rounded shadow">
          <div className="text-sm text-gray-500">Refunds</div>
          <div className="text-2xl font-bold">${Number(analytics?.total_refunds || 0).toFixed(2)}</div>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="px-6 py-4 border-b bg-gray-50">
          <h2 className="text-lg font-semibold">Transactions</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium uppercase">ID</th>
                <th className="px-4 py-3 text-left text-xs font-medium uppercase">Status</th>
                <th className="px-4 py-3 text-left text-xs font-medium uppercase">Amount</th>
                <th className="px-4 py-3 text-left text-xs font-medium uppercase">Created</th>
                <th className="px-4 py-3 text-left text-xs font-medium uppercase">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y">
              {transactions.length ? transactions.map((tx: any) => (
                <tr key={tx.id}>
                  <td className="px-4 py-3 text-sm">{tx.id.slice(0, 8)}</td>
                  <td className="px-4 py-3 text-sm">{tx.status}</td>
                  <td className="px-4 py-3 text-sm">${Number(tx.amount_cents || 0) / 100}</td>
                  <td className="px-4 py-3 text-sm">{tx.created_at ? new Date(tx.created_at).toLocaleDateString() : 'N/A'}</td>
                  <td className="px-4 py-3 text-sm">
                    {tx.status !== 'RECONCILED' && (
                      <button onClick={() => handleReconcile(tx.id)} className="text-blue-600">Reconcile</button>
                    )}
                  </td>
                </tr>
              )) : <tr><td colSpan={5} className="px-4 py-6 text-center text-gray-500">No transactions</td></tr>}
            </tbody>
          </table>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="px-6 py-4 border-b bg-gray-50">
          <h2 className="text-lg font-semibold">Dead Letter Queue</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium uppercase">Event</th>
                <th className="px-4 py-3 text-left text-xs font-medium uppercase">Status</th>
                <th className="px-4 py-3 text-left text-xs font-medium uppercase">Retries</th>
                <th className="px-4 py-3 text-left text-xs font-medium uppercase">Error</th>
                <th className="px-4 py-3 text-left text-xs font-medium uppercase">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y">
              {webhooks.length ? webhooks.map((item: any) => (
                <tr key={item.id}>
                  <td className="px-4 py-3 text-sm">{item.event_type}</td>
                  <td className="px-4 py-3 text-sm">{item.status}</td>
                  <td className="px-4 py-3 text-sm">{item.retry_count}</td>
                  <td className="px-4 py-3 text-sm">{item.error_message || '—'}</td>
                  <td className="px-4 py-3 text-sm"><button onClick={() => handleRetry(item.id)} className="text-blue-600">Retry</button></td>
                </tr>
              )) : <tr><td colSpan={5} className="px-4 py-6 text-center text-gray-500">No failed webhooks</td></tr>}
            </tbody>
          </table>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="px-6 py-4 border-b bg-gray-50">
          <h2 className="text-lg font-semibold">Chargebacks & Disputes</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium uppercase">Type</th>
                <th className="px-4 py-3 text-left text-xs font-medium uppercase">Amount</th>
                <th className="px-4 py-3 text-left text-xs font-medium uppercase">Status</th>
                <th className="px-4 py-3 text-left text-xs font-medium uppercase">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y">
              {disputes.length ? disputes.map((item: any) => (
                <tr key={item.id}>
                  <td className="px-4 py-3 text-sm">{item.dispute_type}</td>
                  <td className="px-4 py-3 text-sm">${Number(item.dispute_amount || 0).toFixed(2)}</td>
                  <td className="px-4 py-3 text-sm">{item.status}</td>
                  <td className="px-4 py-3 text-sm">
                    <select defaultValue={item.status} onChange={(e) => handleDisputeStatus(item.id, e.target.value)} className="border rounded px-2 py-1">
                      <option value="open">Open</option>
                      <option value="investigation">Investigation</option>
                      <option value="resolved">Resolved</option>
                      <option value="lost">Lost</option>
                    </select>
                  </td>
                </tr>
              )) : <tr><td colSpan={4} className="px-4 py-6 text-center text-gray-500">No disputes</td></tr>}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
