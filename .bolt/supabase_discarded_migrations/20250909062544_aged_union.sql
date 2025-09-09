/*
  # Fix Consolidated Table Data and Display Issues

  1. Data Population
    - Populate consolidated tables with existing validated data
    - Fix monthly data aggregation logic
    - Ensure proper site counting and listing

  2. Table Structure Updates
    - Add missing columns for site information
    - Fix monthly data separation
    - Update consolidation logic

  3. View Refresh
    - Refresh materialized views
    - Update dashboard performance data
*/

-- First, let's ensure the consolidated table has the right structure
DO $$
BEGIN
  -- Add sites_list column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'site_indicator_values_consolidated' 
    AND column_name = 'sites_list'
  ) THEN
    ALTER TABLE site_indicator_values_consolidated 
    ADD COLUMN sites_list text[];
  END IF;

  -- Add sites_count column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'site_indicator_values_consolidated' 
    AND column_name = 'sites_count'
  ) THEN
    ALTER TABLE site_indicator_values_consolidated 
    ADD COLUMN sites_count integer DEFAULT 0;
  END IF;
END $$;

-- Clear existing consolidated data to rebuild correctly
DELETE FROM site_indicator_values_consolidated WHERE organization_name = 'TestFiliere';
DELETE FROM dashboard_performance_data WHERE organization_name = 'TestFiliere';

-- Populate consolidated data with proper monthly separation
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
  enjeux,
  normes,
  criteres,
  value_raw,
  value_consolidated,
  sites_count,
  sites_list,
  target_value,
  previous_year_value,
  variation,
  performance
)
SELECT DISTINCT
  iv.organization_name,
  iv.business_line_name,
  iv.subsidiary_name,
  iv.site_name,
  iv.process_code,
  iv.indicator_code,
  iv.year,
  iv.month, -- Keep month-specific data
  i.name as indicator_name,
  i.unit,
  i.axe,
  i.type,
  i.formule,
  i.frequence,
  p.name as process_name,
  p.description as process_description,
  'Enjeux consolidés' as enjeux,
  'Normes consolidées' as normes,
  'Critères consolidés' as criteres,
  iv.value as value_raw,
  -- Consolidation logic based on formula
  CASE 
    WHEN i.formule = 'somme' THEN (
      SELECT COALESCE(SUM(iv2.value), 0)
      FROM indicator_values iv2
      WHERE iv2.organization_name = iv.organization_name
        AND iv2.indicator_code = iv.indicator_code
        AND iv2.process_code = iv.process_code
        AND iv2.year = iv.year
        AND iv2.month = iv.month -- Same month only
        AND iv2.status = 'validated'
        AND iv2.value IS NOT NULL
    )
    WHEN i.formule = 'moyenne' THEN (
      SELECT COALESCE(AVG(iv2.value), 0)
      FROM indicator_values iv2
      WHERE iv2.organization_name = iv.organization_name
        AND iv2.indicator_code = iv.indicator_code
        AND iv2.process_code = iv.process_code
        AND iv2.year = iv.year
        AND iv2.month = iv.month -- Same month only
        AND iv2.status = 'validated'
        AND iv2.value IS NOT NULL
    )
    WHEN i.formule = 'max' THEN (
      SELECT COALESCE(MAX(iv2.value), 0)
      FROM indicator_values iv2
      WHERE iv2.organization_name = iv.organization_name
        AND iv2.indicator_code = iv.indicator_code
        AND iv2.process_code = iv.process_code
        AND iv2.year = iv.year
        AND iv2.month = iv.month -- Same month only
        AND iv2.status = 'validated'
        AND iv2.value IS NOT NULL
    )
    WHEN i.formule = 'min' THEN (
      SELECT COALESCE(MIN(iv2.value), 0)
      FROM indicator_values iv2
      WHERE iv2.organization_name = iv.organization_name
        AND iv2.indicator_code = iv.indicator_code
        AND iv2.process_code = iv.process_code
        AND iv2.year = iv.year
        AND iv2.month = iv.month -- Same month only
        AND iv2.status = 'validated'
        AND iv2.value IS NOT NULL
    )
    ELSE iv.value
  END as value_consolidated,
  -- Count sites contributing to this indicator for this month
  (
    SELECT COUNT(DISTINCT iv2.site_name)
    FROM indicator_values iv2
    WHERE iv2.organization_name = iv.organization_name
      AND iv2.indicator_code = iv.indicator_code
      AND iv2.process_code = iv.process_code
      AND iv2.year = iv.year
      AND iv2.month = iv.month -- Same month only
      AND iv2.status = 'validated'
      AND iv2.value IS NOT NULL
      AND iv2.site_name IS NOT NULL
  ) as sites_count,
  -- List sites contributing to this indicator for this month
  (
    SELECT ARRAY_AGG(DISTINCT iv2.site_name)
    FROM indicator_values iv2
    WHERE iv2.organization_name = iv.organization_name
      AND iv2.indicator_code = iv.indicator_code
      AND iv2.process_code = iv.process_code
      AND iv2.year = iv.year
      AND iv2.month = iv.month -- Same month only
      AND iv2.status = 'validated'
      AND iv2.value IS NOT NULL
      AND iv2.site_name IS NOT NULL
  ) as sites_list,
  0 as target_value,
  0 as previous_year_value,
  0 as variation,
  0 as performance
