import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  CheckCircle,
  AlertTriangle,
  XCircle,
  RefreshCw,
  Settings,
  Database,
  TrendingUp,
  Eye,
  Wrench
} from 'lucide-react';
import { useAuthStore } from '../../store/authStore';
import {
  runDashboardDiagnostics,
  recoverDashboardView,
  formatValidationResults,
  getStatusMessage,
  DashboardHealthSummary,
  DashboardValidationResult
} from '../../utils/dashboardValidation';
import toast from 'react-hot-toast';

interface DashboardDiagnosticsProps {
  isOpen: boolean;
  onClose: () => void;
  onRecoveryComplete?: () => void;
}

export const DashboardDiagnostics: React.FC<DashboardDiagnosticsProps> = ({
  isOpen,
  onClose,
  onRecoveryComplete
}) => {
  const { profile, impersonatedOrganization } = useAuthStore();
  const [diagnostics, setDiagnostics] = useState<{
    health: DashboardHealthSummary | null;
    validation: DashboardValidationResult[];
    coverage: any;
    overall_status: 'healthy' | 'warning' | 'critical';
  } | null>(null);
  const [loading, setLoading] = useState(false);
  const [recovering, setRecovering] = useState(false);

  const currentOrganization = impersonatedOrganization || profile?.organization_name;

  useEffect(() => {
    if (isOpen && currentOrganization) {
      runDiagnostics();
    }
  }, [isOpen, currentOrganization]);

  const runDiagnostics = async () => {
    if (!currentOrganization) return;

    try {
      setLoading(true);
      const results = await runDashboardDiagnostics(currentOrganization);
      setDiagnostics(results);
    } catch (error) {
      console.error('Error running diagnostics:', error);
      toast.error('Erreur lors du diagnostic');
    } finally {
      setLoading(false);
    }
  };

  const handleRecovery = async () => {
    try {
      setRecovering(true);
      const success = await recoverDashboardView();
      
      if (success) {
        // Re-run diagnostics after recovery
        await runDiagnostics();
        onRecoveryComplete?.();
      }
    } catch (error) {
      console.error('Error during recovery:', error);
    } finally {
      setRecovering(false);
    }
  };

  if (!isOpen) return null;

  const statusInfo = diagnostics ? getStatusMessage(diagnostics.overall_status) : null;

  return (
    <AnimatePresence>
      <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black bg-opacity-50">
        <motion.div
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          exit={{ opacity: 0, scale: 0.95 }}
          className="relative w-full max-w-4xl bg-white rounded-xl shadow-xl max-h-[90vh] overflow-hidden"
        >
          {/* Header */}
          <div className="flex items-center justify-between p-6 border-b border-gray-200">
            <div className="flex items-center gap-3">
              <div className="p-2 rounded-lg bg-blue-100">
                <Database className="h-6 w-6 text-blue-600" />
              </div>
              <div>
                <h3 className="text-xl font-semibold text-gray-900">
                  Diagnostics du Tableau de Bord
                </h3>
                <p className="text-sm text-gray-600">{currentOrganization}</p>
              </div>
            </div>
            <button
              onClick={onClose}
              className="p-2 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <XCircle className="h-5 w-5 text-gray-500" />
            </button>
          </div>

          {/* Content */}
          <div className="p-6 overflow-y-auto max-h-[calc(90vh-140px)]">
            {loading ? (
              <div className="flex items-center justify-center py-12">
                <RefreshCw className="h-8 w-8 animate-spin text-blue-600" />
                <span className="ml-3 text-gray-600">Analyse en cours...</span>
              </div>
            ) : diagnostics ? (
              <div className="space-y-6">
                {/* Overall Status */}
                <div className={`p-4 rounded-lg border ${
                  diagnostics.overall_status === 'healthy' ? 'bg-green-50 border-green-200' :
                  diagnostics.overall_status === 'warning' ? 'bg-yellow-50 border-yellow-200' :
                  'bg-red-50 border-red-200'
                }`}>
                  <div className="flex items-center gap-3">
                    {diagnostics.overall_status === 'healthy' && <CheckCircle className="h-6 w-6 text-green-600" />}
                    {diagnostics.overall_status === 'warning' && <AlertTriangle className="h-6 w-6 text-yellow-600" />}
                    {diagnostics.overall_status === 'critical' && <XCircle className="h-6 w-6 text-red-600" />}
                    <div>
                      <h4 className={`font-semibold ${statusInfo?.color}`}>
                        {statusInfo?.message}
                      </h4>
                      <p className="text-sm text-gray-600">
                        État général du système de tableau de bord
                      </p>
                    </div>
                  </div>
                </div>

                {/* Health Summary */}
                {diagnostics.health && (
                  <div className="bg-white border border-gray-200 rounded-lg p-4">
                    <h4 className="font-semibold text-gray-900 mb-3 flex items-center gap-2">
                      <TrendingUp className="h-5 w-5 text-blue-600" />
                      Résumé de Santé
                    </h4>
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                      <div className="text-center">
                        <p className="text-2xl font-bold text-blue-600">
                          {diagnostics.health.total_indicators}
                        </p>
                        <p className="text-sm text-gray-600">Indicateurs configurés</p>
                      </div>
                      <div className="text-center">
                        <p className="text-2xl font-bold text-green-600">
                          {diagnostics.health.indicators_with_data}
                        </p>
                        <p className="text-sm text-gray-600">Avec données</p>
                      </div>
                      <div className="text-center">
                        <p className="text-2xl font-bold text-purple-600">
                          {diagnostics.health.data_completeness_rate}%
                        </p>
                        <p className="text-sm text-gray-600">Taux de completion</p>
                      </div>
                      <div className="text-center">
                        <p className={`text-lg font-bold ${
                          diagnostics.health.view_status === 'excellent' ? 'text-green-600' :
                          diagnostics.health.view_status === 'good' ? 'text-blue-600' :
                          diagnostics.health.view_status === 'fair' ? 'text-yellow-600' :
                          'text-red-600'
                        }`}>
                          {diagnostics.health.view_status.toUpperCase()}
                        </p>
                        <p className="text-sm text-gray-600">État de la vue</p>
                      </div>
                    </div>
                  </div>
                )}

                {/* Coverage Details */}
                <div className="bg-white border border-gray-200 rounded-lg p-4">
                  <h4 className="font-semibold text-gray-900 mb-3 flex items-center gap-2">
                    <Eye className="h-5 w-5 text-green-600" />
                    Couverture des Indicateurs
                  </h4>
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div>
                      <p className="text-sm text-gray-600">Configurés</p>
                      <p className="text-xl font-bold text-gray-900">{diagnostics.coverage.configured}</p>
                    </div>
                    <div>
                      <p className="text-sm text-gray-600">Affichés</p>
                      <p className="text-xl font-bold text-gray-900">{diagnostics.coverage.displayed}</p>
                    </div>
                    <div>
                      <p className="text-sm text-gray-600">Taux de couverture</p>
                      <p className={`text-xl font-bold ${
                        diagnostics.coverage.coverage_rate >= 90 ? 'text-green-600' :
                        diagnostics.coverage.coverage_rate >= 70 ? 'text-yellow-600' :
                        'text-red-600'
                      }`}>
                        {diagnostics.coverage.coverage_rate.toFixed(1)}%
                      </p>
                    </div>
                  </div>
                  
                  {diagnostics.coverage.missing.length > 0 && (
                    <div className="mt-4 p-3 bg-red-50 border border-red-200 rounded-lg">
                      <p className="text-sm font-medium text-red-800 mb-2">
                        Indicateurs manquants ({diagnostics.coverage.missing.length}):
                      </p>
                      <div className="flex flex-wrap gap-1">
                        {diagnostics.coverage.missing.slice(0, 10).map((code, index) => (
                          <span key={index} className="px-2 py-1 bg-red-100 text-red-700 rounded text-xs">
                            {code}
                          </span>
                        ))}
                        {diagnostics.coverage.missing.length > 10 && (
                          <span className="px-2 py-1 bg-red-100 text-red-700 rounded text-xs">
                            +{diagnostics.coverage.missing.length - 10} autres
                          </span>
                        )}
                      </div>
                    </div>
                  )}
                </div>

                {/* Validation Results */}
                <div className="bg-white border border-gray-200 rounded-lg p-4">
                  <h4 className="font-semibold text-gray-900 mb-3 flex items-center gap-2">
                    <Settings className="h-5 w-5 text-purple-600" />
                    Tests de Validation
                  </h4>
                  <div className="space-y-3">
                    {diagnostics.validation.map((test, index) => (
                      <div key={index} className={`flex items-start gap-3 p-3 rounded-lg ${
                        test.passed ? 'bg-green-50 border border-green-200' : 'bg-red-50 border border-red-200'
                      }`}>
                        {test.passed ? (
                          <CheckCircle className="h-5 w-5 text-green-600 flex-shrink-0 mt-0.5" />
                        ) : (
                          <XCircle className="h-5 w-5 text-red-600 flex-shrink-0 mt-0.5" />
                        )}
                        <div className="flex-1">
                          <p className={`font-medium ${test.passed ? 'text-green-800' : 'text-red-800'}`}>
                            {test.test_name.replace(/_/g, ' ').toUpperCase()}
                          </p>
                          <p className="text-sm text-gray-600">{test.details}</p>
                          {!test.passed && (
                            <p className="text-sm text-gray-700 mt-1 font-medium">
                              Recommandation: {test.recommendation}
                            </p>
                          )}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Recommendations */}
                {diagnostics.health?.recommendations && diagnostics.health.recommendations.length > 0 && (
                  <div className="bg-amber-50 border border-amber-200 rounded-lg p-4">
                    <h4 className="font-semibold text-amber-800 mb-3">Recommandations</h4>
                    <ul className="space-y-2">
                      {diagnostics.health.recommendations.map((rec, index) => (
                        <li key={index} className="flex items-start gap-2 text-sm text-amber-700">
                          <span className="text-amber-600 mt-1">•</span>
                          {rec}
                        </li>
                      ))}
                    </ul>
                  </div>
                )}
              </div>
            ) : (
              <div className="text-center py-12">
                <AlertTriangle className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                <p className="text-gray-600">Impossible de charger les diagnostics</p>
              </div>
            )}
          </div>

          {/* Footer */}
          <div className="flex items-center justify-between p-6 border-t border-gray-200 bg-gray-50">
            <div className="flex items-center gap-2">
              <button
                onClick={runDiagnostics}
                disabled={loading}
                className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 transition-colors"
              >
                <RefreshCw className={`h-4 w-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
                Relancer le diagnostic
              </button>
              
              {diagnostics?.overall_status !== 'healthy' && (
                <button
                  onClick={handleRecovery}
                  disabled={recovering}
                  className="flex items-center px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50 transition-colors"
                >
                  <Wrench className={`h-4 w-4 mr-2 ${recovering ? 'animate-pulse' : ''}`} />
                  {recovering ? 'Récupération...' : 'Réparer automatiquement'}
                </button>
              )}
            </div>
            
            <button
              onClick={onClose}
              className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
            >
              Fermer
            </button>
          </div>
        </motion.div>
      </div>
    </AnimatePresence>
  );
};