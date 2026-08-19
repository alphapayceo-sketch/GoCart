'use client';

import React, { createContext, useContext, useEffect, useState } from 'react';

interface AuthContextType {
  token: string | null;
  setToken: (token: string | null) => void;
  logout: () => void;
  isAuthenticated: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [token, setToken] = useState<string | null>(null);
  const [isLoaded, setIsLoaded] = useState(false);

  useEffect(() => {
    // Load token from localStorage on mount
    if (typeof window !== 'undefined') {
      const storedToken = localStorage.getItem('admin_token');
      setToken(storedToken);
      setIsLoaded(true);
    }
  }, []);

  const handleSetToken = (newToken: string | null) => {
    setToken(newToken);
    if (typeof window !== 'undefined') {
      if (newToken) {
        localStorage.setItem('admin_token', newToken);
      } else {
        localStorage.removeItem('admin_token');
      }
    }
  };

  const logout = () => {
    handleSetToken(null);
  };

  if (!isLoaded) {
    return <div>Loading...</div>;
  }

  return (
    <AuthContext.Provider value={{ token, setToken: handleSetToken, logout, isAuthenticated: !!token }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
}
