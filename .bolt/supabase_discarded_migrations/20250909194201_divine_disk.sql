/*
  # Fix hierarchical consolidation display

  1. Database Changes
    - Update consolidated view to support hierarchical aggregation
    - Add business line and subsidiary level consolidation
    - Ensure proper grouping by organizational hierarchy

  2. View Structure
    - Organization level: Shows business lines consolidated
    - Business line level: Shows subsidiaries consolidated
    - Subsidiary level: Shows sites consolidated
    - Site level: Shows individual site data

  3. Consolidation Logic
    - Respect organizational hierarchy for aggregation
    - Proper grouping by level (organization > business_line > subsidiary > site)
    - Maintain data integrity across all levels
*/

-- Drop existing view and recreate with hierarchical support
DROP VIEW IF EXISTS site_indicator_values_consolidated CASCADE;

-- Create enhanced consolidated view with hierarchical support
CREATE OR REPLACE VIEW site_indicator_values_consolidated AS
WITH indicator_metadata AS (
  -- Get comprehensive metadata for all indicators
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
    p.organization_name,
    
    -- Get enjeux (issues) from sector/subsector standards
    COALESCE(
      (SELECT string_agg(DISTINCT iss.name, ', ')
       FROM organization_sectors os
       LEFT JOIN sector_standards_issues ssi ON ssi.sector_name = os.sector_name
       LEFT JOIN issues iss ON iss.code = ANY(ssi.issue_codes)
       WHERE os.organization_name = p.organization_name),
      (SELECT string_agg(DISTINCT iss.name, ', ')
       FROM organization_sectors os
       LEFT JOIN subsector_standards_issues sssi ON sssi.subsector_name = os.subsector_name
       LEFT JOIN issues iss ON iss.code = ANY(sssi.issue_codes)
       WHERE os.organization_name = p.organization_name),
      'Enjeux non définis'
    ) as enjeux,
    
    -- Get normes (standards) from organization standards
    COALESCE(
      (SELECT string_agg(DISTINCT std.name, ', ')
       FROM organization_standards ost
       LEFT JOIN standards std ON std.code = ANY(ost.standard_codes)
       WHERE ost.organization_name = p.organization_name),
      'Normes non définies'
    ) as normes,
    
    -- Get critères from sector/subsector standards criteria
    COALESCE(
      (SELECT string_agg(DISTINCT crit.name, ', ')
       FROM organization_sectors os
       LEFT JOIN sector_standards_issues_criteria ssic ON ssic.sector_name = os.sector_name
       LEFT JOIN criteria crit ON crit.code = ANY(ssic.criteria_codes)
       WHERE os.organization_name = p.organization_name),
      (SELECT string_agg(DISTINCT crit.name, ', ')
       FROM organization_sectors os
       LEFT JOIN subsector_standards_issues_criteria sssic ON sssic.subsector_name = os.subsector_name
       LEFT JOIN criteria crit ON crit.code = ANY(sssic.criteria_codes)
       WHERE os.organization_name = p.organization_name),
      'Critères non définis'
    ) as criteres
    
  FROM indicators i
  CROSS JOIN processes p
  WHERE i.code = ANY(p.indicator_codes)
),

