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

type ViewType = 'overview' | 'business-lines' | 'subsidiaries' | 'sites' | 'consolidated';

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

interface ConsolidatedData {
  organization_name: string;
  business_line_name?: string;
  subsidiary_name?: string;
  indicator_code: string;
  year: number;
  indicator_name?: string;
  unit?: string;
  type?: string;
  axe?: string;
  formule?: string;
  frequence?: string;
  process_name?: string;
  janvier?: number;
  fevrier?: number;
  mars?: number;
  avril?: number;
  mai?: number;
  juin?: number;
  juillet?: number;
  aout?: number;
  septembre?: number;
  octobre?: number;
  novembre?: number;
  decembre?: number;
  site_names?: string[];
  site_count?: number;
  valeur_totale?: number;
  valeur_precedente?: number;
  variation?: number;
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
  const [selectedYear, setSelectedYear] = useState(new Date().getFullYear());
  const [selectedMonth, setSelectedMonth] = useState(new Date().getMonth() + 1);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterAxe, setFilterAxe] = useState('all');
  const [filterProcessus, setFilterProcessus] = useState('all');
  
  // Data states
  const [organization, setOrganization] = useState<Organization | null>(null);
  const [businessLines, setBusinessLines] = useState<BusinessLine[]>([]);
  const [subsidiaries, setSubsidiaries] = useState<Subsidiary[]>([]);
  const [sites, setSites] = useState<Site[]>([]);
  const [consolidatedData, setConsolidatedData] = useState<ConsolidatedData[]>([]);
  
  // Filters
  const [filters, setFilters] = useState({
    axe: 'all',
    processus: 'all',
    level: 'all'
  });
  
  // UI states
  const [expandedRows, setExpandedRows] = useState<string[]>([]);
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
      fetchConsolidatedData();
    }
  }, [view, organization, year, selectedLevel, selectedEntity]);

  useEffect(() => {
    if (currentOrganization) {
      fetchSites();
      fetchConsolidatedData();
    }
  }, [currentOrganization, selectedYear, selectedMonth]);

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
      const { data: businessLinesData, error: blError } = await supabase
        .from('business_lines')
        .select('*')
        .eq('organization_name', currentOrganization)
        .order('name');
      
      if (blError) throw blError;
      setBusinessLines(businessLinesData || []);

      // Fetch subsidiaries
      const { data: subsidiariesData, error: subError } = await supabase
        .from('subsidiaries')
        .select('*')
        .eq('organization_name', currentOrganization)
        .order('name');
      
      if (subError) throw subError;
      setSubsidiaries(subsidiariesData || []);

      // Fetch all sites
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

  const fetchSites = async () => {
    if (!currentOrganization) return;

    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('sites')
        .select('*')
        .eq('organization_name', currentOrganization)
        .order('name');
      
      if (error) throw error;
      setSites(data || []);
    } catch (error) {
      console.error('Error fetching sites:', error);
      toast.error('Erreur lors du chargement des sites');
    } finally {
      setLoading(false);
    }
  };

  const fetchConsolidatedData = async () => {
    if (!currentOrganization) return;

    try {
      setLoading(true);
      
      // 1. Récupérer tous les sites de l'organisation
      const { data: sitesData, error: sitesError } = await supabase
        .from('sites')
        .select('name')
        .eq('organization_name', currentOrganization);
      
      if (sitesError) throw sitesError;
      const siteNames = sitesData?.map(s => s.name) || [];
      
      if (siteNames.length === 0) {
        setConsolidatedData([]);
        return;
      }

      // 2. Récupérer toutes les valeurs d'indicateurs pour tous les sites
      const { data: indicatorValues, error: valuesError } = await supabase
        .from('indicator_values')
        .select(`
          *,
          indicators (name, unit, axe, type, formule, frequence),
          processes (name, description)
        `)
        .eq('organization_name', currentOrganization)
        .eq('year', selectedYear)
        .eq('month', selectedMonth)
        .in('site_name', siteNames);
      
      if (valuesError) throw valuesError;
      
      // 3. Grouper par indicateur et processus pour consolidation
      const grouped = (indicatorValues || []).reduce((acc: any, value: any) => {
        const key = `${value.process_code}-${value.indicator_code}`;
        if (!acc[key]) {
          acc[key] = {
            process_code: value.process_code,
            indicator_code: value.indicator_code,
            process_name: value.processes?.name || value.process_code,
            indicator_name: value.indicators?.name || value.indicator_code,
            unit: value.indicators?.unit || '',
            axe: value.indicators?.axe || 'Non défini',
            type: value.indicators?.type || 'primaire',
            formule: value.indicators?.formule || 'somme',
            frequence: value.indicators?.frequence || 'mensuelle',
            values: [],
            sites: []
          };
        }
        acc[key].values.push(value.value);
        acc[key].sites.push(value.site_name);
        return acc;
      }, {});
      
      // 4. Calculer les valeurs consolidées selon la formule
      const consolidated = Object.values(grouped).map((group: any) => {
        let consolidatedValue = 0;
        const validValues = group.values.filter((v: number) => v !== null && v !== undefined);
        
        if (validValues.length > 0) {
          switch (group.formule) {
            case 'somme':
              consolidatedValue = validValues.reduce((sum: number, val: number) => sum + val, 0);
              break;
            case 'moyenne':
              consolidatedValue = validValues.reduce((sum: number, val: number) => sum + val, 0) / validValues.length;
              break;
            case 'max':
              consolidatedValue = Math.max(...validValues);
              break;
            case 'min':
              consolidatedValue = Math.min(...validValues);
              break;
            case 'dernier_mois':
              consolidatedValue = validValues[validValues.length - 1];
              break;
            default:
              consolidatedValue = validValues.reduce((sum: number, val: number) => sum + val, 0);
          }
        }
        
        return {
          organization_name: currentOrganization,
          process_code: group.process_code,
          indicator_code: group.indicator_code,
          year: selectedYear,
          month: selectedMonth,
          axe: group.axe,
          enjeux: 'Données consolidées',
          normes: 'Données consolidées',
          criteres: 'Données consolidées',
          processus: group.process_name,
          indicateur: group.indicator_name,
          unite: group.unit,
          frequence: group.frequence,
          type: group.type,
          formule: group.formule,
          valeur: consolidatedValue,
          valeur_cible: 0,
          variation: 0,
          performance: 0,
          sites_count: group.sites.length,
          sites_names: [...new Set(group.sites)].join(', ')
        };
      });
      
      setConsolidatedData(consolidated);
    } catch (error) {
      console.error('Error fetching consolidated data:', error);
      toast.error('Erreur lors du chargement des données consolidées');
    } finally {
      setLoading(false);
    }
  };

  const handleRefresh = async () => {
    setRefreshing(true);
    await fetchSites();
    await fetchConsolidatedData();
    setRefreshing(false);
    toast.success('Données actualisées');
  };

  const handleExport = async (format: 'excel' | 'pdf') => {
    try {
      let exportData: any[] = [];
      let filename = '';

      if (view === 'consolidated') {
        exportData = filteredConsolidatedData.map(indicator => ({
          'Niveau': selectedLevel === 'organization' ? 'Organisation' : 
                   selectedLevel === 'business_line' ? 'Filière' : 'Filiale',
          'Entité': selectedEntity || currentOrganization,
          'Code Indicateur': indicator.indicator_code,
          'Indicateur': indicator.indicator_name || '-',
          'Unité': indicator.unit || '-',
          'Type': indicator.type || '-',
          'Axe': indicator.axe || '-',
          'Processus': indicator.process_name || '-',
          'Janvier': indicator.janvier || 0,
          'Février': indicator.fevrier || 0,
          'Mars': indicator.mars || 0,
          'Avril': indicator.avril || 0,
          'Mai': indicator.mai || 0,
          'Juin': indicator.juin || 0,
          'Juillet': indicator.juillet || 0,
          'Août': indicator.aout || 0,
          'Septembre': indicator.septembre || 0,
          'Octobre': indicator.octobre || 0,
          'Novembre': indicator.novembre || 0,
          'Décembre': indicator.decembre || 0,
          'Valeur Totale': indicator.valeur_totale || '-',
          'Variation (%)': indicator.variation || '-',
          'Sites': indicator.site_names?.join(', ') || '-'
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

  // Filter and sort consolidated data
  const filteredConsolidatedData = React.useMemo(() => {
    let filtered = consolidatedData.filter(row => {
      const matchesAxe = filterAxe === 'all' || row.axe === filterAxe;
      const matchesProcessus = filterProcessus === 'all' || row.processus === filterProcessus;
      const matchesSearch = !searchTerm || 
        row.indicateur.toLowerCase().includes(searchTerm.toLowerCase()) ||
        row.process_code.toLowerCase().includes(searchTerm.toLowerCase()) ||
        row.processus.toLowerCase().includes(searchTerm.toLowerCase());
      
      return matchesAxe && matchesProcessus && matchesSearch;
    });

    if (sortConfig.key) {
      filtered.sort((a, b) => {
        const aVal = a[sortConfig.key!];
        const bVal = b[sortConfig.key!];
        
        if (aVal === null || aVal === undefined) return 1;
        if (bVal === null || bVal === undefined) return -1;
        
        if (typeof aVal === 'number' && typeof bVal === 'number') {
          return sortConfig.direction === 'asc' ? aVal - bVal : bVal - aVal;
        }
        
        const aStr = String(aVal).toLowerCase();
        const bStr = String(bVal).toLowerCase();
        
        if (sortConfig.direction === 'asc') {
          return aStr < bStr ? -1 : aStr > bStr ? 1 : 0;
        } else {
          return aStr > bStr ? -1 : aStr < bStr ? 1 : 0;
        }
      });
    }

    return filtered;
  }, [consolidatedData, filterAxe, filterProcessus, searchTerm, sortConfig]);

  const getMonthName = (m: number) =>
    ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'][m - 1];

  // Get unique values for filters
  const uniqueAxes = [...new Set(consolidatedData.map(row => row.axe))].filter(Boolean);
  const uniqueProcessus = [...new Set(consolidatedData.map(row => row.processus))].filter(Boolean);

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
            description: 'Lignes d\'affaires'
          },
          {
            title: 'Filiales',
            value: subsidiaries.length,
            icon: Building,
            color: 'bg-purple-500',
            description: 'Entités juridiques'
          },
          {
            title: 'Sites',
            value: sites.length,
            icon: Factory,
            color: 'bg-green-500',
            description: 'Localisations physiques'
          },
          {
            title: 'Indicateurs',
            value: consolidatedData.length,
            icon: BarChart3,
            color: 'bg-amber-500',
            description: 'Indicateurs consolidés'
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
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {organization?.organization_type === 'group' && (
          <motion.div
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.3 }}
            onClick={() => setView('business-lines')}
            className="bg-gradient-to-r from-blue-500 to-cyan-500 rounded-xl p-8 text-white cursor-pointer hover:shadow-lg transition-all"
          >
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-xl font-bold mb-2">Filières d'Affaires</h3>
                <p className="text-blue-100">Gérez vos lignes d'affaires</p>
              </div>
              <Layers className="h-12 w-12 text-blue-200" />
            </div>
          </motion.div>
        )}

        {(organization?.organization_type === 'with_subsidiaries' || organization?.organization_type === 'group') && (
          <motion.div
            initial={{ opacity: 0, x: 0 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.4 }}
            onClick={() => setView('subsidiaries')}
            className="bg-gradient-to-r from-purple-500 to-pink-500 rounded-xl p-8 text-white cursor-pointer hover:shadow-lg transition-all"
          >
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-xl font-bold mb-2">Filiales</h3>
                <p className="text-purple-100">Visualisez vos entités juridiques</p>
              </div>
              <Building className="h-12 w-12 text-purple-200" />
            </div>
          </motion.div>
        )}

        <motion.div
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 0.5 }}
          onClick={() => setView('sites')}
          className="bg-gradient-to-r from-green-500 to-emerald-500 rounded-xl p-8 text-white cursor-pointer hover:shadow-lg transition-all"
        >
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-xl font-bold mb-2">Sites</h3>
              <p className="text-green-100">Accédez aux tableaux de bord des sites</p>
            </div>
            <Factory className="h-12 w-12 text-green-200" />
          </div>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 0.6 }}
          onClick={() => {
            setSelectedLevel('organization');
            setSelectedEntity(null);
            setView('consolidated');
          }}
          className="bg-gradient-to-r from-indigo-500 to-blue-500 rounded-xl p-8 text-white cursor-pointer hover:shadow-lg transition-all"
        >
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-xl font-bold mb-2">Vue Consolidée</h3>
              <p className="text-indigo-100">Analyse consolidée globale</p>
            </div>
            <Globe className="h-12 w-12 text-indigo-200" />
          </div>
        </motion.div>
      </div>
    </motion.div>
  );

  const renderBusinessLinesView = () => (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="space-y-6"
    >
      {/* Header */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-3">
            <div className="p-3 rounded-lg bg-blue-500">
              <Layers className="h-6 w-6 text-white" />
            </div>
            <div>
              <h2 className="text-2xl font-semibold text-gray-900">Filières d'Affaires</h2>
              <p className="text-gray-600">Lignes d'affaires de votre organisation</p>
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

        {/* Search */}
        <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
          <input
            type="text"
            placeholder="Rechercher une filière..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="pl-10 pr-4 py-2 w-full border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          />
        </div>
      </div>

      {/* Business Lines Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredBusinessLines.map((businessLine, index) => (
          <motion.div
            key={businessLine.name}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.1 }}
            className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 cursor-pointer hover:shadow-md transition-all"
          >
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-3">
                <div className="p-2 rounded-lg bg-blue-100">
                  <Layers className="h-5 w-5 text-blue-600" />
                </div>
                <div>
                  <h3 className="font-semibold text-gray-900">{businessLine.name}</h3>
                  <p className="text-sm text-gray-600">{businessLine.description || 'Filière d\'affaires'}</p>
                </div>
              </div>
            </div>

            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <span className="text-sm text-gray-600">Filiales</span>
                <span className="font-semibold text-gray-900">
                  {subsidiaries.filter(sub => sub.business_line_name === businessLine.name).length}
                </span>
              </div>
              
              <div className="flex items-center justify-between">
                <span className="text-sm text-gray-600">Sites</span>
                <span className="font-semibold text-gray-900">
                  {sites.filter(site => site.business_line_name === businessLine.name).length}
                </span>
              </div>
            </div>

            <div className="mt-4 flex gap-2">
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  handleEntityClick('business_line', businessLine.name);
                }}
                className="flex-1 px-3 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors text-sm"
              >
                Vue Consolidée
              </button>
            </div>
          </motion.div>
        ))}
      </div>

      {filteredBusinessLines.length === 0 && (
        <div className="text-center py-12">
          <Layers className="h-16 w-16 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">Aucune filière trouvée</h3>
          <p className="text-gray-500">
            {search ? 
              "Aucune filière ne correspond à votre recherche." :
              "Cette organisation n'a pas de filières configurées."
            }
          </p>
        </div>
      )}
    </motion.div>
  );

  const renderSubsidiariesView = () => (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="space-y-6"
    >
      {/* Header */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-3">
            <div className="p-3 rounded-lg bg-purple-500">
              <Building className="h-6 w-6 text-white" />
            </div>
            <div>
              <h2 className="text-2xl font-semibold text-gray-900">Filiales</h2>
              <p className="text-gray-600">Entités juridiques de votre organisation</p>
            </div>
          </div>
          
          <div className="flex items-center gap-3">
            <button
              onClick={handleRefresh}
              disabled={refreshing}
              className="flex items-center px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 disabled:opacity-50 transition-colors"
            >
              <RefreshCw className={`h-4 w-4 mr-2 ${refreshing ? 'animate-spin' : ''}`} />
              Actualiser
            </button>
          </div>
        </div>

        {/* Search */}
        <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
          <input
            type="text"
            placeholder="Rechercher une filiale..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="pl-10 pr-4 py-2 w-full border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
          />
        </div>
      </div>

      {/* Subsidiaries Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredSubsidiaries.map((subsidiary, index) => (
          <motion.div
            key={subsidiary.name}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.1 }}
            className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 cursor-pointer hover:shadow-md transition-all"
          >
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-3">
                <div className="p-2 rounded-lg bg-purple-100">
                  <Building className="h-5 w-5 text-purple-600" />
                </div>
                <div>
                  <h3 className="font-semibold text-gray-900">{subsidiary.name}</h3>
                  <p className="text-sm text-gray-600">{subsidiary.city}, {subsidiary.country}</p>
                </div>
              </div>
            </div>

            <div className="space-y-3">
              {subsidiary.business_line_name && (
                <div className="flex items-center justify-between">
                  <span className="text-sm text-gray-600">Filière</span>
                  <span className="font-semibold text-gray-900">{subsidiary.business_line_name}</span>
                </div>
              )}
              
              <div className="flex items-center justify-between">
                <span className="text-sm text-gray-600">Sites</span>
                <span className="font-semibold text-gray-900">
                  {sites.filter(site => site.subsidiary_name === subsidiary.name).length}
                </span>
              </div>
            </div>

            <div className="mt-4 flex gap-2">
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  handleEntityClick('subsidiary', subsidiary.name);
                }}
                className="flex-1 px-3 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors text-sm"
              >
                Vue Consolidée
              </button>
            </div>
          </motion.div>
        ))}
      </div>

      {filteredSubsidiaries.length === 0 && (
        <div className="text-center py-12">
          <Building className="h-16 w-16 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">Aucune filiale trouvée</h3>
          <p className="text-gray-500">
            {search ? 
              "Aucune filiale ne correspond à votre recherche." :
              "Cette organisation n'a pas de filiales configurées."
            }
          </p>
        </div>
      )}
    </motion.div>
  );

  const renderSitesView = () => (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="space-y-6"
    >
      {/* Header */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-3">
            <div className="p-3 rounded-lg bg-green-500">
              <Factory className="h-6 w-6 text-white" />
            </div>
            <div>
              <h2 className="text-2xl font-semibold text-gray-900">Sites</h2>
              <p className="text-gray-600">Localisations physiques de votre organisation</p>
            </div>
          </div>
          
          <div className="flex items-center gap-3">
            <button
              onClick={handleRefresh}
              disabled={refreshing}
              className="flex items-center px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50 transition-colors"
            >
              <RefreshCw className={`h-4 w-4 mr-2 ${refreshing ? 'animate-spin' : ''}`} />
              Actualiser
            </button>
          </div>
        </div>

        {/* Search */}
        <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
          <input
            type="text"
            placeholder="Rechercher un site..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="pl-10 pr-4 py-2 w-full border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
          />
        </div>
      </div>

      {/* Filters for consolidated view */}
      <div className="grid grid-cols-1 md:grid-cols-5 gap-4 mb-6">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            <Calendar className="h-4 w-4 inline mr-1" />
            Année
          </label>
          <select
            value={selectedYear}
            onChange={(e) => setSelectedYear(parseInt(e.target.value))}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          >
            {Array.from({ length: 5 }, (_, i) => new Date().getFullYear() - 2 + i).map(year => (
              <option key={year} value={year}>{year}</option>
            ))}
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            <Calendar className="h-4 w-4 inline mr-1" />
            Mois
          </label>
          <select
            value={selectedMonth}
            onChange={(e) => setSelectedMonth(parseInt(e.target.value))}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          >
            {Array.from({ length: 12 }, (_, i) => i + 1).map(month => (
              <option key={month} value={month}>{getMonthName(month)}</option>
            ))}
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            <Filter className="h-4 w-4 inline mr-1" />
            Axe ESG
          </label>
          <select
            value={filterAxe}
            onChange={(e) => setFilterAxe(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          >
            <option value="all">Tous les axes</option>
            {uniqueAxes.map(axe => (
              <option key={axe} value={axe}>{axe}</option>
            ))}
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            <Filter className="h-4 w-4 inline mr-1" />
            Processus
          </label>
          <select
            value={filterProcessus}
            onChange={(e) => setFilterProcessus(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          >
            <option value="all">Tous les processus</option>
            {uniqueProcessus.map(processus => (
              <option key={processus} value={processus}>{processus}</option>
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
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          />
        </div>
      </div>

      {/* Consolidated Dashboard Table */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2 }}
        className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden"
      >
        <div className="px-6 py-4 border-b border-gray-200 bg-gray-50">
          <div className="flex items-center justify-between">
            <h3 className="text-lg font-semibold text-gray-900">
              Tableau de Bord Consolidé - {getMonthName(selectedMonth)} {selectedYear}
            </h3>
            <div className="flex items-center gap-2 text-sm text-gray-600">
              <BarChart3 className="h-4 w-4" />
              {filteredConsolidatedData.length} indicateurs consolidés
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
                  { key: 'processus', label: 'Processus' },
                  { key: 'indicateur', label: 'Indicateur' },
                  { key: 'unite', label: 'Unité' },
                  { key: 'frequence', label: 'Fréquence' },
                  { key: 'type', label: 'Type' },
                  { key: 'formule', label: 'Formule' },
                  { key: 'valeur', label: 'Valeur Consolidée' },
                  { key: 'sites_count', label: 'Nb Sites' },
                  { key: 'sites_names', label: 'Sites Concernés' }
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
              </tr>
            </thead>
            
            <tbody className="bg-white divide-y divide-gray-200">
              <AnimatePresence>
                {filteredConsolidatedData.map((row, index) => (
                  <motion.tr
                    key={`${row.process_code}-${row.indicator_code}`}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -20 }}
                    transition={{ delay: index * 0.02 }}
                    className="hover:bg-gray-50 transition-colors"
                  >
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                        row.axe === 'Environnement' ? 'bg-green-100 text-green-800' :
                        row.axe === 'Social' ? 'bg-blue-100 text-blue-800' :
                        row.axe === 'Gouvernance' ? 'bg-purple-100 text-purple-800' :
                        'bg-gray-100 text-gray-800'
                      }`}>
                        {row.axe}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900 max-w-xs truncate" title={row.enjeux}>
                      {row.enjeux}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900 max-w-xs truncate" title={row.normes}>
                      {row.normes}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900 max-w-xs truncate" title={row.criteres}>
                      {row.criteres}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-mono text-gray-900">
                      {row.process_code}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900 max-w-xs" title={row.processus}>
                      <div className="font-medium truncate">{row.processus}</div>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900 max-w-xs" title={row.indicateur}>
                      <div className="font-medium truncate">{row.indicateur}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{row.unite || '-'}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{row.frequence || '-'}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{row.type || '-'}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                        row.formule === 'somme' ? 'bg-blue-100 text-blue-800' :
                        row.formule === 'moyenne' ? 'bg-green-100 text-green-800' :
                        row.formule === 'max' ? 'bg-red-100 text-red-800' :
                        row.formule === 'min' ? 'bg-yellow-100 text-yellow-800' :
                        'bg-gray-100 text-gray-800'
                      }`}>
                        {row.formule}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-center">
                      <span className="font-bold text-blue-600 text-lg">
                        {row.valeur ? Number(row.valeur).toLocaleString() : '-'}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-center">
                      <span className="px-2 py-1 bg-blue-100 text-blue-800 rounded-full font-medium">
                        {row.sites_count}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900 max-w-xs">
                      <div className="truncate" title={row.sites_names}>
                        {row.sites_names}
                      </div>
                    </td>
                  </motion.tr>
                ))}
              </AnimatePresence>
            </tbody>
          </table>
        </div>

        {filteredConsolidatedData.length === 0 && (
          <div className="text-center py-12">
            <FileText className="h-12 w-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">
              Aucune donnée consolidée
            </h3>
            <p className="text-gray-500">
              {searchTerm ? 
                "Aucun indicateur ne correspond à votre recherche." :
                `Aucune donnée disponible pour ${getMonthName(selectedMonth)} ${selectedYear}.`
              }
            </p>
          </div>
        )}
      </motion.div>

      {/* Consolidation Summary */}
      {filteredConsolidatedData.length > 0 && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="bg-white rounded-xl shadow-sm border border-gray-200 p-6"
        >
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Résumé de Consolidation</h3>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
            {['Environnement', 'Social', 'Gouvernance'].map(axe => {
              const axeData = filteredConsolidatedData.filter(row => row.axe === axe);
              const totalValue = axeData.reduce((sum, row) => sum + (row.valeur || 0), 0);
              
              return (
                <div key={axe} className="text-center">
                  <div className={`inline-flex items-center justify-center w-16 h-16 rounded-full mb-3 ${
                    axe === 'Environnement' ? 'bg-green-100' :
                    axe === 'Social' ? 'bg-blue-100' :
                    'bg-purple-100'
                  }`}>
                    <span className={`text-2xl ${
                      axe === 'Environnement' ? 'text-green-600' :
                      axe === 'Social' ? 'text-blue-600' :
                      'text-purple-600'
                    }`}>
                      {axe === 'Environnement' ? '🌱' : axe === 'Social' ? '👥' : '⚖️'}
                    </span>
                  </div>
                  <h4 className="font-semibold text-gray-900">{axe}</h4>
                  <p className="text-2xl font-bold text-gray-900 mt-1">
                    {totalValue.toLocaleString()}
                  </p>
                  <p className="text-sm text-gray-600">{axeData.length} indicateurs</p>
                </div>
              );
            })}
            
            <div className="text-center">
              <div className="inline-flex items-center justify-center w-16 h-16 rounded-full mb-3 bg-gray-100">
                <Building2 className="h-8 w-8 text-gray-600" />
              </div>
              <h4 className="font-semibold text-gray-900">Sites Actifs</h4>
              <p className="text-2xl font-bold text-gray-900 mt-1">{sites.length}</p>
              <p className="text-sm text-gray-600">Localisations</p>
            </div>
          </div>
        </motion.div>
      )}

      {/* Sites Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredSites.map((site, index) => (
          <motion.div
            key={site.name}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.1 }}
            onClick={() => handleSiteClick(site.name)}
            className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 cursor-pointer hover:shadow-md transition-all"
          >
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-3">
                <div className="p-2 rounded-lg bg-green-100">
                  <Factory className="h-5 w-5 text-green-600" />
                </div>
                <div>
                  <h3 className="font-semibold text-gray-900">{site.name}</h3>
                  <p className="text-sm text-gray-600">{site.city}, {site.country}</p>
                </div>
              </div>
              <ChevronRight className="h-5 w-5 text-gray-400" />
            </div>

            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <span className="text-sm text-gray-600">Filière</span>
                <span className="font-medium text-gray-900">{site.business_line_name || '-'}</span>
              </div>
              
              <div className="flex items-center justify-between">
                <span className="text-sm text-gray-600">Filiale</span>
                <span className="font-medium text-gray-900">{site.subsidiary_name || '-'}</span>
              </div>
              
              <div className="flex items-center justify-between">
                <span className="text-sm text-gray-600">Adresse</span>
                <span className="font-medium text-gray-900 text-right">{site.address || '-'}</span>
              </div>
            </div>
          </motion.div>
        ))}
      </div>

      {filteredSites.length === 0 && (
        <div className="text-center py-12">
          <Factory className="h-16 w-16 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">Aucun site trouvé</h3>
          <p className="text-gray-500">
            {search ? 
              "Aucun site ne correspond à votre recherche." :
              "Cette organisation n'a pas de sites configurés."
            }
          </p>
        </div>
      )}
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
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
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
                fetchConsolidatedData();
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
                onChange={(e) => {
                  setSelectedEntity(e.target.value || null);
                  fetchConsolidatedData();
                }}
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
              {filteredConsolidatedData.length} indicateurs
            </div>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Code
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Indicateur
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Unité
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Axe
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Processus
                </th>
                
                {/* Monthly columns */}
                {monthLabels.map((month) => (
                  <th
                    key={month}
                    className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider"
                  >
                    {month}
                  </th>
                ))}
                
                <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Total
                </th>
                <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Variation
                </th>
                <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Sites
                </th>
              </tr>
            </thead>
            
            <tbody className="bg-white divide-y divide-gray-200">
              <AnimatePresence>
                {filteredConsolidatedData.map((indicator, index) => (
                  <motion.tr
                    key={indicator.indicator_code}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -20 }}
                    transition={{ delay: index * 0.02 }}
                    className="hover:bg-gray-50 transition-colors"
                  >
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-mono text-gray-900">
                      {indicator.indicator_code}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900 max-w-xs" title={indicator.indicator_name}>
                      <div className="font-medium truncate">{indicator.indicator_name || indicator.indicator_code}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{indicator.unit || '-'}</td>
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
                    <td className="px-6 py-4 text-sm text-gray-900 max-w-xs truncate" title={indicator.process_name}>
                      {indicator.process_name || '-'}
                    </td>
                    
                    {/* Monthly values */}
                    {months.map((month) => (
                      <td key={month} className="px-4 py-4 whitespace-nowrap text-sm text-center text-gray-900">
                        <span className={`font-medium ${
                          indicator[month as keyof ConsolidatedData] ? 'text-gray-900' : 'text-gray-400'
                        }`}>
                          {indicator[month as keyof ConsolidatedData] ? 
                            Number(indicator[month as keyof ConsolidatedData]).toLocaleString() : 
                            '-'
                          }
                        </span>
                      </td>
                    ))}
                    
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-center text-gray-900">
                      {indicator.valeur_totale ? indicator.valeur_totale.toLocaleString() : '-'}
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
                    <td className="px-6 py-4 text-sm text-gray-900">
                      <div className="flex flex-wrap gap-1">
                        {indicator.site_names?.slice(0, 2).map((site, i) => (
                          <span key={i} className="px-2 py-1 bg-blue-100 text-blue-800 rounded-full text-xs">
                            {site}
                          </span>
                        ))}
                        {indicator.site_names && indicator.site_names.length > 2 && (
                          <span className="px-2 py-1 bg-gray-100 text-gray-800 rounded-full text-xs">
                            +{indicator.site_names.length - 2}
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

        {filteredConsolidatedData.length === 0 && (
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
              {organization?.organization_type === 'group' && (
                <button
                  onClick={() => setView('business-lines')}
                  className={`flex items-center space-x-2 px-4 py-2 rounded-md transition-colors ${
                    view === 'business-lines' 
                      ? 'bg-white text-gray-900 shadow-sm' 
                      : 'text-gray-600 hover:bg-gray-200'
                  }`}
                >
                  <Layers className="w-4 h-4" />
                  <span>Filières</span>
                </button>
              )}
              {(organization?.organization_type === 'with_subsidiaries' || organization?.organization_type === 'group') && (
                <button
                  onClick={() => setView('subsidiaries')}
                  className={`flex items-center space-x-2 px-4 py-2 rounded-md transition-colors ${
                    view === 'subsidiaries' 
                      ? 'bg-white text-gray-900 shadow-sm' 
                      : 'text-gray-600 hover:bg-gray-200'
                  }`}
                >
                  <Building className="w-4 h-4" />
                  <span>Filiales</span>
                </button>
              )}
              <button
                onClick={() => setView('sites')}
                className={`flex items-center space-x-2 px-4 py-2 rounded-md transition-colors ${
                  view === 'sites' 
                    ? 'bg-white text-gray-900 shadow-sm' 
                    : 'text-gray-600 hover:bg-gray-200'
                }`}
              >
                <Factory className="w-4 h-4" />
                <span>Sites</span>
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
            {view === 'business-lines' && renderBusinessLinesView()}
            {view === 'subsidiaries' && renderSubsidiariesView()}
            {view === 'sites' && renderSitesView()}
            {view === 'consolidated' && renderConsolidatedView()}
          </motion.div>
        </AnimatePresence>
      </div>
    </div>
  );
};