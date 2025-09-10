import React from 'react';
import { useAuthStore } from '../../store/authStore';
import { ContributorPilotageReplicated } from '../../components/pilotage/ContributorPilotageReplicated';
import { ValidatorPilotageReplicated } from '../../components/pilotage/ValidatorPilotageReplicated';
import { DashboardTab } from '../../components/pilotage/DashboardTab';
import { Navigate, useSearchParams } from 'react-router-dom';
import { useState } from 'react';
import { motion } from 'framer-motion';
import { BarChart3, Table, Eye, CheckCircle, Zap } from 'lucide-react';

export default function PilotageEnergetique() {
  const { profile, impersonatedOrganization } = useAuthStore();
  const [searchParams, setSearchParams] = useSearchParams();
  const [activeView, setActiveView] = useState(() => {
    const viewFromParams = searchParams.get('view');
    if (viewFromParams) return viewFromParams;
    
    // Default selon le rôle
    const isContributor = ['contributeur', 'contributor'].includes(profile?.role || '');
    const isValidator = ['validateur', 'validator'].includes(profile?.role || '');
    
    if (isContributor) return 'collection';
    if (isValidator) return 'validation';
    return 'dashboard';
  });

  // Vérifier les permissions d'accès
  const isAdmin = profile?.role === 'admin';
  const isEnterprise = ['enterprise', 'admin_client'].includes(profile?.role || '');
  const isContributor = ['contributeur', 'contributor'].includes(profile?.role || '');
  const isValidator = ['validateur', 'validator'].includes(profile?.role || '');
  
  // Permettre l'accès aux rôles autorisés
  const hasAccess = isEnterprise || isContributor || isValidator || (isAdmin && impersonatedOrganization);

  if (!profile || !hasAccess) {
    return <Navigate to="/login" replace />;
  }

  // Update URL when view changes
  const handleViewChange = (view: string) => {
    setActiveView(view);
    setSearchParams({ view });
  };

  // Interface selon le rôle
  if (isContributor) {
    return (
      <div className="min-h-screen bg-gray-50">
        {/* Navigation Header */}
        <div className="bg-white shadow-sm border-b px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="p-2 rounded-lg bg-blue-500">
                <Zap className="h-6 w-6 text-white" />
              </div>
              <h1 className="text-2xl font-bold text-gray-900">Module Pilotage Énergétique</h1>
            </div>
            <div className="flex items-center space-x-2 bg-gray-100 rounded-lg p-1">
              <button
                onClick={() => handleViewChange('dashboard')}
                className={`flex items-center space-x-2 px-4 py-2 rounded-md transition-colors ${
                  activeView === 'dashboard' 
                    ? 'bg-blue-600 text-white' 
                    : 'text-gray-600 hover:bg-gray-200'
                }`}
              >
                <BarChart3 className="w-4 h-4" />
                <span>Tableau de Bord</span>
              </button>
              <button
                onClick={() => handleViewChange('collection')}
                className={`flex items-center space-x-2 px-4 py-2 rounded-md transition-colors ${
                  activeView === 'collection' 
                    ? 'bg-blue-600 text-white' 
                    : 'text-gray-600 hover:bg-gray-200'
                }`}
              >
                <Table className="w-4 h-4" />
                <span>Collecte</span>
              </button>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="p-6">
          <motion.div
            key={activeView}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            transition={{ duration: 0.2 }}
          >
            {activeView === 'dashboard' ? <DashboardTab /> : <ContributorPilotageReplicated />}
          </motion.div>
        </div>
      </div>
    );
  }
   
  if (isValidator) {
    return (
      <div className="min-h-screen bg-gray-50">
        {/* Navigation Header */} 
        <div className="bg-white shadow-sm border-b px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="p-2 rounded-lg bg-green-500">
                <CheckCircle className="h-6 w-6 text-white" />
              </div>
              <h1 className="text-2xl font-bold text-gray-900">Module Pilotage Énergétique</h1>
            </div>
            <div className="flex items-center space-x-2 bg-gray-100 rounded-lg p-1">
              <button
                onClick={() => handleViewChange('dashboard')}
                className={`flex items-center space-x-2 px-4 py-2 rounded-md transition-colors ${
                  activeView === 'dashboard' 
                    ? 'bg-blue-600 text-white' 
                    : 'text-gray-600 hover:bg-gray-200'
                }`}
              >
                <BarChart3 className="w-4 h-4" />
                <span>Tableau de Bord</span>
              </button>
              <button
                onClick={() => handleViewChange('validation')}
                className={`flex items-center space-x-2 px-4 py-2 rounded-md transition-colors ${
                  activeView === 'validation' 
                    ? 'bg-blue-600 text-white' 
                    : 'text-gray-600 hover:bg-gray-200'
                }`}
              >
                <Eye className="w-4 h-4" />
                <span>Validation</span>
              </button>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="p-6">
          <motion.div
            key={activeView}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            transition={{ duration: 0.2 }}
          >
            {activeView === 'dashboard' ? <DashboardTab /> : <ValidatorPilotageReplicated />}
          </motion.div>
        </div>
      </div>
    );
  }
  
  // Pour les autres rôles, rediriger vers le dashboard principal
  return <Navigate to="/enterprise/dashboard" replace />;
}