-- Site level data (individual sites)
site_level_data AS (
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
    
    -- Monthly aggregation based on formula
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(CASE WHEN iv.month = 1 THEN iv.value END), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(CASE WHEN iv.month = 1 THEN iv.value END), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(CASE WHEN iv.month = 1 THEN iv.value END), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(CASE WHEN iv.month = 1 THEN iv.value END), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE((
        SELECT iv2.value FROM indicator_values iv2 
        WHERE iv2.organization_name = iv.organization_name 
        AND iv2.indicator_code = iv.indicator_code 
        AND iv2.process_code = iv.process_code
        AND iv2.site_name = iv.site_name
        AND iv2.year = iv.year 
        AND iv2.status = 'validated'
        ORDER BY iv2.month DESC LIMIT 1
      ), 0)
      ELSE COALESCE(SUM(CASE WHEN iv.month = 1 THEN iv.value END), 0)
    END as janvier,
    
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(CASE WHEN iv.month = 2 THEN iv.value END), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(CASE WHEN iv.month = 2 THEN iv.value END), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(CASE WHEN iv.month = 2 THEN iv.value END), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(CASE WHEN iv.month = 2 THEN iv.value END), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE((
        SELECT iv2.value FROM indicator_values iv2 
        WHERE iv2.organization_name = iv.organization_name 
        AND iv2.indicator_code = iv.indicator_code 
        AND iv2.process_code = iv.process_code
        AND iv2.site_name = iv.site_name
        AND iv2.year = iv.year 
        AND iv2.status = 'validated'
        ORDER BY iv2.month DESC LIMIT 1
      ), 0)
      ELSE COALESCE(SUM(CASE WHEN iv.month = 2 THEN iv.value END), 0)
    END as fevrier,
    
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(CASE WHEN iv.month = 3 THEN iv.value END), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(CASE WHEN iv.month = 3 THEN iv.value END), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(CASE WHEN iv.month = 3 THEN iv.value END), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(CASE WHEN iv.month = 3 THEN iv.value END), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE((
        SELECT iv2.value FROM indicator_values iv2 
        WHERE iv2.organization_name = iv.organization_name 
        AND iv2.indicator_code = iv.indicator_code 
        AND iv2.process_code = iv.process_code
        AND iv2.site_name = iv.site_name
        AND iv2.year = iv.year 
        AND iv2.status = 'validated'
        ORDER BY iv2.month DESC LIMIT 1
      ), 0)
      ELSE COALESCE(SUM(CASE WHEN iv.month = 3 THEN iv.value END), 0)
    END as mars,
    
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(CASE WHEN iv.month = 4 THEN iv.value END), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(CASE WHEN iv.month = 4 THEN iv.value END), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(CASE WHEN iv.month = 4 THEN iv.value END), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(CASE WHEN iv.month = 4 THEN iv.value END), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE((
        SELECT iv2.value FROM indicator_values iv2 
        WHERE iv2.organization_name = iv.organization_name 
        AND iv2.indicator_code = iv.indicator_code 
        AND iv2.process_code = iv.process_code
        AND iv2.site_name = iv.site_name
        AND iv2.year = iv.year 
        AND iv2.status = 'validated'
        ORDER BY iv2.month DESC LIMIT 1
      ), 0)
      ELSE COALESCE(SUM(CASE WHEN iv.month = 4 THEN iv.value END), 0)
    END as avril,
    
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(CASE WHEN iv.month = 5 THEN iv.value END), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(CASE WHEN iv.month = 5 THEN iv.value END), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(CASE WHEN iv.month = 5 THEN iv.value END), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(CASE WHEN iv.month = 5 THEN iv.value END), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE((
        SELECT iv2.value FROM indicator_values iv2 
        WHERE iv2.organization_name = iv.organization_name 
        AND iv2.indicator_code = iv.indicator_code 
        AND iv2.process_code = iv.process_code
        AND iv2.site_name = iv.site_name
        AND iv2.year = iv.year 
        AND iv2.status = 'validated'
        ORDER BY iv2.month DESC LIMIT 1
      ), 0)
      ELSE COALESCE(SUM(CASE WHEN iv.month = 5 THEN iv.value END), 0)
    END as mai,
    
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(CASE WHEN iv.month = 6 THEN iv.value END), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(CASE WHEN iv.month = 6 THEN iv.value END), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(CASE WHEN iv.month = 6 THEN iv.value END), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(CASE WHEN iv.month = 6 THEN iv.value END), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE((
        SELECT iv2.value FROM indicator_values iv2 
        WHERE iv2.organization_name = iv.organization_name 
        AND iv2.indicator_code = iv.indicator_code 
        AND iv2.process_code = iv.process_code
        AND iv2.site_name = iv.site_name
        AND iv2.year = iv.year 
        AND iv2.status = 'validated'
        ORDER BY iv2.month DESC LIMIT 1
      ), 0)
      ELSE COALESCE(SUM(CASE WHEN iv.month = 6 THEN iv.value END), 0)
    END as juin,
    
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(CASE WHEN iv.month = 7 THEN iv.value END), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(CASE WHEN iv.month = 7 THEN iv.value END), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(CASE WHEN iv.month = 7 THEN iv.value END), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(CASE WHEN iv.month = 7 THEN iv.value END), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE((
        SELECT iv2.value FROM indicator_values iv2 
        WHERE iv2.organization_name = iv.organization_name 
        AND iv2.indicator_code = iv.indicator_code 
        AND iv2.process_code = iv.process_code
        AND iv2.site_name = iv.site_name
        AND iv2.year = iv.year 
        AND iv2.status = 'validated'
        ORDER BY iv2.month DESC LIMIT 1
      ), 0)
      ELSE COALESCE(SUM(CASE WHEN iv.month = 7 THEN iv.value END), 0)
    END as juillet,
    
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(CASE WHEN iv.month = 8 THEN iv.value END), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(CASE WHEN iv.month = 8 THEN iv.value END), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(CASE WHEN iv.month = 8 THEN iv.value END), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(CASE WHEN iv.month = 8 THEN iv.value END), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE((
        SELECT iv2.value FROM indicator_values iv2 
        WHERE iv2.organization_name = iv.organization_name 
        AND iv2.indicator_code = iv.indicator_code 
        AND iv2.process_code = iv.process_code
        AND iv2.site_name = iv.site_name
        AND iv2.year = iv.year 
        AND iv2.status = 'validated'
        ORDER BY iv2.month DESC LIMIT 1
      ), 0)
      ELSE COALESCE(SUM(CASE WHEN iv.month = 8 THEN iv.value END), 0)
    END as aout,
    
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(CASE WHEN iv.month = 9 THEN iv.value END), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(CASE WHEN iv.month = 9 THEN iv.value END), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(CASE WHEN iv.month = 9 THEN iv.value END), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(CASE WHEN iv.month = 9 THEN iv.value END), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE((
        SELECT iv2.value FROM indicator_values iv2 
        WHERE iv2.organization_name = iv.organization_name 
        AND iv2.indicator_code = iv.indicator_code 
        AND iv2.process_code = iv.process_code
        AND iv2.site_name = iv.site_name
        AND iv2.year = iv.year 
        AND iv2.status = 'validated'
        ORDER BY iv2.month DESC LIMIT 1
      ), 0)
      ELSE COALESCE(SUM(CASE WHEN iv.month = 9 THEN iv.value END), 0)
    END as septembre,
    
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(CASE WHEN iv.month = 10 THEN iv.value END), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(CASE WHEN iv.month = 10 THEN iv.value END), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(CASE WHEN iv.month = 10 THEN iv.value END), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(CASE WHEN iv.month = 10 THEN iv.value END), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE((
        SELECT iv2.value FROM indicator_values iv2 
        WHERE iv2.organization_name = iv.organization_name 
        AND iv2.indicator_code = iv.indicator_code 
        AND iv2.process_code = iv.process_code
        AND iv2.site_name = iv.site_name
        AND iv2.year = iv.year 
        AND iv2.status = 'validated'
        ORDER BY iv2.month DESC LIMIT 1
      ), 0)
      ELSE COALESCE(SUM(CASE WHEN iv.month = 10 THEN iv.value END), 0)
    END as octobre,
    
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(CASE WHEN iv.month = 11 THEN iv.value END), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(CASE WHEN iv.month = 11 THEN iv.value END), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(CASE WHEN iv.month = 11 THEN iv.value END), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(CASE WHEN iv.month = 11 THEN iv.value END), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE((
        SELECT iv2.value FROM indicator_values iv2 
        WHERE iv2.organization_name = iv.organization_name 
        AND iv2.indicator_code = iv.indicator_code 
        AND iv2.process_code = iv.process_code
        AND iv2.site_name = iv.site_name
        AND iv2.year = iv.year 
        AND iv2.status = 'validated'
        ORDER BY iv2.month DESC LIMIT 1
      ), 0)
      ELSE COALESCE(SUM(CASE WHEN iv.month = 11 THEN iv.value END), 0)
    END as novembre,
    
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(CASE WHEN iv.month = 12 THEN iv.value END), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(CASE WHEN iv.month = 12 THEN iv.value END), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(CASE WHEN iv.month = 12 THEN iv.value END), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(CASE WHEN iv.month = 12 THEN iv.value END), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE((
        SELECT iv2.value FROM indicator_values iv2 
        WHERE iv2.organization_name = iv.organization_name 
        AND iv2.indicator_code = iv.indicator_code 
        AND iv2.process_code = iv.process_code
        AND iv2.site_name = iv.site_name
        AND iv2.year = iv.year 
        AND iv2.status = 'validated'
        ORDER BY iv2.month DESC LIMIT 1
      ), 0)
      ELSE COALESCE(SUM(CASE WHEN iv.month = 12 THEN iv.value END), 0)
    END as decembre,
    
    -- Calculate total value based on formula
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(iv.value), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(iv.value), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(iv.value), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(iv.value), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE((
        SELECT iv2.value FROM indicator_values iv2 
        WHERE iv2.organization_name = iv.organization_name 
        AND iv2.indicator_code = iv.indicator_code 
        AND iv2.process_code = iv.process_code
        AND iv2.site_name = iv.site_name
        AND iv2.year = iv.year 
        AND iv2.status = 'validated'
        ORDER BY iv2.month DESC LIMIT 1
      ), 0)
      ELSE COALESCE(SUM(iv.value), 0)
    END as value_consolidated,
    
    1 as sites_count,
    ARRAY[iv.site_name] as sites_list,
    0 as target_value,
    0 as previous_year_value,
    0 as variation,
    0 as performance,
    MAX(iv.updated_at) as last_updated
    
  FROM indicator_values iv
  JOIN indicator_metadata im ON iv.indicator_code = im.indicator_code 
    AND iv.process_code = im.process_code 
    AND iv.organization_name = im.organization_name
  WHERE iv.status = 'validated'
    AND iv.site_name IS NOT NULL
  GROUP BY 
    iv.organization_name, iv.business_line_name, iv.subsidiary_name, iv.site_name,
    iv.process_code, iv.indicator_code, iv.year,
    im.indicator_name, im.unit, im.axe, im.type, im.formule, im.frequence,
    im.process_name, im.process_description, im.enjeux, im.normes, im.criteres
),

