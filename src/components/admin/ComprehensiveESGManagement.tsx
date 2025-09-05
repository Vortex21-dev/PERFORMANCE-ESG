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
  RefreshCw,
  FileText,
  Grid3X3,
  Layers
} from 'lucide-react';
import toast from 'react-hot-toast';

interface Organization {
  name: string;
  description?: string;
  city: string;
  country: string;
  organization_type: 'simple' | 'with_subsidiaries' | 'group';
}

interface ESGElement {
  code: string;
  name: string;
  description?: string;
  unit?: string;
  type?: string;
  axe?: string;
  formule?: string;
  frequence?: string;
}

interface OrganizationESGData {
  organization_name: string;
  sectors: ESGElement[];
  standards: ESGElement[];
  issues: ESGElement[];
  criteria: ESGElement[];
  indicators: ESGElement[];
  processes: ESGElement[];
}

type ESGElementType = 'sectors' | 'standards' | 'issues' | 'criteria' | 'indicators' | 'processes';

interface AssignmentData {
  organization_name: string;
  element_type: ESGElementType;
  element_codes: string[];
}

export const ComprehensiveESGManagement: React.FC = () => {
  const { profile } = useAuthStore();
  const [organizations, setOrganizations] = useState<Organization[]>([]);
  const [organizationESGData, setOrganizationESGData] = useState<Record<string, OrganizationESGData>>({});
  const [allESGElements, setAllESGElements] = useState<Record<ESGElementType, ESGElement[]>>({
    sectors: [],
    standards: [],
    issues: [],
    criteria: [],
    indicators: [],
    processes: []
  });
  
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedOrganization, setSelectedOrganization] = useState<string | null>(null);
  const [selectedElementType, setSelectedElementType] = useState<ESGElementType>('sectors');
  const [showAssignModal, setShowAssignModal] = useState(false);
  const [showModifyModal, setShowModifyModal] = useState(false);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [expandedOrg, setExpandedOrg] = useState<string | null>(null);
  
  const [assignmentData, setAssignmentData] = useState<AssignmentData>({
    organization_name: '',
    element_type: 'sectors',
    element_codes: []
  });
  
  const [bulkSelection, setBulkSelection] = useState<string[]>([]);
  const [bulkElementType, setBulkElementType] = useState<ESGElementType>('sectors');
  const [bulkElementCodes, setBulkElementCodes] = useState<string[]>([]);
  const [searchTerms, setSearchTerms] = useState<Record<ESGElementType, string>>({
    sectors: '',
    standards: '',
    issues: '',
    criteria: '',
    indicators: '',
    processes: ''
  });
  const [sectorAssignments, setSectorAssignments] = useState<any[]>([]);
  const [sectors, setSectors] = useState<any[]>([]);
  const [subsectors, setSubsectors] = useState<any[]>([]);

  // Vérifier les permissions
  const isSystemAdmin = profile?.role === 'admin';

  const elementTypeConfig = {
    sectors: {
      label: 'Secteurs',
      icon: Building2,
      color: 'text-blue-600',
      bgColor: 'bg-blue-50',
      table: 'organization_sectors',
      codeField: 'sector_name',
      sourceTable: 'sectors'
    },
    standards: {
      label: 'Normes',
      icon: Award,
      color: 'text-purple-600',
      bgColor: 'bg-purple-50',
      table: 'organization_standards',
      codeField: 'standard_codes',
      sourceTable: 'standards'
    },
    issues: {
      label: 'Enjeux',
      icon: Target,
      color: 'text-green-600',
      bgColor: 'bg-green-50',
      table: 'organization_issues',
      codeField: 'issue_codes',
      sourceTable: 'issues'
    },
    criteria: {
      label: 'Critères',
      icon: CheckCircle,
      color: 'text-amber-600',
      bgColor: 'bg-amber-50',
      table: 'organization_criteria',
      codeField: 'criteria_codes',
      sourceTable: 'criteria'
    },
    indicators: {
      label: 'Indicateurs',
      icon: BarChart3,
      color: 'text-cyan-600',
      bgColor: 'bg-cyan-50',
      table: 'organization_indicators',
      codeField: 'indicator_codes',
      sourceTable: 'indicators'
    },
    processes: {
      label: 'Processus',
      icon: Settings,
      color: 'text-indigo-600',
      bgColor: 'bg-indigo-50',
      table: 'processes',
      codeField: 'indicator_codes',
      sourceTable: 'processes'
    }
  };

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
        fetchAllESGElements(),
        fetchOrganizationESGData(),
        fetchSectors(),
        fetchSubsectors(),
        fetchSectorAssignments()
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

  const fetchAllESGElements = async () => {
    try {
      const [sectors, standards, issues, criteria, indicators, processes] = await Promise.all([
        supabase.from('sectors').select('code:name, name').order('name'),
        supabase.from('standards').select('*').order('name'),
        supabase.from('issues').select('*').order('name'),
        supabase.from('criteria').select('*').order('name'),
        supabase.from('indicators').select('*').order('name'),
        supabase.from('processes').select('*').order('name')
      ]);

      setAllESGElements({
        sectors: sectors.data || [],
        standards: standards.data || [],
        issues: issues.data || [],
        criteria: criteria.data || [],
        indicators: indicators.data || [],
        processes: processes.data || []
      });
    } catch (error) {
      console.error('Error fetching ESG elements:', error);
    }
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
          .select('*')
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
          .select('*')
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
          .select('*')
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
          .select('*')
          .in('code', indicatorCodes);
        
        // Fetch processes
        const { data: processes } = await supabase
          .from('processes')
          .select('*')
          .eq('organization_name', orgName);
        
        // Fetch sector assignment
        const { data: sectorData } = await supabase
          .from('organization_sectors')
          .select('sector_name, subsector_name')
          .eq('organization_name', orgName)
          .maybeSingle();
        
        esgData[orgName] = {
          organization_name: orgName,
          sectors: sectorData ? [{ 
            code: sectorData.sector_name, 
            name: sectorData.subsector_name || sectorData.sector_name 
          }] : [],
          standards: standards || [],
          issues: issues || [],
          criteria: criteria || [],
          indicators: indicators || [],
          processes: processes || []
        };
      }
      
      setOrganizationESGData(esgData);
    } catch (error) {
      console.error('Error fetching ESG data:', error);
    }
  };

  const handleAssignElements = async () => {
    if (!assignmentData.organization_name || !assignmentData.element_codes.length) {
      toast.error('Veuillez sélectionner une organisation et des éléments');
      return;
    }

    try {
      const config = elementTypeConfig[assignmentData.element_type];
      
      if (assignmentData.element_type === 'sectors') {
        // For sectors, update organization_sectors table
        const sectorName = assignmentData.element_codes[0];
        const subsectorName = assignmentData.element_codes[1] || null;
        
        const { error } = await supabase
          .from('organization_sectors')
          .upsert({
            organization_name: assignmentData.organization_name,
            sector_name: sectorName,
            subsector_name: subsectorName
          });
        
        if (error) throw error;
      } else if (assignmentData.element_type === 'processes') {
        // For processes, we need to update the organization_name field
        const { error } = await supabase
          .from('processes')
          .update({ organization_name: assignmentData.organization_name })
          .in('code', assignmentData.element_codes);
        
        if (error) throw error;
      } else {
        // For other elements, update the organization_* table
        const { error } = await supabase
          .from(config.table)
          .upsert({
            organization_name: assignmentData.organization_name,
            [config.codeField]: assignmentData.element_codes
          });

        if (error) throw error;
      }

      toast.success(`${config.label} assigné(s) avec succès`);
      setShowAssignModal(false);
      setAssignmentData({ organization_name: '', element_type: 'sectors', element_codes: [] });
      fetchOrganizationESGData();
      if (assignmentData.element_type === 'sectors') {
        fetchSectorAssignments();
      }
    } catch (error) {
      console.error('Error assigning elements:', error);
      toast.error('Erreur lors de l\'assignation');
    }
  };

  const handleModifyElements = async () => {
    if (!selectedOrganization || !assignmentData.element_codes.length) {
      toast.error('Données incomplètes pour la modification');
      return;
    }

    try {
      const config = elementTypeConfig[assignmentData.element_type];
      
      if (assignmentData.element_type === 'sectors') {
        // For sectors, update organization_sectors table
        const sectorName = assignmentData.element_codes[0];
        const subsectorName = assignmentData.element_codes[1] || null;
        
        const { error } = await supabase
          .from('organization_sectors')
          .update({
            sector_name: sectorName,
            subsector_name: subsectorName
          })
          .eq('organization_name', selectedOrganization);
        
        if (error) throw error;
      } else if (assignmentData.element_type === 'processes') {
        // First, remove organization assignment from all processes of this org
        await supabase
          .from('processes')
          .update({ organization_name: 'TestFiliere' })
          .eq('organization_name', selectedOrganization);
        
        // Then assign selected processes to this organization
        const { error } = await supabase
          .from('processes')
          .update({ organization_name: selectedOrganization })
          .in('code', assignmentData.element_codes);
        
        if (error) throw error;
      } else {
        const { error } = await supabase
          .from(config.table)
          .update({
            [config.codeField]: assignmentData.element_codes
          })
          .eq('organization_name', selectedOrganization);

        if (error) throw error;
      }

      toast.success(`${config.label} modifié(s) avec succès`);
      setShowModifyModal(false);
      setSelectedOrganization(null);
      fetchOrganizationESGData();
      if (assignmentData.element_type === 'sectors') {
        fetchSectorAssignments();
      }
    } catch (error) {
      console.error('Error modifying elements:', error);
      toast.error('Erreur lors de la modification');
    }
  };

  const handleDeleteElements = async () => {
    if (!selectedOrganization) return;

    try {
      const config = elementTypeConfig[selectedElementType];
      
      if (selectedElementType === 'sectors') {
        // For sectors, delete from organization_sectors table
        const { error } = await supabase
          .from('organization_sectors')
          .delete()
          .eq('organization_name', selectedOrganization);
        
        if (error) throw error;
      } else if (selectedElementType === 'processes') {
        // Reset processes to default organization
        const { error } = await supabase
          .from('processes')
          .update({ organization_name: 'TestFiliere' })
          .eq('organization_name', selectedOrganization);
        
        if (error) throw error;
      } else {
        const { error } = await supabase
          .from(config.table)
          .delete()
          .eq('organization_name', selectedOrganization);

        if (error) throw error;
      }

      toast.success(`${config.label} supprimé(s) avec succès`);
      setShowDeleteModal(false);
      setSelectedOrganization(null);
      fetchOrganizationESGData();
      if (selectedElementType === 'sectors') {
        fetchSectorAssignments();
      }
    } catch (error) {
      console.error('Error deleting elements:', error);
      toast.error('Erreur lors de la suppression');
    }
  };

  const handleBulkAssign = async () => {
    if (bulkSelection.length === 0 || bulkElementCodes.length === 0) {
      toast.error('Veuillez sélectionner des organisations et des éléments');
      return;
    }

    try {
      const config = elementTypeConfig[bulkElementType];
      
      if (bulkElementType === 'sectors') {
        // For sectors, update organization_sectors for each selected organization
        const sectorName = bulkElementCodes[0];
        const subsectorName = bulkElementCodes[1] || null;
        
        for (const orgName of bulkSelection) {
          const { error } = await supabase
            .from('organization_sectors')
            .upsert({
              organization_name: orgName,
              sector_name: sectorName,
              subsector_name: subsectorName
            });
          
          if (error) throw error;
        }
      } else if (bulkElementType === 'processes') {
        // For processes, update organization_name for selected processes
        for (const orgName of bulkSelection) {
          const { error } = await supabase
            .from('processes')
            .update({ organization_name: orgName })
            .in('code', bulkElementCodes);
          
          if (error) throw error;
        }
      } else {
        // For other elements, upsert organization_* records
        const assignments = bulkSelection.map(orgName => ({
          organization_name: orgName,
          [config.codeField]: bulkElementCodes
        }));

        const { error } = await supabase
          .from(config.table)
          .upsert(assignments);

        if (error) throw error;
      }

      toast.success(`${config.label} assigné(s) à ${bulkSelection.length} organisation(s)`);
      setBulkSelection([]);
      setBulkElementCodes([]);
      fetchOrganizationESGData();
      if (bulkElementType === 'sectors') {
        fetchSectorAssignments();
      }
    } catch (error) {
      console.error('Error bulk assigning elements:', error);
      toast.error('Erreur lors de l\'assignation en masse');
    }
  };

  const getOrganizationElements = (orgName: string, elementType: ESGElementType) => {
    const data = organizationESGData[orgName];
    if (!data) return [];
    
    if (elementType === 'sectors') {
      const assignment = sectorAssignments.find(sa => sa.organization_name === orgName);
      return assignment ? [{
        code: assignment.sector_name,
        name: assignment.subsector_name || assignment.sector_name,
        description: assignment.subsector_name ? `${assignment.sector_name} > ${assignment.subsector_name}` : assignment.sector_name
      }] : [];
    }
    
    return data[elementType] || [];
  };

  const getESGElementsCount = (orgName: string) => {
    const data = organizationESGData[orgName];
    if (!data) return 0;
    const sectorCount = getOrganizationElements(orgName, 'sectors').length;
    return sectorCount + data.standards.length + data.issues.length + data.criteria.length + 
           data.indicators.length + data.processes.length;
  };

  const getFilteredElements = (elementType: ESGElementType) => {
    const searchTerm = searchTerms[elementType].toLowerCase();
    if (!searchTerm) return allESGElements[elementType];
    
    if (elementType === 'sectors') {
      return [...sectors, ...subsectors].filter(element =>
        element.name.toLowerCase().includes(searchTerm)
      ).map(element => ({
        code: element.name,
        name: element.name,
        description: element.sector_name ? `${element.sector_name} > ${element.name}` : undefined
      }));
    }
    
    return allESGElements[elementType].filter(element =>
      element.name.toLowerCase().includes(searchTerm) ||
      (element.description && element.description.toLowerCase().includes(searchTerm))
    );
  };

  const filteredOrganizations = organizations.filter(org =>
    org.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    org.city.toLowerCase().includes(searchTerm.toLowerCase()) ||
    org.country.toLowerCase().includes(searchTerm.toLowerCase())
  );

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
              <Grid3X3 className="h-6 w-6 text-white" />
            </div>
            <div>
              <h2 className="text-2xl font-semibold text-gray-900">Gestion Complète ESG</h2>
              <p className="text-gray-600">Assignation et gestion des éléments ESG pour les organisations</p>
            </div>
          </div>
          
          <div className="flex items-center gap-3">
            <button
              onClick={() => setShowAssignModal(true)}
              className="flex items-center px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
            >
              <Plus className="h-4 w-4 mr-2" />
              Assigner des éléments
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

        {/* Search and Bulk Operations */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
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
              value={bulkElementType}
              onChange={(e) => setBulkElementType(e.target.value as ESGElementType)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            >
              {Object.entries(elementTypeConfig).map(([key, config]) => (
                <option key={key} value={key}>{config.label}</option>
              ))}
            </select>
          </div>
          
          <div>
            <select
              multiple
              value={bulkElementCodes}
              onChange={(e) => setBulkElementCodes(Array.from(e.target.selectedOptions, option => option.value))}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 h-20"
            >
              {/* Search input for bulk operations */}
              <div className="mb-2">
                <input
                  type="text"
                  placeholder={`Rechercher...`}
                  value={searchTerms[bulkElementType]}
                  onChange={(e) => setSearchTerms(prev => ({
                    ...prev,
                    [bulkElementType]: e.target.value
                  }))}
                  className="w-full px-2 py-1 border border-gray-300 rounded text-sm"
                />
              </div>
              {getFilteredElements(bulkElementType).map(element => (
                <option key={element.code} value={element.code}>{element.name}</option>
              ))}
            </select>
          </div>
          
          <div>
            <button
              onClick={handleBulkAssign}
              disabled={bulkSelection.length === 0 || bulkElementCodes.length === 0}
              className="w-full px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              Assigner à {bulkSelection.length} org(s)
            </button>
          </div>
        </div>
        
        <div className="text-xs text-gray-500 mt-1">
          {getFilteredElements(bulkElementType).length} élément(s) disponible(s)
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
                        <span className="px-3 py-1 bg-gray-100 text-gray-600 rounded-full text-sm">
                          {elementsCount} éléments ESG
                        </span>
                        {(() => {
                          const assignment = sectorAssignments.find(sa => sa.organization_name === org.name);
                          return assignment ? (
                            <span className="px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm font-medium">
                              {assignment.subsector_name || assignment.sector_name}
                            </span>
                          ) : (
                            <span className="px-3 py-1 bg-gray-100 text-gray-600 rounded-full text-sm">
                              Aucun secteur
                            </span>
                          );
                        })()}
                      </div>
                      
                      <div className="flex items-center gap-4 text-sm text-gray-600">
                        <span>{org.city}, {org.country}</span>
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
                    
                    <button
                      onClick={() => {
                        setSelectedOrganization(org.name);
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
                      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-6 gap-4">
                        {Object.entries(elementTypeConfig).map(([type, config]) => {
                          const elements = getOrganizationElements(org.name, type as ESGElementType);
                          const Icon = config.icon;
                          
                          return (
                            <div key={type} className={`${config.bgColor} rounded-lg p-3`}>
                              <div className="flex items-center gap-2 mb-2">
                                <Icon className={`h-4 w-4 ${config.color}`} />
                                <span className={`font-medium ${config.color.replace('text-', 'text-')}`}>
                                  {config.label}
                                </span>
                              </div>
                              <p className={`text-2xl font-bold ${config.color}`}>{elements.length}</p>
                              <div className="mt-2 space-y-1 max-h-20 overflow-y-auto">
                                {elements.slice(0, 3).map((element, index) => (
                                  <div key={index} className={`text-xs ${config.color.replace('600', '700')} bg-white/50 px-2 py-1 rounded`}>
                                    {element.name}
                                  </div>
                                ))}
                                {elements.length > 3 && (
                                  <div className={`text-xs ${config.color}`}>+{elements.length - 3} autres</div>
                                )}
                              </div>
                            </div>
                          );
                        })}
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>
              </div>
            );
          })}
        </div>
      </div>

      {/* Assign Elements Modal */}
      {showAssignModal && (
        <div className="fixed inset-0 z-50 overflow-y-auto">
          <div className="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center">
            <div className="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" onClick={() => setShowAssignModal(false)} />
            <div className="inline-block align-middle bg-white rounded-xl text-left overflow-hidden shadow-xl transform transition-all my-8 max-w-2xl w-full">
              <div className="bg-white px-6 pt-6 pb-4">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Assigner des éléments ESG</h3>
                
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
                    <label className="block text-sm font-medium text-gray-700 mb-1">Type d'élément</label>
                    <select
                      value={assignmentData.element_type}
                      onChange={(e) => {
                        setAssignmentData({ 
                          ...assignmentData, 
                          element_type: e.target.value as ESGElementType,
                          element_codes: []
                        });
                      }}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    >
                      {Object.entries(elementTypeConfig).map(([key, config]) => (
                        <option key={key} value={key}>{config.label}</option>
                      ))}
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      {elementTypeConfig[assignmentData.element_type].label} à assigner
                    </label>
                    
                    {/* Search input */}
                    <div className="mb-3">
                      <input
                        type="text"
                        placeholder={`Rechercher dans ${elementTypeConfig[assignmentData.element_type].label.toLowerCase()}...`}
                        value={searchTerms[assignmentData.element_type]}
                        onChange={(e) => setSearchTerms(prev => ({
                          ...prev,
                          [assignmentData.element_type]: e.target.value
                        }))}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm"
                      />
                    </div>
                    
                    <div className="max-h-48 overflow-y-auto border border-gray-300 rounded-lg p-3">
                      {assignmentData.element_type === 'sectors' ? (
                        // Special handling for sectors
                        <>
                          {getFilteredElements('sectors').map(element => (
                            <label key={element.code} className="flex items-center space-x-3 py-2">
                              <input
                                type="radio"
                                name="sector"
                                checked={assignmentData.element_codes.includes(element.code)}
                                onChange={(e) => {
                                  if (e.target.checked) {
                                    setAssignmentData({
                                      ...assignmentData,
                                      element_codes: [element.code]
                                    });
                                  }
                                }}
                                className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                              />
                              <div>
                                <span className="text-sm font-medium text-gray-700">{element.name}</span>
                                {element.description && (
                                  <p className="text-xs text-gray-500">{element.description}</p>
                                )}
                              </div>
                            </label>
                          ))}
                        </>
                      ) : (
                        // Standard handling for other elements
                        getFilteredElements(assignmentData.element_type).map(element => (
                        <label key={element.code} className="flex items-center space-x-3 py-2">
                          <input
                            type="checkbox"
                            checked={assignmentData.element_codes.includes(element.code)}
                            onChange={(e) => {
                              if (e.target.checked) {
                                setAssignmentData({
                                  ...assignmentData,
                                  element_codes: [...assignmentData.element_codes, element.code]
                                });
                              } else {
                                setAssignmentData({
                                  ...assignmentData,
                                  element_codes: assignmentData.element_codes.filter(code => code !== element.code)
                                });
                              }
                            }}
                            className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                          />
                          <div>
                            <span className="text-sm font-medium text-gray-700">{element.name}</span>
                            {element.description && (
                              <p className="text-xs text-gray-500">{element.description}</p>
                            )}
                          </div>
                        </label>
                        ))
                      )}
                    </div>
                  </div>
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
                  onClick={handleAssignElements}
                  className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
                >
                  Assigner
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Modify Elements Modal */}
      {showModifyModal && selectedOrganization && (
        <div className="fixed inset-0 z-50 overflow-y-auto">
          <div className="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center">
            <div className="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" onClick={() => setShowModifyModal(false)} />
            <div className="inline-block align-middle bg-white rounded-xl text-left overflow-hidden shadow-xl transform transition-all my-8 max-w-2xl w-full">
              <div className="bg-white px-6 pt-6 pb-4">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">
                  Modifier les éléments ESG - {selectedOrganization}
                </h3>
                
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Type d'élément</label>
                    <select
                      value={assignmentData.element_type}
                      onChange={(e) => {
                        const elementType = e.target.value as ESGElementType;
                        const currentElements = getOrganizationElements(selectedOrganization, elementType);
                        setAssignmentData({ 
                          ...assignmentData, 
                          element_type: elementType,
                          element_codes: currentElements.map(el => el.code)
                        });
                      }}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    >
                      {Object.entries(elementTypeConfig).map(([key, config]) => (
                        <option key={key} value={key}>{config.label}</option>
                      ))}
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      {elementTypeConfig[assignmentData.element_type].label} assignés
                    </label>
                    
                    {/* Search input */}
                    <div className="mb-3">
                      <input
                        type="text"
                        placeholder={`Rechercher dans ${elementTypeConfig[assignmentData.element_type].label.toLowerCase()}...`}
                        value={searchTerms[assignmentData.element_type]}
                        onChange={(e) => setSearchTerms(prev => ({
                          ...prev,
                          [assignmentData.element_type]: e.target.value
                        }))}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm"
                      />
                    </div>
                    
                    <div className="max-h-48 overflow-y-auto border border-gray-300 rounded-lg p-3">
                      {assignmentData.element_type === 'sectors' ? (
                        // Special handling for sectors
                        getFilteredElements('sectors').map(element => (
                          <label key={element.code} className="flex items-center space-x-3 py-2">
                            <input
                              type="radio"
                              name="sector-modify"
                              checked={assignmentData.element_codes.includes(element.code)}
                              onChange={(e) => {
                                if (e.target.checked) {
                                  setAssignmentData({
                                    ...assignmentData,
                                    element_codes: [element.code]
                                  });
                                }
                              }}
                              className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                            />
                            <div>
                              <span className="text-sm font-medium text-gray-700">{element.name}</span>
                              {element.description && (
                                <p className="text-xs text-gray-500">{element.description}</p>
                              )}
                            </div>
                          </label>
                        ))
                      ) : (
                        // Standard handling for other elements
                        getFilteredElements(assignmentData.element_type).map(element => (
                        <label key={element.code} className="flex items-center space-x-3 py-2">
                          <input
                            type="checkbox"
                            checked={assignmentData.element_codes.includes(element.code)}
                            onChange={(e) => {
                              if (e.target.checked) {
                                setAssignmentData({
                                  ...assignmentData,
                                  element_codes: [...assignmentData.element_codes, element.code]
                                });
                              } else {
                                setAssignmentData({
                                  ...assignmentData,
                                  element_codes: assignmentData.element_codes.filter(code => code !== element.code)
                                });
                              }
                            }}
                            className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                          />
                          <div>
                            <span className="text-sm font-medium text-gray-700">{element.name}</span>
                            {element.description && (
                              <p className="text-xs text-gray-500">{element.description}</p>
                            )}
                          </div>
                        </label>
                        ))
                      )}
                    </div>
                  </div>
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
                  onClick={handleModifyElements}
                  className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                >
                  Modifier
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Delete Elements Modal */}
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
                
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Type d'élément à supprimer</label>
                    <select
                      value={selectedElementType}
                      onChange={(e) => setSelectedElementType(e.target.value as ESGElementType)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    >
                      {Object.entries(elementTypeConfig).map(([key, config]) => (
                        <option key={key} value={key}>{config.label}</option>
                      ))}
                    </select>
                  </div>
                  
                  <p className="text-gray-700">
                    Êtes-vous sûr de vouloir supprimer tous les <strong>{elementTypeConfig[selectedElementType].label.toLowerCase()}</strong> de <strong>{selectedOrganization}</strong> ?
                  </p>
                  
                  <div className="bg-amber-50 border border-amber-200 rounded-lg p-3">
                    <p className="text-sm text-amber-800">
                      <strong>Attention :</strong> Cette action supprimera l'assignation des {elementTypeConfig[selectedElementType].label.toLowerCase()} mais conservera les éléments dans le système.
                    </p>
                  </div>
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
                  onClick={handleDeleteElements}
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