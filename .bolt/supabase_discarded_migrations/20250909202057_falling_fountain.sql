/*
  # Fix consolidated view metadata retrieval

  1. Problem
    - Enjeux, normes, critères not properly retrieved from standards tables
    - Missing joins with sector_standards_issues_criteria_indicators and subsector_standards_issues_criteria_indicators

  2. Solution
    - Add proper joins to retrieve metadata from standards tables
    - Use organization sector/subsector to determine which table to use
    - Aggregate enjeux, normes, critères properly
    - Maintain dashboard_performance_data structure
*/

-- Drop existing view and recreate with proper metadata joins
DROP VIEW IF EXISTS site_indicator_values_consolidated CASCADE;

-- Create improved consolidated view with proper metadata retrieval
CREATE VIEW site_indicator_values_consolidated AS
WITH organization_metadata AS (
  -- Get organization sector/subsector info
  SELECT DISTINCT
    os.organization_name,
    os.sector_name,
    os.subsector_name,
    CASE WHEN os.subsector_name IS NOT NULL THEN 'subsector' ELSE 'sector' END as metadata_source
  FROM organization_sectors os
),
indicator_metadata AS (
  -- Get comprehensive metadata for each indicator
  SELECT DISTINCT
    i.code as indicator_code,
    i.name as indicator_name,
    i.unit,
    i.axe,
    i.type,
    i.formule,
    i.frequence,
    p.code as process_code,
    p.name as process_name,
    p.description as process_description,
    om.organization_name,
    om.sector_name,
    om.subsector_name,
    om.metadata_source,
    
    -- Get enjeux from sector tables
    COALESCE(
      (SELECT string_agg(DISTINCT iss.name, ', ' ORDER BY iss.name)
       FROM subsector_standards_issues_criteria_indicators ssici
       JOIN issues iss ON iss.code = ANY(ssici.issue_codes)
       WHERE ssici.subsector_name = om.subsector_name
       AND i.code = ANY(ssici.indicator_codes)
       AND om.metadata_source = 'subsector'),
      (SELECT string_agg(DISTINCT iss.name, ', ' ORDER BY iss.name)
       FROM sector_standards_issues_criteria_indicators ssici
       JOIN issues iss ON iss.code = ANY(ssici.issue_codes)
       WHERE ssici.sector_name = om.sector_name
       AND i.code = ANY(ssici.indicator_codes)
       AND om.metadata_source = 'sector'),
      'Enjeux non définis'
    ) as enjeux,
    
    -- Get normes from organization standards
    COALESCE(
      (SELECT string_agg(DISTINCT s.name, ', ' ORDER BY s.name)
       FROM organization_standards os_std
       JOIN standards s ON s.code = ANY(os_std.standard_codes)
       WHERE os_std.organization_name = om.organization_name),
      'Normes non définies'
    ) as normes,
    
    -- Get critères from sector tables
    COALESCE(
      (SELECT string_agg(DISTINCT c.name, ', ' ORDER BY c.name)
       FROM subsector_standards_issues_criteria_indicators ssici
       JOIN criteria c ON c.code = ANY(ssici.criteria_codes)
       WHERE ssici.subsector_name = om.subsector_name
       AND i.code = ANY(ssici.indicator_codes)
       AND om.metadata_source = 'subsector'),
      (SELECT string_agg(DISTINCT c.name, ', ' ORDER BY c.name)
       FROM sector_standards_issues_criteria_indicators ssici
       JOIN criteria c ON c.code = ANY(ssici.criteria_codes)
       WHERE ssici.sector_name = om.sector_name
       AND i.code = ANY(ssici.indicator_codes)
       AND om.metadata_source = 'sector'),
      'Critères non définis'
    ) as criteres
    
  FROM indicators i
  CROSS JOIN processes p
  CROSS JOIN organization_metadata om
  WHERE i.code = ANY(p.indicator_codes)
),
consolidated_data AS (
  -- Consolidate indicator values by organization/business_line/subsidiary/site/process/indicator/year
  SELECT 
    iv.organization_name,
    iv.business_line_name,
    iv.subsidiary_name,
    iv.site_name,
    iv.process_code,
    iv.indicator_code,
    iv.year,
    im.indicator_name,
    im.unit,
    im.axe,
    im.type,
    im.formule,
    im.frequence,
    im.process_name,
    im.process_description,
    im.enjeux,
    im.normes,
    im.criteres,
    
    -- Monthly aggregations based on formula
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(CASE WHEN iv.month = 1 THEN iv.value END), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(CASE WHEN iv.month = 1 THEN iv.value END), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(CASE WHEN iv.month = 1 THEN iv.value END), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(CASE WHEN iv.month = 1 THEN iv.value END), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE(
        (SELECT iv2.value FROM indicator_values iv2 
         WHERE iv2.organization_name = iv.organization_name 
         AND iv2.process_code = iv.process_code 
         AND iv2.indicator_code = iv.indicator_code 
         AND iv2.year = iv.year 
         AND iv2.month = 1
         AND iv2.status = 'validated'
         ORDER BY iv2.month DESC LIMIT 1), 0)
      ELSE COALESCE(SUM(CASE WHEN iv.month = 1 THEN iv.value END), 0)
    END as janvier,
    
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(CASE WHEN iv.month = 2 THEN iv.value END), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(CASE WHEN iv.month = 2 THEN iv.value END), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(CASE WHEN iv.month = 2 THEN iv.value END), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(CASE WHEN iv.month = 2 THEN iv.value END), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE(
        (SELECT iv2.value FROM indicator_values iv2 
         WHERE iv2.organization_name = iv.organization_name 
         AND iv2.process_code = iv.process_code 
         AND iv2.indicator_code = iv.indicator_code 
         AND iv2.year = iv.year 
         AND iv2.month = 2
         AND iv2.status = 'validated'
         ORDER BY iv2.month DESC LIMIT 1), 0)
      ELSE COALESCE(SUM(CASE WHEN iv.month = 2 THEN iv.value END), 0)
    END as fevrier,
    
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(CASE WHEN iv.month = 3 THEN iv.value END), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(CASE WHEN iv.month = 3 THEN iv.value END), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(CASE WHEN iv.month = 3 THEN iv.value END), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(CASE WHEN iv.month = 3 THEN iv.value END), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE(
        (SELECT iv2.value FROM indicator_values iv2 
         WHERE iv2.organization_name = iv.organization_name 
         AND iv2.process_code = iv.process_code 
         AND iv2.indicator_code = iv.indicator_code 
         AND iv2.year = iv.year 
         AND iv2.month = 3
         AND iv2.status = 'validated'
         ORDER BY iv2.month DESC LIMIT 1), 0)
      ELSE COALESCE(SUM(CASE WHEN iv.month = 3 THEN iv.value END), 0)
    END as mars,
    
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(CASE WHEN iv.month = 4 THEN iv.value END), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(CASE WHEN iv.month = 4 THEN iv.value END), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(CASE WHEN iv.month = 4 THEN iv.value END), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(CASE WHEN iv.month = 4 THEN iv.value END), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE(
        (SELECT iv2.value FROM indicator_values iv2 
         WHERE iv2.organization_name = iv.organization_name 
         AND iv2.process_code = iv.process_code 
         AND iv2.indicator_code = iv.indicator_code 
         AND iv2.year = iv.year 
         AND iv2.month = 4
         AND iv2.status = 'validated'
         ORDER BY iv2.month DESC LIMIT 1), 0)
      ELSE COALESCE(SUM(CASE WHEN iv.month = 4 THEN iv.value END), 0)
    END as avril,
    
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(CASE WHEN iv.month = 5 THEN iv.value END), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(CASE WHEN iv.month = 5 THEN iv.value END), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(CASE WHEN iv.month = 5 THEN iv.value END), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(CASE WHEN iv.month = 5 THEN iv.value END), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE(
        (SELECT iv2.value FROM indicator_values iv2 
         WHERE iv2.organization_name = iv.organization_name 
         AND iv2.process_code = iv.process_code 
         AND iv2.indicator_code = iv.indicator_code 
         AND iv2.year = iv.year 
         AND iv2.month = 5
         AND iv2.status = 'validated'
         ORDER BY iv2.month DESC LIMIT 1), 0)
      ELSE COALESCE(SUM(CASE WHEN iv.month = 5 THEN iv.value END), 0)
    END as mai,
    
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(CASE WHEN iv.month = 6 THEN iv.value END), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(CASE WHEN iv.month = 6 THEN iv.value END), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(CASE WHEN iv.month = 6 THEN iv.value END), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(CASE WHEN iv.month = 6 THEN iv.value END), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE(
        (SELECT iv2.value FROM indicator_values iv2 
         WHERE iv2.organization_name = iv.organization_name 
         AND iv2.process_code = iv.process_code 
         AND iv2.indicator_code = iv.indicator_code 
         AND iv2.year = iv.year 
         AND iv2.month = 6
         AND iv2.status = 'validated'
         ORDER BY iv2.month DESC LIMIT 1), 0)
      ELSE COALESCE(SUM(CASE WHEN iv.month = 6 THEN iv.value END), 0)
    END as juin,
    
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(CASE WHEN iv.month = 7 THEN iv.value END), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(CASE WHEN iv.month = 7 THEN iv.value END), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(CASE WHEN iv.month = 7 THEN iv.value END), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(CASE WHEN iv.month = 7 THEN iv.value END), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE(
        (SELECT iv2.value FROM indicator_values iv2 
         WHERE iv2.organization_name = iv.organization_name 
         AND iv2.process_code = iv.process_code 
         AND iv2.indicator_code = iv.indicator_code 
         AND iv2.year = iv.year 
         AND iv2.month = 7
         AND iv2.status = 'validated'
         ORDER BY iv2.month DESC LIMIT 1), 0)
      ELSE COALESCE(SUM(CASE WHEN iv.month = 7 THEN iv.value END), 0)
    END as juillet,
    
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(CASE WHEN iv.month = 8 THEN iv.value END), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(CASE WHEN iv.month = 8 THEN iv.value END), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(CASE WHEN iv.month = 8 THEN iv.value END), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(CASE WHEN iv.month = 8 THEN iv.value END), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE(
        (SELECT iv2.value FROM indicator_values iv2 
         WHERE iv2.organization_name = iv.organization_name 
         AND iv2.process_code = iv.process_code 
         AND iv2.indicator_code = iv.indicator_code 
         AND iv2.year = iv.year 
         AND iv2.month = 8
         AND iv2.status = 'validated'
         ORDER BY iv2.month DESC LIMIT 1), 0)
      ELSE COALESCE(SUM(CASE WHEN iv.month = 8 THEN iv.value END), 0)
    END as aout,
    
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(CASE WHEN iv.month = 9 THEN iv.value END), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(CASE WHEN iv.month = 9 THEN iv.value END), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(CASE WHEN iv.month = 9 THEN iv.value END), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(CASE WHEN iv.month = 9 THEN iv.value END), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE(
        (SELECT iv2.value FROM indicator_values iv2 
         WHERE iv2.organization_name = iv.organization_name 
         AND iv2.process_code = iv.process_code 
         AND iv2.indicator_code = iv.indicator_code 
         AND iv2.year = iv.year 
         AND iv2.month = 9
         AND iv2.status = 'validated'
         ORDER BY iv2.month DESC LIMIT 1), 0)
      ELSE COALESCE(SUM(CASE WHEN iv.month = 9 THEN iv.value END), 0)
    END as septembre,
    
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(CASE WHEN iv.month = 10 THEN iv.value END), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(CASE WHEN iv.month = 10 THEN iv.value END), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(CASE WHEN iv.month = 10 THEN iv.value END), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(CASE WHEN iv.month = 10 THEN iv.value END), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE(
        (SELECT iv2.value FROM indicator_values iv2 
         WHERE iv2.organization_name = iv.organization_name 
         AND iv2.process_code = iv.process_code 
         AND iv2.indicator_code = iv.indicator_code 
         AND iv2.year = iv.year 
         AND iv2.month = 10
         AND iv2.status = 'validated'
         ORDER BY iv2.month DESC LIMIT 1), 0)
      ELSE COALESCE(SUM(CASE WHEN iv.month = 10 THEN iv.value END), 0)
    END as octobre,
    
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(CASE WHEN iv.month = 11 THEN iv.value END), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(CASE WHEN iv.month = 11 THEN iv.value END), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(CASE WHEN iv.month = 11 THEN iv.value END), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(CASE WHEN iv.month = 11 THEN iv.value END), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE(
        (SELECT iv2.value FROM indicator_values iv2 
         WHERE iv2.organization_name = iv.organization_name 
         AND iv2.process_code = iv.process_code 
         AND iv2.indicator_code = iv.indicator_code 
         AND iv2.year = iv.year 
         AND iv2.month = 11
         AND iv2.status = 'validated'
         ORDER BY iv2.month DESC LIMIT 1), 0)
      ELSE COALESCE(SUM(CASE WHEN iv.month = 11 THEN iv.value END), 0)
    END as novembre,
    
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(CASE WHEN iv.month = 12 THEN iv.value END), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(CASE WHEN iv.month = 12 THEN iv.value END), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(CASE WHEN iv.month = 12 THEN iv.value END), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(CASE WHEN iv.month = 12 THEN iv.value END), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE(
        (SELECT iv2.value FROM indicator_values iv2 
         WHERE iv2.organization_name = iv.organization_name 
         AND iv2.process_code = iv.process_code 
         AND iv2.indicator_code = iv.indicator_code 
         AND iv2.year = iv.year 
         AND iv2.month = 12
         AND iv2.status = 'validated'
         ORDER BY iv2.month DESC LIMIT 1), 0)
      ELSE COALESCE(SUM(CASE WHEN iv.month = 12 THEN iv.value END), 0)
    END as decembre,
    
    -- Calculate total value based on formula
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(iv.value), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(iv.value), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(iv.value), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(iv.value), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE(
        (SELECT iv2.value FROM indicator_values iv2 
         WHERE iv2.organization_name = iv.organization_name 
         AND iv2.process_code = iv.process_code 
         AND iv2.indicator_code = iv.indicator_code 
         AND iv2.year = iv.year 
         AND iv2.status = 'validated'
         ORDER BY iv2.month DESC LIMIT 1), 0)
      ELSE COALESCE(SUM(iv.value), 0)
    END as valeur_totale,
    
    -- Previous year value (for variation calculation)
    COALESCE(
      (SELECT 
        CASE 
          WHEN im.formule = 'somme' THEN SUM(iv_prev.value)
          WHEN im.formule = 'moyenne' THEN AVG(iv_prev.value)
          WHEN im.formule = 'max' THEN MAX(iv_prev.value)
          WHEN im.formule = 'min' THEN MIN(iv_prev.value)
          WHEN im.formule = 'dernier_mois' THEN 
            (SELECT iv_prev2.value FROM indicator_values iv_prev2 
             WHERE iv_prev2.organization_name = iv.organization_name 
             AND iv_prev2.process_code = iv.process_code 
             AND iv_prev2.indicator_code = iv.indicator_code 
             AND iv_prev2.year = iv.year - 1
             AND iv_prev2.status = 'validated'
             ORDER BY iv_prev2.month DESC LIMIT 1)
          ELSE SUM(iv_prev.value)
        END
       FROM indicator_values iv_prev 
       WHERE iv_prev.organization_name = iv.organization_name 
       AND iv_prev.process_code = iv.process_code 
       AND iv_prev.indicator_code = iv.indicator_code 
       AND iv_prev.year = iv.year - 1
       AND iv_prev.status = 'validated'), 0) as valeur_precedente,
    
    -- Target value (default to 0 for now)
    0 as valeur_cible,
    
    -- Count of sites contributing to this indicator
    COUNT(DISTINCT COALESCE(iv.site_name, 'organization_level')) as sites_count,
    
    -- List of sites contributing
    array_agg(DISTINCT COALESCE(iv.site_name, 'organization_level')) as sites_list,
    
    -- Last update timestamp
    MAX(iv.updated_at) as last_updated
    
  FROM indicator_values iv
  JOIN indicator_metadata im ON (
    iv.indicator_code = im.indicator_code 
    AND iv.process_code = im.process_code
    AND iv.organization_name = im.organization_name
  )
  WHERE iv.status = 'validated'
    AND iv.value IS NOT NULL
  GROUP BY 
    iv.organization_name,
    iv.business_line_name,
    iv.subsidiary_name,
    iv.site_name,
    iv.process_code,
    iv.indicator_code,
    iv.year,
    im.indicator_name,
    im.unit,
    im.axe,
    im.type,
    im.formule,
    im.frequence,
    im.process_name,
    im.process_description,
    im.enjeux,
    im.normes,
    im.criteres
),
final_consolidated AS (
  SELECT 
    gen_random_uuid() as id,
    cd.*,
    
    -- Calculate variation percentage
    CASE 
      WHEN cd.valeur_precedente > 0 THEN 
        ROUND(((cd.valeur_totale - cd.valeur_precedente) / cd.valeur_precedente * 100)::numeric, 2)
      ELSE 0
    END as variation,
    
    -- Calculate performance percentage (vs target)
    CASE 
      WHEN cd.valeur_cible > 0 THEN 
        ROUND((cd.valeur_totale / cd.valeur_cible * 100)::numeric, 2)
      ELSE 0
    END as performance,
    
    -- Calculate average value
    ROUND((
      COALESCE(cd.janvier, 0) + COALESCE(cd.fevrier, 0) + COALESCE(cd.mars, 0) + 
      COALESCE(cd.avril, 0) + COALESCE(cd.mai, 0) + COALESCE(cd.juin, 0) + 
      COALESCE(cd.juillet, 0) + COALESCE(cd.aout, 0) + COALESCE(cd.septembre, 0) + 
      COALESCE(cd.octobre, 0) + COALESCE(cd.novembre, 0) + COALESCE(cd.decembre, 0)
    ) / 12.0, 2) as valeur_moyenne,
    
    now() as created_at,
    now() as updated_at
    
  FROM consolidated_data cd
)
SELECT * FROM final_consolidated
ORDER BY organization_name, business_line_name NULLS LAST, subsidiary_name NULLS LAST, site_name NULLS LAST, process_code, indicator_code;

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_site_indicator_values_consolidated_org_year 
ON site_indicator_values_consolidated(organization_name, year);

