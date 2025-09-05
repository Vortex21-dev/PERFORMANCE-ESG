import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useAuthStore } from '../../store/authStore';
import { supabase } from '../../lib/supabase';
import {
  Building2,
  Search,
  Filter,
  Plus,
  Edit3,
  Trash2,
  Save,
  X,
  AlertTriangle,
  CheckCircle,
  Users,
  Target,
  BarChart3,
  Settings,
  Award,
  ChevronDown,
  ChevronUp,
  ArrowRight,
  Loader2,
  RefreshCw
} from 'lucide-react';
import toast from 'react-hot-toast';

interface Organization {
  name: string;
  description?: string;
  city: string;
  country: string;
  organization_type: 'simple' | 'with_subsidiaries' | 'group';
}

interface SectorAssignment {
  organization_name: string;
  sector_name?: string;
  subsector_name?: string;
}

interface OrganizationESGData {
  organization_name: string;
  standards: string[];
  issues: string[];
  criteria: string[];
  indicators: string[];
  processes: string[];
}

interface Sector {
  name: string;
  created_at: string;
}

interface Subsector {
  name: string;
  sector_name: string;
  created_at: string;
}

export const SectorManagement: React.FC = () => {
  const { profile } = useAuthStore();
  const [organizations, setOrganizations] = useState<Organization[]>([]);
  const [sectors, setSectors] = useState<Sector[]>([]);
  const [subsectors, setSubsectors] = useState<Subsector[]>([]);
  const [sectorAssignments, setSectorAssignments] = useState<SectorAssignment[]>([]);
  const [organizationESGData, setOrganizationESGData] = useState<Record<string, OrganizationESGData>>({});
  
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedOrganization, setSelectedOrganization] = useState<string | null>(null);
  const [showAssignModal, setShowAssignModal] = useState(false);
  const [showModifyModal, setShowModifyModal] = useState(false);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [expandedOrg, setExpandedOrg] = useState<string | null>(null);
  
  const [assignmentData, setAssignmentData] = useState({
    organization_name: '',
    sector_name: '',
    subsector_name: ''
  });
  
  const [bulkSelection, setBulkSelection] = useState<string[]>([]);
  const [bulkSector, setBulkSector] = useState('');
  const [bulkSubsector, setBulkSubsector] = useState('');

  // Vérifier les permissions
  const isSystemAdmin = profile?.role === 'admin';

  useEffect(() => {
    if (!isSystemAdmin) {
      toast.error('Accès refusé - Administrateurs système uniquement');
      return;
    }
    fetchAllData();
  }, [isSystemAdmin]);

  const fetchAllData = async () => {
    try {
      setLoading(true);
      await Promise.all([
        fetchOrganizations(),
        fetchSectors(),
        fetchSubsectors(),
        fetchSectorAssignments(),
        fetchOrganizationESGData()
      ]);
    } catch (error) {
      console.error('Error fetching data:', error);
      toast.error('Erreur lors du chargement des données');
    } finally {
      setLoading(false);
    }
  };

  const fetchOrganizations = async () => {
    const { data, error } = await supabase
      .from('organizations')
      .select('*')
      .order('name');
    
    if (error) throw error;
    setOrganizations(data || []);
  };

  const fetchSectors = async () => {
    const { data, error } = await supabase
      .from('sectors')
      .select('*')
      .order('name');
    
    if (error) throw error;
    setSectors(data || []);
  };

  const fetchSubsectors = async () => {
    const { data, error } = await supabase
      .from('subsectors')
      .select('*')
      .order('name');
    
    if (error) throw error;
    setSubsectors(data || []);
  };

  const fetchSectorAssignments = async () => {
    const { data, error } = await supabase
      .from('organization_sectors')
      .select('*');
    
    if (error) throw error;
    setSectorAssignments(data || []);
  };

  const fetchOrganizationESGData = async () => {
    try {
      const { data: orgs } = await supabase.from('organizations').select('name');
      const orgNames = orgs?.map(o => o.name) || [];
      
      const esgData: Record<string, OrganizationESGData> = {};
      
      for (const orgName of orgNames) {
        // Fetch standards
        const { data: standardsData } = await supabase
          .from('organization_standards')
          .select('standard_codes')
          .eq('organization_name', orgName)
          .maybeSingle();
        
        const standardCodes = standardsData?.standard_codes || [];
        const { data: standards } = await supabase
          .from('standards')
          .select('name')
          .in('code', standardCodes);
        
        // Fetch issues
        const { data: issuesData } = await supabase
          .from('organization_issues')
          .select('issue_codes')
          .eq('organization_name', orgName)
          .maybeSingle();
        
        const issueCodes = issuesData?.issue_codes || [];
        const { data: issues } = await supabase
          .from('issues')
          .select('name')
          .in('code', issueCodes);
        
        // Fetch criteria
        const { data: criteriaData } = await supabase
          .from('organization_criteria')
          .select('criteria_codes')
          .eq('organization_name', orgName)
          .maybeSingle();
        
        const criteriaCodes = criteriaData?.criteria_codes || [];
        const { data: criteria } = await supabase
          .from('criteria')
          .select('name')
          .in('code', criteriaCodes);
        
        // Fetch indicators
        const { data: indicatorsData } = await supabase
          .from('organization_indicators')
          .select('indicator_codes')
          .eq('organization_name', orgName)
          .maybeSingle();
        
        const indicatorCodes = indicatorsData?.indicator_codes || [];
        const { data: indicators } = await supabase
          .from('indicators')
          .select('name')
          .in('code', indicatorCodes);
        
        // Fetch processes
        const { data: processes } = await supabase
          .from('processes')
          .select('name')
          .eq('organization_name', orgName);
        
        esgData[orgName] = {
          organization_name: orgName,
          standards: standards?.map(s => s.name) || [],
          issues: issues?.map(i => i.name) || [],
          criteria: criteria?.map(c => c.name) || [],
          indicators: indicators?.map(i => i.name) || [],
          processes: processes?.map(p => p.name) || []
        };
      }
      
      setOrganizationESGData(esgData);
    } catch (error) {
      console.error('Error fetching ESG data:', error);
    }
  };

  const handleAssignSector = async () => {
    if (!assignmentData.organization_name || !assignmentData.sector_name) {
      toast.error('Veuillez sélectionner une organisation et un secteur');
      return;
    }

    try {
      const { error } = await supabase
        .from('organization_sectors')
        .upsert({
          organization_name: assignmentData.organization_name,
          sector_name: assignmentData.sector_name,
          subsector_name: assignmentData.subsector_name || null
        });

      if (error) throw error;

      toast.success('Secteur assigné avec succès');
      setShowAssignModal(false);
      setAssignmentData({ organization_name: '', sector_name: '', subsector_name: '' });
      fetchSectorAssignments();
    } catch (error) {
      console.error('Error assigning sector:', error);
      toast.error('Erreur lors de l\'assignation du secteur');
    }
  };

  const handleModifySector = async () => {
    if (!selectedOrganization || !assignmentData.sector_name) {
      toast.error('Données incomplètes pour la modification');
      return;
    }

    try {
      const { error } = await supabase
        .from('organization_sectors')
        .update({
          sector_name: assignmentData.sector_name,
          subsector_name: assignmentData.subsector_name || null
        })
        .eq('organization_name', selectedOrganization);

      if (error) throw error;

      toast.success('Secteur modifié avec succès');
      setShowModifyModal(false);
      setSelectedOrganization(null);
      fetchSectorAssignments();
    } catch (error) {
      console.error('Error modifying sector:', error);
      toast.error('Erreur lors de la modification du secteur');
    }
  };

  const handleDeleteSector = async () => {
    if (!selectedOrganization) return;

    try {
      const { error } = await supabase
        .from('organization_sectors')
        .delete()
        .eq('organization_name', selectedOrganization);

      if (error) throw error;

      toast.success('Secteur supprimé avec succès');
      setShowDeleteModal(false);
      setSelectedOrganization(null);
      fetchSectorAssignments();
    } catch (error) {
      console.error('Error deleting sector:', error);
      toast.error('Erreur lors de la suppression du secteur');
    }
  };

  const handleBulkAssign = async () => {
    if (bulkSelection.length === 0 || !bulkSector) {
      toast.error('Veuillez sélectionner des organisations et un secteur');
      return;
    }

    try {
      const assignments = bulkSelection.map(orgName => ({
        organization_name: orgName,
        sector_name: bulkSector,
        subsector_name: bulkSubsector || null
      }));

      const { error } = await supabase
        .from('organization_sectors')
        .upsert(assignments);

      if (error) throw error;

      toast.success(`Secteur assigné à ${bulkSelection.length} organisation(s)`);
      setBulkSelection([]);
      setBulkSector('');
      setBulkSubsector('');
      fetchSectorAssignments();
    } catch (error) {
      console.error('Error bulk assigning sectors:', error);
      toast.error('Erreur lors de l\'assignation en masse');
    }
  };

  const getOrganizationSector = (orgName: string) => {
    return sectorAssignments.find(sa => sa.organization_name === orgName);
  };

  const getSubsectorsForSector = (sectorName: string) => {
    return subsectors.filter(sub => sub.sector_name === sectorName);
  };

  const filteredOrganizations = organizations.filter(org =>
    org.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    org.city.toLowerCase().includes(searchTerm.toLowerCase()) ||
    org.country.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const getESGElementsCount = (orgName: string) => {
    const data = organizationESGData[orgName];
    if (!data) return 0;
    return data.standards.length + data.issues.length + data.criteria.length + 
           data.indicators.length + data.processes.length;
  };

  if (!isSystemAdmin) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <AlertTriangle className="h-12 w-12 text-red-500 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">Accès refusé</h3>
          <p className="text-gray-600">Cette fonctionnalité est réservée aux administrateurs système.</p>
        </div>
      </div>
    );
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
        <span className="ml-3 text-gray-600">Chargement des données...</span>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-3">
            <div className="p-3 rounded-lg bg-blue-500">
              <Building2 className="h-6 w-6 text-white" />
            </div>
            <div>
              <h2 className="text-2xl font-semibold text-gray-900">Gestion des Secteurs</h2>
              <p className="text-gray-600">Assignation et gestion des secteurs pour les organisations</p>
            </div>
          </div>
          
          <div className="flex items-center gap-3">
            <button
              onClick={() => setShowAssignModal(true)}
              className="flex items-center px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
            >
              <Plus className="h-4 w-4 mr-2" />
              Assigner un secteur
            </button>
            <button
              onClick={fetchAllData}
              className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
            >
              <RefreshCw className="h-4 w-4 mr-2" />
              Actualiser
            </button>
          </div>
        </div>

        {/* Search and Filters */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
            <input
              type="text"
              placeholder="Rechercher une organisation..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10 pr-4 py-2 w-full border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
          
          <div>
            <select
              value={bulkSector}
              onChange={(e) => setBulkSector(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="">Sélectionner un secteur pour assignation en masse</option>
              {sectors.map(sector => (
                <option key={sector.name} value={sector.name}>{sector.name}</option>
              ))}
            </select>
          </div>
          
          <div>
            <button
              onClick={handleBulkAssign}
              disabled={bulkSelection.length === 0 || !bulkSector}
              className="w-full px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              Assigner à {bulkSelection.length} org(s)
            </button>
          </div>
        </div>
      </div>

      {/* Organizations List */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-200 bg-gray-50">
          <h3 className="text-lg font-semibold text-gray-900">
            Organisations ({filteredOrganizations.length})
          </h3>
        </div>
        
        <div className="divide-y divide-gray-200">
          {filteredOrganizations.map((org) => {
            const assignment = getOrganizationSector(org.name);
            const esgData = organizationESGData[org.name];
            const elementsCount = getESGElementsCount(org.name);
            const isExpanded = expandedOrg === org.name;
            const isSelected = bulkSelection.includes(org.name);
            
            return (
              <div key={org.name} className="p-6 hover:bg-gray-50 transition-colors">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-4">
                    <input
                      type="checkbox"
                      checked={isSelected}
                      onChange={(e) => {
                        if (e.target.checked) {
                          setBulkSelection([...bulkSelection, org.name]);
                        } else {
                          setBulkSelection(bulkSelection.filter(name => name !== org.name));
                        }
                      }}
                      className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                    />
                    
                    <div className="flex-1">
                      <div className="flex items-center gap-3 mb-2">
                        <h4 className="text-lg font-semibold text-gray-900">{org.name}</h4>
                        <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                          org.organization_type === 'simple' ? 'bg-green-100 text-green-800' :
                          org.organization_type === 'with_subsidiaries' ? 'bg-blue-100 text-blue-800' :
                          'bg-purple-100 text-purple-800'
                        }`}>
                          {org.organization_type}
                        </span>
                        {assignment ? (
                          <span className="px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm font-medium">
                            {assignment.subsector_name || assignment.sector_name}
                          </span>
                        ) : (
                          <span className="px-3 py-1 bg-gray-100 text-gray-600 rounded-full text-sm">
                            Aucun secteur
                          </span>
                        )}
                      </div>
                      
                      <div className="flex items-center gap-4 text-sm text-gray-600">
                        <span>{org.city}, {org.country}</span>
                        <span>{elementsCount} éléments ESG</span>
                      </div>
                    </div>
                  </div>
                  
                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => setExpandedOrg(isExpanded ? null : org.name)}
                      className="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
                    >
                      {isExpanded ? <ChevronUp className="h-4 w-4" /> : <ChevronDown className="h-4 w-4" />}
                    </button>
                    
                    {assignment ? (
                      <>
                        <button
                          onClick={() => {
                            setSelectedOrganization(org.name);
                            setAssignmentData({
                              organization_name: org.name,
                              sector_name: assignment.sector_name || '',
                              subsector_name: assignment.subsector_name || ''
                            });
                            setShowModifyModal(true);
                          }}
                          className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                        >
                          <Edit3 className="h-4 w-4" />
                        </button>
                        <button
                          onClick={() => {
                            setSelectedOrganization(org.name);
                            setShowDeleteModal(true);
                          }}
                          className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                        >
                          <Trash2 className="h-4 w-4" />
                        </button>
                      </>
                    ) : (
                      <button
                        onClick={() => {
                          setAssignmentData({
                            organization_name: org.name,
                            sector_name: '',
                            subsector_name: ''
                          });
                          setShowAssignModal(true);
                        }}
                        className="p-2 text-green-600 hover:bg-green-50 rounded-lg transition-colors"
                      >
                        <Plus className="h-4 w-4" />
                      </button>
                    )}
                  </div>
                </div>

                {/* Expanded Details */}
                <AnimatePresence>
                  {isExpanded && esgData && (
                    <motion.div
                      initial={{ opacity: 0, height: 0 }}
                      animate={{ opacity: 1, height: 'auto' }}
                      exit={{ opacity: 0, height: 0 }}
                      className="mt-4 pt-4 border-t border-gray-200"
                    >
                      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
                        <div className="bg-purple-50 rounded-lg p-3">
                          <div className="flex items-center gap-2 mb-2">
                            <Award className="h-4 w-4 text-purple-600" />
                            <span className="font-medium text-purple-800">Normes</span>
                          </div>
                          <p className="text-2xl font-bold text-purple-600">{esgData.standards.length}</p>
                          <div className="mt-2 space-y-1 max-h-20 overflow-y-auto">
                            {esgData.standards.slice(0, 3).map((standard, index) => (
                              <div key={index} className="text-xs text-purple-700 bg-purple-100 px-2 py-1 rounded">
                                {standard}
                              </div>
                            ))}
                            {esgData.standards.length > 3 && (
                              <div className="text-xs text-purple-600">+{esgData.standards.length - 3} autres</div>
                            )}
                          </div>
                        </div>

                        <div className="bg-green-50 rounded-lg p-3">
                          <div className="flex items-center gap-2 mb-2">
                            <Target className="h-4 w-4 text-green-600" />
                            <span className="font-medium text-green-800">Enjeux</span>
                          </div>
                          <p className="text-2xl font-bold text-green-600">{esgData.issues.length}</p>
                          <div className="mt-2 space-y-1 max-h-20 overflow-y-auto">
                            {esgData.issues.slice(0, 3).map((issue, index) => (
                              <div key={index} className="text-xs text-green-700 bg-green-100 px-2 py-1 rounded">
                                {issue}
                              </div>
                            ))}
                            {esgData.issues.length > 3 && (
                              <div className="text-xs text-green-600">+{esgData.issues.length - 3} autres</div>
                            )}
                          </div>
                        </div>

                        <div className="bg-amber-50 rounded-lg p-3">
                          <div className="flex items-center gap-2 mb-2">
                            <CheckCircle className="h-4 w-4 text-amber-600" />
                            <span className="font-medium text-amber-800">Critères</span>
                          </div>
                          <p className="text-2xl font-bold text-amber-600">{esgData.criteria.length}</p>
                          <div className="mt-2 space-y-1 max-h-20 overflow-y-auto">
                            {esgData.criteria.slice(0, 3).map((criteria, index) => (
                              <div key={index} className="text-xs text-amber-700 bg-amber-100 px-2 py-1 rounded">
                                {criteria}
                              </div>
                            ))}
                            {esgData.criteria.length > 3 && (
                              <div className="text-xs text-amber-600">+{esgData.criteria.length - 3} autres</div>
                            )}
                          </div>
                        </div>

                        <div className="bg-cyan-50 rounded-lg p-3">
                          <div className="flex items-center gap-2 mb-2">
                            <BarChart3 className="h-4 w-4 text-cyan-600" />
                            <span className="font-medium text-cyan-800">Indicateurs</span>
                          </div>
                          <p className="text-2xl font-bold text-cyan-600">{esgData.indicators.length}</p>
                          <div className="mt-2 space-y-1 max-h-20 overflow-y-auto">
                            {esgData.indicators.slice(0, 3).map((indicator, index) => (
                              <div key={index} className="text-xs text-cyan-700 bg-cyan-100 px-2 py-1 rounded">
                                {indicator}
                              </div>
                            ))}
                            {esgData.indicators.length > 3 && (
                              <div className="text-xs text-cyan-600">+{esgData.indicators.length - 3} autres</div>
                            )}
                          </div>
                        </div>

                        <div className="bg-indigo-50 rounded-lg p-3">
                          <div className="flex items-center gap-2 mb-2">
                            <Settings className="h-4 w-4 text-indigo-600" />
                            <span className="font-medium text-indigo-800">Processus</span>
                          </div>
                          <p className="text-2xl font-bold text-indigo-600">{esgData.processes.length}</p>
                          <div className="mt-2 space-y-1 max-h-20 overflow-y-auto">
                            {esgData.processes.slice(0, 3).map((process, index) => (
                              <div key={index} className="text-xs text-indigo-700 bg-indigo-100 px-2 py-1 rounded">
                                {process}
                              </div>
                            ))}
                            {esgData.processes.length > 3 && (
                              <div className="text-xs text-indigo-600">+{esgData.processes.length - 3} autres</div>
                            )}
                          </div>
                        </div>
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>
              </div>
            );
          })}
        </div>
      </div>

      {/* Assign Sector Modal */}
      {showAssignModal && (
        <div className="fixed inset-0 z-50 overflow-y-auto">
          <div className="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center">
            <div className="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" onClick={() => setShowAssignModal(false)} />
            <div className="inline-block align-middle bg-white rounded-xl text-left overflow-hidden shadow-xl transform transition-all my-8 max-w-lg w-full">
              <div className="bg-white px-6 pt-6 pb-4">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Assigner un secteur</h3>
                
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Organisation</label>
                    <select
                      value={assignmentData.organization_name}
                      onChange={(e) => setAssignmentData({ ...assignmentData, organization_name: e.target.value })}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    >
                      <option value="">Sélectionner une organisation</option>
                      {organizations.map(org => (
                        <option key={org.name} value={org.name}>{org.name}</option>
                      ))}
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Secteur</label>
                    <select
                      value={assignmentData.sector_name}
                      onChange={(e) => {
                        setAssignmentData({ 
                          ...assignmentData, 
                          sector_name: e.target.value,
                          subsector_name: '' 
                        });
                      }}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    >
                      <option value="">Sélectionner un secteur</option>
                      {sectors.map(sector => (
                        <option key={sector.name} value={sector.name}>{sector.name}</option>
                      ))}
                    </select>
                  </div>
                  
                  {assignmentData.sector_name && (
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Sous-secteur (optionnel)</label>
                      <select
                        value={assignmentData.subsector_name}
                        onChange={(e) => setAssignmentData({ ...assignmentData, subsector_name: e.target.value })}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      >
                        <option value="">Aucun sous-secteur</option>
                        {getSubsectorsForSector(assignmentData.sector_name).map(subsector => (
                          <option key={subsector.name} value={subsector.name}>{subsector.name}</option>
                        ))}
                      </select>
                    </div>
                  )}
                </div>
              </div>
              
              <div className="bg-gray-50 px-6 py-4 flex justify-end gap-3">
                <button
                  onClick={() => setShowAssignModal(false)}
                  className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
                >
                  Annuler
                </button>
                <button
                  onClick={handleAssignSector}
                  className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
                >
                  Assigner
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Modify Sector Modal */}
      {showModifyModal && selectedOrganization && (
        <div className="fixed inset-0 z-50 overflow-y-auto">
          <div className="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center">
            <div className="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" onClick={() => setShowModifyModal(false)} />
            <div className="inline-block align-middle bg-white rounded-xl text-left overflow-hidden shadow-xl transform transition-all my-8 max-w-lg w-full">
              <div className="bg-white px-6 pt-6 pb-4">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">
                  Modifier le secteur - {selectedOrganization}
                </h3>
                
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Secteur</label>
                    <select
                      value={assignmentData.sector_name}
                      onChange={(e) => {
                        setAssignmentData({ 
                          ...assignmentData, 
                          sector_name: e.target.value,
                          subsector_name: '' 
                        });
                      }}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    >
                      <option value="">Sélectionner un secteur</option>
                      {sectors.map(sector => (
                        <option key={sector.name} value={sector.name}>{sector.name}</option>
                      ))}
                    </select>
                  </div>
                  
                  {assignmentData.sector_name && (
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Sous-secteur (optionnel)</label>
                      <select
                        value={assignmentData.subsector_name}
                        onChange={(e) => setAssignmentData({ ...assignmentData, subsector_name: e.target.value })}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      >
                        <option value="">Aucun sous-secteur</option>
                        {getSubsectorsForSector(assignmentData.sector_name).map(subsector => (
                          <option key={subsector.name} value={subsector.name}>{subsector.name}</option>
                        ))}
                      </select>
                    </div>
                  )}
                </div>
              </div>
              
              <div className="bg-gray-50 px-6 py-4 flex justify-end gap-3">
                <button
                  onClick={() => setShowModifyModal(false)}
                  className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
                >
                  Annuler
                </button>
                <button
                  onClick={handleModifySector}
                  className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                >
                  Modifier
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Delete Sector Modal */}
      {showDeleteModal && selectedOrganization && (
        <div className="fixed inset-0 z-50 overflow-y-auto">
          <div className="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center">
            <div className="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" onClick={() => setShowDeleteModal(false)} />
            <div className="inline-block align-middle bg-white rounded-xl text-left overflow-hidden shadow-xl transform transition-all my-8 max-w-lg w-full">
              <div className="bg-white px-6 pt-6 pb-4">
                <div className="flex items-center gap-3 mb-4">
                  <AlertTriangle className="h-6 w-6 text-red-600" />
                  <h3 className="text-lg font-semibold text-gray-900">Confirmer la suppression</h3>
                </div>
                
                <p className="text-gray-700 mb-4">
                  Êtes-vous sûr de vouloir supprimer l'assignation de secteur pour <strong>{selectedOrganization}</strong> ?
                </p>
                
                <div className="bg-amber-50 border border-amber-200 rounded-lg p-3">
                  <p className="text-sm text-amber-800">
                    <strong>Attention :</strong> Cette action supprimera l'assignation de secteur mais conservera tous les éléments ESG de l'organisation.
                  </p>
                </div>
              </div>
              
              <div className="bg-gray-50 px-6 py-4 flex justify-end gap-3">
                <button
                  onClick={() => setShowDeleteModal(false)}
                  className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
                >
                  Annuler
                </button>
                <button
                  onClick={handleDeleteSector}
                  className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
                >
                  Supprimer
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};