-- Subsidiary level consolidation (aggregates sites within subsidiaries)
subsidiary_level_data AS (
  SELECT 
    sld.organization_name,
    sld.business_line_name,
    sld.subsidiary_name,
    NULL as site_name, -- NULL indicates this is subsidiary-level data
    sld.process_code,
    sld.indicator_code,
    sld.year,
    sld.indicator_name,
    sld.unit,
    sld.axe,
    sld.type,
    sld.formule,
    sld.frequence,
    sld.process_name,
    sld.process_description,
    sld.enjeux,
    sld.normes,
    sld.criteres,
    
    -- Aggregate monthly values across sites in subsidiary
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.janvier)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.janvier)
      WHEN sld.formule = 'max' THEN MAX(sld.janvier)
      WHEN sld.formule = 'min' THEN MIN(sld.janvier)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.janvier)
      ELSE SUM(sld.janvier)
    END as janvier,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.fevrier)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.fevrier)
      WHEN sld.formule = 'max' THEN MAX(sld.fevrier)
      WHEN sld.formule = 'min' THEN MIN(sld.fevrier)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.fevrier)
      ELSE SUM(sld.fevrier)
    END as fevrier,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.mars)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.mars)
      WHEN sld.formule = 'max' THEN MAX(sld.mars)
      WHEN sld.formule = 'min' THEN MIN(sld.mars)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.mars)
      ELSE SUM(sld.mars)
    END as mars,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.avril)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.avril)
      WHEN sld.formule = 'max' THEN MAX(sld.avril)
      WHEN sld.formule = 'min' THEN MIN(sld.avril)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.avril)
      ELSE SUM(sld.avril)
    END as avril,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.mai)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.mai)
      WHEN sld.formule = 'max' THEN MAX(sld.mai)
      WHEN sld.formule = 'min' THEN MIN(sld.mai)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.mai)
      ELSE SUM(sld.mai)
    END as mai,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.juin)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.juin)
      WHEN sld.formule = 'max' THEN MAX(sld.juin)
      WHEN sld.formule = 'min' THEN MIN(sld.juin)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.juin)
      ELSE SUM(sld.juin)
    END as juin,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.juillet)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.juillet)
      WHEN sld.formule = 'max' THEN MAX(sld.juillet)
      WHEN sld.formule = 'min' THEN MIN(sld.juillet)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.juillet)
      ELSE SUM(sld.juillet)
    END as juillet,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.aout)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.aout)
      WHEN sld.formule = 'max' THEN MAX(sld.aout)
      WHEN sld.formule = 'min' THEN MIN(sld.aout)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.aout)
      ELSE SUM(sld.aout)
    END as aout,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.septembre)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.septembre)
      WHEN sld.formule = 'max' THEN MAX(sld.septembre)
      WHEN sld.formule = 'min' THEN MIN(sld.septembre)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.septembre)
      ELSE SUM(sld.septembre)
    END as septembre,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.octobre)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.octobre)
      WHEN sld.formule = 'max' THEN MAX(sld.octobre)
      WHEN sld.formule = 'min' THEN MIN(sld.octobre)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.octobre)
      ELSE SUM(sld.octobre)
    END as octobre,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.novembre)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.novembre)
      WHEN sld.formule = 'max' THEN MAX(sld.novembre)
      WHEN sld.formule = 'min' THEN MIN(sld.novembre)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.novembre)
      ELSE SUM(sld.novembre)
    END as novembre,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.decembre)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.decembre)
      WHEN sld.formule = 'max' THEN MAX(sld.decembre)
      WHEN sld.formule = 'min' THEN MIN(sld.decembre)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.decembre)
      ELSE SUM(sld.decembre)
    END as decembre,
    
    -- Aggregate total value
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.value_consolidated)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.value_consolidated)
      WHEN sld.formule = 'max' THEN MAX(sld.value_consolidated)
      WHEN sld.formule = 'min' THEN MIN(sld.value_consolidated)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.value_consolidated)
      ELSE SUM(sld.value_consolidated)
    END as value_consolidated,
    
    COUNT(DISTINCT sld.site_name) as sites_count,
    array_agg(DISTINCT sld.site_name) as sites_list,
    0 as target_value,
    0 as previous_year_value,
    0 as variation,
    0 as performance,
    MAX(sld.last_updated) as last_updated
    
  FROM site_level_data sld
  WHERE sld.subsidiary_name IS NOT NULL
  GROUP BY 
    sld.organization_name, sld.business_line_name, sld.subsidiary_name,
    sld.process_code, sld.indicator_code, sld.year,
    sld.indicator_name, sld.unit, sld.axe, sld.type, sld.formule, sld.frequence,
    sld.process_name, sld.process_description, sld.enjeux, sld.normes, sld.criteres
),

