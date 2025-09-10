import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../../store/authStore';
import { supabase } from '../../lib/supabase';
import {
  Calendar,
  CheckCircle2,
  Clock,
  Filter,
  BarChart3,
  ChevronDown,
  ChevronUp,
  Search,
  Send,
  Edit3,
  Save,
  XCircle,
  Loader2,
  Download,
  ArrowLeft,
  Building2,
  Factory,
  Zap
} from 'lucide-react';
import toast from 'react-hot-toast';

interface IndicatorValue {
  id: string;
  organization_name: string;
  filiere_name?: string;
  filiale_name?: string;
  site_name?: string;
  year: number;
  month: number;
  processus_code: string;
  indicator_code: string;
  value: number | null;
  unit: string;
  status: 'draft' | 'submitted' | 'validated' | 'rejected';
  comment?: string;
  submitted_by?: string;
  submitted_at?: string;
  validated_by?: string;
  validated_at?: string;
  created_at: string;
  updated_at: string;
}

interface Processus {
  code: string;
  name: string;
  description?: string;
  indicateurs: string[];
}

interface Indicator {
  code: string;
  name: string;
  unit?: string;
  frequence?: string;
  enjeux?: string;
  normes?: string;
  critere?: string;
}

interface OrganizationIndicator {
  indicator_code: string;
  indicator_name: string;
  unit?: string;
  processus_code: string;
  processus_name: string;
}

interface Site {
  name: string;
  organization_name: string;
  filiere_name?: string;
  filiale_name?: string;
  city: string;
}

interface CollectionPeriod {
  id: string;
  year: number;
  period_type: string;
  period_number: number;
  start_date: string;
  end_date: string;
  status: string;
}