CREATE INDEX IF NOT EXISTS idx_site_indicator_values_consolidated_hierarchy 
ON site_indicator_values_consolidated(organization_name, business_line_name, subsidiary_name, site_name);

CREATE INDEX IF NOT EXISTS idx_site_indicator_values_consolidated_indicator 
ON site_indicator_values_consolidated(indicator_code, process_code);

CREATE INDEX IF NOT EXISTS idx_site_indicator_values_consolidated_axe 
ON site_indicator_values_consolidated(axe);

-- Enable RLS
ALTER TABLE site_indicator_values_consolidated ENABLE ROW LEVEL SECURITY;

-- Create RLS policy
CREATE POLICY "Users can access their organization consolidated data"
  ON site_indicator_values_consolidated
  FOR ALL
  TO authenticated
  USING (organization_name IN (
    SELECT organization_name 
    FROM profiles 
    WHERE email = (jwt() ->> 'email')
  ));

-- Update trigger function to properly refresh consolidated view
CREATE OR REPLACE FUNCTION refresh_site_consolidation_after_validation()
RETURNS TRIGGER AS $$
BEGIN
  -- Log the validation event
  INSERT INTO system_logs (action, details)
  VALUES (
    'VALIDATION_CONSOLIDATION_TRIGGER',
    format('Validation detected for indicator %s in organization %s - triggering consolidation', 
           NEW.indicator_code, NEW.organization_name)
  );
  
  -- Refresh consolidated data for this organization
  PERFORM refresh_site_consolidation(NEW.organization_name);
  
  -- Update dashboard performance data
  PERFORM update_dashboard_performance_for_org(NEW.organization_name);
  
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  -- Log any errors
  INSERT INTO system_logs (action, details, error_message)
  VALUES (
    'VALIDATION_CONSOLIDATION_ERROR',
    format('Error during consolidation for organization %s', NEW.organization_name),
    SQLERRM
  );
  
  -- Don't fail the validation, just log the error
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate the trigger with proper conditions
DROP TRIGGER IF EXISTS trigger_consolidation_after_validation ON indicator_values;