-- Business line level consolidation (aggregates subsidiaries within business lines)
business_line_level_data AS (
  SELECT 
    sld.organization_name,
    sld.business_line_name,
    NULL as subsidiary_name, -- NULL indicates this is business line-level data
    NULL as site_name,
    sld.process_code,
    sld.indicator_code,
    sld.year,
    sld.indicator_name,
    sld.unit,
    sld.axe,
    sld.type,
    sld.formule,
    sld.frequence,
    sld.process_name,
    sld.process_description,
    sld.enjeux,
    sld.normes,
    sld.criteres,
    
    -- Aggregate monthly values across subsidiaries in business line
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.janvier)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.janvier)
      WHEN sld.formule = 'max' THEN MAX(sld.janvier)
      WHEN sld.formule = 'min' THEN MIN(sld.janvier)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.janvier)
      ELSE SUM(sld.janvier)
    END as janvier,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.fevrier)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.fevrier)
      WHEN sld.formule = 'max' THEN MAX(sld.fevrier)
      WHEN sld.formule = 'min' THEN MIN(sld.fevrier)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.fevrier)
      ELSE SUM(sld.fevrier)
    END as fevrier,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.mars)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.mars)
      WHEN sld.formule = 'max' THEN MAX(sld.mars)
      WHEN sld.formule = 'min' THEN MIN(sld.mars)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.mars)
      ELSE SUM(sld.mars)
    END as mars,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.avril)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.avril)
      WHEN sld.formule = 'max' THEN MAX(sld.avril)
      WHEN sld.formule = 'min' THEN MIN(sld.avril)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.avril)
      ELSE SUM(sld.avril)
    END as avril,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.mai)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.mai)
      WHEN sld.formule = 'max' THEN MAX(sld.mai)
      WHEN sld.formule = 'min' THEN MIN(sld.mai)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.mai)
      ELSE SUM(sld.mai)
    END as mai,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.juin)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.juin)
      WHEN sld.formule = 'max' THEN MAX(sld.juin)
      WHEN sld.formule = 'min' THEN MIN(sld.juin)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.juin)
      ELSE SUM(sld.juin)
    END as juin,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.juillet)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.juillet)
      WHEN sld.formule = 'max' THEN MAX(sld.juillet)
      WHEN sld.formule = 'min' THEN MIN(sld.juillet)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.juillet)
      ELSE SUM(sld.juillet)
    END as juillet,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.aout)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.aout)
      WHEN sld.formule = 'max' THEN MAX(sld.aout)
      WHEN sld.formule = 'min' THEN MIN(sld.aout)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.aout)
      ELSE SUM(sld.aout)
    END as aout,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.septembre)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.septembre)
      WHEN sld.formule = 'max' THEN MAX(sld.septembre)
      WHEN sld.formule = 'min' THEN MIN(sld.septembre)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.septembre)
      ELSE SUM(sld.septembre)
    END as septembre,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.octobre)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.octobre)
      WHEN sld.formule = 'max' THEN MAX(sld.octobre)
      WHEN sld.formule = 'min' THEN MIN(sld.octobre)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.octobre)
      ELSE SUM(sld.octobre)
    END as octobre,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.novembre)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.novembre)
      WHEN sld.formule = 'max' THEN MAX(sld.novembre)
      WHEN sld.formule = 'min' THEN MIN(sld.novembre)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.novembre)
      ELSE SUM(sld.novembre)
    END as novembre,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.decembre)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.decembre)
      WHEN sld.formule = 'max' THEN MAX(sld.decembre)
      WHEN sld.formule = 'min' THEN MIN(sld.decembre)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.decembre)
      ELSE SUM(sld.decembre)
    END as decembre,
    
    -- Aggregate total value
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.value_consolidated)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.value_consolidated)
      WHEN sld.formule = 'max' THEN MAX(sld.value_consolidated)
      WHEN sld.formule = 'min' THEN MIN(sld.value_consolidated)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.value_consolidated)
      ELSE SUM(sld.value_consolidated)
    END as value_consolidated,
    
    COUNT(DISTINCT sld.site_name) as sites_count,
    array_agg(DISTINCT sld.site_name) as sites_list,
    0 as target_value,
    0 as previous_year_value,
    0 as variation,
    0 as performance,
    MAX(sld.last_updated) as last_updated
    
  FROM site_level_data sld
  WHERE sld.business_line_name IS NOT NULL 
    AND sld.subsidiary_name IS NOT NULL
  GROUP BY 
    sld.organization_name, sld.business_line_name,
    sld.process_code, sld.indicator_code, sld.year,
    sld.indicator_name, sld.unit, sld.axe, sld.type, sld.formule, sld.frequence,
    sld.process_name, sld.process_description, sld.enjeux, sld.normes, sld.criteres
),

