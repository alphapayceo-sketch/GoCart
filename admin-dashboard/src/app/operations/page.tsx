'use client';

import { useEffect, useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { adminService } from '@/lib/adminService';

interface Operation {
  id: string;
  status?: string;
  amount?: number;
  refund_amount?: number;
  is_resolved?: boolean;
  created_at?: string;
  [key: string]: any;
}

export default function OperationsPage() {
  const { token } = useAuth();
  const [operations, setOperations] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [updating, setUpdating] = useState<string | null>(null);

  useEffect(() => {
    if (!token) return;
    fetchOperations();
  }, [token]);

  const fetchOperations = async () => {
    try {
      setLoading(true);
      const data = await adminService.getOperations(token!);
      setOperations(data);
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleShipmentStatus = async (id: string, status: string) => {
    try {
      setUpdating(id);
      await adminService.updateShipmentStatus(id, status, token!);
      await fetchOperations();
    } catch (err: any) {
      setError(err.message);
    } finally {
      setUpdating(null);
    }
  };

  const handleProcessRefund = async (id: string) => {
    try {
      setUpdating(id);
      await adminService.processRefund(id, { refund_percent: 100 }, token!);
      await fetchOperations();
    } catch (err: any) {
      setError(err.message);
    } finally {
      setUpdating(null);
    }
  };

  const handleSettlementStatus = async (id: string, status: string) => {
    try {
      setUpdating(id);
      await adminService.updateSettlementStatus(id, status, token!);
      await fetchOperations();
    } catch (err: any) {
      setError(err.message);
    } finally {
      setUpdating(null);
    }
  };

  const handleResolveFraud = async (id: string) => {
    try {
      setUpdating(id);
      await adminService.resolveFraudFlag(id, token!);
      await fetchOperations();
    } catch (err: any) {
      setError(err.message);
    } finally {
      setUpdating(null);
    }
  };

  if (loading) return <div className="text-center py-10">Loading operations...</div>;

  return (
    <div>
      <h1 className="text-3xl font-bold text-gray-900 mb-8">Operations</h1>

      {error && (
        <div className="rounded-md bg-red-50 p-4 mb-4">
          <p className="text-sm font-medium text-red-800">{error}</p>
        </div>
      )}

      <div className="space-y-6">
        {/* Shipments */}
        <div className="bg-white rounded-lg shadow overflow-hidden">
          <div className="px-6 py-4 bg-gray-50 border-b border-gray-200">
            <h2 className="text-lg font-semibold text-gray-900">Fulfillment & Shipments</h2>
          </div>
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">ID</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Created</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {operations?.shipments?.length > 0 ? (
                operations.shipments.map((item: Operation) => (
                  <tr key={item.id}>
                    <td className="px-6 py-4 text-sm text-gray-900">{item.id}</td>
                    <td className="px-6 py-4 text-sm text-gray-500">{item.status}</td>
                    <td className="px-6 py-4 text-sm text-gray-500">
                      {item.created_at ? new Date(item.created_at).toLocaleDateString() : 'N/A'}
                    </td>
                    <td className="px-6 py-4 text-sm">
                      <select
                        disabled={updating === item.id}
                        onChange={(e) => handleShipmentStatus(item.id, e.target.value)}
                        value={item.status || ''}
                        className="rounded border border-gray-300 px-2 py-1"
                      >
                        <option value="">Update status</option>
                        <option value="packed">Packed</option>
                        <option value="ready_for_dispatch">Ready for dispatch</option>
                        <option value="in_transit">In transit</option>
                        <option value="delivered">Delivered</option>
                        <option value="returned">Returned</option>
                        <option value="failed_delivery">Failed delivery</option>
                      </select>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={4} className="px-6 py-4 text-center text-gray-500">
                    No shipments
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        {/* Returns & Refunds */}
        <div className="bg-white rounded-lg shadow overflow-hidden">
          <div className="px-6 py-4 bg-gray-50 border-b border-gray-200">
            <h2 className="text-lg font-semibold text-gray-900">Returns & Refunds</h2>
          </div>
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">ID</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Amount</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {operations?.returns?.length > 0 ? (
                operations.returns.map((item: Operation) => (
                  <tr key={item.id}>
                    <td className="px-6 py-4 text-sm text-gray-900">{item.id}</td>
                    <td className="px-6 py-4 text-sm text-gray-500">{item.status}</td>
                    <td className="px-6 py-4 text-sm text-gray-900">
                      ${item.refund_amount?.toFixed(2)}
                    </td>
                    <td className="px-6 py-4 text-sm">
                      {item.status?.toLowerCase() === 'refunded' ? (
                        <span className="text-green-600">Refunded</span>
                      ) : (
                        <button
                          disabled={updating === item.id}
                          onClick={() => handleProcessRefund(item.id)}
                          className="text-blue-600 hover:text-blue-900 disabled:opacity-50"
                        >
                          Process Refund
                        </button>
                      )}
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={4} className="px-6 py-4 text-center text-gray-500">
                    No returns
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        {/* Fraud Flags */}
        <div className="bg-white rounded-lg shadow overflow-hidden">
          <div className="px-6 py-4 bg-gray-50 border-b border-gray-200">
            <h2 className="text-lg font-semibold text-gray-900">Fraud Flags</h2>
          </div>
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">ID</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Created</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {operations?.fraudFlags?.length > 0 ? (
                operations.fraudFlags.map((item: Operation) => (
                  <tr key={item.id}>
                    <td className="px-6 py-4 text-sm text-gray-900">{item.id}</td>
                    <td className="px-6 py-4 text-sm text-gray-500">
                      {item.is_resolved ? 'Resolved' : 'Pending'}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-500">
                      {item.created_at ? new Date(item.created_at).toLocaleDateString() : 'N/A'}
                    </td>
                    <td className="px-6 py-4 text-sm">
                      {item.is_resolved ? (
                        <span className="text-green-600">Resolved</span>
                      ) : (
                        <button
                          disabled={updating === item.id}
                          onClick={() => handleResolveFraud(item.id)}
                          className="text-blue-600 hover:text-blue-900 disabled:opacity-50"
                        >
                          Resolve
                        </button>
                      )}
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={4} className="px-6 py-4 text-center text-gray-500">
                    No fraud flags
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        {/* Settlements */}
        <div className="bg-white rounded-lg shadow overflow-hidden">
          <div className="px-6 py-4 bg-gray-50 border-b border-gray-200">
            <h2 className="text-lg font-semibold text-gray-900">Settlement Reconciliation</h2>
          </div>
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">ID</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Amount</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {operations?.settlements?.length > 0 ? (
                operations.settlements.map((item: Operation) => (
                  <tr key={item.id}>
                    <td className="px-6 py-4 text-sm text-gray-900">{item.id}</td>
                    <td className="px-6 py-4 text-sm text-gray-500">{item.status}</td>
                    <td className="px-6 py-4 text-sm text-gray-900">
                      ${item.amount?.toFixed(2)}
                    </td>
                    <td className="px-6 py-4 text-sm">
                      <select
                        disabled={updating === item.id}
                        onChange={(e) => handleSettlementStatus(item.id, e.target.value)}
                        value={item.status || ''}
                        className="rounded border border-gray-300 px-2 py-1"
                      >
                        <option value="">Update status</option>
                        <option value="APPROVED">Approve</option>
                        <option value="PAID">Mark Paid</option>
                        <option value="REJECTED">Reject</option>
                        <option value="FAILED">Failed</option>
                      </select>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={4} className="px-6 py-4 text-center text-gray-500">
                    No settlements
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
