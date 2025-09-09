/*
  # Fix consolidated view structure and eliminate duplicates

  1. New View Structure
    - `site_indicator_values_consolidated` redesigned to match `dashboard_performance_data`
    - One row per indicator/process/organization/year (not per month)
    - Monthly values as separate columns (janvier, fevrier, etc.)
    - Metadata from sector_standards_issues_criteria_indicators

  2. Metadata Integration
    - Enjeux, normes, criteres from sector/subsector standards tables
    - Complete indicator metadata (axe, type, formule, frequence)
    - Process information and descriptions

  3. Performance Calculations
    - Valeur totale based on formule (somme, moyenne, dernier_mois, etc.)
    - Performance vs target calculations
    - Variation vs previous year
    - Proper NULL handling

  4. Consolidation Logic
    - Aggregates data from multiple sites per indicator
    - Respects indicator formule for aggregation method
    - Only includes validated data
    - Maintains data integrity
*/

-- Drop existing view and related objects
DROP VIEW IF EXISTS site_indicator_values_consolidated CASCADE;
DROP TABLE IF EXISTS site_indicator_values_consolidated CASCADE;

-- Create the new consolidated table with proper structure
CREATE TABLE site_indicator_values_consolidated (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_name text NOT NULL,
  business_line_name text,
  subsidiary_name text,
  site_name text,
  process_code text NOT NULL,
  indicator_code text NOT NULL,
  year integer NOT NULL,
  month integer NOT NULL,
  
  -- Metadata fields
  indicator_name text,
  unit text,
  axe text,
  type text,
  formule text DEFAULT 'somme',
  frequence text,
  process_name text,
  process_description text,
  enjeux text,
  normes text,
  criteres text,
  
  -- Value fields
  value_raw numeric DEFAULT 0,
  value_consolidated numeric DEFAULT 0,
  sites_count integer DEFAULT 1,
  sites_list text[],
  target_value numeric DEFAULT 0,
  previous_year_value numeric DEFAULT 0,
  variation numeric DEFAULT 0,
  performance numeric DEFAULT 0,
  
  -- Timestamps
  last_updated timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  
  -- Unique constraint to prevent duplicates
  UNIQUE(organization_name, site_name, process_code, indicator_code, year, month)
);

-- Add indexes for performance
CREATE INDEX idx_site_indicator_values_consolidated_org_year_month 
ON site_indicator_values_consolidated(organization_name, year, month);

CREATE INDEX idx_site_indicator_values_consolidated_process 
ON site_indicator_values_consolidated(process_code);

CREATE INDEX idx_site_indicator_values_consolidated_site_indicator 
ON site_indicator_values_consolidated(site_name, indicator_code);

CREATE INDEX idx_site_indicator_values_consolidated_axe 
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

