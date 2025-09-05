import React from 'react';
import { motion } from 'framer-motion';
import { 
  CheckCircle, 
  AlertTriangle, 
  XCircle, 
  RefreshCw, 
  Database,
  Clock
} from 'lucide-react';
import { useDashboardHealth } from '../../hooks/useDashboardHealth';

interface DashboardHealthIndicatorProps {
  className?: string;
  showDetails?: boolean;
}

export const DashboardHealthIndicator: React.FC<DashboardHealthIndicatorProps> = ({
  className = '',
  showDetails = false
}) => {
  const { health, loading, error, checkHealth, forceRefresh } = useDashboardHealth();

  const getStatusIcon = () => {
    if (loading) return <RefreshCw className="h-4 w-4 animate-spin" />;
    if (error || health?.status === 'error') return <XCircle className="h-4 w-4" />;
    if (health?.status === 'empty') return <AlertTriangle className="h-4 w-4" />;
    if (health?.status === 'healthy') return <CheckCircle className="h-4 w-4" />;
    return <Database className="h-4 w-4" />;
  };

  const getStatusColor = () => {
    if (loading) return 'text-blue-600';
    if (error || health?.status === 'error') return 'text-red-600';
    if (health?.status === 'empty') return 'text-yellow-600';
    if (health?.status === 'healthy') return 'text-green-600';
    return 'text-gray-600';
  };

  const getStatusText = () => {
    if (loading) return 'Vérification...';
    if (error) return 'Erreur système';
    if (health?.status === 'error') return 'Vue défaillante';
    if (health?.status === 'empty') return 'Données manquantes';
    if (health?.status === 'healthy') return 'Système opérationnel';
    return 'État inconnu';
  };

  const getStatusBg = () => {
    if (loading) return 'bg-blue-50 border-blue-200';
    if (error || health?.status === 'error') return 'bg-red-50 border-red-200';
    if (health?.status === 'empty') return 'bg-yellow-50 border-yellow-200';
    if (health?.status === 'healthy') return 'bg-green-50 border-green-200';
    return 'bg-gray-50 border-gray-200';
  };

  if (!showDetails && health?.status === 'healthy') {
    // Only show indicator when there are issues
    return null;
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: -10 }}
      animate={{ opacity: 1, y: 0 }}
      className={`${getStatusBg()} border rounded-lg p-3 ${className}`}
    >
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <div className={getStatusColor()}>
            {getStatusIcon()}
          </div>
          <div>
            <p className={`text-sm font-medium ${getStatusColor()}`}>
              {getStatusText()}
            </p>
            {showDetails && health && (
              <div className="text-xs text-gray-600 mt-1">
                <div className="flex items-center gap-4">
                  <span>{health.row_count} indicateurs</span>
                  {health.last_refresh && (
                    <span className="flex items-center gap-1">
                      <Clock className="h-3 w-3" />
                      MAJ: {new Date(health.last_refresh).toLocaleTimeString('fr-FR')}
                    </span>
                  )}
                </div>
              </div>
            )}
          </div>
        </div>
        
        <div className="flex items-center gap-2">
          <button
            onClick={checkHealth}
            disabled={loading}
            className="p-1 rounded hover:bg-gray-100 transition-colors"
            title="Vérifier l'état"
          >
            <RefreshCw className={`h-3 w-3 ${loading ? 'animate-spin' : ''}`} />
          </button>
          
          {(health?.status === 'empty' || health?.status === 'error') && (
            <button
              onClick={forceRefresh}
              disabled={loading}
              className="px-2 py-1 text-xs bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors"
            >
              Réparer
            </button>
          )}
        </div>
      </div>
      
      {error && (
        <div className="mt-2 text-xs text-red-600">
          Erreur: {error}
        </div>
      )}
    </motion.div>
  );
};