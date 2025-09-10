const API_BASE_URL = '/api';

export interface Visitor {
  id: number;
  name: string;
  email?: string;
  location?: string;
  message?: string;
  created_at: string;
}

export const api = {
  async getVisitors(): Promise<Visitor[]> {
    const response = await fetch(`${API_BASE_URL}/visitors`);
    if (!response.ok) {
      throw new Error('Failed to fetch visitors');
    }
    return response.json();
  },

  async createVisitor(visitor: Omit<Visitor, 'id' | 'created_at'>): Promise<Visitor> {
    const response = await fetch(`${API_BASE_URL}/visitors`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(visitor),
    });
    
    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || 'Failed to create visitor');
    }
    
    return response.json();
  },

  async checkHealth(): Promise<{ status: string; timestamp: string }> {
    const response = await fetch(`${API_BASE_URL}/health`);
    if (!response.ok) {
      throw new Error('Server health check failed');
    }
    return response.json();
  }
};