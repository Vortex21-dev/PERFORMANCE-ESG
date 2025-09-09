/*
  # Fix consolidation after validation

  1. Problem Analysis
    - Data validated but not appearing in consolidated dashboard
    - Consolidation triggers may not be working properly
    - Views may need refresh after validation

  2. Solutions
    - Fix consolidation function to handle validated data properly
    - Update triggers to fire on validation status change
    - Ensure materialized views are refreshed
    - Add proper error handling and logging

  3. Testing
    - Verify data flows from validation to consolidation
    - Check that dashboard shows validated data immediately
*/

-- Drop existing function if it exists
DROP FUNCTION IF EXISTS refresh_consolidated_data_monthly(text);

-- Create improved consolidation function
CREATE OR REPLACE FUNCTION refresh_consolidated_data_monthly(p_organization_name text)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  rec_count integer;
  error_msg text;
BEGIN
  -- Log start of consolidation
  INSERT INTO system_logs (action, details) 
  VALUES ('consolidation_start', 'Starting consolidation for: ' || p_organization_name);

  -- Clear existing consolidated data for this organization
  DELETE FROM site_indicator_values_consolidated 
  WHERE organization_name = p_organization_name;

  -- Insert consolidated data with proper validation check
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
    performance,
    last_updated
  )
  SELECT 
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
    COALESCE(meta.enjeux, 'Non défini') as enjeux,
    COALESCE(meta.normes, 'Non défini') as normes,
    COALESCE(meta.criteres, 'Non défini') as criteres,
    
    -- Raw value (original value)
    iv.value as value_raw,
    
    -- Consolidated value based on formula
    CASE 
      WHEN i.formule = 'somme' THEN 
        (SELECT COALESCE(SUM(iv2.value), 0)
         FROM indicator_values iv2
         WHERE iv2.organization_name = iv.organization_name
         AND iv2.indicator_code = iv.indicator_code
         AND iv2.process_code = iv.process_code
         AND iv2.year = iv.year
         AND iv2.month = iv.month
         AND iv2.status = 'validated'
         AND iv2.value IS NOT NULL)
      WHEN i.formule = 'moyenne' THEN 
        (SELECT COALESCE(AVG(iv2.value), 0)
         FROM indicator_values iv2
         WHERE iv2.organization_name = iv.organization_name
         AND iv2.indicator_code = iv.indicator_code
         AND iv2.process_code = iv.process_code
         AND iv2.year = iv.year
         AND iv2.month = iv.month
         AND iv2.status = 'validated'
         AND iv2.value IS NOT NULL)
      WHEN i.formule = 'max' THEN 
        (SELECT COALESCE(MAX(iv2.value), 0)
         FROM indicator_values iv2
         WHERE iv2.organization_name = iv.organization_name
         AND iv2.indicator_code = iv.indicator_code
         AND iv2.process_code = iv.process_code
         AND iv2.year = iv.year
         AND iv2.month = iv.month
         AND iv2.status = 'validated'
         AND iv2.value IS NOT NULL)
      WHEN i.formule = 'min' THEN 
        (SELECT COALESCE(MIN(iv2.value), 0)
         FROM indicator_values iv2
         WHERE iv2.organization_name = iv.organization_name
         AND iv2.indicator_code = iv.indicator_code
         AND iv2.process_code = iv.process_code
         AND iv2.year = iv.year
         AND iv2.month = iv.month
         AND iv2.status = 'validated'
         AND iv2.value IS NOT NULL)
      ELSE COALESCE(iv.value, 0)
    END as value_consolidated,
    
    -- Count distinct sites for this indicator/month
    (SELECT COUNT(DISTINCT iv2.site_name)
     FROM indicator_values iv2
     WHERE iv2.organization_name = iv.organization_name
     AND iv2.indicator_code = iv.indicator_code
     AND iv2.process_code = iv.process_code
     AND iv2.year = iv.year
     AND iv2.month = iv.month
     AND iv2.status = 'validated'
     AND iv2.site_name IS NOT NULL
     AND iv2.value IS NOT NULL) as sites_count,
    
    -- List distinct sites for this indicator/month
    (SELECT array_agg(DISTINCT iv2.site_name)
     FROM indicator_values iv2
     WHERE iv2.organization_name = iv.organization_name
     AND iv2.indicator_code = iv.indicator_code
     AND iv2.process_code = iv.process_code
     AND iv2.year = iv.year
     AND iv2.month = iv.month
     AND iv2.status = 'validated'
     AND iv2.site_name IS NOT NULL
     AND iv2.value IS NOT NULL) as sites_list,
    
    0 as target_value,
    0 as previous_year_value,
    0 as variation,
    0 as performance,
    NOW() as last_updated
    
  FROM indicator_values iv
  JOIN indicators i ON i.code = iv.indicator_code
  JOIN processes p ON p.code = iv.process_code
  CROSS JOIN LATERAL get_indicator_esg_metadata(iv.organization_name, iv.indicator_code) meta
  WHERE iv.organization_name = p_organization_name
  AND iv.status = 'validated'  -- CRITICAL: Only validated data
  AND iv.value IS NOT NULL
  GROUP BY 
    iv.organization_name,
    iv.business_line_name,
    iv.subsidiary_name,
    iv.site_name,
    iv.process_code,
    iv.indicator_code,
    iv.year,
    iv.month,
    i.name,
    i.unit,
    i.axe,
    i.type,
    i.formule,
    i.frequence,
    p.name,
    p.description,
    meta.enjeux,
    meta.normes,
    meta.criteres,
    iv.value;

  -- Get count of inserted records
  GET DIAGNOSTICS rec_count = ROW_COUNT;
  
  -- Log completion
  INSERT INTO system_logs (action, details) 
  VALUES ('consolidation_complete', 
          'Consolidated ' || rec_count || ' records for: ' || p_organization_name);

  -- Refresh dashboard performance data
  PERFORM update_dashboard_performance_data();

  -- Log final step
  INSERT INTO system_logs (action, details) 
  VALUES ('dashboard_refresh_complete', 'Dashboard updated for: ' || p_organization_name);

