/*
  # Fix consolidation to require validated data only

  1. Problem
    - Data appears in consolidated view immediately after entry (draft status)
    - Should only consolidate validated data

  2. Solution
    - Update consolidation functions to filter only validated data
    - Fix triggers to only consolidate on validation, not on insert
    - Update existing consolidated data to remove non-validated entries

  3. Changes
    - Modify refresh_consolidated_data_monthly function
    - Update consolidation triggers
    - Clean existing consolidated data
*/

-- Update the consolidation refresh function to only include validated data
CREATE OR REPLACE FUNCTION refresh_consolidated_data_monthly(p_organization_name text)
RETURNS void AS $$
BEGIN
  -- Clear existing consolidated data for this organization
  DELETE FROM site_indicator_values_consolidated 
  WHERE organization_name = p_organization_name;

  -- Insert consolidated data ONLY from validated indicator values
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
    MAX(i.name) as indicator_name,
    MAX(i.unit) as unit,
    MAX(i.axe) as axe,
    MAX(i.type) as type,
    MAX(i.formule) as formule,
    MAX(i.frequence) as frequence,
    MAX(p.name) as process_name,
    MAX(p.description) as process_description,
    MAX(meta.enjeux) as enjeux,
    MAX(meta.normes) as normes,
    MAX(meta.criteres) as criteres,
    
    -- Monthly aggregation based on formula - ONLY VALIDATED DATA
    CASE 
      WHEN MAX(i.formule) = 'somme' THEN 
        COALESCE(SUM(iv.value), 0)
      WHEN MAX(i.formule) = 'moyenne' THEN 
        COALESCE(AVG(iv.value), 0)
      WHEN MAX(i.formule) = 'max' THEN 
        COALESCE(MAX(iv.value), 0)
      WHEN MAX(i.formule) = 'min' THEN 
        COALESCE(MIN(iv.value), 0)
      ELSE COALESCE(AVG(iv.value), 0)
    END as value_raw,
    
    -- Same calculation for consolidated value
    CASE 
      WHEN MAX(i.formule) = 'somme' THEN 
        COALESCE(SUM(iv.value), 0)
      WHEN MAX(i.formule) = 'moyenne' THEN 
        COALESCE(AVG(iv.value), 0)
      WHEN MAX(i.formule) = 'max' THEN 
        COALESCE(MAX(iv.value), 0)
      WHEN MAX(i.formule) = 'min' THEN 
        COALESCE(MIN(iv.value), 0)
      ELSE COALESCE(AVG(iv.value), 0)
    END as value_consolidated,
    
    -- Count distinct sites for this specific month and indicator
    COUNT(DISTINCT iv.site_name) as sites_count,
    
    -- List distinct sites for this specific month and indicator
    array_agg(DISTINCT iv.site_name) FILTER (WHERE iv.site_name IS NOT NULL) as sites_list,
    
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
  AND iv.status = 'validated' -- CRITICAL: Only validated data
  AND iv.value IS NOT NULL
  GROUP BY 
    iv.organization_name,
    iv.business_line_name,
    iv.subsidiary_name,
    iv.site_name,
    iv.process_code,
    iv.indicator_code,
    iv.year,
    iv.month;

  RAISE NOTICE 'Consolidated data refreshed for organization: % (validated data only)', p_organization_name;
END;
$$ LANGUAGE plpgsql;

-- Update the consolidation trigger to only fire on validation status change
DROP TRIGGER IF EXISTS trigger_update_consolidation_on_indicator_change ON indicator_values;

CREATE OR REPLACE FUNCTION trigger_consolidation_update()
RETURNS TRIGGER AS $$
BEGIN
  -- Only trigger consolidation when status changes to 'validated'
  IF (TG_OP = 'UPDATE' AND NEW.status = 'validated' AND OLD.status != 'validated') OR
     (TG_OP = 'INSERT' AND NEW.status = 'validated') THEN
    
    -- Refresh consolidated data for this organization
    PERFORM refresh_consolidated_data_monthly(NEW.organization_name);
    
    RAISE NOTICE 'Consolidation triggered for organization: % due to validation', NEW.organization_name;
  END IF;
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Recreate the trigger with the updated function
CREATE TRIGGER trigger_update_consolidation_on_indicator_change
  AFTER INSERT OR UPDATE ON indicator_values
  FOR EACH ROW
  EXECUTE FUNCTION trigger_consolidation_update();

