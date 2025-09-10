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
  XCircle,
  Loader2,
  ArrowLeft,
  MessageSquare,
  Eye,
  Building2
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
}

interface Processus {
  code: string;
  name: string;
  indicateurs: string[];
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
  processus_code: string;
  processus_name: string;
}

export const ValidatorPilotageReplicated: React.FC = () => {
  const navigate = useNavigate();
  const { profile, impersonatedOrganization } = useAuthStore();

  const [values, setValues] = useState<IndicatorValue[]>([]);
  const [processus, setProcessus] = useState<Processus[]>([]);
  const [indicators, setIndicators] = useState<Indicator[]>([]);
  const [organizationIndicators, setOrganizationIndicators] = useState<OrganizationIndicator[]>([]);
  const [selectedYear, setSelectedYear] = useState(new Date().getFullYear());
  const [selectedMonth, setSelectedMonth] = useState(new Date().getMonth() + 1);
  const [loading, setLoading] = useState(true);
  const [filterStatus, setFilterStatus] = useState('submitted');
  const [filterProcessus, setFilterProcessus] = useState('all');
  const [searchTerm, setSearchTerm] = useState('');
  const [validationComment, setValidationComment] = useState('');
  const [showCommentModal, setShowCommentModal] = useState(false);
  const [validationAction, setValidationAction] = useState<'approve' | 'reject' | null>(null);
  const [expandedProcessus, setExpandedProcessus] = useState<string | null>(null);
  const [selectedStatCard, setSelectedStatCard] = useState<string | null>(null);
  const [selectedValueId, setSelectedValueId] = useState<string | null>(null);

  const currentOrganization = impersonatedOrganization || profile?.organization_name;

  /* ---------- DATA ---------- */
  useEffect(() => {
    if (!profile || !['validateur', 'validator'].includes(profile.role)) {
      navigate('/login');
      return;
    }
    fetchInitialData();
  }, [profile, navigate]);

  useEffect(() => {
    if (selectedYear && selectedMonth && currentOrganization) {
      fetchValues(selectedYear, selectedMonth);
    }
  }, [selectedYear, selectedMonth, currentOrganization]);

  const fetchInitialData = async () => {
    setLoading(true);
    await Promise.all([fetchProcessus(), fetchOrganizationIndicators()]);
    setLoading(false);
  };

  const getMonthName = (m: number) =>
    ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'][m - 1];

  const fetchProcessus = async () => {
    try {
      const { data, error } = await supabase
        .from('processus')
        .select('*')
        .order('name');
      
      if (error) throw error;
      setProcessus(data || []);
    } catch (error) {
      console.error('Error fetching processus:', error);
      toast.error('Erreur lors du chargement des processus');
    }
  };

  const fetchOrganizationIndicators = async () => {
    if (!profile?.email) return;

    try {
      // Récupérer les processus assignés au validateur
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

  const fetchValues = async (year: number, month: number) => {
    if (!currentOrganization) return;
    
    setLoading(true);
    try {
      // Récupérer les processus assignés au validateur
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

      const { data, error } = await query.in('status', ['draft', 'submitted', 'validated', 'rejected']);
      if (error) throw error;

      setValues(data || []);
    } catch (error) {
      console.error('Error fetching values:', error);
      toast.error('Erreur lors du chargement des valeurs');
    } finally {
      setLoading(false);
    }
  };

  /* ---------- VALIDATION ---------- */
  const handleValidationClick = (action: 'approve' | 'reject', valueId?: string) => {
    const targetValues = valueId 
      ? values.filter(v => v.id === valueId && v.status === 'submitted')
      : values.filter(v => v.status === 'submitted');
      
    if (!targetValues.length) {
      toast.error(valueId ? 'Aucune valeur soumise sélectionnée' : 'Aucune valeur à valider');
      return;
    }
    
    setValidationAction(action);
    setSelectedValueId(valueId || null);
    setShowCommentModal(true);
  };

  const handleValidate = async () => {
    if (!profile?.email) return;

    try {
      const valuesToValidate = selectedValueId 
        ? values.filter(v => v.id === selectedValueId && v.status === 'submitted')
        : values.filter(v => v.status === 'submitted');

      if (!valuesToValidate.length) {
        toast.error('Aucune valeur à valider');
        return;
      }

      const updateData = {
        status: validationAction === 'approve' ? 'validated' : 'rejected',
        validated_by: profile.email,
        validated_at: new Date().toISOString(),
        comment: validationComment || null,
      };

      const { error } = await supabase
        .from('indicator_values')
        .update(updateData)
        .in('id', valuesToValidate.map(v => v.id));

      if (error) throw error;

      setValues(prevValues =>
        prevValues.map(item =>
          valuesToValidate.some(v => v.id === item.id)
            ? { ...item, ...updateData }
            : item
        )
      );

      setValidationComment('');
      setShowCommentModal(false);
      setValidationAction(null);
      setSelectedValueId(null);
      
      toast.success(`${valuesToValidate.length} valeur(s) ${validationAction === 'approve' ? 'validée(s)' : 'rejetée(s)'}`);
    } catch (error) {
      console.error('Error validating values:', error);
      toast.error('Erreur lors de la validation');
    }
  };

  /* ---------- FILTER & GROUP ---------- */
  const getAllRequiredData = () => {
    if (!currentOrganization || !profile?.email) return [];

    return organizationIndicators.map(orgIndicator => {
      const existingValue = values.find(
        v => v.indicator_code === orgIndicator.indicator_code && 
             v.processus_code === orgIndicator.processus_code
      );

      if (existingValue) {
        return existingValue;
      }

      // Créer une entrée vide avec statut 'draft' pour afficher tous les indicateurs
      return {
        id: `empty-${orgIndicator.processus_code}-${orgIndicator.indicator_code}-${selectedYear}-${selectedMonth}`,
        organization_name: currentOrganization,
        year: selectedYear,
        month: selectedMonth,
        processus_code: orgIndicator.processus_code,
        indicator_code: orgIndicator.indicator_code,
        value: null,
        unit: orgIndicator.unit || '',
        status: 'draft' as const,
        comment: undefined,
        submitted_by: undefined,
        submitted_at: undefined,
        validated_by: undefined,
        validated_at: undefined,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      };
    });
  };

  const allRequiredData = getAllRequiredData();

  const filteredData = allRequiredData.filter(v => {
    if (selectedStatCard === 'submitted') return v.status === 'submitted';
    if (selectedStatCard === 'validated') return v.status === 'validated';
    if (selectedStatCard === 'rejected') return v.status === 'rejected';
    if (filterStatus !== 'all' && v.status !== filterStatus) return false;
    if (filterProcessus !== 'all' && v.processus_code !== filterProcessus) return false;
    if (searchTerm) {
      const lower = searchTerm.toLowerCase();
      const orgInd = organizationIndicators.find(i => i.indicator_code === v.indicator_code);
      return (
        v.indicator_code.toLowerCase().includes(lower) ||
        v.processus_code.toLowerCase().includes(lower) ||
        orgInd?.indicator_name.toLowerCase().includes(lower) ||
        orgInd?.processus_name.toLowerCase().includes(lower)
      );
    }
    return true;
  });

  const grouped = filteredData.reduce<Record<string, IndicatorValue[]>>((acc, v) => {
    if (!acc[v.processus_code]) acc[v.processus_code] = [];
    acc[v.processus_code].push(v);
    return acc;
  }, {});

  const getStatusColor = (s: string) =>
    s === 'validated' ? 'bg-green-100 text-green-800' :
    s === 'rejected' ? 'bg-red-100 text-red-800' :
    s === 'submitted' ? 'bg-yellow-100 text-yellow-800' :
    'bg-gray-100 text-gray-800';

  const getStatusLabel = (s: string) => ({ validated: 'Validé', rejected: 'Rejeté', submitted: 'Soumis', draft: 'Brouillon' }[s] || '');
  const getIndicatorName = (c: string) => indicators.find(i => i.code === c)?.name || c;
  const getProcessusName = (c: string) => processus.find(p => p.code === c)?.name || c;

  /* ---------- RENDER ---------- */
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
        {/* Back Button */}
        <button
          onClick={() => navigate(-1)}
          className="mb-4 flex items-center gap-2 px-4 py-2 bg-gray-600 text-white rounded-md hover:bg-gray-700"
        >
          <ArrowLeft size={16} /> Retour au menu
        </button>

        {/* Banner */}
        <div className="relative mb-8 rounded-xl overflow-hidden shadow-lg">
          <img src="/Imade full VSG.jpg" alt="Global ESG Banner" className="w-full h-32 object-cover" />
          <div className="absolute inset-0 bg-gradient-to-r from-black/20 to-transparent"></div>
        </div>

        <h1 className="text-3xl font-bold text-gray-800 mb-2">Module Pilotage Énergétique</h1>
        <p className="text-gray-600 mb-6">Validez ou rejetez les valeurs soumises</p>

        {/* Période + Export */}
        <div className="mb-6 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
          <div className="flex gap-4 items-center">
            <div>
              <label className="text-sm font-medium">Année</label>
              <select value={selectedYear} onChange={e => setSelectedYear(Number(e.target.value))} className="block px-3 py-2 border rounded-md">
                {[...Array(10)].map((_, i) => <option key={i} value={new Date().getFullYear() - 2 + i}>{new Date().getFullYear() - 2 + i}</option>)}
              </select>
            </div>
            <div>
              <label className="text-sm font-medium">Mois</label>
              <select value={selectedMonth} onChange={e => setSelectedMonth(Number(e.target.value))} className="block px-3 py-2 border rounded-md">
                {[...Array(12)].map((_, i) => <option key={i + 1} value={i + 1}>{getMonthName(i + 1)}</option>)}
              </select>
            </div>
          </div>
        </div>

        {/* Progress Bar */}
        <div className="mb-4 max-w-xs">
          <div className="flex justify-between text-sm text-gray-600 mb-1">
            <span>À valider</span>
            <span>{allRequiredData.filter(v => v.status === 'submitted').length} / {allRequiredData.length}</span>
          </div>
          <div className="w-full bg-gray-200 rounded-full h-1.5">
            <div className="bg-yellow-600 h-1.5 rounded-full" style={{ width: `${(allRequiredData.filter(v => v.status === 'submitted').length / allRequiredData.length) * 100 || 0}%` }}></div>
          </div>
        </div>

        {/* Filters */}
        <div className="mb-6 grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label className="text-sm font-medium flex items-center"><Filter className="w-4 h-4 mr-1" /> Statut</label>
            <select value={filterStatus} onChange={e => setFilterStatus(e.target.value)} className="mt-1 block w-full px-3 py-2 border rounded-md">
              <option value="submitted">Soumis</option>
              <option value="validated">Validés</option>
              <option value="rejected">Rejetés</option>
              <option value="draft">Brouillons</option>
              <option value="all">Tous</option>
            </select>
          </div>
          <div>
            <label className="text-sm font-medium flex items-center"><Filter className="w-4 h-4 mr-1" /> Processus</label>
            <select value={filterProcessus} onChange={e => setFilterProcessus(e.target.value)} className="mt-1 block w-full px-3 py-2 border rounded-md">
              <option value="all">Tous</option>
              {processus.map(p => <option key={p.code} value={p.code}>{p.name}</option>)}
            </select>
          </div>
          <div>
            <label className="text-sm font-medium flex items-center"><Search className="w-4 h-4 mr-1" /> Rechercher</label>
            <input type="text" placeholder="Indicateur ou processus..." value={searchTerm} onChange={e => setSearchTerm(e.target.value)} className="mt-1 block w-full px-3 py-2 border rounded-md" />
          </div>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
          {[
            { label: 'Total', count: allRequiredData.length, status: 'all', color: 'bg-blue-500', icon: BarChart3 },
            { label: 'Soumis', count: allRequiredData.filter(v => v.status === 'submitted').length, status: 'submitted', color: 'bg-yellow-500', icon: Clock },
            { label: 'Validés', count: allRequiredData.filter(v => v.status === 'validated').length, status: 'validated', color: 'bg-green-500', icon: CheckCircle2 },
            { label: 'Rejetés', count: allRequiredData.filter(v => v.status === 'rejected').length, status: 'rejected', color: 'bg-red-500', icon: XCircle }
          ].map(({ label, count, status, color, icon: Icon }) => (
            <div
              key={status}
              onClick={() => {
                setSelectedStatCard(status === selectedStatCard ? null : status);
                setFilterStatus(status === 'all' ? 'submitted' : status);
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

        {/* Validation Global */}
        {allRequiredData.filter(v => v.status === 'submitted').length > 0 && (
          <div className="mb-6 flex gap-4">
            <button onClick={() => handleValidationClick('approve')} className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-md">
              <CheckCircle2 size={16} /> Valider tout
            </button>
            <button onClick={() => handleValidationClick('reject')} className="flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-md">
              <XCircle size={16} /> Rejeter tout
            </button>
          </div>
        )}

        {/* Grouped by Processus */}
        {Object.entries(grouped).map(([processusCode, indicators]) => {
          const open = expandedProcessus === processusCode;
          return (
            <div key={processusCode} className="mb-6 border rounded-lg bg-white shadow-sm">
              <div
                onClick={() => setExpandedProcessus(open ? null : processusCode)}
                className="flex items-center justify-between px-6 py-4 cursor-pointer hover:bg-gray-50"
              >
                <div className="flex items-center gap-3">
                  <Building2 className="h-5 w-5 text-blue-600" />
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
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Indicateur</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Valeur</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Unité</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Site</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Statut</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Commentaire</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
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
                          <td className="px-6 py-4 text-sm font-medium">
                            {v.value?.toLocaleString() ?? '-'}
                          </td>
                          <td className="px-6 py-4 text-sm">{v.unit || ''}</td>
                          <td className="px-6 py-4 text-sm">{v.site_name || '-'}</td>
                          <td className="px-6 py-4">
                            <span className={`px-2 py-1 text-xs rounded-full ${getStatusColor(v.status)}`}>
                              {getStatusLabel(v.status)}
                            </span>
                          </td>
                          <td className="px-6 py-4 text-sm max-w-xs">
                            {v.comment ? (
                              <div className="truncate" title={v.comment}>
                                {v.comment}
                              </div>
                            ) : '-'}
                          </td>
                          <td className="px-6 py-4 flex space-x-2">
                            {v.status === 'submitted' && (
                              <>
                                <button 
                                  onClick={() => handleValidationClick('approve', v.id)} 
                                  className="text-green-600 hover:text-green-800"
                                  title="Valider"
                                >
                                  <CheckCircle2 size={16} />
                                </button>
                                <button 
                                  onClick={() => handleValidationClick('reject', v.id)} 
                                  className="text-red-600 hover:text-red-800"
                                  title="Rejeter"
                                >
                                  <XCircle size={16} />
                                </button>
                              </>
                            )}
                            {v.comment && (
                              <MessageSquare className="text-amber-600" size={16} title={v.comment} />
                            )}
                            {v.submitted_by && (
                              <Eye className="text-blue-600" size={16} title={`Soumis par: ${v.submitted_by}`} />
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
              Contactez votre administrateur pour vous assigner des processus à valider.
            </p>
          </div>
        )}

        {/* Modal validation */}
        {showCommentModal && (
          <div className="fixed inset-0 z-50 bg-black/50 flex items-center justify-center">
            <div className="bg-white max-w-lg w-full rounded-lg shadow-xl p-6">
              <h3 className="text-lg font-medium mb-4">
                {selectedValueId 
                  ? `${validationAction === 'approve' ? 'Valider' : 'Rejeter'} l'indicateur`
                  : `${validationAction === 'approve' ? 'Valider' : 'Rejeter'} toutes les données`}
              </h3>
              <textarea
                value={validationComment}
                onChange={(e) => setValidationComment(e.target.value)}
                rows={3}
                className="w-full border rounded p-2"
                placeholder={`Commentaire ${validationAction === 'reject' ? '(obligatoire)' : '(optionnel)'}`}
              />
              <div className="flex justify-end mt-4 space-x-2">
                <button onClick={() => {
                  setShowCommentModal(false);
                  setSelectedValueId(null);
                  setValidationComment('');
                }} className="px-4 py-2 border rounded">Annuler</button>
                <button 
                  onClick={handleValidate} 
                  disabled={validationAction === 'reject' && !validationComment.trim()}
                  className={`px-4 py-2 rounded text-white disabled:opacity-50 ${validationAction === 'approve' ? 'bg-green-600' : 'bg-red-600'}`}
                >
                  {validationAction === 'approve' ? 'Valider' : 'Rejeter'}
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};