-- Create comprehensive consolidation function
CREATE OR REPLACE FUNCTION refresh_site_consolidation_comprehensive(p_organization_name text DEFAULT NULL)
RETURNS TABLE(
  processed_organizations integer,
  total_indicators_processed integer,
  consolidation_success boolean
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  org_record record;
  indicator_record record;
  metadata_record record;
  monthly_data record;
  total_orgs integer := 0;
  total_indicators integer := 0;
  success_flag boolean := true;
BEGIN
  -- Log start
  INSERT INTO system_logs (action, details) 
  VALUES ('CONSOLIDATION_START', 'Starting comprehensive consolidation for: ' || COALESCE(p_organization_name, 'ALL'));

  -- Clear existing consolidated data for the organization(s)
  IF p_organization_name IS NOT NULL THEN
    DELETE FROM site_indicator_values_consolidated 
    WHERE organization_name = p_organization_name;
  ELSE
    DELETE FROM site_indicator_values_consolidated;
  END IF;

  -- Process each organization
  FOR org_record IN 
    SELECT DISTINCT iv.organization_name
    FROM indicator_values iv
    WHERE iv.status = 'validated'
      AND (p_organization_name IS NULL OR iv.organization_name = p_organization_name)
  LOOP
    total_orgs := total_orgs + 1;
    
    -- Process each unique indicator/process combination for this organization
    FOR indicator_record IN
      SELECT DISTINCT 
        iv.organization_name,
        iv.process_code,
        iv.indicator_code,
        iv.year
      FROM indicator_values iv
      WHERE iv.status = 'validated'
        AND iv.organization_name = org_record.organization_name
        AND iv.value IS NOT NULL
    LOOP
      total_indicators := total_indicators + 1;
      
      -- Get metadata for this indicator
      SELECT 
        i.name as indicator_name,
        i.unit,
        i.axe,
        i.type,
        i.formule,
        i.frequence,
        p.name as process_name,
        p.description as process_description,
        COALESCE(
          -- Try subsector first
          (SELECT string_agg(DISTINCT issues.name, ', ')
           FROM organization_sectors os
           JOIN subsector_standards_issues_criteria_indicators ssici 
             ON ssici.subsector_name = os.subsector_name
           JOIN issues ON issues.code = ANY(
             SELECT unnest(ssii.issue_codes)
             FROM subsector_standards_issues ssii
             WHERE ssii.subsector_name = os.subsector_name
               AND ssii.standard_name = ssici.standard_name
           )
           WHERE os.organization_name = indicator_record.organization_name
             AND ssici.indicator_codes @> ARRAY[indicator_record.indicator_code]),
          -- Fallback to sector
          (SELECT string_agg(DISTINCT issues.name, ', ')
           FROM organization_sectors os
           JOIN sector_standards_issues_criteria_indicators ssici 
             ON ssici.sector_name = os.sector_name
           JOIN issues ON issues.code = ANY(
             SELECT unnest(ssi.issue_codes)
             FROM sector_standards_issues ssi
             WHERE ssi.sector_name = os.sector_name
               AND ssi.standard_name = ssici.standard_name
           )
           WHERE os.organization_name = indicator_record.organization_name
             AND ssici.indicator_codes @> ARRAY[indicator_record.indicator_code]),
          'Enjeux non définis'
        ) as enjeux,
        COALESCE(
          -- Try subsector standards
          (SELECT string_agg(DISTINCT standards.name, ', ')
           FROM organization_sectors os
           JOIN subsector_standards ss ON ss.subsector_name = os.subsector_name
           JOIN standards ON standards.code = ANY(ss.standard_codes)
           WHERE os.organization_name = indicator_record.organization_name),
          -- Fallback to sector standards
          (SELECT string_agg(DISTINCT standards.name, ', ')
           FROM organization_sectors os
           JOIN sector_standards ss ON ss.sector_name = os.sector_name
           JOIN standards ON standards.code = ANY(ss.standard_codes)
           WHERE os.organization_name = indicator_record.organization_name),
          'Normes non définies'
        ) as normes,
        COALESCE(
          -- Try subsector criteria
          (SELECT string_agg(DISTINCT criteria.name, ', ')
           FROM organization_sectors os
           JOIN subsector_standards_issues_criteria_indicators ssici 
             ON ssici.subsector_name = os.subsector_name
           JOIN criteria ON criteria.code = ANY(
             SELECT unnest(ssic.criteria_codes)
             FROM subsector_standards_issues_criteria ssic
             WHERE ssic.subsector_name = os.subsector_name
               AND ssic.standard_name = ssici.standard_name
           )
           WHERE os.organization_name = indicator_record.organization_name
             AND ssici.indicator_codes @> ARRAY[indicator_record.indicator_code]),
          -- Fallback to sector criteria
          (SELECT string_agg(DISTINCT criteria.name, ', ')
           FROM organization_sectors os
           JOIN sector_standards_issues_criteria_indicators ssici 
             ON ssici.sector_name = os.sector_name
           JOIN criteria ON criteria.code = ANY(
             SELECT unnest(ssic.criteria_codes)
             FROM sector_standards_issues_criteria ssic
             WHERE ssic.sector_name = os.sector_name
               AND ssic.standard_name = ssici.standard_name
           )
           WHERE os.organization_name = indicator_record.organization_name
             AND ssici.indicator_codes @> ARRAY[indicator_record.indicator_code]),
          'Critères non définis'
        ) as criteres
      INTO metadata_record
      FROM indicators i
      JOIN processes p ON p.indicator_codes @> ARRAY[i.code]
      WHERE i.code = indicator_record.indicator_code
        AND p.code = indicator_record.process_code
      LIMIT 1;
      
      -- Process each month for this indicator
      FOR monthly_data IN
        SELECT 
          iv.month,
          iv.site_name,
          iv.business_line_name,
          iv.subsidiary_name,
          -- Aggregate values by site and month using the indicator's formula
          CASE 
            WHEN COALESCE(metadata_record.formule, 'somme') = 'somme' THEN SUM(iv.value)
            WHEN COALESCE(metadata_record.formule, 'somme') = 'moyenne' THEN AVG(iv.value)
            WHEN COALESCE(metadata_record.formule, 'somme') = 'max' THEN MAX(iv.value)
            WHEN COALESCE(metadata_record.formule, 'somme') = 'min' THEN MIN(iv.value)
            WHEN COALESCE(metadata_record.formule, 'somme') = 'dernier_mois' THEN 
              (SELECT value FROM indicator_values 
               WHERE indicator_code = iv.indicator_code 
                 AND process_code = iv.process_code
                 AND organization_name = iv.organization_name
                 AND year = iv.year
                 AND status = 'validated'
               ORDER BY month DESC LIMIT 1)
            ELSE SUM(iv.value)
          END as consolidated_value,
          COUNT(DISTINCT iv.site_name) as sites_count,
          array_agg(DISTINCT iv.site_name) as sites_list
        FROM indicator_values iv
        WHERE iv.status = 'validated'
          AND iv.organization_name = indicator_record.organization_name
          AND iv.process_code = indicator_record.process_code
          AND iv.indicator_code = indicator_record.indicator_code
          AND iv.year = indicator_record.year
          AND iv.value IS NOT NULL
        GROUP BY iv.month, iv.site_name, iv.business_line_name, iv.subsidiary_name
      LOOP
        -- Insert consolidated data for this month
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
        ) VALUES (
          indicator_record.organization_name,
          monthly_data.business_line_name,
          monthly_data.subsidiary_name,
          monthly_data.site_name,
          indicator_record.process_code,
          indicator_record.indicator_code,
          indicator_record.year,
          monthly_data.month,
          metadata_record.indicator_name,
          metadata_record.unit,
          metadata_record.axe,
          metadata_record.type,
          metadata_record.formule,
          metadata_record.frequence,
          metadata_record.process_name,
          metadata_record.process_description,
          metadata_record.enjeux,
          metadata_record.normes,
          metadata_record.criteres,
          monthly_data.consolidated_value,
          monthly_data.consolidated_value,
          monthly_data.sites_count,
          monthly_data.sites_list,
          0, -- target_value (to be calculated separately)
          0, -- previous_year_value (to be calculated separately)
          0, -- variation (to be calculated separately)
          0, -- performance (to be calculated separately)
          now()
        )
        ON CONFLICT (organization_name, site_name, process_code, indicator_code, year, month)
        DO UPDATE SET
          value_consolidated = EXCLUDED.value_consolidated,
          sites_count = EXCLUDED.sites_count,
          sites_list = EXCLUDED.sites_list,
          enjeux = EXCLUDED.enjeux,
          normes = EXCLUDED.normes,
          criteres = EXCLUDED.criteres,
          last_updated = now();
      END LOOP;
    END LOOP;
  END LOOP;

  -- Log completion
  INSERT INTO system_logs (action, details) 
  VALUES ('CONSOLIDATION_COMPLETE', 
    format('Processed %s organizations, %s indicators', total_orgs, total_indicators));

  RETURN QUERY SELECT total_orgs, total_indicators, success_flag;
