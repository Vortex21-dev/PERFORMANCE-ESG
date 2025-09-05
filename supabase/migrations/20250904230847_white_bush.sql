/*
  # Debug and Fix Dashboard Metadata Retrieval

  1. Diagnostic Functions
    - Check data in sector_standards_issues_criteria_indicators
    - Verify indicator mappings
    - Test metadata retrieval logic

  2. Corrected View
    - Fixed JOIN logic for metadata retrieval
    - Proper handling of array relationships
    - Comprehensive fallback mechanisms

  3. Testing
    - Validate specific indicator mappings
    - Ensure correct metadata display
*/

-- First, let's create a diagnostic function to check the data
CREATE OR REPLACE FUNCTION debug_indicator_metadata(indicator_name TEXT DEFAULT 'Tonnes CO2 émises')
RETURNS TABLE (
  indicator_code TEXT,
  sector_name TEXT,
  standard_name TEXT,
  issue_name TEXT,
  criteria_name TEXT,
  found_in_table TEXT
) AS $$
BEGIN
  -- Check in sector table
  RETURN QUERY
  SELECT 
    i.code as indicator_code,
    ssici.sector_name,
    ssici.standard_name,
    ssici.issue_name,
    ssici.criteria_name,
    'sector_standards_issues_criteria_indicators'::TEXT as found_in_table
  FROM indicators i
  JOIN sector_standards_issues_criteria_indicators ssici 
    ON i.code = ANY(ssici.indicator_codes)
  WHERE i.name = indicator_name;

  -- Check in subsector table
  RETURN QUERY
  SELECT 
    i.code as indicator_code,
    sssici.subsector_name as sector_name,
    sssici.standard_name,
    sssici.issue_name,
    sssici.criteria_name,
    'subsector_standards_issues_criteria_indicators'::TEXT as found_in_table
  FROM indicators i
  JOIN subsector_standards_issues_criteria_indicators sssici 
    ON i.code = ANY(sssici.indicator_codes)
  WHERE i.name = indicator_name;
END;
$$ LANGUAGE plpgsql;

-- Check what data exists for our test indicator
SELECT * FROM debug_indicator_metadata('Tonnes CO2 émises');

-- Also check what indicators exist
SELECT code, name FROM indicators WHERE name ILIKE '%CO2%' OR name ILIKE '%carbone%' OR name ILIKE '%emission%';

-- Check organization sectors to understand the mapping
SELECT 
  os.organization_name,
  os.sector_name,
  os.subsector_name
FROM organization_sectors os
LIMIT 5;

-- Now let's create a corrected view that properly retrieves metadata
DROP MATERIALIZED VIEW IF EXISTS dashboard_performance_view CASCADE;

CREATE MATERIALIZED VIEW dashboard_performance_view AS
WITH organization_metadata AS (
  -- Get organization sector/subsector info
  SELECT DISTINCT
    os.organization_name,
    os.sector_name,
    os.subsector_name
  FROM organization_sectors os
),

indicator_metadata_enhanced AS (
  -- Get comprehensive metadata for each indicator
  SELECT DISTINCT
    i.code as indicator_code,
    i.name as indicator_name,
    i.unit,
    i.type,
    i.axe,
    i.formule,
    i.frequence,
    p.code as process_code,
    p.name as process_name,
    
    -- Try to get metadata from sector table first
    COALESCE(
      (SELECT ssici.standard_name 
       FROM sector_standards_issues_criteria_indicators ssici 
       JOIN organization_metadata om ON om.sector_name = ssici.sector_name
       WHERE i.code = ANY(ssici.indicator_codes)
       LIMIT 1),
      -- Then try subsector table
      (SELECT sssici.standard_name 
       FROM subsector_standards_issues_criteria_indicators sssici 
       JOIN organization_metadata om ON om.subsector_name = sssici.subsector_name
       WHERE i.code = ANY(sssici.indicator_codes)
       LIMIT 1),
      'Standard non défini'
    ) as normes,
    
    COALESCE(
      (SELECT ssici.issue_name 
       FROM sector_standards_issues_criteria_indicators ssici 
       JOIN organization_metadata om ON om.sector_name = ssici.sector_name
       WHERE i.code = ANY(ssici.indicator_codes)
       LIMIT 1),
      (SELECT sssici.issue_name 
       FROM subsector_standards_issues_criteria_indicators sssici 
       JOIN organization_metadata om ON om.subsector_name = sssici.subsector_name
       WHERE i.code = ANY(sssici.indicator_codes)
       LIMIT 1),
      'Enjeu non défini'
    ) as enjeux,
    
    COALESCE(
      (SELECT ssici.criteria_name 
       FROM sector_standards_issues_criteria_indicators ssici 
       JOIN organization_metadata om ON om.sector_name = ssici.sector_name
       WHERE i.code = ANY(ssici.indicator_codes)
       LIMIT 1),
      (SELECT sssici.criteria_name 
       FROM subsector_standards_issues_criteria_indicators sssici 
       JOIN organization_metadata om ON om.subsector_name = sssici.subsector_name
       WHERE i.code = ANY(sssici.indicator_codes)
       LIMIT 1),
      'Critère non défini'
    ) as criteres
    
  FROM indicators i
  CROSS JOIN processes p
  WHERE i.code = ANY(p.indicator_codes)
),