-- Update dashboard performance data trigger to only include validated data
CREATE OR REPLACE FUNCTION update_dashboard_performance_data()
RETURNS TRIGGER AS $$
BEGIN
  -- Only update dashboard when data is validated
  IF (TG_OP = 'UPDATE' AND NEW.status = 'validated' AND OLD.status != 'validated') OR
     (TG_OP = 'INSERT' AND NEW.status = 'validated') THEN
    
    -- Update or insert dashboard performance data
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
      NEW.organization_name,
      NEW.process_code,
      NEW.indicator_code,
      NEW.year,
      i.axe,
      meta.enjeux,
      meta.normes,
      meta.criteres,
      p.name as processus,
      i.name as indicateur,
      i.unit as unite,
      i.frequence,
      i.type,
      i.formule,
      
      -- Monthly values - only from validated data
      COALESCE((SELECT SUM(value) FROM indicator_values WHERE organization_name = NEW.organization_name AND indicator_code = NEW.indicator_code AND process_code = NEW.process_code AND year = NEW.year AND month = 1 AND status = 'validated'), 0) as janvier,
      COALESCE((SELECT SUM(value) FROM indicator_values WHERE organization_name = NEW.organization_name AND indicator_code = NEW.indicator_code AND process_code = NEW.process_code AND year = NEW.year AND month = 2 AND status = 'validated'), 0) as fevrier,
      COALESCE((SELECT SUM(value) FROM indicator_values WHERE organization_name = NEW.organization_name AND indicator_code = NEW.indicator_code AND process_code = NEW.process_code AND year = NEW.year AND month = 3 AND status = 'validated'), 0) as mars,
      COALESCE((SELECT SUM(value) FROM indicator_values WHERE organization_name = NEW.organization_name AND indicator_code = NEW.indicator_code AND process_code = NEW.process_code AND year = NEW.year AND month = 4 AND status = 'validated'), 0) as avril,
      COALESCE((SELECT SUM(value) FROM indicator_values WHERE organization_name = NEW.organization_name AND indicator_code = NEW.indicator_code AND process_code = NEW.process_code AND year = NEW.year AND month = 5 AND status = 'validated'), 0) as mai,
      COALESCE((SELECT SUM(value) FROM indicator_values WHERE organization_name = NEW.organization_name AND indicator_code = NEW.indicator_code AND process_code = NEW.process_code AND year = NEW.year AND month = 6 AND status = 'validated'), 0) as juin,
      COALESCE((SELECT SUM(value) FROM indicator_values WHERE organization_name = NEW.organization_name AND indicator_code = NEW.indicator_code AND process_code = NEW.process_code AND year = NEW.year AND month = 7 AND status = 'validated'), 0) as juillet,
      COALESCE((SELECT SUM(value) FROM indicator_values WHERE organization_name = NEW.organization_name AND indicator_code = NEW.indicator_code AND process_code = NEW.process_code AND year = NEW.year AND month = 8 AND status = 'validated'), 0) as aout,
      COALESCE((SELECT SUM(value) FROM indicator_values WHERE organization_name = NEW.organization_name AND indicator_code = NEW.indicator_code AND process_code = NEW.process_code AND year = NEW.year AND month = 9 AND status = 'validated'), 0) as septembre,
      COALESCE((SELECT SUM(value) FROM indicator_values WHERE organization_name = NEW.organization_name AND indicator_code = NEW.indicator_code AND process_code = NEW.process_code AND year = NEW.year AND month = 10 AND status = 'validated'), 0) as octobre,
      COALESCE((SELECT SUM(value) FROM indicator_values WHERE organization_name = NEW.organization_name AND indicator_code = NEW.indicator_code AND process_code = NEW.process_code AND year = NEW.year AND month = 11 AND status = 'validated'), 0) as novembre,
      COALESCE((SELECT SUM(value) FROM indicator_values WHERE organization_name = NEW.organization_name AND indicator_code = NEW.indicator_code AND process_code = NEW.process_code AND year = NEW.year AND month = 12 AND status = 'validated'), 0) as decembre,
      
      -- Calculate total value from validated data only
      COALESCE((SELECT SUM(value) FROM indicator_values WHERE organization_name = NEW.organization_name AND indicator_code = NEW.indicator_code AND process_code = NEW.process_code AND year = NEW.year AND status = 'validated'), 0) as valeur_totale,
      
      0 as valeur_precedente,
      0 as valeur_cible,
      0 as variation,
      0 as performance,
      0 as valeur_moyenne,
      NOW() as last_updated
      
    FROM indicators i
    JOIN processes p ON p.code = NEW.process_code
    CROSS JOIN LATERAL get_indicator_esg_metadata(NEW.organization_name, NEW.indicator_code) meta
    WHERE i.code = NEW.indicator_code
    
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
      last_updated = NOW();
  END IF;
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Clean existing consolidated data that contains non-validated entries
DELETE FROM site_indicator_values_consolidated 
WHERE id IN (
  SELECT DISTINCT sic.id
  FROM site_indicator_values_consolidated sic
  WHERE NOT EXISTS (
    SELECT 1 
    FROM indicator_values iv 
    WHERE iv.organization_name = sic.organization_name
    AND iv.indicator_code = sic.indicator_code
    AND iv.process_code = sic.process_code
    AND iv.year = sic.year
    AND iv.month = sic.month
    AND iv.status = 'validated'
    AND iv.value IS NOT NULL
  )
);

