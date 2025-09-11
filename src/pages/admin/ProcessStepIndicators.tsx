// ProcessStepIndicators.tsx
import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAppContext } from '../../context/AppContext';
import ProgressNav from '../../components/ui/ProgressNav';
import SelectionSummary from '../../components/ui/SelectionSummary';
import AddButton from '../../components/ui/AddButton';
import AddForm from '../../components/ui/AddForm';
import SimilarityAlertModal from '../../components/ui/SimilarityAlertModal';
import { supabase } from '../../lib/supabase';
import { Indicator } from '../../types/indicators';
import { Loader, CheckSquare, Check, BarChart3 } from 'lucide-react';
import toast from 'react-hot-toast';
import { validateAdd } from '../../utils/validation';

interface SimilarityAlert {
  items: Array<{ name: string; similarity: number }>;
  itemName: string;
  onConfirm: () => void;
}

interface IndicatorWithCode extends Indicator {
  code: string;
}
const ProcessStepIndicators: React.FC = () => {
  const { 
    selectedCriteria, 
    selectedIndicators, 
    toggleIndicator, 
    setCurrentStep, 
    selectedSector, 
    selectedSubsector,
    selectedIssues,
    selectedStandards
  } = useAppContext();
  const navigate = useNavigate();
  const [indicators, setIndicators] = useState<IndicatorWithCode[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showAddForm, setShowAddForm] = useState(false);
  const [similarityAlert, setSimilarityAlert] = useState<SimilarityAlert | null>(null);
  const [indicatorsCriteriaMap, setIndicatorsCriteriaMap] = useState<{ indicator: IndicatorWithCode; criteria: string }[]>([]);
  
  useEffect(() => {
    if (!selectedCriteria.length) {
      navigate('/process/criteria');
    }
    setCurrentStep(5);
  }, [selectedCriteria, navigate, setCurrentStep]);

  useEffect(() => {
    if (selectedCriteria.length > 0 && selectedIssues.length > 0) {
      fetchIndicators();
    }
  }, [selectedCriteria, selectedIssues, selectedSector, selectedSubsector]);

  async function fetchIndicators() {
    try {
      console.log('🔍 Fetching indicators for criteria:', selectedCriteria);
      console.log('📋 Selected issues:', selectedIssues);
      console.log('🏢 Selected standards:', selectedStandards);
      console.log('🎯 Sector/Subsector:', selectedSector, selectedSubsector);

      let indicatorsWithCriteria: { indicator: IndicatorWithCode; criteria: string }[] = [];
      
      if (selectedSubsector) {
        console.log('📊 Using subsector path for indicators');
        const { data: subsectorData, error: subsectorError } = await supabase
          .from('subsector_standards_issues_criteria_indicators')
          .select('criteria_name, indicator_codes, unit')
          .eq('subsector_name', selectedSubsector)
          .in('standard_name', selectedStandards)
          .in('issue_name', selectedIssues)
          .in('criteria_name', selectedCriteria);

        if (subsectorError) throw subsectorError;
        console.log('📈 Subsector data found:', subsectorData);
        
        for (const row of subsectorData || []) {
          if (row.indicator_codes && row.indicator_codes.length > 0) {
            console.log(`🔗 Processing criteria "${row.criteria_name}" with ${row.indicator_codes.length} indicators`);
            const { data: indicators, error: indicatorError } = await supabase
              .from('indicators')
              .select('*')
              .in('code', row.indicator_codes);
            
            if (indicatorError) throw indicatorError;
            console.log('📊 Indicators fetched:', indicators);
            
            indicators?.forEach(indicator => {
              indicatorsWithCriteria.push({ indicator, criteria: row.criteria_name });
            });
          }
        }
      } else {
        console.log('📊 Using sector path for indicators');
        const { data: sectorData, error: sectorError } = await supabase
          .from('sector_standards_issues_criteria_indicators')
          .select('criteria_name, indicator_codes, unit')
          .eq('sector_name', selectedSector)
          .in('standard_name', selectedStandards)
          .in('issue_name', selectedIssues)
          .in('criteria_name', selectedCriteria);

        if (sectorError) throw sectorError;
        console.log('📈 Sector data found:', sectorData);
        
        for (const row of sectorData || []) {
          if (row.indicator_codes && row.indicator_codes.length > 0) {
            console.log(`🔗 Processing criteria "${row.criteria_name}" with ${row.indicator_codes.length} indicators`);
            const { data: indicators, error: indicatorError } = await supabase
              .from('indicators')
              .select('*')
              .in('code', row.indicator_codes);
            
            if (indicatorError) throw indicatorError;
            console.log('📊 Indicators fetched:', indicators);
            
            indicators?.forEach(indicator => {
              indicatorsWithCriteria.push({ indicator, criteria: row.criteria_name });
            });
          }
        }
      }

      console.log('🎯 Total indicators with criteria mapped:', indicatorsWithCriteria.length);
      setIndicators(indicatorsWithCriteria.map(item => item.indicator));
      setIndicatorsCriteriaMap(indicatorsWithCriteria);
      setError(null);
    } catch (err) {
      console.error('❌ Error fetching indicators:', err);
      setError('Erreur lors du chargement des indicateurs');
      console.error('Error:', err);
    } finally {
      setLoading(false);
    }
  }

  const onSubmit = async (data: {
    name: string;
    parentId?: string;
    unit?: string;
    type: 'primaire' | 'calculé';
    axe: 'Environnement' | 'Social' | 'Gouvernance';
    formule: 'somme' | 'dernier_mois' | 'moyenne' | 'max' | 'min';
    frequence: 'mensuelle' | 'trimestrielle' | 'annuelle';
  }) => {
    try {
      const isValid = await validateAdd('indicator', data.name, undefined, async (items, itemName) => {
        return new Promise((resolve) => {
          setSimilarityAlert({
            items,
            itemName,
            onConfirm: () => {
              setSimilarityAlert(null);
              resolve(true);
            }
          });
        });
      });

      if (!isValid) return;

      const [criteriaName, standardName] = data.parentId!.split('|');
      const indicatorCode = data.name.replace(/\s+/g, '').toUpperCase();

      const { data: existingIndicator } = await supabase
        .from('indicators')
        .select('code')
        .eq('code', indicatorCode)
        .maybeSingle();

      if (!existingIndicator) {
        await supabase.from('indicators').insert({
          code: indicatorCode,
          name: data.name,
          unit: data.unit,
          type: data.type,
          axe: data.axe,
          formule: data.formule,
          frequence: data.frequence
        });
      }

      const table = selectedSubsector
        ? 'subsector_standards_issues_criteria_indicators'
        : 'sector_standards_issues_criteria_indicators';

      const query = {
        ...(selectedSubsector ? { subsector_name: selectedSubsector } : { sector_name: selectedSector }),
        standard_name: standardName,
        issue_name: selectedIssues[0],
        criteria_name: criteriaName
      };

      const { data: currentData } = await supabase
        .from(table)
        .select('indicator_codes')
        .match(query)
        .maybeSingle();

      const existingCodes = currentData?.indicator_codes || [];
      if (!existingCodes.includes(indicatorCode)) {
        const updatedCodes = [...existingCodes, indicatorCode];
        if (currentData) {
          await supabase.from(table).update({ indicator_codes: updatedCodes }).match(query);
        } else {
          await supabase.from(table).insert({ ...query, indicator_codes: [indicatorCode], unit: data.unit });
        }
      }

      toast.success('Indicateur ajouté avec succès');
      setShowAddForm(false);
      fetchIndicators();
    } catch (err) {
      toast.error('Erreur lors de l\'ajout de l\'indicateur');
      console.error('Error:', err);
    }
  };

  const criteriaOptions = selectedCriteria.map(criteria => ({
    id: `${criteria}|${selectedStandards[0] || 'DEFAULT'}`,
    name: criteria
  }));

  const groupedIndicators = React.useMemo(() => {
    const groups: { [criteriaName: string]: typeof indicators } = {};
    selectedCriteria.forEach(criteria => { groups[criteria] = []; });
    
    indicatorsCriteriaMap.forEach(({ indicator, criteria }) => {
      if (groups[criteria] && !groups[criteria].some(existing => existing.code === indicator.code)) {
        groups[criteria].push(indicator);
      }
    });
    
    console.log('🗂️ Grouped indicators:', groups);
    return groups;
  }, [indicatorsCriteriaMap, selectedCriteria]);

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <Loader className="h-8 w-8 animate-spin text-green-600" />
      </div>
    );
  }

  // Debug info in development
  if (import.meta.env.DEV) {
    console.log('🔧 DEBUG INFO:');
    console.log('Selected criteria:', selectedCriteria);
    console.log('Selected issues:', selectedIssues);
    console.log('Selected standards:', selectedStandards);
    console.log('Indicators loaded:', indicators.length);
    console.log('Indicators criteria map:', indicatorsCriteriaMap.length);
    console.log('Grouped indicators keys:', Object.keys(groupedIndicators));
  }
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="max-w-7xl mx-auto">
        <div className="relative mb-8 rounded-xl overflow-hidden shadow-lg">
          <img src="/Imade full VSG.jpg" alt="Global ESG Banner" className="w-full h-32 object-cover" />
          <div className="absolute inset-0 bg-gradient-to-r from-black/20 to-transparent"></div>
        </div>

        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-800">Étape 5 : Sélection des Indicateurs</h1>
          <p className="text-gray-600 mt-2">
            Choisissez les indicateurs de performance pour chaque critère sélectionné.
          </p>
        </div>

        <SelectionSummary />

        {/* Debug Panel - Only in development */}
        {import.meta.env.DEV && (
          <div className="mb-6 p-4 bg-gray-100 rounded-lg">
            <h3 className="font-semibold mb-2">🔧 Debug Info</h3>
            <div className="text-sm space-y-1">
              <p><strong>Critères sélectionnés:</strong> {selectedCriteria.length}</p>
              <p><strong>Enjeux sélectionnés:</strong> {selectedIssues.length}</p>
              <p><strong>Normes sélectionnées:</strong> {selectedStandards.length}</p>
              <p><strong>Indicateurs chargés:</strong> {indicators.length}</p>
              <p><strong>Mapping critères-indicateurs:</strong> {indicatorsCriteriaMap.length}</p>
              <p><strong>Groupes de critères:</strong> {Object.keys(groupedIndicators).length}</p>
              <p><strong>Secteur/Sous-secteur:</strong> {selectedSector} / {selectedSubsector || 'Aucun'}</p>
            </div>
          </div>
        )}
        <div className="mb-8">
          {showAddForm ? (
            <AddForm
              onSubmit={onSubmit}
              onCancel={() => setShowAddForm(false)}
              placeholder="Ex: Tonnes CO2 émises"
              label="Nom de l'indicateur"
              parentOptions={criteriaOptions}
              parentLabel="Critère associé"
              showUnit
              type="indicator"
            />
          ) : (
            <AddButton onClick={() => setShowAddForm(true)} label="Ajouter un indicateur" />
          )}
        </div>

        <div className="space-y-8">
          {Object.entries(groupedIndicators).map(([criteriaName, criteriaIndicators]) => (
            <div key={criteriaName} className="bg-white rounded-lg border border-gray-200 shadow-sm">
              <div className="px-6 py-4 border-b border-gray-200 bg-gray-50">
                <h3 className="text-lg font-semibold text-gray-900 flex items-center">
                  <CheckSquare className="h-5 w-5 text-green-600 mr-2" />
                  {criteriaName}
                </h3>
                <p className="text-sm text-gray-600 mt-1">
                  {criteriaIndicators.length} indicateur(s) disponible(s)
                </p>
              </div>
              
              <div className="p-6">
                {criteriaIndicators.length > 0 ? (
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                    {criteriaIndicators.map((indicator) => (
                      <div
                        key={indicator.code}
                        onClick={() => toggleIndicator(indicator.name)}
                        className={`p-3 rounded-lg border cursor-pointer transition-all ${
                          selectedIndicators.includes(indicator.name)
                            ? 'border-green-500 bg-green-50'
                            : 'border-gray-200 hover:border-green-300 hover:bg-gray-50'
                        }`}
                      >
                        <div className="flex items-start space-x-3">
                          <div
                            className={`flex items-center justify-center w-4 h-4 rounded border transition-colors mt-0.5 ${
                              selectedIndicators.includes(indicator.name)
                                ? 'border-green-600 bg-green-600'
                                : 'border-gray-300'
                            }`}
                          >
                            {selectedIndicators.includes(indicator.name) && (
                              <Check className="h-3 w-3 text-white" />
                            )}
                          </div>
                          <div className="flex-1 min-w-0">
                            <h4 className="font-semibold text-base text-gray-900 leading-tight">{indicator.name}</h4>
                            {indicator.description && (
                              <p className="text-sm text-gray-600 mt-2 leading-relaxed">{indicator.description}</p>
                            )}
                          </div>
                          {selectedIndicators.includes(indicator.name) && (
                            <div className="flex-shrink-0">
                              <BarChart3 className="h-5 w-5 text-green-600" />
                            </div>
                          )}
                        </div>
                        
                        <div className="flex flex-wrap items-center gap-2 mt-3">
                          {indicator.unit && (
                            <span className="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold bg-blue-100 text-blue-800">
                              {indicator.unit}
                            </span>
                          )}
                          <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold ${
                            indicator.axe === 'Environnement' ? 'bg-green-100 text-green-800' :
                            indicator.axe === 'Social' ? 'bg-blue-100 text-blue-800' :
                            indicator.axe === 'Gouvernance' ? 'bg-purple-100 text-purple-800' :
                            'bg-gray-100 text-gray-800'
                          }`}>
                            {indicator.axe}
                          </span>
                          <span className="inline-flex items-center px-1.5 py-0.5 rounded text-xs font-medium bg-purple-100 text-purple-800">
                            {indicator.type}
                          </span>
                          {indicator.formule && (
                            <span className="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold bg-amber-100 text-amber-800">
                              {indicator.formule}
                            </span>
                          )}
                          {indicator.frequence && (
                            <span className="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold bg-cyan-100 text-cyan-800">
                              {indicator.frequence}
                            </span>
                          )}
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-6 text-gray-500">
                    <BarChart3 className="h-8 w-8 mx-auto mb-2 text-gray-300" />
                    <p className="text-sm">Aucun indicateur disponible pour ce critère</p>
                    <p className="text-xs mt-1">Ajoutez des indicateurs en utilisant le bouton ci-dessus</p>
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>

        {/* No data message */}
        {Object.keys(groupedIndicators).length === 0 && !loading && (
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-6 text-center">
            <BarChart3 className="h-12 w-12 text-blue-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-blue-900 mb-2">Aucun indicateur trouvé</h3>
            <p className="text-blue-700 mb-4">
              Aucun indicateur n'a été trouvé pour les critères sélectionnés.
            </p>
            <div className="text-sm text-blue-600 space-y-1">
              <p>• Vérifiez que les critères sont bien liés aux enjeux et normes</p>
              <p>• Assurez-vous que les indicateurs existent dans la base de données</p>
              <p>• Utilisez le bouton "Ajouter un indicateur" pour créer de nouveaux indicateurs</p>
            </div>
          </div>
        )}
        {selectedIndicators.length === 0 && (
          <div className="bg-amber-50 border border-amber-300 text-amber-800 rounded-md p-4 my-8">
            <p className="text-sm">
              Veuillez sélectionner au moins un indicateur pour continuer.
            </p>
          </div>
        )}
        
        <ProgressNav
          currentStep={5}
          totalSteps={6}
          nextPath="/process/company"
          prevPath="/process/criteria"
          isNextDisabled={selectedIndicators.length === 0}
        />

        {similarityAlert && (
          <SimilarityAlertModal
            isOpen
            onClose={() => setSimilarityAlert(null)}
            onConfirm={similarityAlert.onConfirm}
            itemName={similarityAlert.itemName}
            similarItems={similarityAlert.items}
          />
        )}
      </div>
    </div>
  );
};

export default ProcessStepIndicators;