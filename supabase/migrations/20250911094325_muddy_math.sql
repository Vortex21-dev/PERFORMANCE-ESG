/*
  # Populate sector standards issues criteria indicators

  1. New Data
    - Links indicators to criteria in sector_standards_issues_criteria_indicators table
    - Links indicators to criteria in subsector_standards_issues_criteria_indicators table
    - Ensures proper relationships between all ESG elements

  2. Data Population
    - Populates sector-based indicator relationships
    - Populates subsector-based indicator relationships
    - Uses existing data from previous migrations
*/

-- =========================================================
-- POPULATE SECTOR STANDARDS ISSUES CRITERIA INDICATORS
-- =========================================================

-- First, ensure we have the base relationships
INSERT INTO sector_standards_issues_criteria (sector_name, standard_name, issue_name, criteria_codes)
SELECT DISTINCT 
  'Services financiers' as sector_name,
  'ISO 26000' as standard_name,
  issue_name,
  ARRAY[criteria_name] as criteria_codes
FROM (
  VALUES 
    ('GOVERNANCE_LEADERSHIP', 'POLICY_CHARTER'),
    ('GOVERNANCE_LEADERSHIP', 'TRANSPARENCY_ANTICORRUPTION'),
    ('BUSINESS_ETHICS', 'TRANSPARENCY_ANTICORRUPTION'),
    ('STAKEHOLDER_ENGAGEMENT', 'STAKEHOLDER_DIALOGUE'),
    ('STAKEHOLDER_ENGAGEMENT', 'MATERIALITY_ASSESSMENT'),
    ('ORGANIZATIONAL_STRATEGY', 'ORGANIZATIONAL_STRUCTURE'),
    ('ORGANIZATIONAL_STRATEGY', 'RISK_OPPORTUNITY_MANAGEMENT'),
    ('ORGANIZATIONAL_STRATEGY', 'STRATEGY_ROADMAP'),
    ('EMPLOYMENT_PRACTICES', 'EMPLOYMENT_DIALOGUE'),
    ('EMPLOYMENT_PRACTICES', 'WORKFORCE_MANAGEMENT'),
    ('TRAINING_EDUCATION', 'TRAINING_CAREER'),
    ('HUMAN_RIGHTS', 'HUMAN_RIGHTS_POLICY'),
    ('ENVIRONMENTAL_MANAGEMENT', 'ENVIRONMENTAL_MEASUREMENT'),
    ('SOCIAL_RESPONSIBILITY', 'REMUNERATION_EQUITY')
) AS t(issue_name, criteria_name)
ON CONFLICT (sector_name, standard_name) 
DO UPDATE SET criteria_codes = EXCLUDED.criteria_codes;

-- Now populate the indicators for each criteria
INSERT INTO sector_standards_issues_criteria_indicators (
  sector_name, 
  standard_name, 
  issue_name, 
  criteria_name, 
  indicator_codes
)
VALUES
-- Gouvernance - Leadership et responsabilité
('Services financiers', 'ISO 26000', 'GOVERNANCE_LEADERSHIP', 'POLICY_CHARTER', 
 ARRAY['BOARD_COMPOSITION', 'WOMEN_BOARD_RATIO', 'CHIFFRE_AFFAIRES', 'SITES_COUNT']),

('Services financiers', 'ISO 26000', 'GOVERNANCE_LEADERSHIP', 'TRANSPARENCY_ANTICORRUPTION', 
 ARRAY['ETHICS_VIOLATIONS', 'CONFLICTS_DECLARED', 'CORRUPTION_VIOLATIONS']),

-- Gouvernance - Conduite des affaires
('Services financiers', 'ISO 26000', 'BUSINESS_ETHICS', 'TRANSPARENCY_ANTICORRUPTION', 
 ARRAY['ETHICS_VIOLATIONS', 'CORRUPTION_VIOLATIONS', 'FORMAL_CONSULTATIONS']),

-- Gouvernance - Parties prenantes
('Services financiers', 'ISO 26000', 'STAKEHOLDER_ENGAGEMENT', 'STAKEHOLDER_DIALOGUE', 
 ARRAY['STAKEHOLDER_MEETINGS', 'STAKEHOLDER_PARTICIPATION_RATE', 'STAKEHOLDER_RECOMMENDATIONS']),