monthly_aggregations AS (
  -- Calculate monthly values and totals
  SELECT 
    iv.organization_name,
    iv.process_code,
    iv.indicator_code,
    iv.year,
    
    -- Monthly values (NULL-safe)
    COALESCE(SUM(CASE WHEN iv.month = 1 THEN iv.value END), 0) as janvier,
    COALESCE(SUM(CASE WHEN iv.month = 2 THEN iv.value END), 0) as fevrier,
    COALESCE(SUM(CASE WHEN iv.month = 3 THEN iv.value END), 0) as mars,
    COALESCE(SUM(CASE WHEN iv.month = 4 THEN iv.value END), 0) as avril,
    COALESCE(SUM(CASE WHEN iv.month = 5 THEN iv.value END), 0) as mai,
    COALESCE(SUM(CASE WHEN iv.month = 6 THEN iv.value END), 0) as juin,
    COALESCE(SUM(CASE WHEN iv.month = 7 THEN iv.value END), 0) as juillet,
    COALESCE(SUM(CASE WHEN iv.month = 8 THEN iv.value END), 0) as aout,
    COALESCE(SUM(CASE WHEN iv.month = 9 THEN iv.value END), 0) as septembre,
    COALESCE(SUM(CASE WHEN iv.month = 10 THEN iv.value END), 0) as octobre,
    COALESCE(SUM(CASE WHEN iv.month = 11 THEN iv.value END), 0) as novembre,
    COALESCE(SUM(CASE WHEN iv.month = 12 THEN iv.value END), 0) as decembre,
    
    -- Calculate total based on formula
    CASE 
      WHEN ime.formule = 'somme' THEN COALESCE(SUM(iv.value), 0)
      WHEN ime.formule = 'moyenne' THEN COALESCE(AVG(iv.value), 0)
      WHEN ime.formule = 'max' THEN COALESCE(MAX(iv.value), 0)
      WHEN ime.formule = 'min' THEN COALESCE(MIN(iv.value), 0)
      WHEN ime.formule = 'dernier_mois' THEN COALESCE(
        (SELECT iv2.value 
         FROM indicator_values iv2 
         WHERE iv2.organization_name = iv.organization_name 
           AND iv2.indicator_code = iv.indicator_code 
           AND iv2.year = iv.year
         ORDER BY iv2.month DESC 
         LIMIT 1), 0)
      ELSE COALESCE(SUM(iv.value), 0)
    END as valeur_totale,
    
    MAX(iv.updated_at) as last_updated
    
  FROM indicator_values iv
  JOIN indicator_metadata_enhanced ime ON iv.indicator_code = ime.indicator_code 
    AND iv.process_code = ime.process_code
  GROUP BY iv.organization_name, iv.process_code, iv.indicator_code, iv.year, ime.formule
),

performance_calculations AS (
  -- Calculate performance metrics
  SELECT 
    ma.*,
    ime.indicator_name,
    ime.unit,
    ime.type,
    ime.axe,
    ime.formule,
    ime.frequence,
    ime.process_name,
    ime.normes,
    ime.enjeux,
    ime.criteres,
    
    -- Previous year value (for variation calculation)
    COALESCE(
      (SELECT ma2.valeur_totale 
       FROM monthly_aggregations ma2 
       WHERE ma2.organization_name = ma.organization_name 
         AND ma2.indicator_code = ma.indicator_code 
         AND ma2.year = ma.year - 1), 0
    ) as valeur_precedente,
    
    -- Target value (placeholder - should come from targets table if exists)
    CASE 
      WHEN ime.axe = 'Environnement' THEN ma.valeur_totale * 0.9  -- 10% reduction target
      WHEN ime.axe = 'Social' THEN ma.valeur_totale * 1.1         -- 10% improvement target
      ELSE ma.valeur_totale * 1.05                                -- 5% improvement target
    END as valeur_cible
    
  FROM monthly_aggregations ma
  JOIN indicator_metadata_enhanced ime ON ma.indicator_code = ime.indicator_code 
    AND ma.process_code = ime.process_code
)

