import React, { useState, useEffect } from 'react';
import { Users, UserPlus, Clock, MessageCircle, ArrowLeft } from 'lucide-react';
import VisitorForm from './components/VisitorForm';
import VisitorGallery from './components/VisitorGallery';
import { api } from './lib/api';
import type { Visitor } from './types/visitor';

function App() {
  const [currentPage, setCurrentPage] = useState<'sign-in' | 'gallery'>('sign-in');
  const [visitors, setVisitors] = useState<Visitor[]>([]);
  const [loading, setLoading] = useState(true);
  const [totalVisitors, setTotalVisitors] = useState(0);

  useEffect(() => {
    fetchVisitors();
  }, []);

  const fetchVisitors = async () => {
    try {
      const data = await api.getVisitors();
      setVisitors(data);
      setTotalVisitors(data.length);
    } catch (error) {
      console.error('Error fetching visitors:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleVisitorAdded = (newVisitor: Visitor) => {
    setVisitors(prev => [newVisitor, ...prev]);
    setTotalVisitors(prev => prev + 1);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-purple-400 via-pink-500 to-red-500 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-white"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-400 via-pink-500 to-red-500">
      {/* Header */}
      <header className="bg-white/10 backdrop-blur-md border-b border-white/20">
        <div className="max-w-4xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="bg-white/20 p-2 rounded-lg">
                <Users className="h-6 w-6 text-white" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-white">Who's Visiting</h1>
                <p className="text-white/80 text-sm">{totalVisitors} visitors so far</p>
              </div>
            </div>
            
            {currentPage === 'gallery' && (
              <button
                onClick={() => setCurrentPage('sign-in')}
                className="flex items-center space-x-2 bg-white/20 hover:bg-white/30 px-4 py-2 rounded-lg text-white transition-all duration-200"
              >
                <ArrowLeft className="h-4 w-4" />
                <span>Back to Sign In</span>
              </button>
            )}
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-4xl mx-auto px-4 py-8">
        {currentPage === 'sign-in' ? (
          <div className="space-y-8">
            <div className="text-center">
              <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">
                Welcome! Sign Our Visitor Log
              </h2>
              <p className="text-white/90 text-lg max-w-2xl mx-auto">
                Let us know you were here! Share your name and leave a message for future visitors.
              </p>
            </div>

            <VisitorForm onVisitorAdded={handleVisitorAdded} />

            {/* Quick Stats */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-8">
              <div className="bg-white/10 backdrop-blur-md rounded-xl p-6 text-center">
                <Users className="h-8 w-8 text-white mx-auto mb-2" />
                <div className="text-2xl font-bold text-white">{totalVisitors}</div>
                <div className="text-white/80">Total Visitors</div>
              </div>
              
              <div className="bg-white/10 backdrop-blur-md rounded-xl p-6 text-center">
                <Clock className="h-8 w-8 text-white mx-auto mb-2" />
                <div className="text-2xl font-bold text-white">
                  {visitors.filter(v => {
                    const today = new Date().toDateString();
                    return new Date(v.created_at).toDateString() === today;
                  }).length}
                </div>
                <div className="text-white/80">Today</div>
              </div>
              
              <div className="bg-white/10 backdrop-blur-md rounded-xl p-6 text-center">
                <MessageCircle className="h-8 w-8 text-white mx-auto mb-2" />
                <div className="text-2xl font-bold text-white">
                  {visitors.filter(v => v.message).length}
                </div>
                <div className="text-white/80">With Messages</div>
              </div>
            </div>

            {/* CTA to View Visitors */}
            {totalVisitors > 0 && (
              <div className="text-center">
                <button
                  onClick={() => setCurrentPage('gallery')}
                  className="inline-flex items-center space-x-2 bg-white hover:bg-gray-100 text-purple-600 px-6 py-3 rounded-xl font-semibold transition-all duration-200 shadow-lg hover:shadow-xl transform hover:-translate-y-0.5"
                >
                  <Users className="h-5 w-5" />
                  <span>View All Visitors ({totalVisitors})</span>
                </button>
              </div>
            )}
          </div>
        ) : (
          <VisitorGallery visitors={visitors} />
        )}
      </main>
    </div>
  );
}

export default App;