FROM indicator_values iv
JOIN indicators i ON i.code = iv.indicator_code
JOIN processes p ON p.code = iv.process_code
WHERE iv.organization_name = 'TestFiliere'
  AND iv.status = 'validated'
  AND iv.value IS NOT NULL
  AND iv.site_name IS NOT NULL;

-- Update dashboard performance data with proper monthly separation
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
  janvier, fevrier, mars, avril, mai, juin,
  juillet, aout, septembre, octobre, novembre, decembre,
  valeur_totale,
  valeur_precedente,
  valeur_cible,
  variation,
  performance,
  valeur_moyenne
)
SELECT 
  sic.organization_name,
  sic.process_code,
  sic.indicator_code,
  sic.year,
  sic.axe,
  sic.enjeux,
  sic.normes,
  sic.criteres,
  sic.process_name as processus,
  sic.indicator_name as indicateur,
  sic.unit as unite,
  sic.frequence,
  sic.type,
  sic.formule,
  -- Monthly values - only populate the specific month
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
  0 as valeur_precedente,
  0 as valeur_cible,
  0 as variation,
  0 as performance,
  sic.value_consolidated as valeur_moyenne
FROM site_indicator_values_consolidated sic
WHERE sic.organization_name = 'TestFiliere'
ON CONFLICT (organization_name, process_code, indicator_code, year) 
DO UPDATE SET
  janvier = CASE WHEN EXCLUDED.janvier > 0 THEN EXCLUDED.janvier ELSE dashboard_performance_data.janvier END,
  fevrier = CASE WHEN EXCLUDED.fevrier > 0 THEN EXCLUDED.fevrier ELSE dashboard_performance_data.fevrier END,
  mars = CASE WHEN EXCLUDED.mars > 0 THEN EXCLUDED.mars ELSE dashboard_performance_data.mars END,
  avril = CASE WHEN EXCLUDED.avril > 0 THEN EXCLUDED.avril ELSE dashboard_performance_data.avril END,
  mai = CASE WHEN EXCLUDED.mai > 0 THEN EXCLUDED.mai ELSE dashboard_performance_data.mai END,
  juin = CASE WHEN EXCLUDED.juin > 0 THEN EXCLUDED.juin ELSE dashboard_performance_data.juin END,
  juillet = CASE WHEN EXCLUDED.juillet > 0 THEN EXCLUDED.juillet ELSE dashboard_performance_data.juillet END,
  aout = CASE WHEN EXCLUDED.aout > 0 THEN EXCLUDED.aout ELSE dashboard_performance_data.aout END,
  septembre = CASE WHEN EXCLUDED.septembre > 0 THEN EXCLUDED.septembre ELSE dashboard_performance_data.septembre END,
  octobre = CASE WHEN EXCLUDED.octobre > 0 THEN EXCLUDED.octobre ELSE dashboard_performance_data.octobre END,
  novembre = CASE WHEN EXCLUDED.novembre > 0 THEN EXCLUDED.novembre ELSE dashboard_performance_data.novembre END,
  decembre = CASE WHEN EXCLUDED.decembre > 0 THEN EXCLUDED.decembre ELSE dashboard_performance_data.decembre END,
  last_updated = now();