EXCEPTION
  WHEN OTHERS THEN
    error_msg := SQLERRM;
    INSERT INTO system_logs (action, details, error_message) 
    VALUES ('consolidation_error', 'Error for: ' || p_organization_name, error_msg);
    RAISE;
END;
$$;

-- Create trigger function that fires ONLY on validation
CREATE OR REPLACE FUNCTION trigger_consolidation_on_validation()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  -- Only trigger consolidation when status changes TO 'validated'
  IF TG_OP = 'UPDATE' AND OLD.status != 'validated' AND NEW.status = 'validated' THEN
    -- Trigger consolidation for the organization
    PERFORM refresh_consolidated_data_monthly(NEW.organization_name);
    
    -- Log the trigger
    INSERT INTO system_logs (action, details) 
    VALUES ('validation_trigger', 
            'Consolidation triggered for: ' || NEW.organization_name || 
            ' - Indicator: ' || NEW.indicator_code);
  END IF;
  
  RETURN NEW;
END;
$$;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS trigger_consolidation_on_validation ON indicator_values;

-- Create new trigger that fires only on validation
CREATE TRIGGER trigger_consolidation_on_validation
  AFTER UPDATE ON indicator_values
  FOR EACH ROW
  EXECUTE FUNCTION trigger_consolidation_on_validation();