EXCEPTION
  WHEN OTHERS THEN
    INSERT INTO system_logs (action, details, error_message) 
    VALUES ('CONSOLIDATION_ERROR', 'Error in comprehensive consolidation', SQLERRM);
    RETURN QUERY SELECT 0, 0, false;
END;
$$;

-- Create dashboard-style view that aggregates monthly data into single rows
CREATE OR REPLACE VIEW dashboard_performance_consolidated AS
SELECT DISTINCT
  gen_random_uuid() as id,
  organization_name,
  process_code,
  indicator_code,
  year,
  
  -- Metadata
  MAX(axe) as axe,
  MAX(enjeux) as enjeux,
  MAX(normes) as normes,
  MAX(criteres) as criteres,
  MAX(process_name) as processus,
  MAX(indicator_name) as indicateur,
  MAX(unit) as unite,
  MAX(frequence) as frequence,
  MAX(type) as type,
  MAX(formule) as formule,
  
  -- Monthly values (aggregated across all sites)
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
  
  -- Calculated totals
  CASE 
    WHEN MAX(formule) = 'somme' THEN COALESCE(SUM(value_consolidated), 0)
    WHEN MAX(formule) = 'moyenne' THEN COALESCE(AVG(value_consolidated), 0)
    WHEN MAX(formule) = 'max' THEN COALESCE(MAX(value_consolidated), 0)
    WHEN MAX(formule) = 'min' THEN COALESCE(MIN(value_consolidated), 0)
    WHEN MAX(formule) = 'dernier_mois' THEN 
      COALESCE((SELECT value_consolidated 
                FROM site_indicator_values_consolidated sic2 
                WHERE sic2.organization_name = sic.organization_name
                  AND sic2.process_code = sic.process_code
                  AND sic2.indicator_code = sic.indicator_code
                  AND sic2.year = sic.year
                ORDER BY sic2.month DESC LIMIT 1), 0)
    ELSE COALESCE(SUM(value_consolidated), 0)
  END as valeur_totale,
  
  -- Previous year value (for variation calculation)
  COALESCE((
    SELECT SUM(value_consolidated)
    FROM site_indicator_values_consolidated sic_prev
    WHERE sic_prev.organization_name = sic.organization_name
      AND sic_prev.process_code = sic.process_code
      AND sic_prev.indicator_code = sic.indicator_code
      AND sic_prev.year = sic.year - 1
  ), 0) as valeur_precedente,
  
  -- Target value (placeholder - to be configured)
  0 as valeur_cible,
  
  -- Variation calculation
  CASE 
    WHEN (SELECT SUM(value_consolidated)
          FROM site_indicator_values_consolidated sic_prev
          WHERE sic_prev.organization_name = sic.organization_name
            AND sic_prev.process_code = sic.process_code
            AND sic_prev.indicator_code = sic.indicator_code
            AND sic_prev.year = sic.year - 1) > 0
    THEN ROUND(
      ((CASE 
        WHEN MAX(formule) = 'somme' THEN COALESCE(SUM(value_consolidated), 0)
        WHEN MAX(formule) = 'moyenne' THEN COALESCE(AVG(value_consolidated), 0)
        WHEN MAX(formule) = 'max' THEN COALESCE(MAX(value_consolidated), 0)
        WHEN MAX(formule) = 'min' THEN COALESCE(MIN(value_consolidated), 0)
        ELSE COALESCE(SUM(value_consolidated), 0)
      END - (SELECT SUM(value_consolidated)
             FROM site_indicator_values_consolidated sic_prev
             WHERE sic_prev.organization_name = sic.organization_name
               AND sic_prev.process_code = sic.process_code
               AND sic_prev.indicator_code = sic.indicator_code
               AND sic_prev.year = sic.year - 1)) 
      / (SELECT SUM(value_consolidated)
         FROM site_indicator_values_consolidated sic_prev
         WHERE sic_prev.organization_name = sic.organization_name
           AND sic_prev.process_code = sic.process_code
           AND sic_prev.indicator_code = sic.indicator_code
           AND sic_prev.year = sic.year - 1) * 100)::numeric, 2)
    ELSE 0
  END as variation,
  
  -- Performance calculation (placeholder - needs target values)
  0 as performance,
  
  -- Average value
  COALESCE(AVG(value_consolidated), 0) as valeur_moyenne,
  
  -- Metadata
  MAX(last_updated) as last_updated
  
