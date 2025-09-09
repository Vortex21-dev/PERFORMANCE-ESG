/*
  # Fix consolidated data structure with proper metadata and monthly grouping

  1. Updates
    - Add missing metadata columns (enjeux, normes, criteres) to consolidated tables
    - Fix monthly data consolidation to prevent indicator repetition
    - Ensure proper grouping by organization, indicator, process, year, month

  2. Data Population
    - Populate consolidated tables with validated data grouped by month
    - Include proper ESG metadata (enjeux, normes, criteres)
    - Calculate sites_count and sites_list per month per indicator

  3. Functions
    - Create refresh function for proper monthly consolidation
    - Ensure no duplicate indicators across months
*/

-- Add missing metadata columns to site_indicator_values_consolidated if they don't exist
DO $$
BEGIN
  -- Add enjeux column
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'site_indicator_values_consolidated' 
    AND column_name = 'enjeux'
  ) THEN
    ALTER TABLE site_indicator_values_consolidated ADD COLUMN enjeux text;
  END IF;

  -- Add normes column
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'site_indicator_values_consolidated' 
    AND column_name = 'normes'
  ) THEN
    ALTER TABLE site_indicator_values_consolidated ADD COLUMN normes text;
  END IF;

  -- Add criteres column
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'site_indicator_values_consolidated' 
    AND column_name = 'criteres'
  ) THEN
    ALTER TABLE site_indicator_values_consolidated ADD COLUMN criteres text;
  END IF;
END $$;

-- Create function to get ESG metadata for indicators
CREATE OR REPLACE FUNCTION get_indicator_esg_metadata(
  p_organization_name text,
  p_indicator_code text
) RETURNS TABLE (
  enjeux text,
  normes text,
  criteres text
) AS $$
BEGIN
  RETURN QUERY
  WITH org_sector AS (
    SELECT sector_name, subsector_name
    FROM organization_sectors
    WHERE organization_name = p_organization_name
  ),
  org_standards AS (
    SELECT unnest(standard_codes) as standard_code
    FROM organization_standards
    WHERE organization_name = p_organization_name
  ),
  standards_names AS (
    SELECT string_agg(s.name, ', ') as normes
    FROM standards s
    JOIN org_standards os ON s.code = os.standard_code
  ),
  sector_issues AS (
    SELECT 
      CASE 
        WHEN os.subsector_name IS NOT NULL THEN
          (SELECT string_agg(i.name, ', ')
           FROM subsector_standards_issues ssi
           JOIN issues i ON i.code = ANY(ssi.issue_codes)
           WHERE ssi.subsector_name = os.subsector_name)
        ELSE
          (SELECT string_agg(i.name, ', ')
           FROM sector_standards_issues ssi
           JOIN issues i ON i.code = ANY(ssi.issue_codes)
           WHERE ssi.sector_name = os.sector_name)
      END as enjeux
    FROM org_sector os
  ),
  sector_criteria AS (
    SELECT 
      CASE 
        WHEN os.subsector_name IS NOT NULL THEN
          (SELECT string_agg(c.name, ', ')
           FROM subsector_standards_issues_criteria ssic
           JOIN criteria c ON c.code = ANY(ssic.criteria_codes)
           WHERE ssic.subsector_name = os.subsector_name)
        ELSE
          (SELECT string_agg(c.name, ', ')
           FROM sector_standards_issues_criteria ssic
           JOIN criteria c ON c.code = ANY(ssic.criteria_codes)
           WHERE ssic.sector_name = os.sector_name)
      END as criteres
    FROM org_sector os
  )
  SELECT 
    COALESCE(si.enjeux, 'Non défini') as enjeux,
    COALESCE(sn.normes, 'Non défini') as normes,
    COALESCE(sc.criteres, 'Non défini') as criteres
  FROM standards_names sn
  CROSS JOIN sector_issues si
  CROSS JOIN sector_criteria sc;
END;
$$ LANGUAGE plpgsql;