-- Final SELECT with all calculations
SELECT 
  pc.organization_name,
  pc.process_code,
  pc.indicator_code,
  pc.year,
  pc.axe,
  pc.enjeux,
  pc.normes,
  pc.criteres,
  pc.process_name as processus,
  pc.indicator_name as indicateur,
  pc.unit as unite,
  pc.frequence,
  pc.type,
  pc.formule,
  pc.janvier,
  pc.fevrier,
  pc.mars,
  pc.avril,
  pc.mai,
  pc.juin,
  pc.juillet,
  pc.aout,
  pc.septembre,
  pc.octobre,
  pc.novembre,
  pc.decembre,
  pc.valeur_totale,
  pc.valeur_precedente,
  pc.valeur_cible,
  
  -- Calculate variation percentage
  CASE 
    WHEN pc.valeur_precedente > 0 THEN 
      ROUND(((pc.valeur_totale - pc.valeur_precedente) / pc.valeur_precedente * 100)::numeric, 1)
    ELSE 0
  END as variation,
  
  -- Calculate performance percentage
  CASE 
    WHEN pc.valeur_cible > 0 THEN 
      ROUND((pc.valeur_totale / pc.valeur_cible * 100)::numeric, 1)
    ELSE 0
  END as performance,
  
  -- Calculate average monthly value
  ROUND((pc.valeur_totale / 12)::numeric, 2) as valeur_moyenne,
  
  pc.last_updated

FROM performance_calculations pc

-- Include ALL configured indicators, even those without values
UNION ALL

SELECT 
  oi.organization_name,
  p.code as process_code,
  i.code as indicator_code,
  EXTRACT(YEAR FROM CURRENT_DATE)::integer as year,
  i.axe,
  
  -- Get metadata for indicators without values
  COALESCE(
    (SELECT ssici.issue_name 
     FROM sector_standards_issues_criteria_indicators ssici 
     JOIN organization_sectors os ON os.sector_name = ssici.sector_name
     WHERE os.organization_name = oi.organization_name 
       AND i.code = ANY(ssici.indicator_codes)
     LIMIT 1),
    (SELECT sssici.issue_name 
     FROM subsector_standards_issues_criteria_indicators sssici 
     JOIN organization_sectors os ON os.subsector_name = sssici.subsector_name
     WHERE os.organization_name = oi.organization_name 
       AND i.code = ANY(sssici.indicator_codes)
     LIMIT 1),
    'Enjeu non défini'
  ) as enjeux,
  
  COALESCE(
    (SELECT ssici.standard_name 
     FROM sector_standards_issues_criteria_indicators ssici 
     JOIN organization_sectors os ON os.sector_name = ssici.sector_name
     WHERE os.organization_name = oi.organization_name 
       AND i.code = ANY(ssici.indicator_codes)
     LIMIT 1),
    (SELECT sssici.standard_name 
     FROM subsector_standards_issues_criteria_indicators sssici 
     JOIN organization_sectors os ON os.subsector_name = sssici.subsector_name
     WHERE os.organization_name = oi.organization_name 
       AND i.code = ANY(sssici.indicator_codes)
     LIMIT 1),
    'Standard non défini'
  ) as normes,
  
  COALESCE(
    (SELECT ssici.criteria_name 
     FROM sector_standards_issues_criteria_indicators ssici 
     JOIN organization_sectors os ON os.sector_name = ssici.sector_name
     WHERE os.organization_name = oi.organization_name 
       AND i.code = ANY(ssici.indicator_codes)
     LIMIT 1),
    (SELECT sssici.criteria_name 
     FROM subsector_standards_issues_criteria_indicators sssici 
     JOIN organization_sectors os ON os.subsector_name = sssici.subsector_name
     WHERE os.organization_name = oi.organization_name 
       AND i.code = ANY(sssici.indicator_codes)
     LIMIT 1),
    'Critère non défini'
  ) as criteres,
  
  p.name as processus,
  i.name as indicateur,
  i.unit as unite,
  i.frequence,
  i.type,
  i.formule,
  
  -- Zero values for empty indicators
  0 as janvier, 0 as fevrier, 0 as mars, 0 as avril,
  0 as mai, 0 as juin, 0 as juillet, 0 as aout,
  0 as septembre, 0 as octobre, 0 as novembre, 0 as decembre,
  0 as valeur_totale,
  0 as valeur_precedente,
  0 as valeur_cible,
  0 as variation,
  0 as performance,
  0 as valeur_moyenne,
  
  CURRENT_TIMESTAMP as last_updated