-- Update dashboard performance data function to handle validated data only
CREATE OR REPLACE FUNCTION update_dashboard_performance_data()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  -- Clear existing dashboard data
  DELETE FROM dashboard_performance_data;
  
  -- Insert fresh dashboard data from validated indicators only
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
    valeur_moyenne,
    last_updated
  )
  SELECT 
    iv.organization_name,
    iv.process_code,
    iv.indicator_code,
    iv.year,
    i.axe,
    COALESCE(meta.enjeux, 'Non défini') as enjeux,
    COALESCE(meta.normes, 'Non défini') as normes,
    COALESCE(meta.criteres, 'Non défini') as criteres,
    p.name as processus,
    i.name as indicateur,
    i.unit as unite,
    i.frequence,
    i.type,
    i.formule,
    
    -- Monthly aggregations (only validated data)
    COALESCE(SUM(CASE WHEN iv.month = 1 AND iv.status = 'validated' THEN iv.value END), 0) as janvier,
    COALESCE(SUM(CASE WHEN iv.month = 2 AND iv.status = 'validated' THEN iv.value END), 0) as fevrier,
    COALESCE(SUM(CASE WHEN iv.month = 3 AND iv.status = 'validated' THEN iv.value END), 0) as mars,
    COALESCE(SUM(CASE WHEN iv.month = 4 AND iv.status = 'validated' THEN iv.value END), 0) as avril,
    COALESCE(SUM(CASE WHEN iv.month = 5 AND iv.status = 'validated' THEN iv.value END), 0) as mai,
    COALESCE(SUM(CASE WHEN iv.month = 6 AND iv.status = 'validated' THEN iv.value END), 0) as juin,
    COALESCE(SUM(CASE WHEN iv.month = 7 AND iv.status = 'validated' THEN iv.value END), 0) as juillet,
    COALESCE(SUM(CASE WHEN iv.month = 8 AND iv.status = 'validated' THEN iv.value END), 0) as aout,
    COALESCE(SUM(CASE WHEN iv.month = 9 AND iv.status = 'validated' THEN iv.value END), 0) as septembre,
    COALESCE(SUM(CASE WHEN iv.month = 10 AND iv.status = 'validated' THEN iv.value END), 0) as octobre,
    COALESCE(SUM(CASE WHEN iv.month = 11 AND iv.status = 'validated' THEN iv.value END), 0) as novembre,
    COALESCE(SUM(CASE WHEN iv.month = 12 AND iv.status = 'validated' THEN iv.value END), 0) as decembre,
    
    -- Total value (only validated)
    COALESCE(SUM(CASE WHEN iv.status = 'validated' THEN iv.value END), 0) as valeur_totale,
    0 as valeur_precedente,
    0 as valeur_cible,
    0 as variation,
    0 as performance,
    COALESCE(AVG(CASE WHEN iv.status = 'validated' THEN iv.value END), 0) as valeur_moyenne,
    NOW() as last_updated
    
  FROM indicator_values iv
  JOIN indicators i ON i.code = iv.indicator_code
  JOIN processes p ON p.code = iv.process_code
  CROSS JOIN LATERAL get_indicator_esg_metadata(iv.organization_name, iv.indicator_code) meta
  WHERE iv.status = 'validated'  -- CRITICAL: Only validated data
  AND iv.value IS NOT NULL
  GROUP BY 
    iv.organization_name,
    iv.process_code,
    iv.indicator_code,
    iv.year,
    i.axe,
    i.name,
    i.unit,
    i.frequence,
    i.type,
    i.formule,
    p.name,
    p.description,
    meta.enjeux,
    meta.normes,
    meta.criteres;

  -- Log completion
  INSERT INTO system_logs (action, details) 
  VALUES ('dashboard_refresh_complete', 'Dashboard performance data updated');

EXCEPTION
  WHEN OTHERS THEN
    INSERT INTO system_logs (action, details, error_message) 
    VALUES ('dashboard_refresh_error', 'Error updating dashboard', SQLERRM);
    RAISE;
END;
$$;