('Services financiers', 'ISO 26000', 'STAKEHOLDER_ENGAGEMENT', 'MATERIALITY_ASSESSMENT', 
 ARRAY['STRATEGIC_ISSUES_INTEGRATED', 'SUSTAINABILITY_COMMITTEE_MEETINGS']),

-- Gouvernance - Organisation et stratégie
('Services financiers', 'ISO 26000', 'ORGANIZATIONAL_STRATEGY', 'ORGANIZATIONAL_STRUCTURE', 
 ARRAY['SUSTAINABILITY_COMMITTEE_MEETINGS', 'STRATEGIC_DECISIONS_ESG']),

('Services financiers', 'ISO 26000', 'ORGANIZATIONAL_STRATEGY', 'RISK_OPPORTUNITY_MANAGEMENT', 
 ARRAY['IRO_ACTIONS_IMPLEMENTED', 'GREEN_MARKET_OPPORTUNITIES']),

('Services financiers', 'ISO 26000', 'ORGANIZATIONAL_STRATEGY', 'STRATEGY_ROADMAP', 
 ARRAY['SDG_ALIGNMENT_RATE', 'DD_CALENDAR_COMPLIANCE', 'DD_OBJECTIVES_ACHIEVED']),

-- Social - Emplois et main d'œuvre
('Services financiers', 'ISO 26000', 'EMPLOYMENT_PRACTICES', 'EMPLOYMENT_DIALOGUE', 
 ARRAY['EMPLOYEE_COUNT', 'PERMANENT_CONTRACT_EMPLOYEES', 'TEMPORARY_CONTRACT_EMPLOYEES']),

('Services financiers', 'ISO 26000', 'EMPLOYMENT_PRACTICES', 'WORKFORCE_MANAGEMENT', 
 ARRAY['SUBCONTRACTORS_INDEFINITE', 'SUBCONTRACTORS_FIXED_TERM', 'TOTAL_SUBCONTRACTORS']),

-- Social - Formation et éducation
('Services financiers', 'ISO 26000', 'TRAINING_EDUCATION', 'TRAINING_CAREER', 
 ARRAY['TRAINING_HOURS', 'EMPLOYEES_UNDER_30', 'EMPLOYEES_30_50', 'EMPLOYEES_OVER_50']),

-- Social - Droits humains
('Services financiers', 'ISO 26000', 'HUMAN_RIGHTS', 'HUMAN_RIGHTS_POLICY', 
 ARRAY['YEAR_HIRES_UNDER_30', 'YEAR_HIRES_30_50', 'YEAR_HIRES_OVER_50']),

-- Social - Rémunération
('Services financiers', 'ISO 26000', 'SOCIAL_RESPONSIBILITY', 'REMUNERATION_EQUITY', 
 ARRAY['SALARY_EQUITY_RATIO', 'TOTAL_REMUNERATION_MEN', 'TOTAL_REMUNERATION_WOMEN']),

-- Environnement - Gestion environnementale
('Services financiers', 'ISO 26000', 'ENVIRONMENTAL_MANAGEMENT', 'ENVIRONMENTAL_MEASUREMENT', 
 ARRAY['ENERGY_CONSUMPTION', 'WATER_CONSUMPTION', 'WASTE_GENERATED', 'CO2_EMISSIONS'])

ON CONFLICT (sector_name, standard_name, issue_name, criteria_name) 
DO UPDATE SET indicator_codes = EXCLUDED.indicator_codes;

-- Also populate for subsectors if they exist
INSERT INTO subsector_standards_issues_criteria_indicators (
  subsector_name, 
  standard_name, 
  issue_name, 
  criteria_name, 
  indicator_codes
)
SELECT 
  sub.name as subsector_name,
  ssici.standard_name,
  ssici.issue_name,
  ssici.criteria_name,
  ssici.indicator_codes
FROM subsectors sub
CROSS JOIN sector_standards_issues_criteria_indicators ssici
WHERE sub.sector_name = ssici.sector_name
ON CONFLICT (subsector_name, standard_name, issue_name, criteria_name) 
DO UPDATE SET indicator_codes = EXCLUDED.indicator_codes;