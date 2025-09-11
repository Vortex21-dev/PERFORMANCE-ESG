/*
  # Create test user processes data for admin dashboard

  1. Test Data
    - Create user_processes assignments for test users
    - Link users to processes with indicators
    - Ensure proper organization assignments

  2. Security
    - No RLS changes needed (inherits from existing tables)
*/

-- Create test user processes assignments
INSERT INTO user_processes (email, process_codes) VALUES
('admin@test.com', ARRAY['GOVERNANCE_PROC', 'SOCIAL_PROC', 'ENV_PROC']),
('enterprise@test.com', ARRAY['GOVERNANCE_PROC', 'SOCIAL_PROC']),
('contributor@test.com', ARRAY['SOCIAL_PROC', 'ENV_PROC']),
('validator@test.com', ARRAY['GOVERNANCE_PROC'])
ON CONFLICT (email) DO UPDATE SET
  process_codes = EXCLUDED.process_codes;

-- Create test processes with indicator codes
INSERT INTO processes (code, name, description, indicator_codes, organization_name) VALUES
('GOVERNANCE_PROC', 'Processus Gouvernance', 'Gestion de la gouvernance d''entreprise', 
 ARRAY['BOARD_COMPOSITION', 'WOMEN_BOARD_RATIO', 'ETHICS_VIOLATIONS', 'STAKEHOLDER_MEETINGS'], 'TestFiliere'),
('SOCIAL_PROC', 'Processus Social', 'Gestion des aspects sociaux', 
 ARRAY['EMPLOYEE_COUNT', 'TRAINING_HOURS', 'TURNOVER_RATE', 'SALARY_EQUITY_RATIO'], 'TestFiliere'),
('ENV_PROC', 'Processus Environnemental', 'Gestion environnementale', 
 ARRAY['ENERGY_CONSUMPTION', 'WATER_CONSUMPTION', 'WASTE_GENERATED', 'CO2_EMISSIONS'], 'TestFiliere')
ON CONFLICT (code) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  indicator_codes = EXCLUDED.indicator_codes,
  organization_name = EXCLUDED.organization_name;

-- Ensure TestFiliere organization exists
INSERT INTO organizations (name, organization_type, address, city, country, phone, email) VALUES
('TestFiliere', 'simple', '123 Test Street', 'Test City', 'Test Country', '+1234567890', 'test@testfiliere.com')
ON CONFLICT (name) DO NOTHING;

-- Create test profiles if they don't exist
INSERT INTO profiles (email, role, organization_name, organization_level) VALUES
('admin@test.com', 'admin', 'TestFiliere', 'organization'),
('enterprise@test.com', 'enterprise', 'TestFiliere', 'organization'),
('contributor@test.com', 'contributor', 'TestFiliere', 'organization'),
('validator@test.com', 'validator', 'TestFiliere', 'organization')
ON CONFLICT (email) DO UPDATE SET
  organization_name = EXCLUDED.organization_name,
  organization_level = EXCLUDED.organization_level;

-- Create test users if they don't exist
INSERT INTO users (email, nom, prenom, fonction) VALUES
('admin@test.com', 'Admin', 'Test', 'Administrateur'),
('enterprise@test.com', 'Enterprise', 'Test', 'Responsable ESG'),
('contributor@test.com', 'Contributor', 'Test', 'Contributeur'),
('validator@test.com', 'Validator', 'Test', 'Validateur')
ON CONFLICT (email) DO NOTHING;