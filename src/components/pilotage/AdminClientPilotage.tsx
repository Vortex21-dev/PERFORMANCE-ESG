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
  organization_name: string;
  business_line_name?: string;
  description?: string;
  address: string;
  city: string;
  country: string;
  phone: string;
  email: string;
  website?: string;
  created_at: string;
  updated_at: string;
}

interface Site {
  name: string;
  organization_name: string;
  business_line_name?: string;
  subsidiary_name?: string;
  description?: string;
  address: string;
  city: string;
  country: string;
  phone: string;
  email: string;
  created_at: string;
  updated_at: string;
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
  const [sitePerformances, setSitePerformances] = useState<SitePerformance[]>([]);
  const [consolidatedIndicators, setConsolidatedIndicators] = useState<ConsolidatedIndicator[]>([]);
  
  // Missing state variables
  const [businessLines, setBusinessLines] = useState<BusinessLine[]>([]);
  const [subsidiaries, setSubsidiaries] = useState<Subsidiary[]>([]);
  const [sites, setSites] = useState<Site[]>([]);
  
  // Filters
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
    if (view === 'consolidated' && organization) {
      fetchConsolidatedIndicators();
    }
  }, [view, organization, year]);

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
      
      // Fetch business lines
      const { data: businessLinesData, error: businessLinesError } = await supabase
        .from('business_lines')
        .select('*')
        .eq('organization_name', currentOrganization)
        .order('name');
      
      if (businessLinesError) throw businessLinesError;
      setBusinessLines(businessLinesData || []);
      
      // Fetch subsidiaries
      const { data: subsidiariesData, error: subsidiariesError } = await supabase
        .from('subsidiaries')
        .select('*')
        .eq('organization_name', currentOrganization)
        .order('name');
      
      if (subsidiariesError) throw subsidiariesError;
      setSubsidiaries(subsidiariesData || []);
      
      // Fetch sites
      const { data: sitesData, error: sitesError } = await supabase
        .from('sites')
        .select('*')
        .eq('organization_name', currentOrganization)
        .order('name');
      
      if (sitesError) throw sitesError;
      setSites(sitesData || []);
      
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
    if (view === 'consolidated') {
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

      if (view === 'consolidated') {
        exportData = filteredConsolidatedIndicators.map(indicator => ({
          'Niveau': selectedLevel === 'organization' ? 'Organisation' : 
                   selectedLevel === 'business_line' ? 'Filière' : 'Filiale',
          'Entité': selectedEntity || currentOrganization,
          'Axe': indicator.axe || '-',
          'Enjeux': indicator.enjeux || '-',
          'Normes': indicator.normes || '-',
          'Critères': indicator.criteres || '-',
          'Code Processus': indicator.process_code,
          'Processus': indicator.process_name || '-',
          'Code Indicateur': indicator.indicator_code,
          'Indicateur': indicator.indicator_name || '-',
          'Unité': indicator.unit || '-',
          'Fréquence': indicator.frequence || '-',
          'Type': indicator.type || '-',
          'Formule': indicator.formule || '-',
          'Valeur Consolidée': indicator.value_consolidated || '-',
          'Valeur Cible': indicator.target_value || '-',
          'Variation (%)': indicator.variation || '-',
          'Performance (%)': indicator.performance || '-',
          'Nombre de Sites': indicator.sites_count || '-',
          'Sites': indicator.sites_list?.join(', ') || '-'
        }));
        filename = `consolidated_${selectedLevel}_${currentOrganization}_${year}`;
      }

      // Create CSV content
      const headers = Object.keys(exportData[0] || {});
      const csvContent = [
        headers.join(','),
        ...exportData.map(row => 
          headers.map(header => `"${row[header] || ''}"`).join(',')
        )
      ].join('\n');

      // Download file
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

  const handleEntityClick = (entityType: 'business_line' | 'subsidiary', entityName: string) => {
    setSelectedLevel(entityType);
    setSelectedEntity(entityName);
    setView('consolidated');
  };

  // Filter data based on current filters
  const filteredBusinessLines = businessLines.filter(bl => 
    !search || bl.name.toLowerCase().includes(search.toLowerCase())
  );

  const filteredSubsidiaries = subsidiaries.filter(sub => 
    !search || 
    sub.name.toLowerCase().includes(search.toLowerCase()) ||
    (sub.city && sub.city.toLowerCase().includes(search.toLowerCase()))
  );

  const filteredSites = sites.filter(site => 
    !search || 
    site.name.toLowerCase().includes(search.toLowerCase()) ||
    (site.city && site.city.toLowerCase().includes(search.toLowerCase()))
  );

  const filteredSitePerformances = sitePerformances.filter(site => {
    const matchesSearch = !search || 
      site.site_name.toLowerCase().includes(search.toLowerCase()) ||
      (site.city && site.city.toLowerCase().includes(search.toLowerCase())) ||
      (site.business_line_name && site.business_line_name.toLowerCase().includes(search.toLowerCase()));
    
    return matchesSearch;
  });

  const filteredConsolidatedIndicators = consolidatedIndicators.filter(indicator => {
    const matchesSearch = !search || 
      (indicator.indicator_name && indicator.indicator_name.toLowerCase().includes(search.toLowerCase())) ||
      indicator.indicator_code.toLowerCase().includes(search.toLowerCase()) ||
      (indicator.process_name && indicator.process_name.toLowerCase().includes(search.toLowerCase()));
    
    const matchesAxe = filters.axe === 'all' || indicator.axe === filters.axe;
    const matchesProcessus = filters.processus === 'all' || indicator.process_name === filters.processus;
    
    return matchesSearch && matchesAxe && matchesProcessus;
  });

  // Get unique values for filters
  const uniqueAxes = [...new Set(consolidatedIndicators.map(row => row.axe))].filter(Boolean);
  const uniqueProcessus = [...new Set(consolidatedIndicators.map(row => row.process_name))].filter(Boolean);

  const getPerformanceColor = (performance: number | null) => {
    if (performance === null || performance === undefined) return 'text-gray-500';
    if (performance >= 90) return 'text-green-600';
    if (performance >= 70) return 'text-yellow-600';
    return 'text-red-600';
  };

  const getPerformanceIcon = (performance: number | null) => {
    if (performance === null || performance === undefined) return <AlertTriangle className="h-4 w-4" />;
    if (performance >= 90) return <CheckCircle className="h-4 w-4" />;
    if (performance >= 70) return <Target className="h-4 w-4" />;
    return <AlertTriangle className="h-4 w-4" />;
  };

  const getCompletionColor = (rate: number | null) => {
    if (rate === null || rate === undefined) return 'text-gray-500';
    if (rate >= 90) return 'text-green-600';
    if (rate >= 70) return 'text-yellow-600';
    return 'text-red-600';
  };

  const renderOverview = () => (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="space-y-8"
    >
      {/* Organization Header */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-8">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-6">
            {organization?.logo_url ? (
              <img
                src={organization.logo_url}
                alt={`${organization.name} Logo`}
                className="h-16 w-16 object-contain rounded-lg border border-gray-200"
              />
            ) : (
              <div className="h-16 w-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-lg flex items-center justify-center">
                <Building2 className="h-8 w-8 text-white" />
              </div>
            )}
            <div>
              <h1 className="text-3xl font-bold text-gray-900">{organization?.name}</h1>
              <p className="text-gray-600 mt-1">{organization?.city}, {organization?.country}</p>
              <div className="flex items-center gap-2 mt-2">
                <span className="px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm font-medium">
                  {organization?.organization_type === 'simple' ? 'Organisation Simple' :
                   organization?.organization_type === 'with_subsidiaries' ? 'Avec Filiales' :
                   'Groupe'}
                </span>
                <span className="px-3 py-1 bg-green-100 text-green-800 rounded-full text-sm font-medium">
                  Pilotage Organisationnel
                </span>
              </div>
            </div>
          </div>
          
          <div className="text-right">
            <div className="text-sm text-gray-600">Dernière mise à jour</div>
            <div className="text-lg font-semibold text-gray-900">
              {new Date().toLocaleDateString('fr-FR')}
            </div>
          </div>
        </div>
      </div>

      {/* Quick Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        {[
          {
            title: 'Filières',
            value: businessLines.length,
            icon: Layers,
            color: 'bg-blue-500',
            change: 'Stable'
          },
          {
            title: 'Filiales',
            value: subsidiaries.length,
            icon: Building,
            color: 'bg-purple-500',
            change: 'Stable'
          },
          {
            title: 'Sites',
            value: sites.length,
            icon: Factory,
            color: 'bg-amber-500',
            change: 'Stable'
          },
          {
            title: 'Performance Moyenne',
            value: `${sitePerformances.length > 0 ? (sitePerformances.reduce((sum, site) => sum + (site.avg_performance || 0), 0) / sitePerformances.length).toFixed(1) : '0.0'}%`,
            icon: BarChart3,
            color: 'bg-amber-500',
            description: 'Tous sites confondus'
          }
        ].map((stat, index) => (
          <motion.div
            key={stat.title}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.1 }}
            className="bg-white rounded-xl shadow-sm border border-gray-200 p-6"
          >
            <div className="flex items-center justify-between">
              <div className={`p-3 rounded-lg ${stat.color}`}>
                <stat.icon className="h-6 w-6 text-white" />
              </div>
              <div className="text-right">
                <p className="text-sm font-medium text-gray-600">{stat.title}</p>
                <p className="text-2xl font-bold text-gray-900">{stat.value}</p>
                <p className="text-xs text-gray-500">{stat.description}</p>
              </div>
            </div>
          </motion.div>
        ))}
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-1 md:grid-cols-1 gap-6">
        <motion.div
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 0.3 }}
          onClick={() => setView('consolidated')}
          className="bg-gradient-to-r from-green-500 to-emerald-500 rounded-xl p-8 text-white cursor-pointer hover:shadow-lg transition-all"
        >
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-xl font-bold mb-2">Vue Consolidée</h3>
              <p className="text-green-100">Analyse consolidée de tous les indicateurs</p>
            </div>
            <Globe className="h-12 w-12 text-green-200" />
          </div>
        </motion.div>
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
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <div className="flex items-start gap-3">
          <HelpCircle className="h-5 w-5 text-blue-600 flex-shrink-0 mt-0.5" />
          <div>
            <h3 className="text-sm font-medium text-blue-800 mb-1">Méthodes de Consolidation</h3>
            <div className="text-sm text-blue-700 space-y-1">
              <p><strong>Somme :</strong> Addition de toutes les valeurs de tous les sites</p>
              <p><strong>Dernier mois :</strong> Valeur du mois le plus récent uniquement</p>
              <p><strong>Moyenne :</strong> Moyenne arithmétique des valeurs de tous les sites</p>
              <p><strong>Max/Min :</strong> Valeur maximale ou minimale parmi tous les sites</p>
            </div>
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
                onClick={() => setView('consolidated')}
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