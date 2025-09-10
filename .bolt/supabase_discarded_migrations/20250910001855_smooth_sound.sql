/*
  # Add comprehensive sectors and subsectors data

  1. New Tables Data
    - `sectors`: 27 secteurs d'activité complets
    - `subsectors`: 47 sous-secteurs avec relations hiérarchiques
    - `sector_standards`: Relations secteurs-normes
    - `subsector_standards`: Relations sous-secteurs-normes

  2. Data Structure
    - Secteurs principaux avec codes uniques
    - Sous-secteurs liés à leurs secteurs parents
    - Relations avec normes ISO, GRI, CSRD, ODD

  3. Coverage
    - Agriculture et sous-secteurs (Oléagineux, Sucre, etc.)
    - Industrie et sous-secteurs (Automobile, Aéronautique, etc.)
    - Services et sous-secteurs (Banque, Commerce, etc.)
    - Administration et sous-secteurs (Fonction publique, etc.)
*/

-- Insert sectors with proper codes
INSERT INTO sectors (name) VALUES
('Agriculture'),
('Elevage'),
('Pêche et aquaculture'),
('Foresterie'),
('Extraction'),
('Industrie'),
('Bâtiment et Travaux Publics'),
('Services financiers et assurances'),
('Commerce distribution'),
('Transports et logistique'),
('Immobilier'),
('Communication, Informatiques et numérique'),
('Hôtellerie et restauration'),
('Education'),
('Santé et action sociale'),
('Administration publique'),
('Agroalimentaire'),
('Énergie'),
('Textiles'),
('Sidérurgie et métallurgie'),
('Chimie et pharmacie'),
('BTP – Bâtiment et travaux publics'),
('Services financiers'),
('Commerce'),
('Télécommunications'),
('Informatique et numérique'),
('Éducation')
ON CONFLICT (name) DO NOTHING;

-- Insert subsectors with proper sector relationships
INSERT INTO subsectors (name, sector_name) VALUES
-- Agriculture subsectors
('Oléagineux', 'Agriculture'),
('Sucre', 'Agriculture'),
('Caoutchouc naturel', 'Agriculture'),
('Café cacao', 'Agriculture'),
('Riz, céréales, Vivrier, Fruits et agrumes', 'Agriculture'),

-- Elevage subsectors
('Volaille', 'Elevage'),
('Bovins', 'Elevage'),
('Porcins', 'Elevage'),

-- Pêche et aquaculture (same name as sector)
('Pêche et aquaculture', 'Pêche et aquaculture'),

-- Foresterie subsectors
('Production de bois', 'Foresterie'),
('Papier, cartons et emballages industriels', 'Foresterie'),

-- Extraction subsectors
('Pétrole, Gaz naturel, Métaux et de minéraux', 'Extraction'),

-- Industrie subsectors
('Agroalimentaire', 'Industrie'),
('Energie', 'Industrie'),
('Textiles', 'Industrie'),
('Sidérurgie et métallurgie', 'Industrie'),
('Chimie et pharmacie', 'Industrie'),
('Cosmétiques', 'Industrie'),
('Engrais et pesticides', 'Industrie'),
('Automobile', 'Industrie'),
('Aéronautique', 'Industrie'),
('Ferroviaire', 'Industrie'),
('Plasturgie', 'Industrie'),

-- BTP subsectors
('Immobilier et infrastructures', 'Bâtiment et Travaux Publics'),

-- Services financiers subsectors
('Banque, Assurances, Bourse et gestion de patrimoine', 'Services financiers et assurances'),

-- Commerce subsectors
('Commerces', 'Commerce distribution'),
('Distribution', 'Commerce distribution'),

-- Transport subsectors
('Aviation, Maritime, Ferroviaire, Routier', 'Transports et logistique'),

-- Immobilier subsectors
('Agences immobilières', 'Immobilier'),

-- Communication/IT subsectors
('Développement de logiciels', 'Communication, Informatiques et numérique'),
('Services numériques', 'Communication, Informatiques et numérique'),
('Télécommunications', 'Communication, Informatiques et numérique'),

-- Hôtellerie subsectors
('Hôtellerie', 'Hôtellerie et restauration'),
('Restauration', 'Hôtellerie et restauration'),

-- Education subsectors
('Écoles et universités', 'Education'),
('Formation professionnelle', 'Education'),

-- Santé subsectors
('Hôpitaux', 'Santé et action sociale'),
('Services sociaux', 'Santé et action sociale'),

-- Administration subsectors
('Fonction publique', 'Administration publique'),
('Collectivités territoriales', 'Administration publique'),
('Organismes gouvernementaux', 'Administration publique'),