FROM organization_indicators oi
JOIN indicators i ON i.code = ANY(oi.indicator_codes)
JOIN processes p ON i.code = ANY(p.indicator_codes)
WHERE NOT EXISTS (
  SELECT 1 FROM indicator_values iv 
  WHERE iv.organization_name = oi.organization_name
    AND iv.indicator_code = i.code
    AND iv.year = EXTRACT(YEAR FROM CURRENT_DATE)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_dashboard_performance_view_org_year 
ON dashboard_performance_view (organization_name, year);

CREATE INDEX IF NOT EXISTS idx_dashboard_performance_view_indicator 
ON dashboard_performance_view (indicator_code);

CREATE INDEX IF NOT EXISTS idx_dashboard_performance_view_process 
ON dashboard_performance_view (process_code);

CREATE INDEX IF NOT EXISTS idx_dashboard_performance_view_axe 
ON dashboard_performance_view (axe);

-- Create a function to test specific indicator metadata
CREATE OR REPLACE FUNCTION test_indicator_metadata_retrieval(
  test_organization TEXT DEFAULT 'TestFiliere',
  test_indicator TEXT DEFAULT 'Tonnes CO2 émises'
)
RETURNS TABLE (
  organization_name TEXT,
  indicator_code TEXT,
  indicator_name TEXT,
  normes TEXT,
  enjeux TEXT,
  criteres TEXT,
  source_table TEXT
) AS $$
BEGIN
  -- Test the actual view
  RETURN QUERY
  SELECT 
    dpv.organization_name,
    dpv.indicator_code,
    dpv.indicateur as indicator_name,
    dpv.normes,
    dpv.enjeux,
    dpv.criteres,
    'dashboard_performance_view'::TEXT as source_table
  FROM dashboard_performance_view dpv
  WHERE dpv.organization_name = test_organization
    AND dpv.indicateur = test_indicator
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Test the corrected metadata retrieval
SELECT * FROM test_indicator_metadata_retrieval();

-- Create a function to refresh and validate the view
CREATE OR REPLACE FUNCTION refresh_and_validate_dashboard_view()
RETURNS TABLE (
  status TEXT,
  message TEXT,
  indicator_count INTEGER,
  metadata_coverage NUMERIC
) AS $$
DECLARE
  total_indicators INTEGER;
  indicators_with_metadata INTEGER;
  coverage_rate NUMERIC;
BEGIN
  -- Refresh the materialized view
  REFRESH MATERIALIZED VIEW dashboard_performance_view;
  
  -- Count total indicators
  SELECT COUNT(*) INTO total_indicators
  FROM dashboard_performance_view;
  
  -- Count indicators with proper metadata
  SELECT COUNT(*) INTO indicators_with_metadata
  FROM dashboard_performance_view
  WHERE normes != 'Standard non défini' 
    AND enjeux != 'Enjeu non défini'
    AND criteres != 'Critère non défini';
  
  -- Calculate coverage rate
  coverage_rate := CASE 
    WHEN total_indicators > 0 THEN 
      ROUND((indicators_with_metadata::NUMERIC / total_indicators * 100), 2)
    ELSE 0 
  END;
  
  RETURN QUERY SELECT 
    CASE 
      WHEN coverage_rate >= 90 THEN 'excellent'::TEXT
      WHEN coverage_rate >= 70 THEN 'good'::TEXT
      WHEN coverage_rate >= 50 THEN 'fair'::TEXT
      ELSE 'poor'::TEXT
    END as status,
    format('Vue actualisée avec %s indicateurs (%s%% avec métadonnées complètes)', 
           total_indicators, coverage_rate) as message,
    total_indicators as indicator_count,
    coverage_rate as metadata_coverage;
END;
$$ LANGUAGE plpgsql;

-- Execute the refresh and validation
SELECT * FROM refresh_and_validate_dashboard_view();

-- Final test: Check if our specific indicator now has correct metadata
SELECT 
  organization_name,
  indicateur,
  normes,
  enjeux,
  criteres
FROM dashboard_performance_view 
WHERE indicateur ILIKE '%CO2%' OR indicateur ILIKE '%carbone%' OR indicateur ILIKE '%emission%'
LIMIT 5;