-- Create function to refresh consolidated data with proper monthly grouping
-- FIX: Use DELETE + INSERT instead of ON CONFLICT to avoid duplicate row updates
CREATE OR REPLACE FUNCTION refresh_consolidated_data_monthly(p_organization_name text)
RETURNS void AS $$
BEGIN
  -- Clear existing consolidated data for this organization
  DELETE FROM site_indicator_values_consolidated 
  WHERE organization_name = p_organization_name;

  -- Insert consolidated data grouped by month to prevent repetition
  -- FIX: Removed ON CONFLICT clause and ensured proper grouping to prevent duplicates
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
  SELECT DISTINCT ON (
    -- FIX: Use DISTINCT ON to ensure unique combinations and prevent duplicates
    organization_name,
    process_code,
    indicator_code,
    year,
    month,
    COALESCE(site_name, 'consolidated')
  )
    iv.organization_name,
    iv.business_line_name,
    iv.subsidiary_name,
    iv.site_name,
    iv.process_code,
    iv.indicator_code,
    iv.year,
    iv.month, -- CRITICAL: Group by month to prevent repetition
    i.name as indicator_name,
    i.unit,
    i.axe,
    i.type,
    i.formule,
    i.frequence,
    p.name as process_name,
    p.description as process_description,
    meta.enjeux,
    meta.normes,
    meta.criteres,
    
    -- Monthly aggregation based on formula
    CASE 
      WHEN i.formule = 'somme' THEN 
        (SELECT COALESCE(SUM(iv2.value), 0)
         FROM indicator_values iv2
         WHERE iv2.organization_name = iv.organization_name
         AND iv2.indicator_code = iv.indicator_code
         AND iv2.process_code = iv.process_code
         AND iv2.year = iv.year
         AND iv2.month = iv.month -- CRITICAL: Same month only
         AND iv2.status = 'validated')
      WHEN i.formule = 'moyenne' THEN 
        (SELECT COALESCE(AVG(iv2.value), 0)
         FROM indicator_values iv2
         WHERE iv2.organization_name = iv.organization_name
         AND iv2.indicator_code = iv.indicator_code
         AND iv2.process_code = iv.process_code
         AND iv2.year = iv.year
         AND iv2.month = iv.month -- CRITICAL: Same month only
         AND iv2.status = 'validated')
      WHEN i.formule = 'max' THEN 
        (SELECT COALESCE(MAX(iv2.value), 0)
         FROM indicator_values iv2
         WHERE iv2.organization_name = iv.organization_name
         AND iv2.indicator_code = iv.indicator_code
         AND iv2.process_code = iv.process_code
         AND iv2.year = iv.year
         AND iv2.month = iv.month -- CRITICAL: Same month only
         AND iv2.status = 'validated')
      WHEN i.formule = 'min' THEN 
        (SELECT COALESCE(MIN(iv2.value), 0)
         FROM indicator_values iv2
         WHERE iv2.organization_name = iv.organization_name
         AND iv2.indicator_code = iv.indicator_code
         AND iv2.process_code = iv.process_code
         AND iv2.year = iv.year
         AND iv2.month = iv.month -- CRITICAL: Same month only
         AND iv2.status = 'validated')
      ELSE COALESCE(iv.value, 0)
    END as value_consolidated,
    
    -- Count distinct sites for this specific month and indicator
    (SELECT COUNT(DISTINCT iv2.site_name)
     FROM indicator_values iv2
     WHERE iv2.organization_name = iv.organization_name
     AND iv2.indicator_code = iv.indicator_code
     AND iv2.process_code = iv.process_code
     AND iv2.year = iv.year
     AND iv2.month = iv.month -- CRITICAL: Same month only
     AND iv2.status = 'validated'
     AND iv2.site_name IS NOT NULL) as sites_count,
    
    -- List distinct sites for this specific month and indicator
    (SELECT array_agg(DISTINCT iv2.site_name)
     FROM indicator_values iv2
     WHERE iv2.organization_name = iv.organization_name
     AND iv2.indicator_code = iv.indicator_code
     AND iv2.process_code = iv.process_code
     AND iv2.year = iv.year
     AND iv2.month = iv.month -- CRITICAL: Same month only
     AND iv2.status = 'validated'
     AND iv2.site_name IS NOT NULL) as sites_list,
    
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
  AND iv.status = 'validated'
  AND iv.value IS NOT NULL
  -- FIX: Order by to ensure consistent DISTINCT ON behavior
  ORDER BY 
    iv.organization_name,
    iv.process_code,
    iv.indicator_code,
    iv.year,
    iv.month,
    COALESCE(iv.site_name, 'consolidated'),
    iv.created_at DESC; -- Use latest record in case of duplicates

  RAISE NOTICE 'Consolidated data refreshed for organization: %', p_organization_name;
END;
$$ LANGUAGE plpgsql;

-- Execute the refresh for TestFiliere
SELECT refresh_consolidated_data_monthly('TestFiliere');

-- Verify the results
DO $$
DECLARE
  record_count integer;
  site_count integer;
  month_count integer;
BEGIN
  SELECT COUNT(*) INTO record_count
  FROM site_indicator_values_consolidated
  WHERE organization_name = 'TestFiliere';
  
  SELECT COUNT(DISTINCT site_name) INTO site_count
  FROM site_indicator_values_consolidated
  WHERE organization_name = 'TestFiliere'
  AND site_name IS NOT NULL;
  
  SELECT COUNT(DISTINCT month) INTO month_count
  FROM site_indicator_values_consolidated
  WHERE organization_name = 'TestFiliere';
  
  RAISE NOTICE 'Consolidated records created: %, Distinct sites: %, Distinct months: %', record_count, site_count, month_count;
END $$;