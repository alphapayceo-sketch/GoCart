'use client';

import { useEffect, useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { adminService } from '@/lib/adminService';

interface Category {
  id: string;
  name: string;
  tenant_id?: string;
  image_url?: string;
}

export default function CategoriesPage() {
  const { token } = useAuth();
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [showForm, setShowForm] = useState(false);
  const [formData, setFormData] = useState({ name: '', image_url: '' });
  const [editing, setEditing] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    if (!token) return;
    fetchCategories();
  }, [token]);

  const fetchCategories = async () => {
    try {
      setLoading(true);
      const data = await adminService.getAdminCategories(token!);
      setCategories(Array.isArray(data) ? data : data.categories || []);
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setSubmitting(true);
      if (editing) {
        await adminService.updateCategory(editing, formData, token!);
      } else {
        await adminService.createCategory(formData, token!);
      }
      setFormData({ name: '', image_url: '' });
      setEditing(null);
      setShowForm(false);
      await fetchCategories();
    } catch (err: any) {
      setError(err.message);
    } finally {
      setSubmitting(false);
    }
  };

  const deleteCategory = async (id: string) => {
    if (!confirm('Are you sure?')) return;
    try {
      await adminService.deleteCategory(id, token!);
      await fetchCategories();
    } catch (err: any) {
      setError(err.message);
    }
  };

  if (loading) return <div className="text-center py-10">Loading categories...</div>;

  return (
    <div>
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Categories</h1>
        <button
          onClick={() => {
            setEditing(null);
            setFormData({ name: '', image_url: '' });
            setShowForm(!showForm);
          }}
          className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
        >
          {showForm ? 'Cancel' : 'Add Category'}
        </button>
      </div>

      {error && (
        <div className="rounded-md bg-red-50 p-4 mb-4">
          <p className="text-sm font-medium text-red-800">{error}</p>
        </div>
      )}

      {showForm && (
        <div className="bg-white rounded-lg shadow p-6 mb-8">
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700">Name</label>
              <input
                type="text"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                required
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Image URL</label>
              <input
                type="url"
                value={formData.image_url}
                onChange={(e) => setFormData({ ...formData, image_url: e.target.value })}
                className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
              />
            </div>
            <button
              type="submit"
              disabled={submitting}
              className="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700 disabled:opacity-50"
            >
              {submitting ? 'Saving...' : editing ? 'Update' : 'Create'}
            </button>
          </form>
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {categories.map((cat) => (
          <div key={cat.id} className="bg-white rounded-lg shadow p-6">
            {cat.image_url && (
              <img
                src={cat.image_url}
                alt={cat.name}
                className="w-full h-40 object-cover rounded mb-4"
              />
            )}
            <h3 className="text-lg font-semibold text-gray-900">{cat.name}</h3>
            <div className="mt-4 flex space-x-2">
              <button
                onClick={() => {
                  setEditing(cat.id);
                  setFormData({ name: cat.name, image_url: cat.image_url || '' });
                  setShowForm(true);
                }}
                className="text-blue-600 hover:text-blue-900"
              >
                Edit
              </button>
              <button
                onClick={() => deleteCategory(cat.id)}
                className="text-red-600 hover:text-red-900"
              >
                Delete
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
