import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  CheckCircle,
  AlertTriangle,
  XCircle,
  RefreshCw,
  Database,
  Search,
  Wrench,
  Eye,
  TrendingUp
} from 'lucide-react';
import {
  diagnoseSiteConsolidation,
  fixConsolidationIssues,
  validateConsolidationWorking,
  ConsolidationDiagnostic,
  SiteDataDiagnostic
} from '../utils/consolidationDiagnostics';
import toast from 'react-hot-toast';

interface ConsolidationDiagnosticsModalProps {
  isOpen: boolean;
  onClose: () => void;
  organizationName: string;
  siteName?: string;
  onFixComplete?: () => void;
}

export const ConsolidationDiagnosticsModal: React.FC<ConsolidationDiagnosticsModalProps> = ({
  isOpen,
  onClose,
  organizationName,
  siteName = 'Test F2',
  onFixComplete
}) => {
  const [diagnostics, setDiagnostics] = useState<ConsolidationDiagnostic[]>([]);
  const [siteInfo, setSiteInfo] = useState<SiteDataDiagnostic | null>(null);
  const [recommendations, setRecommendations] = useState<string[]>([]);
  const [validationMetrics, setValidationMetrics] = useState<any>(null);
  const [loading, setLoading] = useState(false);
  const [fixing, setFixing] = useState(false);
  const [testSiteName, setTestSiteName] = useState(siteName);

  const runDiagnostics = async () => {
    if (!organizationName || !testSiteName) return;

    try {
      setLoading(true);
      
      // Run site-specific diagnostics
      const siteResults = await diagnoseSiteConsolidation(testSiteName, organizationName);
      setDiagnostics(siteResults.diagnostics);
      setSiteInfo(siteResults.siteInfo);
      setRecommendations(siteResults.recommendations);

      // Run organization-wide validation
      const validationResults = await validateConsolidationWorking(organizationName);
      setValidationMetrics(validationResults);

      toast.success('Diagnostic terminé');
    } catch (error) {
      console.error('Error running diagnostics:', error);
      toast.error('Erreur lors du diagnostic');
    } finally {
      setLoading(false);
    }
  };

  const runFixes = async () => {
    if (!organizationName || !testSiteName) return;

    try {
      setFixing(true);
      
      const fixResults = await fixConsolidationIssues(testSiteName, organizationName);
      
      if (fixResults.success) {
        toast.success(`Corrections appliquées: ${fixResults.actions_taken.join(', ')}`);
        onFixComplete?.();
        // Re-run diagnostics to verify fixes
        await runDiagnostics();
      } else {
        toast.error(`Corrections partielles: ${fixResults.remaining_issues.join(', ')}`);
      }
    } catch (error) {
      console.error('Error applying fixes:', error);
      toast.error('Erreur lors de l\'application des corrections');
    } finally {
      setFixing(false);
    }
  };

  const getStatusIcon = (status: 'pass' | 'fail' | 'warning') => {
    switch (status) {
      case 'pass': return <CheckCircle className="h-5 w-5 text-green-600" />;
      case 'warning': return <AlertTriangle className="h-5 w-5 text-yellow-600" />;
      case 'fail': return <XCircle className="h-5 w-5 text-red-600" />;
    }
  };

  const getStatusColor = (status: 'pass' | 'fail' | 'warning') => {
    switch (status) {
      case 'pass': return 'bg-green-50 border-green-200';
      case 'warning': return 'bg-yellow-50 border-yellow-200';
      case 'fail': return 'bg-red-50 border-red-200';
    }
  };

  if (!isOpen) return null;

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
                  Diagnostic de Consolidation
                </h3>
                <p className="text-sm text-gray-600">{organizationName}</p>
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
            {/* Site Selection */}
            <div className="mb-6 p-4 bg-gray-50 rounded-lg">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Site à diagnostiquer
              </label>
              <div className="flex gap-3">
                <input
                  type="text"
                  value={testSiteName}
                  onChange={(e) => setTestSiteName(e.target.value)}
                  placeholder="Nom du site (ex: Test F2)"
                  className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
                <button
                  onClick={runDiagnostics}
                  disabled={loading}
                  className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 transition-colors"
                >
                  <Search className={`h-4 w-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
                  Diagnostiquer
                </button>
              </div>
            </div>

            {/* Site Information */}
            {siteInfo && (
              <div className="mb-6 p-4 bg-white border border-gray-200 rounded-lg">
                <h4 className="font-semibold text-gray-900 mb-3 flex items-center gap-2">
                  <Eye className="h-5 w-5 text-blue-600" />
                  Informations du Site
                </h4>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                  <div>
                    <p className="text-sm text-gray-600">Site</p>
                    <p className="font-medium">{siteInfo.site_name}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Filière</p>
                    <p className="font-medium">{siteInfo.business_line_name || 'Non assigné'}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Filiale</p>
                    <p className="font-medium">{siteInfo.subsidiary_name || 'Non assigné'}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Statut</p>
                    <p className={`font-medium ${
                      siteInfo.appears_in_consolidated ? 'text-green-600' : 'text-red-600'
                    }`}>
                      {siteInfo.appears_in_consolidated ? 'Consolidé' : 'Non consolidé'}
                    </p>
                  </div>
                </div>
              </div>
            )}

            {/* Diagnostic Results */}
            {diagnostics.length > 0 && (
              <div className="mb-6">
                <h4 className="font-semibold text-gray-900 mb-3 flex items-center gap-2">
                  <TrendingUp className="h-5 w-5 text-purple-600" />
                  Résultats du Diagnostic
                </h4>
                <div className="space-y-3">
                  {diagnostics.map((diagnostic, index) => (
                    <div key={index} className={`p-3 rounded-lg border ${getStatusColor(diagnostic.status)}`}>
                      <div className="flex items-start gap-3">
                        {getStatusIcon(diagnostic.status)}
                        <div className="flex-1">
                          <p className="font-medium text-gray-900">{diagnostic.step}</p>
                          <p className="text-sm text-gray-600">{diagnostic.details}</p>
                          {diagnostic.recommendation && (
                            <p className="text-sm text-blue-700 mt-1 font-medium">
                              💡 {diagnostic.recommendation}
                            </p>
                          )}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Organization Metrics */}
            {validationMetrics && (
              <div className="mb-6 p-4 bg-white border border-gray-200 rounded-lg">
                <h4 className="font-semibold text-gray-900 mb-3">Métriques Organisationnelles</h4>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                  <div className="text-center">
                    <p className="text-2xl font-bold text-blue-600">
                      {validationMetrics.metrics.total_sites}
                    </p>
                    <p className="text-sm text-gray-600">Sites totaux</p>
                  </div>
                  <div className="text-center">
                    <p className="text-2xl font-bold text-green-600">
                      {validationMetrics.metrics.sites_with_data}
                    </p>
                    <p className="text-sm text-gray-600">Sites avec données</p>
                  </div>
                  <div className="text-center">
                    <p className="text-2xl font-bold text-purple-600">
                      {validationMetrics.metrics.sites_in_consolidated}
                    </p>
                    <p className="text-sm text-gray-600">Sites consolidés</p>
                  </div>
                  <div className="text-center">
                    <p className={`text-2xl font-bold ${
                      validationMetrics.metrics.consolidation_rate >= 95 ? 'text-green-600' :
                      validationMetrics.metrics.consolidation_rate >= 80 ? 'text-yellow-600' :
                      'text-red-600'
                    }`}>
                      {validationMetrics.metrics.consolidation_rate.toFixed(1)}%
                    </p>
                    <p className="text-sm text-gray-600">Taux consolidation</p>
                  </div>
                </div>
              </div>
            )}

            {/* Recommendations */}
            {recommendations.length > 0 && (
              <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                <h4 className="font-semibold text-blue-800 mb-3">Recommandations</h4>
                <ul className="space-y-2">
                  {recommendations.map((rec, index) => (
                    <li key={index} className="flex items-start gap-2 text-sm text-blue-700">
                      <span className="text-blue-600 mt-1">•</span>
                      {rec}
                    </li>
                  ))}
                </ul>
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
              
              {siteInfo && siteInfo.issues.length > 0 && (
                <button
                  onClick={runFixes}
                  disabled={fixing}
                  className="flex items-center px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50 transition-colors"
                >
                  <Wrench className={`h-4 w-4 mr-2 ${fixing ? 'animate-pulse' : ''}`} />
                  {fixing ? 'Correction...' : 'Corriger automatiquement'}
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