-- Organization level consolidation (aggregates business lines within organization)
organization_level_data AS (
  SELECT 
    sld.organization_name,
    NULL as business_line_name, -- NULL indicates this is organization-level data
    NULL as subsidiary_name,
    NULL as site_name,
    sld.process_code,
    sld.indicator_code,
    sld.year,
    sld.indicator_name,
    sld.unit,
    sld.axe,
    sld.type,
    sld.formule,
    sld.frequence,
    sld.process_name,
    sld.process_description,
    sld.enjeux,
    sld.normes,
    sld.criteres,
    
    -- Aggregate monthly values across all business lines in organization
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.janvier)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.janvier)
      WHEN sld.formule = 'max' THEN MAX(sld.janvier)
      WHEN sld.formule = 'min' THEN MIN(sld.janvier)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.janvier)
      ELSE SUM(sld.janvier)
    END as janvier,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.fevrier)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.fevrier)
      WHEN sld.formule = 'max' THEN MAX(sld.fevrier)
      WHEN sld.formule = 'min' THEN MIN(sld.fevrier)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.fevrier)
      ELSE SUM(sld.fevrier)
    END as fevrier,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.mars)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.mars)
      WHEN sld.formule = 'max' THEN MAX(sld.mars)
      WHEN sld.formule = 'min' THEN MIN(sld.mars)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.mars)
      ELSE SUM(sld.mars)
    END as mars,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.avril)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.avril)
      WHEN sld.formule = 'max' THEN MAX(sld.avril)
      WHEN sld.formule = 'min' THEN MIN(sld.avril)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.avril)
      ELSE SUM(sld.avril)
    END as avril,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.mai)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.mai)
      WHEN sld.formule = 'max' THEN MAX(sld.mai)
      WHEN sld.formule = 'min' THEN MIN(sld.mai)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.mai)
      ELSE SUM(sld.mai)
    END as mai,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.juin)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.juin)
      WHEN sld.formule = 'max' THEN MAX(sld.juin)
      WHEN sld.formule = 'min' THEN MIN(sld.juin)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.juin)
      ELSE SUM(sld.juin)
    END as juin,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.juillet)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.juillet)
      WHEN sld.formule = 'max' THEN MAX(sld.juillet)
      WHEN sld.formule = 'min' THEN MIN(sld.juillet)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.juillet)
      ELSE SUM(sld.juillet)
    END as juillet,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.aout)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.aout)
      WHEN sld.formule = 'max' THEN MAX(sld.aout)
      WHEN sld.formule = 'min' THEN MIN(sld.aout)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.aout)
      ELSE SUM(sld.aout)
    END as aout,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.septembre)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.septembre)
      WHEN sld.formule = 'max' THEN MAX(sld.septembre)
      WHEN sld.formule = 'min' THEN MIN(sld.septembre)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.septembre)
      ELSE SUM(sld.septembre)
    END as septembre,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.octobre)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.octobre)
      WHEN sld.formule = 'max' THEN MAX(sld.octobre)
      WHEN sld.formule = 'min' THEN MIN(sld.octobre)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.octobre)
      ELSE SUM(sld.octobre)
    END as octobre,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.novembre)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.novembre)
      WHEN sld.formule = 'max' THEN MAX(sld.novembre)
      WHEN sld.formule = 'min' THEN MIN(sld.novembre)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.novembre)
      ELSE SUM(sld.novembre)
    END as novembre,
    
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.decembre)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.decembre)
      WHEN sld.formule = 'max' THEN MAX(sld.decembre)
      WHEN sld.formule = 'min' THEN MIN(sld.decembre)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.decembre)
      ELSE SUM(sld.decembre)
    END as decembre,
    
    -- Aggregate total value
    CASE 
      WHEN sld.formule = 'somme' THEN SUM(sld.value_consolidated)
      WHEN sld.formule = 'moyenne' THEN AVG(sld.value_consolidated)
      WHEN sld.formule = 'max' THEN MAX(sld.value_consolidated)
      WHEN sld.formule = 'min' THEN MIN(sld.value_consolidated)
      WHEN sld.formule = 'dernier_mois' THEN MAX(sld.value_consolidated)
      ELSE SUM(sld.value_consolidated)
    END as value_consolidated,
    
    COUNT(DISTINCT sld.site_name) as sites_count,
    array_agg(DISTINCT sld.site_name) as sites_list,
    0 as target_value,
    0 as previous_year_value,
    0 as variation,
    0 as performance,
    MAX(sld.last_updated) as last_updated
    
  FROM site_level_data sld
  WHERE sld.business_line_name IS NOT NULL
  GROUP BY 
    sld.organization_name,
    sld.process_code, sld.indicator_code, sld.year,
    sld.indicator_name, sld.unit, sld.axe, sld.type, sld.formule, sld.frequence,
    sld.process_name, sld.process_description, sld.enjeux, sld.normes, sld.criteres
)

