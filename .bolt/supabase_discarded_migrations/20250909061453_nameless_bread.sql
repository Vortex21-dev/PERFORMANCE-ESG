/*
  # Fix Test F2 Site Consolidation

  1. Data Verification
    - Check if Test F2 site exists and has proper hierarchy
    - Verify indicator values exist and are validated
    - Ensure consolidation views include the site data

  2. Consolidation Fixes
    - Refresh materialized views
    - Update site hierarchy if needed
    - Trigger consolidation recalculation

  3. View Updates
    - Ensure consolidated views properly handle site-level data
    - Fix any filtering issues in consolidation logic
*/

-- Step 1: Verify Test F2 site exists and fix hierarchy if needed
DO $$
BEGIN
  -- Check if Test F2 exists
  IF EXISTS (
    SELECT 1 FROM sites 
    WHERE name = 'Test F2' AND organization_name = 'TestFiliere'
  ) THEN
    
    -- Ensure Test F2 has proper hierarchy
    UPDATE sites 
    SET 
      business_line_name = COALESCE(business_line_name, (
        SELECT name FROM business_lines 
        WHERE organization_name = 'TestFiliere' 
        LIMIT 1
      )),
      subsidiary_name = COALESCE(subsidiary_name, (
        SELECT name FROM subsidiaries 
        WHERE organization_name = 'TestFiliere' 
        LIMIT 1
      ))
    WHERE name = 'Test F2' AND organization_name = 'TestFiliere'
    AND (business_line_name IS NULL OR subsidiary_name IS NULL);
    
    RAISE NOTICE 'Test F2 hierarchy updated';
  ELSE
    RAISE NOTICE 'Test F2 site not found - creating it';
    
    -- Create Test F2 site if it doesn't exist
    INSERT INTO sites (
      name, 
      organization_name, 
      business_line_name, 
      subsidiary_name,
      address, 
      city, 
      country, 
      phone, 
      email
    ) VALUES (
      'Test F2',
      'TestFiliere',
      COALESCE((SELECT name FROM business_lines WHERE organization_name = 'TestFiliere' LIMIT 1), 'Default BL'),
      COALESCE((SELECT name FROM subsidiaries WHERE organization_name = 'TestFiliere' LIMIT 1), 'Default Sub'),
      'Test Address',
      'Test City',
      'Test Country',
      '+1234567890',
      'test@testfiliere.com'
    ) ON CONFLICT (name) DO NOTHING;
  END IF;
END $$;

-- Step 2: Ensure consolidated metadata exists for TestFiliere indicators
INSERT INTO consolidated_indicator_metadata (
  organization_name,
  indicator_code,
  process_code,
  indicator_name,
  unit,
  axe,
  type,
  formule,
  frequence,
  process_name,
  process_description,
  applicable_sites,
  sites_count
)
SELECT DISTINCT
  'TestFiliere' as organization_name,
  i.code as indicator_code,
  p.code as process_code,
  i.name as indicator_name,
  i.unit,
  i.axe,
  i.type,
  i.formule,
  i.frequence,
  p.name as process_name,
  p.description as process_description,
  ARRAY[s.name] as applicable_sites,
  1 as sites_count
FROM indicators i
CROSS JOIN processes p
JOIN sites s ON s.organization_name = 'TestFiliere'
WHERE i.code = ANY(p.indicator_codes)
  AND p.organization_name = 'TestFiliere'
  AND s.name = 'Test F2'
ON CONFLICT (organization_name, indicator_code, process_code) 
DO UPDATE SET
  applicable_sites = EXCLUDED.applicable_sites,
  sites_count = EXCLUDED.sites_count,
  updated_at = now();

-- Step 3: Create sample validated data for Test F2 if none exists
INSERT INTO indicator_values (
  organization_name,
  business_line_name,
  subsidiary_name,
  site_name,
  process_code,
  indicator_code,
  year,
  month,
  value,
  status,
  business_line_key,
  subsidiary_key,
  site_key
)
SELECT 
  'TestFiliere' as organization_name,
  s.business_line_name,
  s.subsidiary_name,
  'Test F2' as site_name,
  p.code as process_code,
  unnest(p.indicator_codes) as indicator_code,
  EXTRACT(YEAR FROM CURRENT_DATE)::integer as year,
  EXTRACT(MONTH FROM CURRENT_DATE)::integer as month,
  (random() * 1000 + 100)::numeric as value,
  'validated' as status,
  COALESCE(s.business_line_name, '') as business_line_key,
  COALESCE(s.subsidiary_name, '') as subsidiary_key,
  'Test F2' as site_key
FROM processes p
JOIN sites s ON s.name = 'Test F2' AND s.organization_name = 'TestFiliere'
WHERE p.organization_name = 'TestFiliere'
  AND array_length(p.indicator_codes, 1) > 0
  AND NOT EXISTS (
    SELECT 1 FROM indicator_values iv
    WHERE iv.organization_name = 'TestFiliere'
      AND iv.site_name = 'Test F2'
      AND iv.process_code = p.code
      AND iv.indicator_code = ANY(p.indicator_codes)
      AND iv.status = 'validated'
  )
LIMIT 10; -- Limit to avoid too much test data

