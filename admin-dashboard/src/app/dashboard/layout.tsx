'use client';

import { useRouter } from 'next/navigation';
import { useEffect } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import Link from 'next/link';

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const { isAuthenticated, token, logout } = useAuth();

  useEffect(() => {
    if (!isAuthenticated) {
      router.push('/login');
    }
  }, [isAuthenticated, router]);

  if (!isAuthenticated) {
    return null;
  }

  return (
    <div className="min-h-screen bg-gray-100">
      <nav className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex items-center">
              <Link href="/dashboard" className="text-xl font-bold text-blue-600">
                GoCart Admin
              </Link>
            </div>
            <div className="flex items-center space-x-8">
              <Link href="/dashboard" className="text-gray-600 hover:text-gray-900">
                Dashboard
              </Link>
              <Link href="/merchants" className="text-gray-600 hover:text-gray-900">
                Merchants
              </Link>
              <Link href="/users" className="text-gray-600 hover:text-gray-900">
                Users
              </Link>
              <Link href="/categories" className="text-gray-600 hover:text-gray-900">
                Categories
              </Link>
              <Link href="/products" className="text-gray-600 hover:text-gray-900">
                Products
              </Link>
              <Link href="/orders" className="text-gray-600 hover:text-gray-900">
                Orders
              </Link>
              <Link href="/operations" className="text-gray-600 hover:text-gray-900">
                Operations
              </Link>
              <Link href="/payments" className="text-gray-600 hover:text-gray-900">
                Payments
              </Link>
              <button
                onClick={() => {
                  logout();
                  router.push('/login');
                }}
                className="text-gray-600 hover:text-gray-900"
              >
                Logout
              </button>
            </div>
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        {children}
      </main>
    </div>
  );
}