-- Union all levels: sites, subsidiaries, business lines, and organization
SELECT * FROM site_level_data
UNION ALL
SELECT * FROM subsidiary_level_data
UNION ALL
SELECT * FROM business_line_level_data
UNION ALL
SELECT * FROM organization_level_data;

-- Create unique index to prevent duplicates
CREATE UNIQUE INDEX IF NOT EXISTS idx_site_indicator_values_consolidated_unique 
ON site_indicator_values_consolidated (
  organization_name, 
  COALESCE(business_line_name, ''), 
  COALESCE(subsidiary_name, ''), 
  COALESCE(site_name, ''),
  process_code, 
  indicator_code, 
  year
);

-- Update the dashboard performance data table structure to match
DROP TABLE IF EXISTS dashboard_performance_data CASCADE;

CREATE TABLE dashboard_performance_data (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_name text NOT NULL,
  business_line_name text,
  subsidiary_name text,
  site_name text,
  process_code text NOT NULL,
  indicator_code text NOT NULL,
  year integer NOT NULL,
  
  -- Metadata columns
  axe text,
  enjeux text,
  normes text,
  criteres text,
  processus text,
  indicateur text,
  unite text,
  frequence text,
  type text,
  formule text,
  
  -- Monthly values
  janvier numeric DEFAULT 0,
  fevrier numeric DEFAULT 0,
  mars numeric DEFAULT 0,
  avril numeric DEFAULT 0,
  mai numeric DEFAULT 0,
  juin numeric DEFAULT 0,
  juillet numeric DEFAULT 0,
  aout numeric DEFAULT 0,
  septembre numeric DEFAULT 0,
  octobre numeric DEFAULT 0,
  novembre numeric DEFAULT 0,
  decembre numeric DEFAULT 0,
  
  -- Calculated values
  valeur_totale numeric DEFAULT 0,
  valeur_precedente numeric DEFAULT 0,
  valeur_cible numeric DEFAULT 0,
  variation numeric DEFAULT 0,
  performance numeric DEFAULT 0,
  valeur_moyenne numeric DEFAULT 0,
  
  -- Consolidation info
  sites_count integer DEFAULT 1,
  sites_list text[],
  
  -- Timestamps
  last_updated timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  
  -- Unique constraint to prevent duplicates
  CONSTRAINT dashboard_performance_data_unique UNIQUE (
    organization_name, 
    COALESCE(business_line_name, ''), 
    COALESCE(subsidiary_name, ''), 
    COALESCE(site_name, ''),
    process_code, 
    indicator_code, 
    year
  )
);

