/*
  # Fix consolidated view refresh after validation

  1. Problem Analysis
    - Validated data not appearing in consolidated view
    - Triggers not properly refreshing materialized views
    - Dashboard not showing updated data after validation

  2. Solutions
    - Fix trigger to properly refresh consolidated data
    - Ensure materialized views are refreshed
    - Add proper logging for debugging
    - Create manual refresh function for testing

  3. Security
    - Maintain RLS policies
    - Ensure proper permissions for refresh functions
*/

-- Drop existing problematic triggers
DROP TRIGGER IF EXISTS refresh_dashboard_on_indicator_update ON indicator_values;
DROP TRIGGER IF EXISTS trigger_update_consolidation_on_indicator_change ON indicator_values;
DROP TRIGGER IF EXISTS trigger_update_dashboard_performance_data ON indicator_values;

-- Drop existing functions that might be causing issues
DROP FUNCTION IF EXISTS trigger_refresh_dashboard_view();
DROP FUNCTION IF EXISTS trigger_consolidation_update();
DROP FUNCTION IF EXISTS update_dashboard_performance_data();
DROP FUNCTION IF EXISTS manual_trigger_consolidation(text);

-- Create improved consolidation refresh function
CREATE OR REPLACE FUNCTION refresh_consolidated_data_after_validation()
RETURNS TRIGGER AS $$
BEGIN
  -- Only process if status changed to 'validated'
  IF TG_OP = 'UPDATE' AND OLD.status != 'validated' AND NEW.status = 'validated' THEN
    -- Log the validation event
    INSERT INTO system_logs (action, details) 
    VALUES (
      'VALIDATION_CONSOLIDATION_TRIGGER',
      format('Validated indicator %s for org %s, triggering consolidation', 
             NEW.indicator_code, NEW.organization_name)
    );
    
    -- Refresh consolidated data for this organization
    PERFORM refresh_site_consolidation(NEW.organization_name);
    
    -- Refresh dashboard performance data
    PERFORM update_dashboard_performance_for_org(NEW.organization_name);
    
    -- Log completion
    INSERT INTO system_logs (action, details) 
    VALUES (
      'CONSOLIDATION_COMPLETED',
      format('Consolidation completed for org %s after validation', NEW.organization_name)
    );
  END IF;
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to refresh site consolidation for an organization
CREATE OR REPLACE FUNCTION refresh_site_consolidation(org_name TEXT)
RETURNS INTEGER AS $$
DECLARE
  rows_affected INTEGER := 0;
BEGIN
  -- Delete existing consolidated data for this organization
  DELETE FROM site_indicator_values_consolidated 
  WHERE organization_name = org_name;
  
  -- Insert fresh consolidated data from validated indicator values
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
    COALESCE(i.name, iv.indicator_code) as indicator_name,
    COALESCE(i.unit, '') as unit,
    COALESCE(i.axe, 'Non défini') as axe,
    COALESCE(i.type, 'primaire') as type,
    COALESCE(i.formule, 'somme') as formule,
    COALESCE(i.frequence, 'mensuelle') as frequence,
    COALESCE(p.name, iv.process_code) as process_name,
    p.description as process_description,
    'Données consolidées' as enjeux,
    'Standards appliqués' as normes,
    'Critères définis' as criteres,
    iv.value as value_raw,
    iv.value as value_consolidated,
    1 as sites_count,
    ARRAY[COALESCE(iv.site_name, 'Site principal')] as sites_list,
    0 as target_value,
    0 as previous_year_value,
    0 as variation,
    0 as performance
  FROM indicator_values iv
  LEFT JOIN indicators i ON i.code = iv.indicator_code
  LEFT JOIN processes p ON p.code = iv.process_code
  WHERE iv.organization_name = org_name
    AND iv.status = 'validated'  -- Only validated data
    AND iv.value IS NOT NULL;
  
  GET DIAGNOSTICS rows_affected = ROW_COUNT;
  
  -- Log the consolidation
  INSERT INTO system_logs (action, details) 
  VALUES (
    'SITE_CONSOLIDATION_REFRESH',
    format('Refreshed consolidation for %s: %s rows affected', org_name, rows_affected)
  );
  
  RETURN rows_affected;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to update dashboard performance data for an organization
CREATE OR REPLACE FUNCTION update_dashboard_performance_for_org(org_name TEXT)
RETURNS INTEGER AS $$
DECLARE
  rows_affected INTEGER := 0;