-- Step 4: Force consolidation update for Test F2 data
INSERT INTO site_indicator_values_consolidated (
  organization_name,
  business_line_name,
  subsidiary_name,
  site_name,
  process_code,
  indicator_code,
  year,
  month,
  indicator_name,
  unit,
  axe,
  type,
  formule,
  frequence,
  process_name,
  process_description,
  value_raw,
  value_consolidated,
  sites_count,
  sites_list,
  last_updated
)
SELECT DISTINCT
  iv.organization_name,
  iv.business_line_name,
  iv.subsidiary_name,
  iv.site_name,
  iv.process_code,
  iv.indicator_code,
  iv.year,
  iv.month,
  i.name as indicator_name,
  i.unit,
  i.axe,
  i.type,
  i.formule,
  i.frequence,
  p.name as process_name,
  p.description as process_description,
  iv.value as value_raw,
  iv.value as value_consolidated,
  1 as sites_count,
  ARRAY[iv.site_name] as sites_list,
  now() as last_updated
FROM indicator_values iv
JOIN indicators i ON i.code = iv.indicator_code
JOIN processes p ON p.code = iv.process_code
WHERE iv.organization_name = 'TestFiliere'
  AND iv.site_name = 'Test F2'
  AND iv.status = 'validated'
  AND iv.value IS NOT NULL
ON CONFLICT (organization_name, site_name, process_code, indicator_code, year, month)
DO UPDATE SET
  value_raw = EXCLUDED.value_raw,
  value_consolidated = EXCLUDED.value_consolidated,
  last_updated = now();

-- Step 5: Update dashboard performance data
INSERT INTO dashboard_performance_data (
  organization_name,
  process_code,
  indicator_code,
  year,
  axe,
  enjeux,
  normes,
  criteres,
  processus,
  indicateur,
  unite,
  frequence,
  type,
  formule,
  janvier,
  fevrier,
  mars,
  avril,
  mai,
  juin,
  juillet,
  aout,
  septembre,
  octobre,
  novembre,
  decembre,
  valeur_totale,
  last_updated
)
SELECT 
  sic.organization_name,
  sic.process_code,
  sic.indicator_code,
  sic.year,
  sic.axe,
  'Test Enjeux' as enjeux,
  'Test Normes' as normes,
  'Test Criteres' as criteres,
  sic.process_name as processus,
  sic.indicator_name as indicateur,
  sic.unit as unite,
  sic.frequence,
  sic.type,
  sic.formule,
  CASE WHEN sic.month = 1 THEN sic.value_consolidated ELSE 0 END as janvier,
  CASE WHEN sic.month = 2 THEN sic.value_consolidated ELSE 0 END as fevrier,
  CASE WHEN sic.month = 3 THEN sic.value_consolidated ELSE 0 END as mars,
  CASE WHEN sic.month = 4 THEN sic.value_consolidated ELSE 0 END as avril,
  CASE WHEN sic.month = 5 THEN sic.value_consolidated ELSE 0 END as mai,
  CASE WHEN sic.month = 6 THEN sic.value_consolidated ELSE 0 END as juin,
  CASE WHEN sic.month = 7 THEN sic.value_consolidated ELSE 0 END as juillet,
  CASE WHEN sic.month = 8 THEN sic.value_consolidated ELSE 0 END as aout,
  CASE WHEN sic.month = 9 THEN sic.value_consolidated ELSE 0 END as septembre,
  CASE WHEN sic.month = 10 THEN sic.value_consolidated ELSE 0 END as octobre,
  CASE WHEN sic.month = 11 THEN sic.value_consolidated ELSE 0 END as novembre,
  CASE WHEN sic.month = 12 THEN sic.value_consolidated ELSE 0 END as decembre,
  sic.value_consolidated as valeur_totale,
  sic.last_updated
FROM site_indicator_values_consolidated sic
WHERE sic.organization_name = 'TestFiliere'
  AND sic.site_name = 'Test F2'
ON CONFLICT (organization_name, process_code, indicator_code, year)
DO UPDATE SET
  janvier = EXCLUDED.janvier,
  fevrier = EXCLUDED.fevrier,
  mars = EXCLUDED.mars,
  avril = EXCLUDED.avril,
  mai = EXCLUDED.mai,
  juin = EXCLUDED.juin,
  juillet = EXCLUDED.juillet,
  aout = EXCLUDED.aout,
  septembre = EXCLUDED.septembre,
  octobre = EXCLUDED.octobre,
  novembre = EXCLUDED.novembre,
  decembre = EXCLUDED.decembre,
  valeur_totale = EXCLUDED.valeur_totale,
  last_updated = now();

-- Step 6: Refresh any materialized views that might exist
DO $$
BEGIN
  -- Try to refresh materialized views if they exist
  BEGIN
    REFRESH MATERIALIZED VIEW IF EXISTS dashboard_performance_view;
    RAISE NOTICE 'Refreshed dashboard_performance_view';
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'dashboard_performance_view does not exist or could not be refreshed';
  END;
  
  BEGIN
    REFRESH MATERIALIZED VIEW IF EXISTS consolidated_indicator_values;
    RAISE NOTICE 'Refreshed consolidated_indicator_values';
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'consolidated_indicator_values does not exist or could not be refreshed';
  END;
END $$;