export const ContributorPilotageReplicated: React.FC = () => {
  const navigate = useNavigate();
  const { profile, impersonatedOrganization } = useAuthStore();

  /* ----------  ÉTAT  ---------- */
  const [values, setValues] = useState<IndicatorValue[]>([]);
  const [processus, setProcessus] = useState<Processus[]>([]);
  const [indicators, setIndicators] = useState<Indicator[]>([]);
  const [organizationIndicators, setOrganizationIndicators] = useState<OrganizationIndicator[]>([]);
  const [sites, setSites] = useState<Site[]>([]);
  const [collectionPeriods, setCollectionPeriods] = useState<CollectionPeriod[]>([]);
  
  const [selectedYear, setSelectedYear] = useState(new Date().getFullYear());
  const [selectedMonth, setSelectedMonth] = useState(new Date().getMonth() + 1);
  const [selectedSite, setSelectedSite] = useState<string>('');
  const [selectedPeriod, setSelectedPeriod] = useState<string>('');
  
  const [loading, setLoading] = useState(true);
  const [editingValue, setEditingValue] = useState<string | null>(null);
  const [tempValue, setTempValue] = useState('');
  const [filterStatus, setFilterStatus] = useState<string>('all');
  const [filterProcessus, setFilterProcessus] = useState<string>('all');
  const [searchTerm, setSearchTerm] = useState('');
  const [expandedProcessus, setExpandedProcessus] = useState<string | null>(null);
  const [selectedStatCard, setSelectedStatCard] = useState<string | null>(null);

  const currentOrganization = impersonatedOrganization || profile?.organization_name;

  // Fonction de validation de hiérarchie
  const validateHierarchy = (userProfile: any) => {
    const hierarchy = {
      organization_name: userProfile?.organization_name || null,
      filiere_name: userProfile?.filiere_name || null,
      filiale_name: userProfile?.filiale_name || null,
      site_name: userProfile?.site_name || null
    };

    // Validation selon les règles de hiérarchie
    if (hierarchy.site_name && (!hierarchy.filiale_name || !hierarchy.filiere_name)) {
      // Si site défini, filiale et filière doivent l'être aussi
      return {
        organization_name: hierarchy.organization_name,
        filiere_name: hierarchy.filiere_name || 'Filière Production',
        filiale_name: hierarchy.filiale_name || 'Filiale Nord',
        site_name: hierarchy.site_name
      };
    }
    
    if (hierarchy.filiale_name && !hierarchy.filiere_name) {
      // Si filiale définie, filière doit l'être aussi
      return {
        organization_name: hierarchy.organization_name,
        filiere_name: hierarchy.filiere_name || 'Filière Production',
        filiale_name: hierarchy.filiale_name,
        site_name: hierarchy.site_name
      };
    }

    return hierarchy;
  };

  const rawUserHierarchy = {
    organization_name: profile?.organization_name,
    filiere_name: profile?.filiere_name,
    filiale_name: profile?.filiale_name,
    site_name: profile?.site_name
  };

  const userHierarchy = validateHierarchy(rawUserHierarchy);

  /* ----------  HOOKS  ---------- */
  useEffect(() => {
    if (!profile || !['contributeur', 'contributor'].includes(profile.role)) {
      navigate('/login');
      return;
    }
    fetchInitialData();
  }, [profile, navigate]);

  useEffect(() => {
    if (currentOrganization && selectedYear && selectedMonth) {
      fetchValues(selectedYear, selectedMonth);
    }
  }, [selectedYear, selectedMonth, currentOrganization, organizationIndicators, selectedSite]);

  /* ----------  DATA DE BASE  ---------- */
  const fetchInitialData = async () => {
    setLoading(true);
    await Promise.all([
      fetchSites(),
      fetchProcessus(),
      fetchOrganizationIndicators(),
      fetchCollectionPeriods()
    ]);
    setLoading(false);
  };

  const getMonthName = (m: number) =>
    ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'][m - 1];

  const fetchSites = async () => {
    if (!profile?.email) return;

    try {
      // Récupérer les sites assignés à l'utilisateur
      const { data: userSites, error } = await supabase
        .from('sites')
        .select('name, organization_name, filiere_name, filiale_name, city')
        .eq('organization_name', currentOrganization);

      if (error) throw error;
      setSites(userSites || []);
      
      // Sélectionner automatiquement le premier site si aucun n'est sélectionné
      if (userSites && userSites.length > 0 && !selectedSite) {
        setSelectedSite(userSites[0].name);
      }
    } catch (error) {
      console.error('Error fetching sites:', error);
      toast.error('Erreur lors du chargement des sites');
    }
  };

  const fetchProcessus = async () => {
    if (!profile?.email) return;

    try {
      // Récupérer les processus assignés à l'utilisateur
      const { data: userProcessus, error } = await supabase
        .from('user_processus')
        .select(`
          processus_code,
          processus:processus_code (
            code,
            name,
            description,
            indicateurs
          )
        `)
        .eq('email', profile.email);

      if (error) throw error;

      const processusData = userProcessus?.map(up => ({
        code: up.processus.code,
        name: up.processus.name,
        description: up.processus.description,
        indicateurs: up.processus.indicateurs || []
      })) || [];

      setProcessus(processusData);
    } catch (error) {
      console.error('Error fetching processus:', error);
      toast.error('Erreur lors du chargement des processus');
    }
  };

  const fetchOrganizationIndicators = async () => {
    if (!profile?.email || !currentOrganization) return;

    try {
      // Récupérer les processus de l'utilisateur
      const { data: userProcessus, error: processusError } = await supabase
        .from('user_processus')
        .select('processus_code')
        .eq('email', profile.email);

      if (processusError) throw processusError;
      if (!userProcessus?.length) return;

      const processusDetails = await Promise.all(
        userProcessus.map(async (up) => {
          const { data: processusData, error } = await supabase
            .from('processus')
            .select('code, name, indicateurs')
            .eq('code', up.processus_code)
            .single();

          if (error) throw error;
          return processusData;
        })
      );

      // Collecter tous les codes d'indicateurs
      const indicatorCodes = new Set<string>();
      for (const p of processusDetails) {
        if (p.indicateurs) {
          for (const ic of p.indicateurs) {
            indicatorCodes.add(ic);
          }
        }
      }

      // Récupérer les détails des indicateurs
      const { data: indicatorDetails, error: indicatorError } = await supabase
        .from('indicators')
        .select('*')
        .in('code', Array.from(indicatorCodes));

      if (indicatorError) throw indicatorError;

      // Créer les indicateurs manquants
      for (const ic of indicatorCodes) {
        const existingIndicator = indicatorDetails?.find(i => i.code === ic);
        if (!existingIndicator) {
          try {
            const placeholderCode = ic.replace(/\s+/g, '_').toUpperCase();
            const { data: newIndicator, error: createError } = await supabase
              .from('indicators')
              .select('code')
              .eq('code', placeholderCode)
              .maybeSingle();

            if (!newIndicator) {
              await supabase
                .from('indicators')
                .insert({
                  code: placeholderCode,
                  name: ic,
                  description: `Indicateur ${ic}`,
                  unit: '',
                  frequence: 'mensuelle',
                  processus_code: processusDetails.find(p => p.indicateurs?.includes(ic))?.code
                });
            }
          } catch (createError) {
            console.warn(`Could not create indicator ${ic}:`, createError);
          }
        }
      }

      // Mapper les indicateurs avec leurs processus
      const mapped: OrganizationIndicator[] = [];
      for (const p of processusDetails) {
        if (p.indicateurs) {
          for (const ic of p.indicateurs) {
            const ind = indicatorDetails?.find(i => i.code === ic);
            if (ind) {
              mapped.push({
                indicator_code: ind.code,
                indicator_name: ind.name,
                unit: ind.unit,
                processus_code: p.code,
                processus_name: p.name
              });
            }
          }
        }
      }

      setOrganizationIndicators(mapped);
      setIndicators(indicatorDetails || []);
    } catch (error) {
      console.error('Error fetching organization indicators:', error);
      toast.error('Erreur lors du chargement des indicateurs');
    }
  };

  const fetchCollectionPeriods = async () => {
    if (!currentOrganization) return;

    try {
      const { data, error } = await supabase
        .from('collection_periods')
        .select('*')
        .eq('organization_name', currentOrganization)
        .eq('year', selectedYear)
        .order('period_number', { ascending: false });

      if (error) throw error;
      setCollectionPeriods(data || []);
    } catch (error) {
      console.error('Error fetching collection periods:', error);
      toast.error('Erreur lors du chargement des périodes');
    }
  };

  /* ----------  VALEURS (avec entrées vides dynamiques)  ---------- */
  const fetchValues = async (year: number, month: number) => {
    if (!currentOrganization || !organizationIndicators.length) return;
    setLoading(true);

    try {
      // Récupérer les processus de l'utilisateur
      const { data: userProcessus, error: processusError } = await supabase
        .from('user_processus')
        .select('processus_code')
        .eq('email', profile?.email);

      if (processusError) throw processusError;

      let query = supabase
        .from('indicator_values')
        .select('*')
        .eq('organization_name', currentOrganization)
        .eq('year', year)
        .eq('month', month);

      if (userProcessus?.length) {
        query = query.in('processus_code', userProcessus.map(up => up.processus_code));
      }

      if (selectedSite) {
        query = query.eq('site_name', selectedSite);
      }

      const { data, error } = await query;
      if (error) throw error;

      // Fusionner les données existantes avec les "slots" vides
      const enriched: IndicatorValue[] = organizationIndicators.map(orgInd => {
        const existing = (data || []).find(
          v =>
            v.indicator_code === orgInd.indicator_code &&
            v.processus_code === orgInd.processus_code &&
            (!selectedSite || v.site_name === selectedSite)
        );

        if (existing) return existing;

        // Création d'un placeholder local
        return {
          id: `empty-${orgInd.processus_code}-${orgInd.indicator_code}-${year}-${month}`,
          organization_name: currentOrganization,
          filiere_name: userHierarchy.filiere_name,
          filiale_name: userHierarchy.filiale_name,
          site_name: selectedSite || userHierarchy.site_name,
          year,
          month,
          processus_code: orgInd.processus_code,
          indicator_code: orgInd.indicator_code,
          unit: orgInd.unit || '',
          value: null,
          status: 'draft',
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        };
      });

      setValues(enriched);
    } catch (error) {
      console.error('Error fetching values:', error);
      toast.error('Erreur lors du chargement des valeurs');
    } finally {
      setLoading(false);
    }
  };

  /* ----------  SAISIE / INSERT / UPDATE  ---------- */
  const handleValueChange = async (value: IndicatorValue, newValueStr: string) => {
    const newValue = newValueStr ? parseFloat(newValueStr) : null;
    if (newValue !== null && isNaN(newValue)) {
      toast.error('Veuillez entrer un nombre valide');
      return;
    }

    try {
      // Obtenir ou créer la période de collecte
      let periodId = selectedPeriod;
      if (!periodId) {
        const { data: period, error: periodError } = await supabase
          .rpc('create_collection_period', {
            org_name: currentOrganization,
            target_year: selectedYear,
            target_month: selectedMonth
          });

        if (periodError) throw periodError;
        periodId = period;
      }

      // 1) Premier enregistrement : INSERT
      if (value.id.startsWith('empty-')) {
        const insertData = {
          period_id: periodId,
          organization_name: currentOrganization,
          filiere_name: userHierarchy.filiere_name,
          filiale_name: userHierarchy.filiale_name,
          site_name: selectedSite || userHierarchy.site_name,
          processus_code: value.processus_code,
          indicator_code: value.indicator_code,
          year: selectedYear,
          month: selectedMonth,
          value: newValue,
          unit: value.unit,
          status: 'draft'
        };

        const { data: inserted, error } = await supabase
          .from('indicator_values')
          .insert(insertData)
          .select()
          .single();

        if (error) throw error;

        setValues(prev => [...prev.filter(v => v.id !== value.id), inserted]);
      } else {
        // 2) Mise à jour simple
        const { error } = await supabase
          .from('indicator_values')
          .update({ value: newValue, status: 'draft' })
          .eq('id', value.id);

        if (error) throw error;

        setValues(prev =>
          prev.map(v => (v.id === value.id ? { ...v, value: newValue, status: 'draft' } : v))
        );
      }

      setEditingValue(null);
      setTempValue('');
      toast.success('Valeur mise à jour');
    } catch (error) {
      console.error('Error updating value:', error);
      toast.error('Erreur lors de la mise à jour');
    }
  };

  const handleSubmit = async () => {
    const draftValues = values.filter(v => v.status === 'draft' && v.value !== null);
    if (draftValues.length === 0) {
      toast.error('Aucun brouillon à soumettre');
      return;
    }

    try {
      const existingDrafts = draftValues.filter(v => !v.id.startsWith('empty-'));
      if (existingDrafts.length > 0) {
        const { error } = await supabase
          .from('indicator_values')
          .update({ 
            status: 'submitted',
            submitted_by: profile?.email,
            submitted_at: new Date().toISOString()
          })
          .in('id', existingDrafts.map(v => v.id));

        if (error) throw error;

        setValues(prev =>
          prev.map(v =>
            existingDrafts.find(dv => dv.id === v.id) 
              ? { ...v, status: 'submitted', submitted_by: profile?.email, submitted_at: new Date().toISOString() } 
              : v
          )
        );
      }
      toast.success(`${draftValues.length} indicateur(s) soumis avec succès`);
    } catch (error) {
      console.error('Error submitting values:', error);
      toast.error('Erreur lors de la soumission');
    }
  };

  /* ----------  STATS & FILTRES  ---------- */
  const totalIndicators = organizationIndicators.length;
  const filledIndicators = values.filter(v => typeof v.value === 'number').length;
  const progress = totalIndicators ? ((filledIndicators / totalIndicators) * 100).toFixed(2) : 0;

  const stats = {
    total: values.length,
    submitted: values.filter(v => v.status === 'submitted').length,
    validated: values.filter(v => v.status === 'validated').length,
    rejected: values.filter(v => v.status === 'rejected').length,
  };

  const filtered = values.filter(v => {
    if (selectedStatCard === 'all') return true;
    if (selectedStatCard === 'submitted') return v.status === 'submitted';
    if (selectedStatCard === 'validated') return v.status === 'validated';
    if (selectedStatCard === 'rejected') return v.status === 'rejected';
    if (filterStatus !== 'all' && v.status !== filterStatus) return false;
    if (filterProcessus !== 'all' && v.processus_code !== filterProcessus) return false;
    if (searchTerm) {
      const lower = searchTerm.toLowerCase();
      const ind = organizationIndicators.find(i => i.indicator_code === v.indicator_code);
      const proc = processus.find(p => p.code === v.processus_code);
      return (
        v.indicator_code.toLowerCase().includes(lower) ||
        v.processus_code.toLowerCase().includes(lower) ||
        ind?.indicator_name.toLowerCase().includes(lower) ||
        proc?.name.toLowerCase().includes(lower)
      );
    }
    return true;
  });

  const grouped = filtered.reduce<Record<string, IndicatorValue[]>>((acc, v) => {
    if (!acc[v.processus_code]) acc[v.processus_code] = [];
    acc[v.processus_code].push(v);
    return acc;
  }, {});

  const getStatusColor = (s: string) =>
    s === 'validated' ? 'bg-green-100 text-green-800' : 
    s === 'rejected' ? 'bg-red-100 text-red-800' : 
    s === 'submitted' ? 'bg-yellow-100 text-yellow-800' : 
    'bg-gray-100 text-gray-800';

  const getStatusLabel = (s: string) =>
    ({ validated: 'Validé', rejected: 'Rejeté', submitted: 'Soumis', draft: 'Brouillon' }[s] || '');

  const getIndicatorName = (c: string) => indicators.find(i => i.code === c)?.name || c;
  const getProcessusName = (c: string) => processus.find(p => p.code === c)?.name || c;

  /* ----------  RENDER  ---------- */
  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <Loader2 className="h-8 w-8 animate-spin text-green-600" />
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="max-w-7xl mx-auto">
        <button
          onClick={() => navigate(-1)}
          className="mb-4 flex items-center gap-2 px-4 py-2 bg-gray-600 text-white rounded-md hover:bg-gray-700"
        >
          <ArrowLeft size={16} /> Retour au menu
        </button>

        <div className="relative mb-8 rounded-xl overflow-hidden shadow-lg">
          <img src="/Imade full VSG.jpg" alt="Global ESG Banner" className="w-full h-32 object-cover" />
          <div className="absolute inset-0 bg-gradient-to-r from-black/20 to-transparent"></div>
        </div>

        <h1 className="text-3xl font-bold text-gray-800 mb-2">Module Pilotage Énergétique</h1>
        <p className="text-gray-600 mb-6">Collectez vos indicateurs de performance énergétique</p>

        {/* Sélection du site */}
        {sites.length > 1 && (
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              <Factory className="h-4 w-4 inline mr-1" />
              Site
            </label>
            <select
              value={selectedSite}
              onChange={(e) => setSelectedSite(e.target.value)}
              className="block px-3 py-2 border rounded-md"
            >
              <option value="">Tous les sites</option>
              {sites.map(site => (
                <option key={site.name} value={site.name}>
                  {site.name} - {site.city}
                </option>
              ))}
            </select>
          </div>
        )}

        {/* Période */}
        <div className="mb-6 flex gap-4 items-center">
          <div>
            <label className="text-sm font-medium">Année</label>
            <select
              value={selectedYear}
              onChange={e => setSelectedYear(Number(e.target.value))}
              className="block px-3 py-2 border rounded-md"
            >
              {[...Array(10)].map((_, i) => (
                <option key={i} value={new Date().getFullYear() - 2 + i}>
                  {new Date().getFullYear() - 2 + i}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label className="text-sm font-medium">Mois</label>
            <select
              value={selectedMonth}
              onChange={e => setSelectedMonth(Number(e.target.value))}
              className="block px-3 py-2 border rounded-md"
            >
              {[...Array(12)].map((_, i) => (
                <option key={i + 1} value={i + 1}>
                  {getMonthName(i + 1)}
                </option>
              ))}
            </select>
          </div>
        </div>

        {/* Progression */}
        <div className="mb-4 max-w-xs">
          <div className="flex justify-between text-sm text-gray-600 mb-1">
            <span>Progression</span>
            <span>{filledIndicators}/{totalIndicators}</span>
          </div>
          <div className="w-full bg-gray-200 rounded-full h-1.5">
            <div className="bg-green-600 h-1.5 rounded-full" style={{ width: `${progress}%` }}></div>
          </div>
        </div>

        {/* Filtres */}
        <div className="mb-6 grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label className="text-sm font-medium flex items-center"><Filter className="w-4 h-4 mr-1" /> Statut</label>
            <select
              value={filterStatus}
              onChange={e => setFilterStatus(e.target.value)}
              className="mt-1 block w-full px-3 py-2 border rounded-md"
            >
              <option value="all">Tous les statuts</option>
              <option value="draft">Brouillon</option>
              <option value="submitted">Soumis</option>
              <option value="validated">Validé</option>
              <option value="rejected">Rejeté</option>
            </select>
          </div>
          <div>
            <label className="text-sm font-medium flex items-center"><Filter className="w-4 h-4 mr-1" /> Processus</label>
            <select
              value={filterProcessus}
              onChange={e => setFilterProcessus(e.target.value)}
              className="mt-1 block w-full px-3 py-2 border rounded-md"
            >
              <option value="all">Tous</option>
              {processus.map(p => (
                <option key={p.code} value={p.code}>
                  {p.name}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label className="text-sm font-medium flex items-center"><Search className="w-4 h-4 mr-1" /> Rechercher</label>
            <input
              type="text"
              placeholder="Indicateur ou processus..."
              value={searchTerm}
              onChange={e => setSearchTerm(e.target.value)}
              className="mt-1 block w-full px-3 py-2 border rounded-md"
            />
          </div>
        </div>

        {/* Stat Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
          {[
            { label: 'Total', count: stats.total, status: 'all', color: 'bg-blue-500', icon: BarChart3 },
            { label: 'Soumis', count: stats.submitted, status: 'submitted', color: 'bg-yellow-500', icon: Clock },
            { label: 'Validés', count: stats.validated, status: 'validated', color: 'bg-green-500', icon: CheckCircle2 },
            { label: 'Rejetés', count: stats.rejected, status: 'rejected', color: 'bg-red-500', icon: XCircle }
          ].map(({ label, count, status, color, icon: Icon }) => (
            <div
              key={status}
              onClick={() => {
                setSelectedStatCard(status === selectedStatCard ? null : status);
                setFilterStatus('all');
              }}
              className={`p-4 rounded-lg shadow-md text-white cursor-pointer transition-transform hover:scale-105 ${color} ${selectedStatCard === status ? 'ring-4 ring-offset-2 ring-blue-600' : ''}`}
            >
              <div className="flex items-center">
                <Icon className="w-6 h-6 mr-3" />
                <div>
                  <p className="text-sm font-semibold">{label}</p>
                  <p className="text-2xl font-bold">{count}</p>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Bouton Soumettre */}
        {values.filter(v => v.status === 'draft' && v.value !== null).length > 0 && (
          <div className="mb-6">
            <button
              onClick={handleSubmit}
              className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-md"
            >
              <Send size={16} /> Soumettre les brouillons
            </button>
          </div>
        )}

        {/* Affichage par processus */}
        {Object.entries(grouped).map(([processusCode, indicators]) => {
          const open = expandedProcessus === processusCode;
          return (
            <div key={processusCode} className="mb-6 border rounded-lg bg-white shadow-sm">
              <div
                onClick={() => setExpandedProcessus(open ? null : processusCode)}
                className="flex items-center justify-between px-6 py-4 cursor-pointer hover:bg-gray-50"
              >
                <div className="flex items-center gap-3">
                  <Zap className="h-5 w-5 text-blue-600" />
                  <h3 className="text-lg font-semibold">{getProcessusName(processusCode)}</h3>
                  <span className="px-2 py-1 bg-blue-100 text-blue-800 rounded-full text-sm">
                    {indicators.length} indicateurs
                  </span>
                </div>
                {open ? <ChevronUp /> : <ChevronDown />}
              </div>
              {open && (
                <div className="px-6 pb-4">
                  <table className="min-w-full divide-y divide-gray-200">
                    <thead className="bg-gray-50">
                      <tr>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                          Indicateur
                        </th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                          Valeur
                        </th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                          Unité
                        </th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                          Statut
                        </th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                          Actions
                        </th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-200">
                      {indicators.map(v => (
                        <tr key={v.id} className="hover:bg-gray-50">
                          <td className="px-6 py-4 text-sm">
                            <div>
                              <div className="font-medium text-gray-900">
                                {getIndicatorName(v.indicator_code)}
                              </div>
                              <div className="text-xs text-gray-500">
                                Code: {v.indicator_code}
                              </div>
                            </div>
                          </td>
                          <td className="px-6 py-4 text-sm">
                            {editingValue === v.id ? (
                              <>
                                <input
                                  type="number"
                                  value={tempValue}
                                  onChange={e => setTempValue(e.target.value)}
                                  className="w-20 border rounded px-1"
                                  step="0.01"
                                />
                                <button
                                  onClick={() => handleValueChange(v, tempValue)}
                                  className="ml-2 text-green-600"
                                >
                                  <Save size={16} />
                                </button>
                                <button
                                  onClick={() => {
                                    setEditingValue(null);
                                    setTempValue('');
                                  }}
                                  className="ml-1 text-red-600"
                                >
                                  <XCircle size={16} />
                                </button>
                              </>
                            ) : (
                              <span className="font-medium">
                                {v.value?.toLocaleString() ?? '-'}
                              </span>
                            )}
                          </td>
                          <td className="px-6 py-4 text-sm">{v.unit || ''}</td>
                          <td className="px-6 py-4">
                            <span className={`px-2 py-1 text-xs rounded-full ${getStatusColor(v.status)}`}>
                              {getStatusLabel(v.status)}
                            </span>
                          </td>
                          <td className="px-6 py-4">
                            {['draft', 'rejected'].includes(v.status) && editingValue !== v.id && (
                              <button
                                onClick={() => {
                                  setEditingValue(v.id);
                                  setTempValue(v.value?.toString() || '');
                                }}
                                className="text-blue-600 hover:text-blue-800"
                              >
                                <Edit3 size={16} />
                              </button>
                            )}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          );
        })}

        {/* Message si aucun processus */}
        {processus.length === 0 && (
          <div className="text-center py-12">
            <Building2 className="h-12 w-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">
              Aucun processus assigné
            </h3>
            <p className="text-gray-500">
              Contactez votre administrateur pour vous assigner des processus.
            </p>
          </div>
        )}
      </div>
    </div>
  );
};