-- Clean existing dashboard performance data that contains non-validated entries
DELETE FROM dashboard_performance_data 
WHERE id IN (
  SELECT DISTINCT dpd.id
  FROM dashboard_performance_data dpd
  WHERE NOT EXISTS (
    SELECT 1 
    FROM indicator_values iv 
    WHERE iv.organization_name = dpd.organization_name
    AND iv.indicator_code = dpd.indicator_code
    AND iv.process_code = dpd.process_code
    AND iv.year = dpd.year
    AND iv.status = 'validated'
    AND iv.value IS NOT NULL
  )
);

-- Refresh consolidated data for all organizations with validated data only
DO $$
DECLARE
  org_record RECORD;
BEGIN
  FOR org_record IN 
    SELECT DISTINCT organization_name 
    FROM indicator_values 
    WHERE status = 'validated'
  LOOP
    PERFORM refresh_consolidated_data_monthly(org_record.organization_name);
    RAISE NOTICE 'Refreshed consolidated data for organization: %', org_record.organization_name;
  END LOOP;
END $$;

-- Verify the fix
DO $$
DECLARE
  total_consolidated integer;
  validated_source integer;
BEGIN
  SELECT COUNT(*) INTO total_consolidated
  FROM site_indicator_values_consolidated;
  
  SELECT COUNT(*) INTO validated_source
  FROM indicator_values
  WHERE status = 'validated' AND value IS NOT NULL;
  
  RAISE NOTICE 'Consolidated records: %, Source validated records: %', total_consolidated, validated_source;
  
  -- Check for any non-validated data in consolidated view
  IF EXISTS (
    SELECT 1 
    FROM site_indicator_values_consolidated sic
    WHERE NOT EXISTS (
      SELECT 1 
      FROM indicator_values iv 
      WHERE iv.organization_name = sic.organization_name
      AND iv.indicator_code = sic.indicator_code
      AND iv.process_code = sic.process_code
      AND iv.year = sic.year
      AND iv.month = sic.month
      AND iv.status = 'validated'
    )
  ) THEN
    RAISE WARNING 'Some consolidated data may still contain non-validated entries';
  ELSE
    RAISE NOTICE 'All consolidated data is now from validated sources only';
  END IF;
END $$;