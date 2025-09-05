import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { useAuthStore } from '../../store/authStore';
import { supabase } from '../../lib/supabase';
import {
  ArrowLeft,
  Factory,
  Settings,
  BarChart3,
  MapPin,
  Phone,
  Mail,
  Calendar,
  Users,
  CheckCircle,
  AlertTriangle,
  Loader2,
  RefreshCw,
  Download,
  Eye,
  ChevronRight
} from 'lucide-react';
import toast from 'react-hot-toast';

interface Site {
  name: string;
  organization_name: string;
  business_line_name?: string;
  subsidiary_name?: string;
  address?: string;
  city?: string;
  country?: string;
  phone?: string;
  email?: string;
  description?: string;
}

interface Process {
  code: string;
  name: string;
  description?: string;
  indicator_codes: string[];
}

interface SiteProcess {
  site_name: string;
  process_code: string;
  process_name: string;
  description?: string;
  indicator_codes: string[];
  organization_name: string;
}

const SiteProcessesPage: React.FC = () => {
  const { siteName } = useParams<{ siteName: string }>();
  const navigate = useNavigate();
  const { profile, impersonatedOrganization } = useAuthStore();
  
  const [site, setSite] = useState<Site | null>(null);
  const [processes, setProcesses] = useState<SiteProcess[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  const currentOrganization = impersonatedOrganization || profile?.organization_name;

  useEffect(() => {
    if (siteName && currentOrganization) {
      fetchSiteData();
    }
  }, [siteName, currentOrganization]);

  const fetchSiteData = async () => {
    if (!siteName || !currentOrganization) return;

    try {
      setLoading(true);

      // Fetch site details
      const { data: siteData, error: siteError } = await supabase
        .from('sites')
        .select('*')
        .eq('name', siteName)
        .eq('organization_name', currentOrganization)
        .single();

      if (siteError) throw siteError;
      setSite(siteData);

      // Fetch site processes
      const { data: processesData, error: processesError } = await supabase
        .from('site_processes')
        .select('*')
        .eq('site_name', siteName)
        .eq('organization_name', currentOrganization);

      if (processesError) throw processesError;
      setProcesses(processesData || []);

    } catch (error) {
      console.error('Error fetching site data:', error);
      toast.error('Erreur lors du chargement des données du site');
    } finally {
      setLoading(false);
    }
  };

  const handleRefresh = async () => {
    setRefreshing(true);
    await fetchSiteData();
    setRefreshing(false);
    toast.success('Données actualisées');
  };

  const handleProcessClick = (processCode: string) => {
    navigate(`/site/${siteName}/process/${processCode}`);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="text-center"
        >
          <Loader2 className="h-12 w-12 animate-spin text-blue-600 mx-auto mb-4" />
          <p className="text-gray-600">Chargement des données du site...</p>
        </motion.div>
      </div>
    );
  }

  if (!site) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <AlertTriangle className="h-12 w-12 text-red-500 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">Site non trouvé</h3>
          <p className="text-gray-500 mb-4">Le site "{siteName}" n'existe pas ou vous n'y avez pas accès.</p>
          <button
            onClick={() => navigate(-1)}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            Retour
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="py-8 px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-center gap-4 mb-6">
            <button
              onClick={() => navigate(-1)}
              className="p-2 rounded-lg border border-gray-300 hover:bg-gray-50 transition-colors"
            >
              <ArrowLeft className="h-5 w-5 text-gray-600" />
            </button>
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Site : {site.name}</h1>
              <p className="text-gray-600 mt-1">Processus et indicateurs du site</p>
            </div>
          </div>
        </div>

        {/* Site Information */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="bg-white rounded-xl shadow-sm border border-gray-200 p-8 mb-8"
        >
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center gap-4">
              <div className="p-3 rounded-lg bg-blue-100">
                <Factory className="h-8 w-8 text-blue-600" />
              </div>
              <div>
                <h2 className="text-2xl font-bold text-gray-900">{site.name}</h2>
                <p className="text-gray-600">{site.description || 'Site de production'}</p>
              </div>
            </div>
            
            <div className="flex items-center gap-3">
              <button
                onClick={handleRefresh}
                disabled={refreshing}
                className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 transition-colors"
              >
                <RefreshCw className={`h-4 w-4 mr-2 ${refreshing ? 'animate-spin' : ''}`} />
                Actualiser
              </button>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {site.address && (
              <div className="flex items-center gap-3">
                <MapPin className="h-5 w-5 text-gray-400" />
                <div>
                  <p className="text-sm text-gray-600">Adresse</p>
                  <p className="font-medium text-gray-900">{site.address}</p>
                  <p className="text-sm text-gray-600">{site.city}, {site.country}</p>
                </div>
              </div>
            )}
            
            {site.phone && (
              <div className="flex items-center gap-3">
                <Phone className="h-5 w-5 text-gray-400" />
                <div>
                  <p className="text-sm text-gray-600">Téléphone</p>
                  <p className="font-medium text-gray-900">{site.phone}</p>
                </div>
              </div>
            )}
            
            {site.email && (
              <div className="flex items-center gap-3">
                <Mail className="h-5 w-5 text-gray-400" />
                <div>
                  <p className="text-sm text-gray-600">Email</p>
                  <p className="font-medium text-gray-900">{site.email}</p>
                </div>
              </div>
            )}
            
            <div className="flex items-center gap-3">
              <Users className="h-5 w-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-600">Processus</p>
                <p className="font-medium text-gray-900">{processes.length} actifs</p>
              </div>
            </div>
          </div>
        </motion.div>

        {/* Processes List */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden"
        >
          <div className="px-6 py-4 border-b border-gray-200 bg-gray-50">
            <div className="flex items-center justify-between">
              <h3 className="text-lg font-semibold text-gray-900">
                Processus du Site
              </h3>
              <div className="flex items-center gap-2 text-sm text-gray-600">
                <Settings className="h-4 w-4" />
                {processes.length} processus
              </div>
            </div>
          </div>

          <div className="divide-y divide-gray-200">
            {processes.length > 0 ? (
              processes.map((process, index) => (
                <motion.div
                  key={process.process_code}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: index * 0.05 }}
                  onClick={() => handleProcessClick(process.process_code)}
                  className="p-6 hover:bg-gray-50 cursor-pointer transition-colors"
                >
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-4">
                      <div className="p-3 rounded-lg bg-green-100">
                        <Settings className="h-6 w-6 text-green-600" />
                      </div>
                      <div>
                        <h4 className="text-lg font-semibold text-gray-900">{process.process_name}</h4>
                        <p className="text-sm text-gray-600 mt-1">{process.description || 'Processus ESG'}</p>
                        <div className="flex items-center gap-4 mt-2 text-sm text-gray-500">
                          <span className="flex items-center gap-1">
                            <BarChart3 className="h-4 w-4" />
                            {process.indicator_codes?.length || 0} indicateurs
                          </span>
                          <span className="flex items-center gap-1">
                            <CheckCircle className="h-4 w-4" />
                            Code: {process.process_code}
                          </span>
                        </div>
                      </div>
                    </div>
                    <ChevronRight className="h-5 w-5 text-gray-400" />
                  </div>
                </motion.div>
              ))
            ) : (
              <div className="text-center py-12">
                <Settings className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-gray-900 mb-2">Aucun processus configuré</h3>
                <p className="text-gray-500">
                  Ce site n'a pas encore de processus ESG configurés.
                </p>
              </div>
            )}
          </div>
        </motion.div>

        {/* Quick Stats */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-8"
        >
          <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
            <div className="flex items-center">
              <div className="p-3 rounded-lg bg-blue-500">
                <Settings className="h-6 w-6 text-white" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Processus Actifs</p>
                <p className="text-2xl font-bold text-gray-900">{processes.length}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
            <div className="flex items-center">
              <div className="p-3 rounded-lg bg-green-500">
                <BarChart3 className="h-6 w-6 text-white" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Indicateurs Total</p>
                <p className="text-2xl font-bold text-gray-900">
                  {processes.reduce((sum, p) => sum + (p.indicator_codes?.length || 0), 0)}
                </p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
            <div className="flex items-center">
              <div className="p-3 rounded-lg bg-purple-500">
                <CheckCircle className="h-6 w-6 text-white" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Statut</p>
                <p className="text-lg font-bold text-green-600">Opérationnel</p>
              </div>
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  );
};

export default SiteProcessesPage;