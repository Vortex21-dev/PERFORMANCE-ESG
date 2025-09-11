/*
  # Create test user processes assignments

  1. Test Data
    - Create test user processes assignments for existing users
    - Link users to processes with indicators
    - Ensure proper data flow for testing

  2. Security
    - Uses existing RLS policies
    - No additional security changes needed
*/

-- Create test user processes assignments
INSERT INTO user_processes (email, process_codes) VALUES
('admin@test.com', ARRAY['PROC_GOV_001', 'PROC_SOC_001', 'PROC_ENV_001']),
('enterprise@test.com', ARRAY['PROC_GOV_001', 'PROC_SOC_001', 'PROC_ENV_001']),
('contributor@test.com', ARRAY['PROC_SOC_001', 'PROC_ENV_001']),
('validator@test.com', ARRAY['PROC_GOV_001', 'PROC_SOC_001'])
ON CONFLICT (email) DO UPDATE SET
  process_codes = EXCLUDED.process_codes;

-- Create test processes with proper indicator assignments
INSERT INTO processes (code, name, description, indicator_codes, organization_name) VALUES
('PROC_GOV_001', 'Processus Gouvernance', 'Processus de gouvernance et éthique', 
 ARRAY['BOARD_COMPOSITION', 'WOMEN_BOARD_RATIO', 'ETHICS_VIOLATIONS', 'STAKEHOLDER_MEETINGS'], 'TestFiliere'),
('PROC_SOC_001', 'Processus Social', 'Processus ressources humaines et social', 
 ARRAY['EMPLOYEE_COUNT', 'TRAINING_HOURS', 'TURNOVER_RATE', 'SALARY_EQUITY_RATIO'], 'TestFiliere'),
('PROC_ENV_001', 'Processus Environnement', 'Processus environnemental', 
 ARRAY['ENERGY_CONSUMPTION', 'WATER_CONSUMPTION', 'WASTE_GENERATED', 'CO2_EMISSIONS'], 'TestFiliere')
ON CONFLICT (code) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  indicator_codes = EXCLUDED.indicator_codes,
  organization_name = EXCLUDED.organization_name;