CREATE TRIGGER trigger_consolidation_after_validation
  AFTER UPDATE ON indicator_values
  FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM NEW.status AND NEW.status = 'validated')
  EXECUTE FUNCTION refresh_site_consolidation_after_validation();

-- Function to manually trigger consolidation for testing
CREATE OR REPLACE FUNCTION manual_trigger_consolidation(p_organization_name text DEFAULT NULL)
RETURNS TABLE(
  organization_name text,
  validated_indicators bigint,
  consolidated_indicators bigint,
  success boolean
) AS $$
BEGIN
  IF p_organization_name IS NOT NULL THEN
    -- Consolidate specific organization
    PERFORM refresh_site_consolidation(p_organization_name);
    PERFORM update_dashboard_performance_for_org(p_organization_name);
    
    RETURN QUERY
    SELECT 
      p_organization_name::text,
      (SELECT COUNT(*) FROM indicator_values iv WHERE iv.organization_name = p_organization_name AND iv.status = 'validated')::bigint,
      (SELECT COUNT(*) FROM site_indicator_values_consolidated siv WHERE siv.organization_name = p_organization_name)::bigint,
      true;
  ELSE
    -- Consolidate all organizations with validated data
    FOR organization_name IN 
      SELECT DISTINCT iv.organization_name 
      FROM indicator_values iv 
      WHERE iv.status = 'validated'
    LOOP
      PERFORM refresh_site_consolidation(organization_name);
      PERFORM update_dashboard_performance_for_org(organization_name);
      
      RETURN QUERY
      SELECT 
        organization_name::text,
        (SELECT COUNT(*) FROM indicator_values iv WHERE iv.organization_name = organization_name AND iv.status = 'validated')::bigint,
        (SELECT COUNT(*) FROM site_indicator_values_consolidated siv WHERE siv.organization_name = organization_name)::bigint,
        true;
    END LOOP;
  END IF;
  
  -- Log the manual consolidation
  INSERT INTO system_logs (action, details)
  VALUES (
    'MANUAL_CONSOLIDATION_COMPLETE',
    format('Manual consolidation completed for %s', COALESCE(p_organization_name, 'all organizations'))
  );
  
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger immediate consolidation for all organizations with validated data
SELECT * FROM manual_trigger_consolidation();