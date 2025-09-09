import React, { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../../store/authStore';
import { supabase } from '../../lib/supabase';
import {
  ArrowLeft,
  BarChart3,
  Building2,
  Factory,
  Layers,
  MapPin,
  ChevronRight,
  Search,
  Calendar,
  Download,
  Loader2,
  Home,
  ChevronDown,
  ChevronUp,
  List,
  LayoutGrid,
  FileText,
  HelpCircle,
  Globe,
  Building,
  AlertTriangle,
  CheckCircle,
  TrendingUp,
  TrendingDown,
  Target,
  Filter,
  RefreshCw,
  Eye,
  Users,
  Settings
} from 'lucide-react';
import toast from 'react-hot-toast';

type ViewType = 'overview' | 'consolidated';

interface Organization {
  name: string;
  description?: string;
  city: string;
  country: string;
  logo_url?: string;
  organization_type: 'simple' | 'with_subsidiaries' | 'group';
}

interface BusinessLine {
  name: string;
  organization_name: string;
  description?: string;
  created_at: string;
  updated_at: string;
}

interface Subsidiary {
  name: string;
  business_line_name?: string;
  organization_name: string;
  address?: string;
  city?: string;
  country?: string;
  phone?: string;
  email?: string;
  website?: string;
  description?: string;
  created_at: string;
  updated_at: string;
}

interface Site {
  name: string;
  subsidiary_name?: string;
  business_line_name?: string;
  organization_name: string;
  address?: string;
  city?: string;
  country?: string;
  phone?: string;
  email?: string;
  description?: string;
}

interface SitePerformanceSummary {
  site_name: string;
  organization_name: string;
  business_line_name?: string;
  subsidiary_name?: string;
  address?: string;
  city?: string;
  country?: string;
  total_indicators: number;
  filled_indicators: number;
  completion_rate: number;
  avg_performance: number;
  active_processes: number;
  last_updated: string;
}

interface ConsolidatedIndicator {
  id: string;
  organization_name: string;
  business_line_name?: string;
  subsidiary_name?: string;
  site_name?: string;
  process_code: string;
  indicator_code: string;
  year: number;
  month: number;
  indicator_name?: string;
  unit?: string;
  axe?: string;
  type?: string;
  formule?: string;
  frequence?: string;
  process_name?: string;
  process_description?: string;
  enjeux?: string;
  normes?: string;
  criteres?: string;
  value_raw?: number;
  value_consolidated?: number;
  sites_count?: number;
  sites_list?: string[];
  target_value?: number;
  previous_year_value?: number;
  variation?: number;
  performance?: number;
  last_updated?: string;
}

export const AdminClientPilotage: React.FC = () => {
  const navigate = useNavigate();
  const { profile, impersonatedOrganization } = useAuthStore();
  
  const [view, setView] = useState<ViewType>('overview');
  const [year, setYear] = useState(new Date().getFullYear());
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  
  // Data states
  const [organization, setOrganization] = useState<Organization | null>(null);
  const [businessLines, setBusinessLines] = useState<BusinessLine[]>([]);
  const [subsidiaries, setSubsidiaries] = useState<Subsidiary[]>([]);
  const [sites, setSites] = useState<Site[]>([]);
  const [sitePerformances, setSitePerformances] = useState<SitePerformanceSummary[]>([]);
  const [consolidatedIndicators, setConsolidatedIndicators] = useState<ConsolidatedIndicator[]>([]);
  const [filters, setFilters] = useState({
    axe: 'all',
    processus: 'all',
    level: 'all'
  });
  
  // UI states
  const [selectedLevel, setSelectedLevel] = useState<'organization' | 'business_line' | 'subsidiary'>('organization');
  const [selectedEntity, setSelectedEntity] = useState<string | null>(null);
  const [sortConfig, setSortConfig] = useState<{
    key: string | null;
    direction: 'asc' | 'desc';
  }>({ key: null, direction: 'asc' });

  const currentOrganization = impersonatedOrganization || profile?.organization_name;
  const currentYear = new Date().getFullYear();
  const years = [currentYear - 2, currentYear - 1, currentYear, currentYear + 1];
  const months = [
    'janvier', 'fevrier', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'aout', 'septembre', 'octobre', 'novembre', 'decembre'
  ];
  const monthLabels = [
    'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
    'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
  ];

  useEffect(() => {
    if (!currentOrganization) return;
    fetchOrganizationData();
  }, [currentOrganization]);

  useEffect(() => {
    if (view === 'sites' && organization) {
      fetchSitePerformances();
    } else if (view === 'consolidated' && organization) {
      fetchConsolidatedIndicators();
    }
  }, [view, organization, year, selectedLevel, selectedEntity]);

  const fetchOrganizationData = async () => {
    try {
      setLoading(true);
      
      // Fetch organization details
      const { data: orgData, error: orgError } = await supabase
        .from('organizations')
        .select('*')
        .eq('name', currentOrganization)
        .single();
      
      if (orgError) throw orgError;
      setOrganization(orgData);


      // Fetch all sites
      const { data: sitesData, error: sitesError } = await supabase
        .from('sites')
        .select('*')
        .eq('organization_name', currentOrganization)
        .order('name');
      
      if (sitesError) throw sitesError;
      setSites(sitesData || []);

      console.log('Sites fetched:', sitesData);
      
    } catch (err: any) {
      console.error('Error fetching organization data:', err);
      toast.error('Erreur lors du chargement des données');
    } finally {
      setLoading(false);
    }
  };

  const fetchSitePerformances = async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('site_performance_summary')
        .select('*')
        .eq('organization_name', currentOrganization)
        .order('completion_rate', { ascending: false });
      
      if (error) throw error;
      setSitePerformances(data || []);
    } catch (err) {
      console.error('Error fetching site performances:', err);
      toast.error('Erreur lors du chargement des performances des sites');
    } finally {
      setLoading(false);
    }
  };

  const fetchConsolidatedIndicators = async () => {
    try {
      setLoading(true);
      
      let query = supabase
        .from('site_indicator_values_consolidated')
        .select('*')
        .eq('organization_name', currentOrganization)
        .eq('year', year);

      // Apply hierarchy filters based on selected level and entity
      if (selectedLevel === 'business_line' && selectedEntity) {
        query = query.eq('business_line_name', selectedEntity);
      } else if (selectedLevel === 'subsidiary' && selectedEntity) {
        query = query.eq('subsidiary_name', selectedEntity);
      }

      const { data, error } = await query.order('indicator_code');
      
      if (error) throw error;
      setConsolidatedIndicators(data || []);
    } catch (err) {
      console.error('Error fetching consolidated indicators:', err);
      toast.error('Erreur lors du chargement des indicateurs consolidés');
    } finally {
      setLoading(false);
    }
  };

  const fetchConsolidatedData = async () => {
    // Implementation for fetchConsolidatedData
  };

  const handleRefresh = async () => {
    setRefreshing(true);
    try {
      // Refresh consolidated data using the correct function name
      await supabase.rpc('refresh_consolidated_views');
      await fetchOrganizationData();
      await fetchConsolidatedData();
      toast.success('Données actualisées');
    } catch (error) {
      console.error('Error refreshing data:', error);
      toast.error('Erreur lors de l\'actualisation des données');
    }
    try {
      await supabase.rpc('refresh_consolidation_data');
    } catch (err) {
      console.log('No consolidation refresh function available');
    }
    
    // Refetch current view data
    if (view === 'sites') {
      await fetchSitePerformances();
    } else if (view === 'consolidated') {
      await fetchConsolidatedIndicators();
    } else {
      await fetchOrganizationData();
    }
    
    setRefreshing(false);
  };

  const handleExport = async (format: 'excel' | 'pdf') => {
    try {
      let exportData: any[] = [];
      let filename = '';

      if (view === 'sites') {
        exportData = sitePerformances;
        filename = `sites_performance_${currentOrganization}_${year}`;
      } else if (view === 'consolidated') {
        exportData = consolidatedIndicators;
        filename = `consolidated_indicators_${currentOrganization}_${year}`;
      }

      // Create CSV content
      const headers = Object.keys(exportData[0] || {});
      const csvContent = [
        headers.join(','),
        ...exportData.map(row => 
          headers.map(header => 
            typeof row[header] === 'string' && row[header].includes(',') 
              ? `"${row[header]}"` 
              : row[header] || ''
          ).join(',')
        )
      ].join('\n');

      const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
      const link = document.createElement('a');
      const url = URL.createObjectURL(blob);
      link.setAttribute('href', url);
      link.setAttribute('download', `${filename}.csv`);
      link.style.visibility = 'hidden';
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      toast.success(`Export ${format.toUpperCase()} généré avec succès`);
    } catch (error) {
      console.error('Error exporting data:', error);
      toast.error('Erreur lors de l\'export');
    }
  };

  const handleSiteClick = (siteName: string) => {
    navigate(`/enterprise/collection?site=${siteName}`);
  };

  const handleSort = (key: string) => {
    setSortConfig(prev => ({
      key,
      direction: prev.key === key && prev.direction === 'asc' ? 'desc' : 'asc'
    }));
  };

  // Helper functions
  const getPerformanceColor = (performance?: number) => {
    if (!performance) return 'text-gray-500';
    if (performance >= 80) return 'text-green-600';
    if (performance >= 60) return 'text-yellow-600';
    return 'text-red-600';
  };

  const getPerformanceIcon = (performance?: number) => {
    if (!performance) return <HelpCircle className="h-3 w-3" />;
    if (performance >= 80) return <CheckCircle className="h-3 w-3" />;
    if (performance >= 60) return <AlertTriangle className="h-3 w-3" />;
    return <AlertTriangle className="h-3 w-3" />;
  };

  // Filter and sort data
  const uniqueAxes = [...new Set(consolidatedIndicators.map(i => i.axe).filter(Boolean))];
  
  const filteredConsolidatedIndicators = consolidatedIndicators
    .filter(indicator => {
      const matchesSearch = !search || 
        indicator.indicator_name?.toLowerCase().includes(search.toLowerCase()) ||
        indicator.indicator_code?.toLowerCase().includes(search.toLowerCase()) ||
        indicator.process_name?.toLowerCase().includes(search.toLowerCase());
      
      const matchesAxe = filters.axe === 'all' || indicator.axe === filters.axe;
      
      return matchesSearch && matchesAxe;
    })
    .sort((a, b) => {
      if (!sortConfig.key) return 0;
      
      const aValue = a[sortConfig.key as keyof ConsolidatedIndicator];
      const bValue = b[sortConfig.key as keyof ConsolidatedIndicator];
      
      if (aValue === null || aValue === undefined) return 1;
      if (bValue === null || bValue === undefined) return -1;
      
      if (typeof aValue === 'string' && typeof bValue === 'string') {
        return sortConfig.direction === 'asc' 
          ? aValue.localeCompare(bValue)
          : bValue.localeCompare(aValue);
      }
      
      if (typeof aValue === 'number' && typeof bValue === 'number') {
        return sortConfig.direction === 'asc' ? aValue - bValue : bValue - aValue;
      }
      
      return 0;
    });

  const renderOverview = () => (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="space-y-6"
    >
      {/* Organization Header */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-4">
            <div className="p-3 rounded-lg bg-blue-500">
              <Building2 className="h-8 w-8 text-white" />
            </div>
            <div>
              <h2 className="text-2xl font-semibold text-gray-900">{organization?.name}</h2>
              <p className="text-gray-600">{organization?.city}, {organization?.country}</p>
              <div className="flex items-center gap-2 mt-2">
                <span className={`px-3 py-1 rounded-full text-sm font-medium ${
                  organization?.organization_type === 'simple' ? 'bg-green-100 text-green-800' :
                  organization?.organization_type === 'with_subsidiaries' ? 'bg-blue-100 text-blue-800' :
                  'bg-purple-100 text-purple-800'
                }`}>
                  {organization?.organization_type === 'simple' ? 'Organisation Simple' :
                   organization?.organization_type === 'with_subsidiaries' ? 'Avec Filiales' :
                   'Groupe'}
                </span>
              </div>
            </div>
          </div>
          
          <div className="flex items-center gap-3">
            <button
              onClick={handleRefresh}
              disabled={refreshing}
              className="flex items-center px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 disabled:opacity-50 transition-colors"
            >
              <RefreshCw className={`h-4 w-4 mr-2 ${refreshing ? 'animate-spin' : ''}`} />
              Actualiser
            </button>
          </div>
        </div>
      </div>

      {/* Quick Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Sites Totaux</p>
              <p className="text-3xl font-bold text-gray-900">{sites.length}</p>
            </div>
            <div className="p-3 rounded-lg bg-blue-100">
              <Factory className="h-6 w-6 text-blue-600" />
            </div>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Filières</p>
              <p className="text-3xl font-bold text-gray-900">{businessLines.length}</p>
            </div>
            <div className="p-3 rounded-lg bg-green-100">
              <Layers className="h-6 w-6 text-green-600" />
            </div>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Filiales</p>
              <p className="text-3xl font-bold text-gray-900">{subsidiaries.length}</p>
            </div>
            <div className="p-3 rounded-lg bg-purple-100">
              <Building className="h-6 w-6 text-purple-600" />
            </div>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Indicateurs</p>
              <p className="text-3xl font-bold text-gray-900">{consolidatedIndicators.length}</p>
            </div>
            <div className="p-3 rounded-lg bg-yellow-100">
              <BarChart3 className="h-6 w-6 text-yellow-600" />
            </div>
          </div>
        </div>
      </div>

      {/* Sites List */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-200">
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-lg font-semibold text-gray-900">Sites de l'Organisation</h3>
        </div>
        <div className="p-6">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {sites.map((site) => (
              <motion.div
                key={site.name}
                whileHover={{ scale: 1.02 }}
                className="p-4 border border-gray-200 rounded-lg hover:border-blue-300 hover:shadow-md transition-all cursor-pointer"
                onClick={() => handleSiteClick(site.name)}
              >
                <div className="flex items-center justify-between mb-2">
                  <h4 className="font-semibold text-gray-900">{site.name}</h4>
                  <ChevronRight className="h-4 w-4 text-gray-400" />
                </div>
                <div className="space-y-1 text-sm text-gray-600">
                  {site.city && (
                    <div className="flex items-center gap-1">
                      <MapPin className="h-3 w-3" />
                      <span>{site.city}, {site.country}</span>
                    </div>
                  )}
                  {site.business_line_name && (
                    <div className="flex items-center gap-1">
                      <Layers className="h-3 w-3" />
                      <span>{site.business_line_name}</span>
                    </div>
                  )}
                  {site.subsidiary_name && (
                    <div className="flex items-center gap-1">
                      <Building className="h-3 w-3" />
                      <span>{site.subsidiary_name}</span>
                    </div>
                  )}
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </div>
    </motion.div>
  );

  const renderConsolidatedView = () => (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="space-y-6"
    >
      {/* Header */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-3">
            <div className="p-3 rounded-lg bg-indigo-500">
              <Globe className="h-6 w-6 text-white" />
            </div>
            <div>
              <h2 className="text-2xl font-semibold text-gray-900">Vue Consolidée</h2>
              <p className="text-gray-600">
                Données consolidées - {selectedEntity || currentOrganization} ({year})
              </p>
            </div>
          </div>
          
          <div className="flex items-center gap-3">
            <button
              onClick={handleRefresh}
              disabled={refreshing}
              className="flex items-center px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 disabled:opacity-50 transition-colors"
            >
              <RefreshCw className={`h-4 w-4 mr-2 ${refreshing ? 'animate-spin' : ''}`} />
              Actualiser
            </button>
            <button
              onClick={() => handleExport('excel')}
              className="flex items-center px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
            >
              <Download className="h-4 w-4 mr-2" />
              Export Excel
            </button>
          </div>
        </div>

        {/* Filters */}
        <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              <Calendar className="h-4 w-4 inline mr-1" />
              Année
            </label>
            <select
              value={year}
              onChange={(e) => setYear(parseInt(e.target.value))}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
            >
              {years.map(y => (
                <option key={y} value={y}>{y}</option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              <Filter className="h-4 w-4 inline mr-1" />
              Niveau
            </label>
            <select
              value={selectedLevel}
              onChange={(e) => {
                setSelectedLevel(e.target.value as any);
                setSelectedEntity(null);
              }}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
            >
              <option value="organization">Organisation</option>
              {businessLines.length > 0 && <option value="business_line">Filière</option>}
              {subsidiaries.length > 0 && <option value="subsidiary">Filiale</option>}
            </select>
          </div>

          {selectedLevel !== 'organization' && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                <Filter className="h-4 w-4 inline mr-1" />
                {selectedLevel === 'business_line' ? 'Filière' : 'Filiale'}
              </label>
              <select
                value={selectedEntity || ''}
                onChange={(e) => setSelectedEntity(e.target.value || null)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
              >
                <option value="">Toutes</option>
                {selectedLevel === 'business_line' && businessLines.map(bl => (
                  <option key={bl.name} value={bl.name}>{bl.name}</option>
                ))}
                {selectedLevel === 'subsidiary' && subsidiaries.map(sub => (
                  <option key={sub.name} value={sub.name}>{sub.name}</option>
                ))}
              </select>
            </div>
          )}

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              <Filter className="h-4 w-4 inline mr-1" />
              Axe ESG
            </label>
            <select
              value={filters.axe}
              onChange={(e) => setFilters(prev => ({ ...prev, axe: e.target.value }))}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
            >
              <option value="all">Tous les axes</option>
              {uniqueAxes.map(axe => (
                <option key={axe} value={axe}>{axe}</option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              <Search className="h-4 w-4 inline mr-1" />
              Recherche
            </label>
            <input
              type="text"
              placeholder="Rechercher un indicateur..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
            />
          </div>
        </div>
      </div>

      {/* Consolidated Table */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-200 bg-gray-50">
          <div className="flex items-center justify-between">
            <h3 className="text-lg font-semibold text-gray-900">
              Indicateurs Consolidés {year}
            </h3>
            <div className="flex items-center gap-2 text-sm text-gray-600">
              <BarChart3 className="h-4 w-4" />
              {filteredConsolidatedIndicators.length} indicateurs
            </div>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                {[
                  { key: 'axe', label: 'Axe' },
                  { key: 'enjeux', label: 'Enjeux' },
                  { key: 'normes', label: 'Normes' },
                  { key: 'criteres', label: 'Critères' },
                  { key: 'process_code', label: 'Code Processus' },
                  { key: 'process_name', label: 'Processus' },
                  { key: 'indicator_code', label: 'Code Indicateur' },
                  { key: 'indicator_name', label: 'Indicateur' },
                  { key: 'unit', label: 'Unité' },
                  { key: 'frequence', label: 'Fréquence' },
                  { key: 'type', label: 'Type' },
                  { key: 'formule', label: 'Formule' }
                ].map(({ key, label }) => (
                  <th
                    key={key}
                    onClick={() => handleSort(key)}
                    className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100 transition-colors"
                  >
                    <div className="flex items-center gap-1">
                      {label}
                      {sortConfig.key === key && (
                        sortConfig.direction === 'asc' ? 
                        <TrendingUp className="h-3 w-3" /> : 
                        <TrendingDown className="h-3 w-3" />
                      )}
                    </div>
                  </th>
                ))}
                
                {/* Monthly columns */}
                {monthLabels.map((month, index) => (
                  <th
                    key={month}
                    onClick={() => handleSort(months[index])}
                    className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100 transition-colors"
                  >
                    {month}
                  </th>
                ))}
                
                {[
                  { key: 'target_value', label: 'Cible' },
                  { key: 'variation', label: 'Variation' },
                  { key: 'performance', label: 'Performance' },
                  { key: 'sites_count', label: 'Nb Sites' },
                  { key: 'sites_list', label: 'Sites' }
                ].map(({ key, label }) => (
                  <th
                    key={key}
                    onClick={() => handleSort(key)}
                    className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100 transition-colors"
                  >
                    <div className="flex items-center justify-center gap-1">
                      {label}
                      {sortConfig.key === key && (
                        sortConfig.direction === 'asc' ? 
                        <TrendingUp className="h-3 w-3" /> : 
                        <TrendingDown className="h-3 w-3" />
                      )}
                    </div>
                  </th>
                ))}
              </tr>
            </thead>
            
            <tbody className="bg-white divide-y divide-gray-200">
              <AnimatePresence>
                {filteredConsolidatedIndicators.map((indicator, index) => (
                  <motion.tr
                    key={`${indicator.process_code}-${indicator.indicator_code}-${indicator.site_name || 'consolidated'}`}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -20 }}
                    transition={{ delay: index * 0.02 }}
                    className="hover:bg-gray-50 transition-colors"
                  >
                    {/* Core columns */}
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                        indicator.axe === 'Environnement' ? 'bg-green-100 text-green-800' :
                        indicator.axe === 'Social' ? 'bg-blue-100 text-blue-800' :
                        indicator.axe === 'Gouvernance' ? 'bg-purple-100 text-purple-800' :
                        'bg-gray-100 text-gray-800'
                      }`}>
                        {indicator.axe || '-'}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900 max-w-xs truncate" title={indicator.enjeux}>
                      {indicator.enjeux || '-'}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900 max-w-xs truncate" title={indicator.normes}>
                      {indicator.normes || '-'}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900 max-w-xs truncate" title={indicator.criteres}>
                      {indicator.criteres || '-'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-mono text-gray-900">
                      {indicator.process_code}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900 max-w-xs" title={indicator.process_name}>
                      <div className="font-medium truncate">{indicator.process_name || '-'}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-mono text-gray-900">
                      {indicator.indicator_code}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900 max-w-xs" title={indicator.indicator_name}>
                      <div className="font-medium truncate">{indicator.indicator_name || indicator.indicator_code}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{indicator.unit || '-'}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{indicator.frequence || '-'}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{indicator.type || '-'}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                        indicator.formule === 'somme' ? 'bg-blue-100 text-blue-800' :
                        indicator.formule === 'moyenne' ? 'bg-green-100 text-green-800' :
                        indicator.formule === 'max' ? 'bg-red-100 text-red-800' :
                        indicator.formule === 'min' ? 'bg-yellow-100 text-yellow-800' :
                        'bg-gray-100 text-gray-800'
                      }`}>
                        {indicator.formule || '-'}
                      </span>
                    </td>
                    
                    {/* Monthly values - using value_consolidated */}
                    {months.map((month) => (
                      <td key={month} className="px-4 py-4 whitespace-nowrap text-sm text-center text-gray-900">
                        <span className="font-medium text-blue-600">
                          {indicator.value_consolidated ? 
                            Number(indicator.value_consolidated).toLocaleString() : 
                            '-'
                          }
                        </span>
                      </td>
                    ))}
                    
                    {/* Target, Variation, Performance */}
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-center text-gray-900">
                      {indicator.target_value ? indicator.target_value.toLocaleString() : '-'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-center">
                      <div className={`flex items-center justify-center gap-1 ${
                        indicator.variation && indicator.variation > 0 ? 'text-green-600' :
                        indicator.variation && indicator.variation < 0 ? 'text-red-600' :
                        'text-gray-500'
                      }`}>
                        {indicator.variation && indicator.variation > 0 && <TrendingUp className="h-3 w-3" />}
                        {indicator.variation && indicator.variation < 0 && <TrendingDown className="h-3 w-3" />}
                        <span className="font-medium">
                          {indicator.variation ? `${indicator.variation > 0 ? '+' : ''}${indicator.variation.toFixed(1)}%` : '-'}
                        </span>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-center">
                      <div className={`flex items-center justify-center gap-1 ${getPerformanceColor(indicator.performance)}`}>
                        {getPerformanceIcon(indicator.performance)}
                        <span className="font-bold">
                          {indicator.performance ? `${indicator.performance.toFixed(1)}%` : '-'}
                        </span>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-center">
                      <span className="px-2 py-1 bg-blue-100 text-blue-800 rounded-full font-medium">
                        {indicator.sites_count || 0}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900">
                      <div className="flex flex-wrap gap-1">
                        {indicator.sites_list?.slice(0, 2).map((site, i) => (
                          <span key={i} className="px-2 py-1 bg-blue-100 text-blue-800 rounded-full text-xs">
                            {site}
                          </span>
                        ))}
                        {indicator.sites_list && indicator.sites_list.length > 2 && (
                          <span className="px-2 py-1 bg-gray-100 text-gray-800 rounded-full text-xs">
                            +{indicator.sites_list.length - 2}
                          </span>
                        )}
                      </div>
                    </td>
                  </motion.tr>
                ))}
              </AnimatePresence>
            </tbody>
          </table>
        </div>

        {filteredConsolidatedIndicators.length === 0 && (
          <div className="text-center py-12">
            <FileText className="h-12 w-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">Aucune donnée consolidée</h3>
            <p className="text-gray-500">
              {search ? 
                "Aucun indicateur ne correspond à votre recherche." :
                `Aucune donnée consolidée disponible pour l'année ${year}.`
              }
            </p>
          </div>
        )}
      </div>

      {/* Consolidation Info */}
      <div className="bg-blue-50 border border-blue-200 rounded-xl p-6">
        <div className="flex items-start gap-3">
          <HelpCircle className="h-5 w-5 text-blue-600 mt-0.5" />
          <div>
            <h4 className="font-medium text-blue-900 mb-2">À propos de la consolidation</h4>
            <p className="text-blue-800 text-sm">
              Les données consolidées agrègent les valeurs de tous les sites selon la formule définie pour chaque indicateur.
              Les formules disponibles sont : somme, moyenne, minimum et maximum.
            </p>
          </div>
        </div>
      </div>
    </motion.div>
  );

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="text-center"
        >
          <Loader2 className="h-12 w-12 animate-spin text-blue-600 mx-auto mb-4" />
          <p className="text-gray-600">Chargement du pilotage organisationnel...</p>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="py-8 px-4 sm:px-6 lg:px-8">
        {/* Navigation Header */}
        <div className="mb-8">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <button
                onClick={() => navigate('/enterprise/dashboard')}
                className="p-2 rounded-lg border border-gray-300 hover:bg-gray-50 transition-colors"
              >
                <ArrowLeft className="h-5 w-5 text-gray-600" />
              </button>
              <div>
                <h1 className="text-3xl font-bold text-gray-900">Pilotage Organisationnel</h1>
                <p className="text-gray-600 mt-1">Navigation et tableaux de bord consolidés</p>
              </div>
            </div>

            {/* View Selector */}
            <div className="flex items-center space-x-2 bg-gray-100 rounded-lg p-1">
              <button
                onClick={() => setView('overview')}
                className={`flex items-center space-x-2 px-4 py-2 rounded-md transition-colors ${
                  view === 'overview' 
                    ? 'bg-white text-gray-900 shadow-sm' 
                    : 'text-gray-600 hover:bg-gray-200'
                }`}
              >
                <Home className="w-4 h-4" />
                <span>Vue d'ensemble</span>
              </button>
              <button
                onClick={() => {
                  setSelectedLevel('organization');
                  setSelectedEntity(null);
                  setView('consolidated');
                }}
                className={`flex items-center space-x-2 px-4 py-2 rounded-md transition-colors ${
                  view === 'consolidated' 
                    ? 'bg-white text-gray-900 shadow-sm' 
                    : 'text-gray-600 hover:bg-gray-200'
                }`}
              >
                <Globe className="w-4 h-4" />
                <span>Consolidée</span>
              </button>
            </div>
          </div>
        </div>

        {/* Content */}
        <AnimatePresence mode="wait">
          <motion.div
            key={view}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            transition={{ duration: 0.2 }}
          >
            {view === 'overview' && renderOverview()}
            {view === 'consolidated' && renderConsolidatedView()}
          </motion.div>
        </AnimatePresence>
      </div>
    </div>
  );
};