-- Enable RLS
ALTER TABLE dashboard_performance_data ENABLE ROW LEVEL SECURITY;

-- Create RLS policy
CREATE POLICY "Users can access their organization dashboard data"
ON dashboard_performance_data
FOR ALL
TO authenticated
USING (
  organization_name IN (
    SELECT organization_name 
    FROM profiles 
    WHERE email = auth.jwt() ->> 'email'
  )
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_dashboard_performance_data_org_year 
ON dashboard_performance_data (organization_name, year);

CREATE INDEX IF NOT EXISTS idx_dashboard_performance_data_hierarchy 
ON dashboard_performance_data (organization_name, business_line_name, subsidiary_name, site_name);

CREATE INDEX IF NOT EXISTS idx_dashboard_performance_data_indicator 
ON dashboard_performance_data (indicator_code, process_code);

-- Function to refresh dashboard performance data from consolidated view
CREATE OR REPLACE FUNCTION refresh_dashboard_performance_data()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Clear existing data
  DELETE FROM dashboard_performance_data;
  
  -- Insert consolidated data
  INSERT INTO dashboard_performance_data (
    organization_name,
    business_line_name,
    subsidiary_name,
    site_name,
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
    valeur_precedente,
    valeur_cible,
    variation,
    performance,
    valeur_moyenne,
    sites_count,
    sites_list,
    last_updated
  )
  SELECT 
    organization_name,
    business_line_name,
    subsidiary_name,
    site_name,
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
    value_consolidated as valeur_totale,
    previous_year_value as valeur_precedente,
    target_value as valeur_cible,
    variation,
    performance,
    value_consolidated as valeur_moyenne,
    sites_count,
    sites_list,
    last_updated
  FROM site_indicator_values_consolidated;
  
  -- Log the refresh
  INSERT INTO system_logs (action, details)
  VALUES ('refresh_dashboard_performance_data', 'Dashboard performance data refreshed from consolidated view');
  
END;
$$;

-- Create trigger to auto-refresh dashboard data when consolidated data changes
CREATE OR REPLACE FUNCTION trigger_dashboard_refresh()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  -- Refresh dashboard performance data
  PERFORM refresh_dashboard_performance_data();
  RETURN NULL;
END;
$$;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS auto_refresh_dashboard_data ON indicator_values;

-- Create trigger on indicator_values for validation
CREATE TRIGGER auto_refresh_dashboard_data
  AFTER UPDATE ON indicator_values
  FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM NEW.status AND NEW.status = 'validated')
  EXECUTE FUNCTION trigger_dashboard_refresh();

-- Initial refresh of dashboard data
SELECT refresh_dashboard_performance_data();

-- Create view that shows the correct hierarchical level based on context
CREATE OR REPLACE VIEW dashboard_performance_view AS
SELECT * FROM dashboard_performance_data
ORDER BY 
  organization_name,
  COALESCE(business_line_name, ''),
  COALESCE(subsidiary_name, ''),
  COALESCE(site_name, ''),
  process_code,
  indicator_code;