-- Create function to refresh materialized views if they exist
CREATE OR REPLACE FUNCTION refresh_dashboard_views()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  -- Try to refresh materialized views (may not exist)
  BEGIN
    REFRESH MATERIALIZED VIEW IF EXISTS dashboard_performance_view;
    INSERT INTO system_logs (action, details) 
    VALUES ('view_refresh', 'Materialized view refreshed');
  EXCEPTION
    WHEN OTHERS THEN
      INSERT INTO system_logs (action, details, error_message) 
      VALUES ('view_refresh_warning', 'Could not refresh materialized view', SQLERRM);
  END;
END;
$$;

-- Update the validation trigger to ensure consolidation happens
CREATE OR REPLACE FUNCTION trigger_consolidation_on_validation()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  -- Trigger consolidation when status changes TO 'validated'
  IF TG_OP = 'UPDATE' AND OLD.status != 'validated' AND NEW.status = 'validated' THEN
    -- Log the validation event
    INSERT INTO system_logs (action, details) 
    VALUES ('data_validated', 
            'Data validated for org: ' || NEW.organization_name || 
            ', indicator: ' || NEW.indicator_code || 
            ', value: ' || COALESCE(NEW.value::text, 'NULL'));
    
    -- Trigger consolidation for the organization
    PERFORM refresh_consolidated_data_monthly(NEW.organization_name);
    
    -- Refresh dashboard views
    PERFORM refresh_dashboard_views();
    
    -- Log completion
    INSERT INTO system_logs (action, details) 
    VALUES ('consolidation_triggered', 
            'Consolidation completed for: ' || NEW.organization_name);
  END IF;
  
  RETURN NEW;
END;
$$;

-- Recreate the trigger
DROP TRIGGER IF EXISTS trigger_consolidation_on_validation ON indicator_values;
CREATE TRIGGER trigger_consolidation_on_validation
  AFTER UPDATE ON indicator_values
  FOR EACH ROW
  EXECUTE FUNCTION trigger_consolidation_on_validation();

-- Force refresh for all organizations with validated data
DO $$
DECLARE
  org_name text;
BEGIN
  FOR org_name IN 
    SELECT DISTINCT organization_name 
    FROM indicator_values 
    WHERE status = 'validated'
  LOOP
    PERFORM refresh_consolidated_data_monthly(org_name);
  END LOOP;
  
  -- Refresh dashboard views
  PERFORM refresh_dashboard_views();
  
  INSERT INTO system_logs (action, details) 
  VALUES ('full_refresh_complete', 'All organizations consolidated');
END;
$$;

-- Create function to manually trigger consolidation (for testing)
CREATE OR REPLACE FUNCTION manual_trigger_consolidation(p_organization_name text)
RETURNS json
LANGUAGE plpgsql
AS $$
DECLARE
  result json;
  validated_count integer;
  consolidated_count integer;
BEGIN
  -- Count validated data
  SELECT COUNT(*) INTO validated_count
  FROM indicator_values
  WHERE organization_name = p_organization_name
  AND status = 'validated'
  AND value IS NOT NULL;
  
  -- Trigger consolidation
  PERFORM refresh_consolidated_data_monthly(p_organization_name);
  
  -- Count consolidated data
  SELECT COUNT(*) INTO consolidated_count
  FROM site_indicator_values_consolidated
  WHERE organization_name = p_organization_name;
  
  -- Refresh views
  PERFORM refresh_dashboard_views();
  
  result := json_build_object(
    'organization', p_organization_name,
    'validated_records', validated_count,
    'consolidated_records', consolidated_count,
    'success', true,
    'timestamp', NOW()
  );
  
  INSERT INTO system_logs (action, details) 
  VALUES ('manual_consolidation', result::text);
  
  RETURN result;
END;
$$;

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION refresh_consolidated_data_monthly(text) TO authenticated;
GRANT EXECUTE ON FUNCTION refresh_dashboard_views() TO authenticated;
GRANT EXECUTE ON FUNCTION manual_trigger_consolidation(text) TO authenticated;