BEGIN
  -- Delete existing dashboard data for this organization
  DELETE FROM dashboard_performance_data 
  WHERE organization_name = org_name;
  
  -- Insert fresh dashboard data from validated consolidated data
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
    sic.process_name,
    sic.indicator_name,
    sic.unit,
    sic.frequence,
    sic.type,
    sic.formule,
    -- Monthly aggregation from consolidated data
    COALESCE(SUM(CASE WHEN sic.month = 1 THEN sic.value_consolidated END), 0) as janvier,
    COALESCE(SUM(CASE WHEN sic.month = 2 THEN sic.value_consolidated END), 0) as fevrier,
    COALESCE(SUM(CASE WHEN sic.month = 3 THEN sic.value_consolidated END), 0) as mars,
    COALESCE(SUM(CASE WHEN sic.month = 4 THEN sic.value_consolidated END), 0) as avril,
    COALESCE(SUM(CASE WHEN sic.month = 5 THEN sic.value_consolidated END), 0) as mai,
    COALESCE(SUM(CASE WHEN sic.month = 6 THEN sic.value_consolidated END), 0) as juin,
    COALESCE(SUM(CASE WHEN sic.month = 7 THEN sic.value_consolidated END), 0) as juillet,
    COALESCE(SUM(CASE WHEN sic.month = 8 THEN sic.value_consolidated END), 0) as aout,
    COALESCE(SUM(CASE WHEN sic.month = 9 THEN sic.value_consolidated END), 0) as septembre,
    COALESCE(SUM(CASE WHEN sic.month = 10 THEN sic.value_consolidated END), 0) as octobre,
    COALESCE(SUM(CASE WHEN sic.month = 11 THEN sic.value_consolidated END), 0) as novembre,
    COALESCE(SUM(CASE WHEN sic.month = 12 THEN sic.value_consolidated END), 0) as decembre,
    COALESCE(SUM(sic.value_consolidated), 0) as valeur_totale,
    0 as valeur_precedente,
    0 as valeur_cible,
    0 as variation,
    0 as performance,
    COALESCE(AVG(sic.value_consolidated), 0) as valeur_moyenne
  FROM site_indicator_values_consolidated sic
  WHERE sic.organization_name = org_name
  GROUP BY 
    sic.organization_name, sic.process_code, sic.indicator_code, sic.year,
    sic.axe, sic.enjeux, sic.normes, sic.criteres, sic.process_name,
    sic.indicator_name, sic.unit, sic.frequence, sic.type, sic.formule;
  
  GET DIAGNOSTICS rows_affected = ROW_COUNT;
  
  -- Log the dashboard update
  INSERT INTO system_logs (action, details) 
  VALUES (
    'DASHBOARD_PERFORMANCE_UPDATE',
    format('Updated dashboard performance for %s: %s rows affected', org_name, rows_affected)
  );
  
  RETURN rows_affected;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the new trigger that fires after validation
CREATE TRIGGER trigger_consolidation_after_validation
  AFTER UPDATE ON indicator_values
  FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM NEW.status AND NEW.status = 'validated')
  EXECUTE FUNCTION refresh_consolidated_data_after_validation();

-- Create manual trigger function for testing
CREATE OR REPLACE FUNCTION manual_trigger_consolidation(org_name TEXT DEFAULT NULL)
RETURNS TABLE(
  organization TEXT,
  validated_count INTEGER,
  consolidated_count INTEGER,
  dashboard_count INTEGER
) AS $$
DECLARE
  org_to_process TEXT;
  validated_cnt INTEGER;
  consolidated_cnt INTEGER;
  dashboard_cnt INTEGER;
BEGIN
  -- If no org specified, process all organizations with validated data
  FOR org_to_process IN 
    SELECT DISTINCT iv.organization_name 
    FROM indicator_values iv 
    WHERE (org_name IS NULL OR iv.organization_name = org_name)
      AND iv.status = 'validated'
  LOOP
    -- Count validated data
    SELECT COUNT(*) INTO validated_cnt
    FROM indicator_values iv
    WHERE iv.organization_name = org_to_process
      AND iv.status = 'validated';
    
    -- Refresh consolidation
    PERFORM refresh_site_consolidation(org_to_process);
    
    -- Count consolidated data
    SELECT COUNT(*) INTO consolidated_cnt
    FROM site_indicator_values_consolidated sic
    WHERE sic.organization_name = org_to_process;
    
    -- Update dashboard
    PERFORM update_dashboard_performance_for_org(org_to_process);
    
    -- Count dashboard data
    SELECT COUNT(*) INTO dashboard_cnt
    FROM dashboard_performance_data dpd
    WHERE dpd.organization_name = org_to_process;
    
    -- Return results
    organization := org_to_process;
    validated_count := validated_cnt;
    consolidated_count := consolidated_cnt;
    dashboard_count := dashboard_cnt;
    
    RETURN NEXT;
  END LOOP;
  
  RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Refresh all existing validated data immediately
SELECT * FROM manual_trigger_consolidation();

-- Log the migration completion
INSERT INTO system_logs (action, details) 
VALUES (
  'MIGRATION_CONSOLIDATION_FIX',
  'Fixed consolidation triggers and refreshed all validated data'
);