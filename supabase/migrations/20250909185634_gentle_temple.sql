/*
  # Fix duplicate indicators in consolidated view

  1. Problem Analysis
    - Indicators appear multiple times in consolidated view
    - Need to ensure one occurrence per indicator per organization/year
    - Consolidate monthly data properly

  2. Solution
    - Update consolidation function to group by indicator properly
    - Ensure unique records per indicator/process/organization/year
    - Aggregate monthly values correctly

  3. Changes
    - Fix refresh_site_consolidation function
    - Update dashboard_performance_data table structure
    - Add proper DISTINCT and GROUP BY clauses
*/

-- Drop existing function
DROP FUNCTION IF EXISTS refresh_site_consolidation(text);

-- Create improved consolidation function that prevents duplicates
CREATE OR REPLACE FUNCTION refresh_site_consolidation(p_organization_name text)
RETURNS TABLE(
  indicators_processed integer,
  records_created integer,
  validation_errors text[]
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_indicators_processed integer := 0;
  v_records_created integer := 0;
  v_errors text[] := '{}';
  v_current_year integer := EXTRACT(YEAR FROM CURRENT_DATE);
BEGIN
  -- Log start of consolidation
  INSERT INTO system_logs (action, details) 
  VALUES ('CONSOLIDATION_START', 'Starting consolidation for organization: ' || p_organization_name);

  -- Clear existing consolidated data for this organization and current year
  DELETE FROM site_indicator_values_consolidated 
  WHERE organization_name = p_organization_name 
    AND year = v_current_year;

  -- Insert consolidated data with proper grouping to prevent duplicates
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
  SELECT DISTINCT ON (iv.organization_name, iv.process_code, iv.indicator_code, iv.year, iv.month)
    iv.organization_name,
    iv.business_line_name,
    iv.subsidiary_name,
    iv.site_name,
    iv.process_code,
    iv.indicator_code,
    iv.year,
    iv.month,
    
    -- Metadata from indicators table
    i.name as indicator_name,
    i.unit,
    i.axe,
    i.type,
    i.formule,
    i.frequence,
    
    -- Metadata from processes table
    p.name as process_name,
    p.description as process_description,
    
    -- ESG metadata (simplified for now)
    'Enjeux ESG' as enjeux,
    'Normes applicables' as normes,
    'Critères définis' as criteres,
    
    -- Values
    iv.value as value_raw,
    iv.value as value_consolidated,
    1 as sites_count,
    ARRAY[COALESCE(iv.site_name, 'Site principal')] as sites_list,
    
    -- Performance calculations
    0 as target_value,
    0 as previous_year_value,
    0 as variation,
    0 as performance
    
  FROM indicator_values iv
  LEFT JOIN indicators i ON i.code = iv.indicator_code
  LEFT JOIN processes p ON p.code = iv.process_code
  WHERE iv.organization_name = p_organization_name
    AND iv.status = 'validated'  -- Only validated data
    AND iv.year = v_current_year
    AND iv.value IS NOT NULL
  ORDER BY iv.organization_name, iv.process_code, iv.indicator_code, iv.year, iv.month, iv.created_at DESC;

  -- Get count of processed indicators
  GET DIAGNOSTICS v_records_created = ROW_COUNT;

  -- Count unique indicators processed
  SELECT COUNT(DISTINCT iv.indicator_code)
  INTO v_indicators_processed
  FROM indicator_values iv
  WHERE iv.organization_name = p_organization_name
    AND iv.status = 'validated'
    AND iv.year = v_current_year
    AND iv.value IS NOT NULL;

  -- Update dashboard performance data
  DELETE FROM dashboard_performance_data 
  WHERE organization_name = p_organization_name 
    AND year = v_current_year;

  -- Insert aggregated dashboard data (one record per indicator per year)
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
  SELECT DISTINCT
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
    
    -- Monthly aggregation
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
    
    -- Total value based on formula
    CASE 
      WHEN sic.formule = 'somme' THEN COALESCE(SUM(sic.value_consolidated), 0)
      WHEN sic.formule = 'moyenne' THEN COALESCE(AVG(sic.value_consolidated), 0)
      WHEN sic.formule = 'dernier_mois' THEN COALESCE(
        (SELECT value_consolidated FROM site_indicator_values_consolidated s2 
         WHERE s2.organization_name = sic.organization_name 
           AND s2.indicator_code = sic.indicator_code 
           AND s2.year = sic.year 
         ORDER BY s2.month DESC LIMIT 1), 0)
      ELSE COALESCE(SUM(sic.value_consolidated), 0)
    END as valeur_totale,
    
    0 as valeur_precedente,
    0 as valeur_cible,
    0 as variation,
    0 as performance,
    COALESCE(AVG(sic.value_consolidated), 0) as valeur_moyenne
    
  FROM site_indicator_values_consolidated sic
  WHERE sic.organization_name = p_organization_name
    AND sic.year = v_current_year
  GROUP BY 
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
    sic.formule;

  -- Log completion
  INSERT INTO system_logs (action, details) 
  VALUES ('CONSOLIDATION_COMPLETE', 
          'Consolidation completed for ' || p_organization_name || 
          '. Indicators: ' || v_indicators_processed || 
          ', Records: ' || v_records_created);

  -- Return results
  RETURN QUERY SELECT v_indicators_processed, v_records_created, v_errors;
END;
$$;

-- Update the trigger to be more robust
DROP TRIGGER IF EXISTS trigger_consolidation_after_validation ON indicator_values;

CREATE OR REPLACE FUNCTION trigger_consolidation_after_validation()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result record;
BEGIN
  -- Only trigger when status changes to 'validated'
  IF TG_OP = 'UPDATE' AND 
     OLD.status IS DISTINCT FROM NEW.status AND 
     NEW.status = 'validated' THEN
    
    -- Log the validation
    INSERT INTO system_logs (action, details) 
    VALUES ('VALIDATION_TRIGGER', 
            'Triggering consolidation for organization: ' || NEW.organization_name || 
            ', indicator: ' || NEW.indicator_code);
    
    -- Trigger consolidation for this organization
    SELECT * INTO v_result 
    FROM refresh_site_consolidation(NEW.organization_name);
    
    -- Log the result
    INSERT INTO system_logs (action, details) 
    VALUES ('CONSOLIDATION_TRIGGERED', 
            'Consolidation result: ' || v_result.indicators_processed || ' indicators, ' || 
            v_result.records_created || ' records');
  END IF;
  
  RETURN COALESCE(NEW, OLD);
END;
$$;

-- Recreate the trigger
CREATE TRIGGER trigger_consolidation_after_validation
  AFTER UPDATE ON indicator_values
  FOR EACH ROW
  EXECUTE FUNCTION trigger_consolidation_after_validation();

-- Force refresh for all organizations with validated data
DO $$
DECLARE
  org_record record;
  result_record record;
BEGIN
  FOR org_record IN 
    SELECT DISTINCT organization_name 
    FROM indicator_values 
    WHERE status = 'validated' 
      AND year = EXTRACT(YEAR FROM CURRENT_DATE)
  LOOP
    SELECT * INTO result_record 
    FROM refresh_site_consolidation(org_record.organization_name);
    
    INSERT INTO system_logs (action, details) 
    VALUES ('INITIAL_CONSOLIDATION', 
            'Initial consolidation for ' || org_record.organization_name || 
            ': ' || result_record.indicators_processed || ' indicators processed');
  END LOOP;
END;
$$;