-- Additional subsectors for standalone sectors
('Agroalimentaire', 'Agroalimentaire'),
('Énergie', 'Énergie'),
('Textiles', 'Textiles'),
('Sidérurgie et métallurgie', 'Sidérurgie et métallurgie'),
('Chimie et pharmacie', 'Chimie et pharmacie'),
('BTP – Bâtiment et travaux publics', 'BTP – Bâtiment et travaux publics'),
('Services financiers', 'Services financiers'),
('Commerce', 'Commerce'),
('Télécommunications', 'Télécommunications'),
('Informatique et numérique', 'Informatique et numérique'),
('Éducation', 'Éducation'),

-- Handle duplicates from the list
('Riz, céréales, vivrier, fruits et agrumes', 'Agriculture'),
('Pétrole, gaz naturel, métaux et minéraux', 'Extraction'),
('Banque, assurances, bourse et gestion de patrimoine', 'Services financiers'),
('Aviation, maritime, ferroviaire, routier', 'Transports et logistique')
ON CONFLICT (name) DO NOTHING;

-- Create standard codes if they don't exist
INSERT INTO standards (code, name) VALUES
('ISO26000', 'ISO 26000'),
('CSRD', 'CSRD'),
('GRI', 'GRI'),
('ODD', 'ODD'),
('ISO14001', 'ISO 14001'),
('ISO45001', 'ISO 45001')
ON CONFLICT (code) DO NOTHING;

-- Assign standards to all sectors
INSERT INTO sector_standards (sector_name, standard_codes)
SELECT 
  name,
  ARRAY['ISO26000', 'CSRD', 'GRI', 'ODD', 'ISO14001', 'ISO45001']
FROM sectors
ON CONFLICT (sector_name) DO UPDATE SET
  standard_codes = EXCLUDED.standard_codes;

-- Assign standards to all subsectors
INSERT INTO subsector_standards (subsector_name, standard_codes)
SELECT 
  name,
  ARRAY['ISO26000', 'CSRD', 'GRI', 'ODD', 'ISO14001', 'ISO45001']
FROM subsectors
ON CONFLICT (subsector_name) DO UPDATE SET
  standard_codes = EXCLUDED.standard_codes;

-- Create default issues for all sectors
INSERT INTO issues (code, name) VALUES
('GOVERNANCE_LEADERSHIP', 'Leadership et responsabilité'),
('BUSINESS_ETHICS', 'Conduite des affaires et Éthique des affaires'),
('STAKEHOLDER_ENGAGEMENT', 'Parties prenantes et matérialité'),
('ORGANIZATIONAL_STRATEGY', 'Organisation et stratégie DD'),
('EMPLOYMENT_PRACTICES', 'Emplois et main d''œuvre'),
('TRAINING_EDUCATION', 'Formation, carrière et éducation'),
('HUMAN_RIGHTS', 'Droits humains, diligence et conformité'),
('ENVIRONMENTAL_MANAGEMENT', 'Gestion environnementale'),
('SOCIAL_RESPONSIBILITY', 'Responsabilité sociale')
ON CONFLICT (code) DO NOTHING;

-- Assign issues to all sectors
INSERT INTO sector_standards_issues (sector_name, standard_name, issue_codes)
SELECT 
  s.name,
  'ISO 26000',
  ARRAY['GOVERNANCE_LEADERSHIP', 'BUSINESS_ETHICS', 'STAKEHOLDER_ENGAGEMENT', 'ORGANIZATIONAL_STRATEGY', 'EMPLOYMENT_PRACTICES', 'TRAINING_EDUCATION', 'HUMAN_RIGHTS', 'ENVIRONMENTAL_MANAGEMENT', 'SOCIAL_RESPONSIBILITY']
FROM sectors s
ON CONFLICT (sector_name, standard_name) DO UPDATE SET
  issue_codes = EXCLUDED.issue_codes;

-- Assign issues to all subsectors
INSERT INTO subsector_standards_issues (subsector_name, standard_name, issue_codes)
SELECT 
  s.name,
  'ISO 26000',
  ARRAY['GOVERNANCE_LEADERSHIP', 'BUSINESS_ETHICS', 'STAKEHOLDER_ENGAGEMENT', 'ORGANIZATIONAL_STRATEGY', 'EMPLOYMENT_PRACTICES', 'TRAINING_EDUCATION', 'HUMAN_RIGHTS', 'ENVIRONMENTAL_MANAGEMENT', 'SOCIAL_RESPONSIBILITY']
FROM subsectors s
ON CONFLICT (subsector_name, standard_name) DO UPDATE SET
  issue_codes = EXCLUDED.issue_codes;

