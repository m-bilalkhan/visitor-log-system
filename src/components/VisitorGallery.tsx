import React from 'react';
import { Users, MapPin, MessageCircle, Calendar, User } from 'lucide-react';
import type { Visitor } from '../types/visitor';

interface VisitorGalleryProps {
  visitors: Visitor[];
}

export default function VisitorGallery({ visitors }: VisitorGalleryProps) {
  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return {
      date: date.toLocaleDateString(),
      time: date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    };
  };

  const getInitials = (name: string) => {
    return name
      .split(' ')
      .map(word => word[0])
      .join('')
      .toUpperCase()
      .slice(0, 2);
  };

  const getAvatarColor = (name: string) => {
    const colors = [
      'bg-gradient-to-br from-purple-500 to-pink-500',
      'bg-gradient-to-br from-blue-500 to-cyan-500',
      'bg-gradient-to-br from-green-500 to-teal-500',
      'bg-gradient-to-br from-orange-500 to-red-500',
      'bg-gradient-to-br from-indigo-500 to-purple-500',
      'bg-gradient-to-br from-pink-500 to-rose-500',
    ];
    const index = name.length % colors.length;
    return colors[index];
  };

  return (
    <div className="space-y-8">
      <div className="text-center">
        <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">
          Our Fellow Visitors
        </h2>
        <p className="text-white/90 text-lg">
          {visitors.length === 0 
            ? "Be the first to sign our visitor log!" 
            : `${visitors.length} wonderful ${visitors.length === 1 ? 'person has' : 'people have'} visited`
          }
        </p>
      </div>

      {visitors.length === 0 ? (
        <div className="text-center py-12">
          <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-8 max-w-md mx-auto">
            <Users className="h-16 w-16 text-white/60 mx-auto mb-4" />
            <h3 className="text-xl font-semibold text-white mb-2">No visitors yet</h3>
            <p className="text-white/80">Be the first to leave your mark!</p>
          </div>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {visitors.map((visitor, index) => {
            const { date, time } = formatDate(visitor.created_at);
            
            return (
              <div
                key={visitor.id}
                className="bg-white/95 backdrop-blur-sm rounded-xl p-6 shadow-lg hover:shadow-xl transition-all duration-300 transform hover:-translate-y-1 border border-white/20"
                style={{
                  animationDelay: `${index * 100}ms`,
                  animation: 'fadeInUp 0.6s ease-out forwards'
                }}
              >
                <div className="flex items-start space-x-4">
                  <div className={`w-12 h-12 rounded-full flex items-center justify-center text-white font-bold text-lg ${getAvatarColor(visitor.name)}`}>
                    {getInitials(visitor.name)}
                  </div>
                  
                  <div className="flex-1 min-w-0">
                    <h3 className="font-semibold text-gray-800 text-lg truncate">
                      {visitor.name}
                    </h3>
                    
                    <div className="flex items-center space-x-2 text-sm text-gray-500 mt-1">
                      <Calendar className="h-4 w-4" />
                      <span>{date}</span>
                      <span>•</span>
                      <span>{time}</span>
                    </div>
                  </div>
                </div>

                <div className="mt-4 space-y-2">
                  {visitor.location && (
                    <div className="flex items-center space-x-2 text-sm text-gray-600">
                      <MapPin className="h-4 w-4 text-gray-400" />
                      <span>{visitor.location}</span>
                    </div>
                  )}
                  
                  {visitor.message && (
                    <div className="mt-3 p-3 bg-gray-50 rounded-lg">
                      <div className="flex items-start space-x-2">
                        <MessageCircle className="h-4 w-4 text-gray-400 mt-0.5 flex-shrink-0" />
                        <p className="text-sm text-gray-700 leading-relaxed">{visitor.message}</p>
                      </div>
                    </div>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}