-- Create a function to properly aggregate monthly data
CREATE OR REPLACE FUNCTION refresh_consolidated_data_for_organization(org_name text)
RETURNS void AS $$
BEGIN
  -- Delete existing consolidated data for the organization
  DELETE FROM site_indicator_values_consolidated WHERE organization_name = org_name;
  DELETE FROM dashboard_performance_data WHERE organization_name = org_name;
  
  -- Repopulate with correct monthly separation
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
    enjeux,
    normes,
    criteres,
    value_raw,
    value_consolidated,
    sites_count,
    sites_list,
    target_value,
    previous_year_value,
    variation,
    performance
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
    'Enjeux consolidés' as enjeux,
    'Normes consolidées' as normes,
    'Critères consolidés' as criteres,
    iv.value as value_raw,
    -- Proper consolidation by month
    CASE 
      WHEN i.formule = 'somme' THEN (
        SELECT COALESCE(SUM(iv2.value), 0)
        FROM indicator_values iv2
        WHERE iv2.organization_name = iv.organization_name
          AND iv2.indicator_code = iv.indicator_code
          AND iv2.process_code = iv.process_code
          AND iv2.year = iv.year
          AND iv2.month = iv.month
          AND iv2.status = 'validated'
          AND iv2.value IS NOT NULL
      )
      WHEN i.formule = 'moyenne' THEN (
        SELECT COALESCE(AVG(iv2.value), 0)
        FROM indicator_values iv2
        WHERE iv2.organization_name = iv.organization_name
          AND iv2.indicator_code = iv.indicator_code
          AND iv2.process_code = iv.process_code
          AND iv2.year = iv.year
          AND iv2.month = iv.month
          AND iv2.status = 'validated'
          AND iv2.value IS NOT NULL
      )
      ELSE iv.value
    END as value_consolidated,
    -- Count sites for this specific month
    (
      SELECT COUNT(DISTINCT iv2.site_name)
      FROM indicator_values iv2
      WHERE iv2.organization_name = iv.organization_name
        AND iv2.indicator_code = iv.indicator_code
        AND iv2.process_code = iv.process_code
        AND iv2.year = iv.year
        AND iv2.month = iv.month
        AND iv2.status = 'validated'
        AND iv2.value IS NOT NULL
        AND iv2.site_name IS NOT NULL
    ) as sites_count,
    -- List sites for this specific month
    (
      SELECT ARRAY_AGG(DISTINCT iv2.site_name)
      FROM indicator_values iv2
      WHERE iv2.organization_name = iv.organization_name
        AND iv2.indicator_code = iv.indicator_code
        AND iv2.process_code = iv.process_code
        AND iv2.year = iv.year
        AND iv2.month = iv.month
        AND iv2.status = 'validated'
        AND iv2.value IS NOT NULL
        AND iv2.site_name IS NOT NULL
    ) as sites_list,
    0 as target_value,
    0 as previous_year_value,
    0 as variation,
    0 as performance
  FROM indicator_values iv
  JOIN indicators i ON i.code = iv.indicator_code
  JOIN processes p ON p.code = iv.process_code
  WHERE iv.organization_name = org_name
    AND iv.status = 'validated'
    AND iv.value IS NOT NULL
    AND iv.site_name IS NOT NULL;

  -- Update dashboard performance data with proper monthly aggregation
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
    janvier, fevrier, mars, avril, mai, juin,
    juillet, aout, septembre, octobre, novembre, decembre,
    valeur_totale,
    valeur_precedente,
    valeur_cible,
    variation,
    performance,
    valeur_moyenne
  )
  SELECT 
    organization_name,
    process_code,
    indicator_code,
    year,
    axe,
    enjeux,
    normes,
    criteres,
    process_name as processus,
    indicator_name as indicateur,
    unit as unite,
    frequence,
    type,
    formule,
    -- Aggregate monthly values properly
    COALESCE(SUM(CASE WHEN month = 1 THEN value_consolidated END), 0) as janvier,
    COALESCE(SUM(CASE WHEN month = 2 THEN value_consolidated END), 0) as fevrier,
    COALESCE(SUM(CASE WHEN month = 3 THEN value_consolidated END), 0) as mars,
    COALESCE(SUM(CASE WHEN month = 4 THEN value_consolidated END), 0) as avril,
    COALESCE(SUM(CASE WHEN month = 5 THEN value_consolidated END), 0) as mai,
    COALESCE(SUM(CASE WHEN month = 6 THEN value_consolidated END), 0) as juin,
    COALESCE(SUM(CASE WHEN month = 7 THEN value_consolidated END), 0) as juillet,
    COALESCE(SUM(CASE WHEN month = 8 THEN value_consolidated END), 0) as aout,
    COALESCE(SUM(CASE WHEN month = 9 THEN value_consolidated END), 0) as septembre,
    COALESCE(SUM(CASE WHEN month = 10 THEN value_consolidated END), 0) as octobre,
    COALESCE(SUM(CASE WHEN month = 11 THEN value_consolidated END), 0) as novembre,
    COALESCE(SUM(CASE WHEN month = 12 THEN value_consolidated END), 0) as decembre,
    COALESCE(SUM(value_consolidated), 0) as valeur_totale,
    0 as valeur_precedente,
    0 as valeur_cible,
    0 as variation,
    0 as performance,
    COALESCE(AVG(value_consolidated), 0) as valeur_moyenne
  FROM site_indicator_values_consolidated
  WHERE organization_name = org_name
  GROUP BY 
    organization_name, process_code, indicator_code, year,
    axe, enjeux, normes, criteres, process_name, indicator_name,
    unit, frequence, type, formule
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
    valeur_moyenne = EXCLUDED.valeur_moyenne,
    last_updated = now();
END;
$$ LANGUAGE plpgsql;

-- Run the consolidation for TestFiliere
SELECT refresh_consolidated_data_for_organization('TestFiliere');

-- Refresh any materialized views
DO $$
BEGIN
  -- Try to refresh dashboard views if they exist
  BEGIN
    REFRESH MATERIALIZED VIEW IF EXISTS dashboard_performance_view;
  EXCEPTION WHEN OTHERS THEN
    -- View doesn't exist or can't be refreshed
    NULL;
  END;
END $$;