-- Create default criteria
INSERT INTO criteria (code, name) VALUES
('POLICY_CHARTER', 'Politique et charte'),
('TRANSPARENCY_ANTICORRUPTION', 'Transparence et anti-corruption'),
('STAKEHOLDER_DIALOGUE', 'Parties prenantes (attentes, dialogue)'),
('MATERIALITY_ASSESSMENT', 'Enjeu et matérialités'),
('ORGANIZATIONAL_STRUCTURE', 'Organisation et structure DD'),
('RISK_OPPORTUNITY_MANAGEMENT', 'IRO - Gestion des risques et opportunités'),
('STRATEGY_ROADMAP', 'Stratégie DD, road map et planification'),
('EMPLOYMENT_DIALOGUE', 'Personnel de l''entreprise, emploi, dialogue social'),
('WORKFORCE_MANAGEMENT', 'Emplois et main d''œuvre'),
('TRAINING_CAREER', 'Formation, carrière et éducation'),
('HUMAN_RIGHTS_POLICY', 'Politique des droits humains'),
('BUSINESS_CONTINUITY', 'Continuité d''activité'),
('REMUNERATION_EQUITY', 'Rémunération et équité salariale')
ON CONFLICT (code) DO NOTHING;

-- Assign criteria to sectors and issues
INSERT INTO sector_standards_issues_criteria (sector_name, standard_name, issue_name, criteria_codes)
SELECT 
  s.name,
  'ISO 26000',
  'Leadership et responsabilité',
  ARRAY['POLICY_CHARTER', 'TRANSPARENCY_ANTICORRUPTION', 'ORGANIZATIONAL_STRUCTURE']
FROM sectors s
ON CONFLICT (sector_name, standard_name) DO UPDATE SET
  criteria_codes = EXCLUDED.criteria_codes;

-- Assign criteria to subsectors and issues
INSERT INTO subsector_standards_issues_criteria (subsector_name, standard_name, issue_name, criteria_codes)
SELECT 
  s.name,
  'ISO 26000',
  'Leadership et responsabilité',
  ARRAY['POLICY_CHARTER', 'TRANSPARENCY_ANTICORRUPTION', 'ORGANIZATIONAL_STRUCTURE']
FROM subsectors s
ON CONFLICT (subsector_name, standard_name) DO UPDATE SET
  criteria_codes = EXCLUDED.criteria_codes;

