export interface Visitor {
  id: number;
  name: string;
  email?: string;
  location?: string;
  message?: string;
  created_at: string;
}