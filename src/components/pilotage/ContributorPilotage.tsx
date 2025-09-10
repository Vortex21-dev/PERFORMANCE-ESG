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
  ArrowLeft
} from 'lucide-react';
import toast from 'react-hot-toast';

interface IndicatorValue {
  id: string;
  organization_name: string;
  business_line_name?: string | null;
  subsidiary_name?: string | null;
  site_name?: string | null;
  year: number;
  month: number;
  process_code: string;
  indicator_code: string;
  value: number | null;
  unit: string;
  status: 'draft' | 'submitted' | 'validated' | 'rejected';
  comment?: string;
}

interface Process {
  code: string;
  name: string;
  indicator_codes: string[];
}

interface Indicator {
  code: string;
  name: string;
  unit?: string;
}

interface OrganizationIndicator {
  indicator_code: string;
  indicator_name: string;
  unit?: string;
  process_code: string;
  process_name: string;
}

export const ContributorPilotage: React.FC = () => {
  const navigate = useNavigate();
  const { profile, impersonatedOrganization } = useAuthStore();

  /* ----------  ÉTAT  ---------- */
  const [values, setValues] = useState<IndicatorValue[]>([]);
  const [processes, setProcesses] = useState<Process[]>([]);
  const [indicators, setIndicators] = useState<Indicator[]>([]);
  const [organizationIndicators, setOrganizationIndicators] = useState<OrganizationIndicator[]>([]);
  const [selectedYear, setSelectedYear] = useState(new Date().getFullYear());
  const [selectedMonth, setSelectedMonth] = useState(new Date().getMonth() + 1);
  const [loading, setLoading] = useState(true);
  const [editingValue, setEditingValue] = useState<string | null>(null);
  const [tempValue, setTempValue] = useState('');
  const [filterStatus, setFilterStatus] = useState<string>('all');
  const [filterProcess, setFilterProcess] = useState<string>('all');
  const [searchTerm, setSearchTerm] = useState('');
  const [expandedProcess, setExpandedProcess] = useState<string | null>(null);
  const [selectedStatCard, setSelectedStatCard] = useState<string | null>(null);

  const currentOrganization = impersonatedOrganization || profile?.organization_name;
  
  // Get user's hierarchy level from profile
  const userHierarchy = {
    organization_name: currentOrganization,
    business_line_name: profile?.business_line_name || null,
    subsidiary_name: profile?.subsidiary_name || null,
    site_name: profile?.site_name || null
  };

  /* ----------  HOOKS  ---------- */
  useEffect(() => {
    if (!profile || profile.role !== 'contributor') {
      navigate('/login');
      return;
    }
    fetchInitialData();
  }, [profile, navigate]);

  useEffect(() => {
    if (currentOrganization) {
      fetchValues(selectedYear, selectedMonth);
    }
  }, [selectedYear, selectedMonth, currentOrganization, organizationIndicators]);

  /* ----------  VALIDATION HIÉRARCHIE  ---------- */
  const validateHierarchy = (hierarchy: {
    business_line_name?: string | null;
    subsidiary_name?: string | null;
    site_name?: string | null;
  }) => {
    // Si site_name est présent, subsidiary_name et business_line_name doivent l'être aussi
    if (hierarchy.site_name && (!hierarchy.subsidiary_name || !hierarchy.business_line_name)) {
      return {
        business_line_name: null,
        subsidiary_name: null,
        site_name: null
      };
    }
    
    // Si subsidiary_name est présent, business_line_name doit l'être aussi
    if (hierarchy.subsidiary_name && !hierarchy.business_line_name) {
      return {
        business_line_name: null,
        subsidiary_name: null,
        site_name: null
      };
    }
    
    return hierarchy;
  };

  /* ----------  DATA DE BASE  ---------- */
  const fetchInitialData = async () => {
    setLoading(true);
    await Promise.all([fetchProcesses(), fetchOrganizationIndicators()]);
    setLoading(false);
  };

  const getMonthName = (m: number) =>
    ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'][m - 1];

  const fetchProcesses = async () => {
    const { data } = await supabase.from('processes').select('*').order('name');
    setProcesses(data || []);
  }; 

  const fetchOrganizationIndicators = async () => {
    if (!profile?.email || !currentOrganization) {
      console.log('❌ Missing profile email or organization:', { email: profile?.email, org: currentOrganization });
      return;
    }

    console.log('🔍 Fetching organization indicators for:', { email: profile.email, org: currentOrganization });

    /* 1. Processus assignés à l'utilisateur */
    console.log('📋 Checking user_processes table for email:', profile.email);
    const { data: userProcs, error: userError } = await supabase
      .from('user_processes')
      .select('process_codes')
      .eq('email', profile.email)
      .single();

    console.log('📋 User processes query result:', { data: userProcs, error: userError });

    if (userError) {
      console.error('❌ Error fetching user processes:', userError);
      console.log('❌ User processes error details:', {
        code: userError.code,
        message: userError.message,
        details: userError.details
      });
      return;
    }

    const allowedProcCodes = userProcs?.process_codes || [];
    console.log('📋 User assigned processes:', allowedProcCodes);

    if (!allowedProcCodes.length) {
      console.log('⚠️ No processes assigned to user');
      console.log('💡 Checking if user exists in user_processes table...');
      
      // Vérifier si l'utilisateur existe dans la table user_processes
      const { data: allUserProcesses, error: allError } = await supabase
        .from('user_processes')
        .select('email, process_codes');
      
      console.log('📊 All user_processes records:', allUserProcesses);
      console.log('🔍 Looking for email:', profile.email);
      
      const userExists = allUserProcesses?.find(up => up.email === profile.email);
      console.log('👤 User found in user_processes:', userExists);
      
      setOrganizationIndicators([]);
      setIndicators([]);
      return;
    }

    /* 2. Détails des processus assignés */
    console.log('🔧 Fetching process details for codes:', allowedProcCodes);
    const { data: procDetails, error: procError } = await supabase
      .from('processes')
      .select('code, name, indicator_codes')
      .in('code', allowedProcCodes);

    console.log('🔧 Process details query result:', { data: procDetails, error: procError });

    if (procError) {
      console.error('❌ Error fetching process details:', procError);
      return;
    }

    console.log('🔧 Process details found:', procDetails);

    if (!procDetails || !procDetails.length) {
      console.log('⚠️ No process details found for assigned codes');
      console.log('💡 Checking all processes in organization...');
      
      // Vérifier tous les processus de l'organisation
      const { data: allOrgProcesses, error: allOrgError } = await supabase
        .from('processes')
        .select('code, name, organization_name')
        .eq('organization_name', currentOrganization);
      
      console.log('🏢 All organization processes:', allOrgProcesses);
      
      // Vérifier tous les processus dans la base
      const { data: allProcesses, error: allProcError } = await supabase
        .from('processes')
        .select('code, name, organization_name');
      
      console.log('🌍 All processes in database:', allProcesses);
      
      setOrganizationIndicators([]);
      setIndicators([]);
      return;
    }

    /* 3. Récupération des indicateurs */
    const allIndicatorCodes = procDetails.flatMap(p => p.indicator_codes || []);
    console.log('📊 All indicator codes from processes:', allIndicatorCodes);

    if (!allIndicatorCodes.length) {
      console.log('⚠️ No indicators found in assigned processes');
      setOrganizationIndicators([]);
      setIndicators([]);
      return;
    }

    const { data: indicators, error: indError } = await supabase
      .from('indicators')
      .select('*')
      .in('code', allIndicatorCodes);

    if (indError) {
      console.error('❌ Error fetching indicators:', indError);
      return;
    }

    console.log('📈 Indicators found:', indicators);

    /* 4. Mapping final */
    const mapped: OrganizationIndicator[] = [];
    procDetails.forEach(p => {
      const indicatorCodes = p.indicator_codes || [];
      console.log(`🔗 Process ${p.code} (${p.name}) has indicators:`, indicatorCodes);
      
      indicatorCodes.forEach((ic: string) => {
        // Try to find by code first, then by name
        const ind = indicators?.find(i => i.code === ic || i.name === ic);
        if (ind) {
          mapped.push({
            indicator_code: ind.code,
            indicator_name: ind.name,
            unit: ind.unit,
            process_code: p.code,
            process_name: p.name,
          });
        } else {
          console.log(`⚠️ Indicator ${ic} not found in indicators table (searched by code and name)`);
          
          // Create a placeholder indicator if it doesn't exist
          const placeholderCode = ic.replace(/\s+/g, '_').toUpperCase();
          mapped.push({
            indicator_code: placeholderCode,
            indicator_name: ic,
            unit: '',
            process_code: p.code,
            process_name: p.name,
          });
          console.log(`📝 Created placeholder for indicator: ${ic} -> ${placeholderCode}`);
        }
      });
    });

    console.log('✅ Final mapped indicators:', mapped);

    setOrganizationIndicators(mapped);
    setIndicators(indicators || []);
  };
  /* ----------  VALEURS (avec entrées vides dynamiques)  ---------- */
  const fetchValues = async (year: number, month: number) => {
    if (!currentOrganization || !organizationIndicators.length) return;
    setLoading(true);

    const { data: userProcesses } = await supabase
      .from('user_processes')
      .select('process_codes')
      .eq('email', profile?.email)
      .single();

    // Build query with user's hierarchy
    let query = supabase
      .from('indicator_values')
      .select('*')
      .eq('organization_name', currentOrganization)
      .eq('year', year)
      .eq('month', month)
      .in('process_code', userProcesses?.process_codes || []);
    
    // Filter by user's hierarchy level
    if (userHierarchy.site_name) {
      query = query.eq('site_name', userHierarchy.site_name);
    } else if (userHierarchy.subsidiary_name) {
      query = query.eq('subsidiary_name', userHierarchy.subsidiary_name);
    } else if (userHierarchy.business_line_name) {
      query = query.eq('business_line_name', userHierarchy.business_line_name);
    }
    
    const { data } = await query;

    // Utiliser directement la hiérarchie de l'utilisateur
    const hierarchyData = {
      business_line_name: userHierarchy.business_line_name,
      subsidiary_name: userHierarchy.subsidiary_name,
      site_name: userHierarchy.site_name,
      business_line_key: userHierarchy.business_line_name || '',
      subsidiary_key: userHierarchy.subsidiary_name || '',
      site_key: userHierarchy.site_name || ''
    };

    // Fusionner les données existantes avec les "slots" vides
    const enriched: IndicatorValue[] = organizationIndicators.map(orgInd => {
      const existing = (data || []).find(
        v =>
          v.indicator_code === orgInd.indicator_code &&
          v.process_code === orgInd.process_code
      );
      if (existing) return existing;

      // Création d'un placeholder local
      return {
        id: `empty-${orgInd.process_code}-${orgInd.indicator_code}-${year}-${month}`,
        organization_name: currentOrganization!,
        business_line_name: userHierarchy.business_line_name,
        subsidiary_name: userHierarchy.subsidiary_name,
        site_name: userHierarchy.site_name,
        year,
        month,
        process_code: orgInd.process_code,
        indicator_code: orgInd.indicator_code,
        unit: orgInd.unit || '',
        value: null,
        status: 'draft',
      };
    });

    setValues(enriched);
    setLoading(false);
  };

  /* ----------  SAISIE / INSERT / UPDATE  ---------- */
  const handleValueChange = async (value: IndicatorValue, newValueStr: string) => {
  const newValue = newValueStr === '' ? null : parseFloat(newValueStr);
  if (newValue !== null && isNaN(newValue)) {
    toast.error('Veuillez entrer un nombre valide');
    return;
  }

  try {
    const now = new Date().toISOString();

    /* 1) PREMIER ENREGISTREMENT : INSERT complet */
    if (value.id.startsWith('empty-')) {
      const { data: inserted, error } = await supabase
        .from('indicator_values')
        .insert({
          organization_name: currentOrganization!,
          business_line_name: userHierarchy.business_line_name,
          subsidiary_name: userHierarchy.subsidiary_name,
          site_name: userHierarchy.site_name,
          year: selectedYear,
          month: selectedMonth,
          process_code: value.process_code,
          indicator_code: value.indicator_code,
          value: newValue,
          unit: value.unit || null,
          status: 'draft',
          comment: null,
          created_at: now,
          updated_at: now,
        })
        .select()
        .single();

      if (error) throw error;
      setValues(prev => [...prev.filter(v => v.id !== value.id), inserted]);
    }

    /* 2) MISE À JOUR */
    else {
      const { error } = await supabase
        .from('indicator_values')
        .update({
          value: newValue,
          unit: value.unit || null,
          status: 'draft',
          updated_at: now,
        })
        .eq('id', value.id);

      if (error) throw error;
      setValues(prev =>
        prev.map(v =>
          v.id === value.id ? { ...v, value: newValue, status: 'draft' } : v
        )
      );
    }

    setEditingValue(null);
    setTempValue('');
    toast.success('Valeur mise à jour');
  } catch (err: any) {
    console.error(err);
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
          .update({ status: 'submitted' })
          .in(
            'id',
            existingDrafts.map(v => v.id)
          );
        if (error) throw error;

        setValues(prev =>
          prev.map(v =>
            existingDrafts.find(dv => dv.id === v.id) ? { ...v, status: 'submitted' } : v
          )
        );
      }
      toast.success(`${draftValues.length} indicateur(s) soumis avec succès`);
    } catch (error) {
      console.error(error);
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
    if (filterProcess !== 'all' && v.process_code !== filterProcess) return false;
    if (searchTerm) {
      const lower = searchTerm.toLowerCase();
      const ind = organizationIndicators.find(i => i.indicator_code === v.indicator_code);
      const proc = processes.find(p => p.code === v.process_code);
      return (
        v.indicator_code.toLowerCase().includes(lower) ||
        v.process_code.toLowerCase().includes(lower) ||
        ind?.indicator_name.toLowerCase().includes(lower) ||
        proc?.name.toLowerCase().includes(lower)
      );
    }
    return true;
  });

  const grouped = filtered.reduce<Record<string, IndicatorValue[]>>((acc, v) => {
    if (!acc[v.process_code]) acc[v.process_code] = [];
    acc[v.process_code].push(v);
    return acc;
  }, {});

  const getStatusColor = (s: string) =>
    s === 'validated' ? 'bg-green-100 text-green-800' : s === 'rejected' ? 'bg-red-100 text-red-800' : s === 'submitted' ? 'bg-yellow-100 text-yellow-800' : 'bg-gray-100 text-gray-800';

  const getStatusLabel = (s: string) =>
    ({ validated: 'Validé', rejected: 'Rejeté', submitted: 'Soumis', draft: 'Brouillon' }[s] || '');

  const getIndicatorName = (c: string) => indicators.find(i => i.code === c)?.name || c;
  const getProcessName = (c: string) => processes.find(p => p.code === c)?.name || c;

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

        <h1 className="text-3xl font-bold text-gray-800 mb-2">Module Pilotage ESG</h1>
        <p className="text-gray-600 mb-6">Collectez vos indicateurs de performance ESG</p>

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
              value={filterProcess}
              onChange={e => setFilterProcess(e.target.value)}
              className="mt-1 block w-full px-3 py-2 border rounded-md"
            >
              <option value="all">Tous</option>
              {processes.map(p => (
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

        {/* Debug Panel - Only in development */}
        {import.meta.env.DEV && (
          <div className="mt-8 p-4 bg-gray-100 rounded-lg">
            <h3 className="font-semibold mb-2">🔧 Debug Info</h3>
            <div className="text-sm space-y-1">
              <p><strong>Email:</strong> {profile?.email}</p>
              <p><strong>Organisation:</strong> {currentOrganization}</p>
              <p><strong>Niveau utilisateur:</strong> {profile?.organization_level}</p>
              <p><strong>Filière:</strong> {userHierarchy.business_line_name || 'Non assigné'}</p>
              <p><strong>Filiale:</strong> {userHierarchy.subsidiary_name || 'Non assigné'}</p>
              <p><strong>Site:</strong> {userHierarchy.site_name || 'Non assigné'}</p>
              <p><strong>Indicateurs mappés:</strong> {organizationIndicators.length}</p>
              <p><strong>Processus groupés:</strong> {Object.keys(grouped).length}</p>
              <p><strong>Valeurs chargées:</strong> {values.length}</p>
            </div>
          </div>
        )}

        {/* Affichage par processus */}
        {Object.entries(grouped).map(([processCode, indicators]) => {
          const open = expandedProcess === processCode;
          const processName = getProcessName(processCode);
          const indicatorCount = indicators.length;
          
          return (
            <div key={processCode} className="mb-6 border rounded-lg bg-white shadow-sm">
              <div
                onClick={() => setExpandedProcess(open ? null : processCode)}
                className="flex items-center justify-between px-6 py-4 cursor-pointer hover:bg-gray-50"
              >
                <div>
                  <h3 className="text-lg font-semibold">{processName}</h3>
                  <p className="text-sm text-gray-600">{indicatorCount} indicateur(s)</p>
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
                          <td className="px-6 py-4 text-sm">{getIndicatorName(v.indicator_code)}</td>
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
                              v.value?.toLocaleString() ?? '-'
                            )}
                          </td>
                          <td className="px-6 py-4 text-sm">
                            {v.unit || organizationIndicators.find(i => i.indicator_code === v.indicator_code)?.unit || ''}
                          </td>
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
                                className="text-blue-600"
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
      </div>
    </div>
  );
};