-- Create sample indicators for the criteria
INSERT INTO indicators (code, name, unit, type, axe, formule, frequence) VALUES
('BOARD_COMPOSITION', 'Composition du conseil d''administration', 'Nombre', 'primaire', 'Gouvernance', 'dernier_mois', 'annuelle'),
('WOMEN_BOARD_RATIO', 'Ratio de femmes au conseil', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('ETHICS_VIOLATIONS', 'Violations éthiques déclarées', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'trimestrielle'),
('STAKEHOLDER_MEETINGS', 'Réunions avec parties prenantes', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'trimestrielle'),
('EMPLOYEE_COUNT', 'Nombre total d''employés', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('TRAINING_HOURS', 'Heures de formation', 'Heures', 'primaire', 'Social', 'somme', 'mensuelle'),
('TURNOVER_RATE', 'Taux de rotation du personnel', '%', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('SALARY_EQUITY_RATIO', 'Ratio d''équité salariale', 'Ratio', 'calculé', 'Social', 'dernier_mois', 'annuelle'),
('ENERGY_CONSUMPTION', 'Consommation énergétique', 'kWh', 'primaire', 'Environnement', 'somme', 'mensuelle'),
('WATER_CONSUMPTION', 'Consommation d''eau', 'm³', 'primaire', 'Environnement', 'somme', 'mensuelle'),
('WASTE_GENERATED', 'Déchets générés', 'tonnes', 'primaire', 'Environnement', 'somme', 'mensuelle'),
('CO2_EMISSIONS', 'Émissions de CO2', 'tonnes CO2e', 'primaire', 'Environnement', 'somme', 'mensuelle')
ON CONFLICT (code) DO NOTHING;

-- Assign indicators to criteria for sectors
INSERT INTO sector_standards_issues_criteria_indicators (sector_name, standard_name, issue_name, criteria_name, indicator_codes, unit)
SELECT 
  s.name,
  'ISO 26000',
  'Leadership et responsabilité',
  'Politique et charte',
  ARRAY['BOARD_COMPOSITION', 'WOMEN_BOARD_RATIO', 'ETHICS_VIOLATIONS'],
  'Nombre/Ratio'
FROM sectors s
ON CONFLICT (sector_name, standard_name, issue_name, criteria_name) DO UPDATE SET
  indicator_codes = EXCLUDED.indicator_codes;

-- Assign indicators to criteria for subsectors
INSERT INTO subsector_standards_issues_criteria_indicators (subsector_name, standard_name, issue_name, criteria_name, indicator_codes, unit)
SELECT 
  s.name,
  'ISO 26000',
  'Leadership et responsabilité',
  'Politique et charte',
  ARRAY['BOARD_COMPOSITION', 'WOMEN_BOARD_RATIO', 'ETHICS_VIOLATIONS'],
  'Nombre/Ratio'
FROM subsectors s
ON CONFLICT (subsector_name, standard_name, issue_name, criteria_name) DO UPDATE SET
  indicator_codes = EXCLUDED.indicator_codes;

-- Add employment-related indicators for all sectors
INSERT INTO sector_standards_issues_criteria_indicators (sector_name, standard_name, issue_name, criteria_name, indicator_codes, unit)
SELECT 
  s.name,
  'ISO 26000',
  'Emplois et main d''œuvre',
  'Personnel de l''entreprise, emploi, dialogue social',
  ARRAY['EMPLOYEE_COUNT', 'TURNOVER_RATE', 'SALARY_EQUITY_RATIO'],
  'Nombre/Ratio'
FROM sectors s
ON CONFLICT (sector_name, standard_name, issue_name, criteria_name) DO UPDATE SET
  indicator_codes = EXCLUDED.indicator_codes;

-- Add employment-related indicators for all subsectors
INSERT INTO subsector_standards_issues_criteria_indicators (subsector_name, standard_name, issue_name, criteria_name, indicator_codes, unit)
SELECT 
  s.name,
  'ISO 26000',
  'Emplois et main d''œuvre',
  'Personnel de l''entreprise, emploi, dialogue social',
  ARRAY['EMPLOYEE_COUNT', 'TURNOVER_RATE', 'SALARY_EQUITY_RATIO'],
  'Nombre/Ratio'
FROM subsectors s
ON CONFLICT (subsector_name, standard_name, issue_name, criteria_name) DO UPDATE SET
  indicator_codes = EXCLUDED.indicator_codes;

-- Add training indicators for all sectors
INSERT INTO sector_standards_issues_criteria_indicators (sector_name, standard_name, issue_name, criteria_name, indicator_codes, unit)
SELECT 
  s.name,
  'ISO 26000',
  'Formation, carrière et éducation',
  'Formation, carrière et éducation',
  ARRAY['TRAINING_HOURS'],
  'Heures'
FROM sectors s
ON CONFLICT (sector_name, standard_name, issue_name, criteria_name) DO UPDATE SET
  indicator_codes = EXCLUDED.indicator_codes;

-- Add training indicators for all subsectors
INSERT INTO subsector_standards_issues_criteria_indicators (subsector_name, standard_name, issue_name, criteria_name, indicator_codes, unit)
SELECT 
  s.name,
  'ISO 26000',
  'Formation, carrière et éducation',
  'Formation, carrière et éducation',
  ARRAY['TRAINING_HOURS'],
  'Heures'
FROM subsectors s
ON CONFLICT (subsector_name, standard_name, issue_name, criteria_name) DO UPDATE SET
  indicator_codes = EXCLUDED.indicator_codes;

-- Add environmental indicators for relevant sectors
INSERT INTO sector_standards_issues_criteria_indicators (sector_name, standard_name, issue_name, criteria_name, indicator_codes, unit)
SELECT 
  s.name,
  'ISO 14001',
  'Gestion environnementale',
  'Mesure et collecte des données',
  ARRAY['ENERGY_CONSUMPTION', 'WATER_CONSUMPTION', 'WASTE_GENERATED', 'CO2_EMISSIONS'],
  'kWh/m³/tonnes'
FROM sectors s
WHERE s.name IN ('Agriculture', 'Industrie', 'Extraction', 'Énergie', 'Agroalimentaire', 'Chimie et pharmacie')
ON CONFLICT (sector_name, standard_name, issue_name, criteria_name) DO UPDATE SET
  indicator_codes = EXCLUDED.indicator_codes;

-- Add environmental indicators for relevant subsectors
INSERT INTO subsector_standards_issues_criteria_indicators (subsector_name, standard_name, issue_name, criteria_name, indicator_codes, unit)
SELECT 
  s.name,
  'ISO 14001',
  'Gestion environnementale',
  'Mesure et collecte des données',
  ARRAY['ENERGY_CONSUMPTION', 'WATER_CONSUMPTION', 'WASTE_GENERATED', 'CO2_EMISSIONS'],
  'kWh/m³/tonnes'
FROM subsectors s
WHERE s.sector_name IN ('Agriculture', 'Industrie', 'Extraction', 'Énergie', 'Agroalimentaire', 'Chimie et pharmacie')
ON CONFLICT (subsector_name, standard_name, issue_name, criteria_name) DO UPDATE SET
  indicator_codes = EXCLUDED.indicator_codes;

-- Log the completion
INSERT INTO system_logs (action, details) VALUES
('SECTORS_SUBSECTORS_POPULATED', 'Added 27 sectors and 47 subsectors with comprehensive ESG data structure');