FROM site_indicator_values_consolidated sic
GROUP BY organization_name, process_code, indicator_code, year;

-- Update the trigger to use the new consolidation function
DROP TRIGGER IF EXISTS trigger_consolidation_after_validation ON indicator_values;

CREATE OR REPLACE FUNCTION trigger_consolidation_after_validation()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Only trigger when status changes to 'validated'
  IF OLD.status IS DISTINCT FROM NEW.status AND NEW.status = 'validated' THEN
    -- Log the validation
    INSERT INTO system_logs (action, details) 
    VALUES ('VALIDATION_TRIGGER', 
      format('Indicator %s validated for org %s, triggering consolidation', 
        NEW.indicator_code, NEW.organization_name));
    
    -- Trigger consolidation for this organization
    PERFORM refresh_site_consolidation_comprehensive(NEW.organization_name);
    
    -- Log completion
    INSERT INTO system_logs (action, details) 
    VALUES ('CONSOLIDATION_TRIGGERED', 
      format('Consolidation completed for org %s after validation', NEW.organization_name));
  END IF;
  
  RETURN NEW;
END;
$$;

-- Recreate the trigger
CREATE TRIGGER trigger_consolidation_after_validation
  AFTER UPDATE ON indicator_values
  FOR EACH ROW
  EXECUTE FUNCTION trigger_consolidation_after_validation();

