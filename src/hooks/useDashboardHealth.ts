import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import toast from 'react-hot-toast';

interface DashboardHealth {
  view_name: string;
  row_count: number;
  last_refresh: string;
  status: 'healthy' | 'empty' | 'error';
}

interface UseDashboardHealthReturn {
  health: DashboardHealth | null;
  loading: boolean;
  error: string | null;
  checkHealth: () => Promise<void>;
  forceRefresh: () => Promise<void>;
}

export function useDashboardHealth(): UseDashboardHealthReturn {
  const [health, setHealth] = useState<DashboardHealth | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const checkHealth = async () => {
    try {
      setLoading(true);
      setError(null);

      const { data, error: healthError } = await supabase
        .rpc('check_dashboard_view_health');

      if (healthError) throw healthError;

      if (data && data.length > 0) {
        setHealth(data[0]);
      } else {
        setHealth({
          view_name: 'dashboard_performance_view',
          row_count: 0,
          last_refresh: new Date().toISOString(),
          status: 'empty'
        });
      }
    } catch (err) {
      console.error('Error checking dashboard health:', err);
      setError(err instanceof Error ? err.message : 'Unknown error');
      setHealth({
        view_name: 'dashboard_performance_view',
        row_count: 0,
        last_refresh: new Date().toISOString(),
        status: 'error'
      });
    } finally {
      setLoading(false);
    }
  };

  const forceRefresh = async () => {
    try {
      setLoading(true);
      
      // Force refresh the materialized view
      const { error: refreshError } = await supabase
        .rpc('safe_refresh_dashboard_performance_view');

      if (refreshError) {
        console.warn('Refresh failed:', refreshError);
        toast.warning('Actualisation partielle - Certaines données peuvent être en retard');
      } else {
        toast.success('Vue du tableau de bord actualisée avec succès');
      }

      // Check health after refresh
      await checkHealth();
    } catch (err) {
      console.error('Error forcing refresh:', err);
      toast.error('Erreur lors de l\'actualisation forcée');
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    checkHealth();
  }, []);

  return {
    health,
    loading,
    error,
    checkHealth,
    forceRefresh
  };
}