'use client';

import { useEffect, useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { adminService } from '@/lib/adminService';

interface User {
  id: string;
  email: string;
  role: string;
  deleted_at?: string;
  created_at?: string;
}

export default function UsersPage() {
  const { token } = useAuth();
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [updating, setUpdating] = useState<string | null>(null);

  useEffect(() => {
    if (!token) return;
    fetchUsers();
  }, [token]);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const data = await adminService.getUsers(token!);
      setUsers(Array.isArray(data) ? data : data.users || []);
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const updateRole = async (id: string, newRole: string) => {
    try {
      setUpdating(id);
      await adminService.updateUserRole(id, newRole, token!);
      await fetchUsers();
    } catch (err: any) {
      setError(err.message);
    } finally {
      setUpdating(null);
    }
  };

  const updateStatus = async (id: string, enabled: boolean) => {
    try {
      setUpdating(id);
      await adminService.updateUserStatus(id, enabled ? 'enable' : 'disable', token!);
      await fetchUsers();
    } catch (err: any) {
      setError(err.message);
    } finally {
      setUpdating(null);
    }
  };

  if (loading) return <div className="text-center py-10">Loading users...</div>;

  return (
    <div>
      <h1 className="text-3xl font-bold text-gray-900 mb-8">Users</h1>

      {error && (
        <div className="rounded-md bg-red-50 p-4 mb-4">
          <p className="text-sm font-medium text-red-800">{error}</p>
        </div>
      )}

      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Email
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Role
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Status
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Created
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {users.map((user) => {
              const isDeleted = !!user.deleted_at;
              return (
                <tr key={user.id} className={isDeleted ? 'bg-gray-50' : ''}>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {user.email}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <select
                      disabled={updating === `${user.id}-role` || isDeleted}
                      onChange={(e) => updateRole(user.id, e.target.value)}
                      value={user.role}
                      className="rounded border border-gray-300 px-2 py-1"
                    >
                      <option value="customer">Customer</option>
                      <option value="merchant">Merchant</option>
                      <option value="admin">Admin</option>
                    </select>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span
                      className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                        isDeleted
                          ? 'bg-red-100 text-red-800'
                          : 'bg-green-100 text-green-800'
                      }`}
                    >
                      {isDeleted ? 'Disabled' : 'Active'}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {user.created_at ? new Date(user.created_at).toLocaleDateString() : 'N/A'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    {!isDeleted ? (
                      <button
                        onClick={() => updateStatus(user.id, false)}
                        disabled={updating === `${user.id}-status`}
                        className="text-red-600 hover:text-red-900 disabled:opacity-50"
                      >
                        Disable
                      </button>
                    ) : (
                      <button
                        onClick={() => updateStatus(user.id, true)}
                        disabled={updating === `${user.id}-status`}
                        className="text-green-600 hover:text-green-900 disabled:opacity-50"
                      >
                        Enable
                      </button>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}