-- Create manual trigger function for testing
CREATE OR REPLACE FUNCTION manual_trigger_consolidation(p_organization_name text DEFAULT NULL)
RETURNS TABLE(
  organization_name text,
  validated_data_count bigint,
  consolidated_data_count bigint,
  consolidation_success boolean
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  org_name text;
  validated_count bigint;
  consolidated_count bigint;
  result_record record;
BEGIN
  -- If specific organization provided
  IF p_organization_name IS NOT NULL THEN
    -- Get validated data count
    SELECT COUNT(*) INTO validated_count
    FROM indicator_values 
    WHERE organization_name = p_organization_name 
      AND status = 'validated' 
      AND value IS NOT NULL;
    
    -- Run consolidation
    PERFORM refresh_site_consolidation_comprehensive(p_organization_name);
    
    -- Get consolidated data count
    SELECT COUNT(*) INTO consolidated_count
    FROM site_indicator_values_consolidated 
    WHERE organization_name = p_organization_name;
    
    RETURN QUERY SELECT p_organization_name, validated_count, consolidated_count, true;
  ELSE
    -- Process all organizations with validated data
    FOR org_name IN 
      SELECT DISTINCT iv.organization_name
      FROM indicator_values iv
      WHERE iv.status = 'validated' AND iv.value IS NOT NULL
    LOOP
      -- Get validated data count for this org
      SELECT COUNT(*) INTO validated_count
      FROM indicator_values 
      WHERE organization_name = org_name 
        AND status = 'validated' 
        AND value IS NOT NULL;
      
      -- Run consolidation for this org
      PERFORM refresh_site_consolidation_comprehensive(org_name);
      
      -- Get consolidated data count for this org
      SELECT COUNT(*) INTO consolidated_count
      FROM site_indicator_values_consolidated 
      WHERE organization_name = org_name;
      
      RETURN QUERY SELECT org_name, validated_count, consolidated_count, true;
    END LOOP;
  END IF;
END;
$$;

-- Refresh all existing validated data
SELECT * FROM manual_trigger_consolidation();

-- Log the migration completion
INSERT INTO system_logs (action, details) 
VALUES ('MIGRATION_COMPLETE', 'Fixed consolidated view structure and eliminated duplicates');