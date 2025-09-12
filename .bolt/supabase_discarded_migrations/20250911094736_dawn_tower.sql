/*
  # Populate missing sector data for Administration publique

  1. New Data
    - Add sector_standards_issues_criteria_indicators entries for Administration publique
    - Link existing criteria to indicators
    - Ensure proper relationships between all elements

  2. Security
    - No RLS changes needed
    - Uses existing table structure
*/

-- First, let's check what we have for Administration publique
DO $$
BEGIN
  -- Insert sector_standards_issues_criteria_indicators for Administration publique
  INSERT INTO sector_standards_issues_criteria_indicators (
    sector_name, 
    standard_name, 
    issue_name, 
    criteria_name, 
    indicator_codes
  ) VALUES
  -- ISO 26000 + Leadership et responsabilité + Politique et charte
  ('Administration publique', 'ISO 26000', 'Leadership et responsabilité', 'Politique et charte', 
   ARRAY['BOARD_COMPOSITION', 'WOMEN_BOARD_RATIO', 'ETHICS_VIOLATIONS']),
  
  -- ISO 26000 + Conduite des affaires + Transparence et anti-corruption  
  ('Administration publique', 'ISO 26000', 'Conduite des affaires et Éthique des affaires', 'Transparence et anti-corruption',
   ARRAY['ETHICS_VIOLATIONS', 'STAKEHOLDER_MEETINGS']),
   
  -- CSRD + Parties prenantes + Parties prenantes (attentes, dialogue)
  ('Administration publique', 'CSRD', 'Parties prenantes et matérialité', 'Parties prenantes (attentes, dialogue)',
   ARRAY['STAKEHOLDER_MEETINGS', 'EMPLOYEE_COUNT']),
   
  -- GRI + Emplois et main d'œuvre + Personnel de l'entreprise
  ('Administration publique', 'GRI', 'Emplois et main d''œuvre', 'Personnel de l''entreprise, emploi, dialogue social et liberté d''association',
   ARRAY['EMPLOYEE_COUNT', 'TRAINING_HOURS', 'TURNOVER_RATE']),
   
  -- ISO 14001 + Gestion environnementale + Mesure et collecte des données
  ('Administration publique', 'ISO 14001', 'Gestion environnementale', 'Mesure et collecte des données',
   ARRAY['ENERGY_CONSUMPTION', 'WATER_CONSUMPTION', 'WASTE_GENERATED', 'CO2_EMISSIONS']);

  RAISE NOTICE 'Sector data populated for Administration publique';
END $$;