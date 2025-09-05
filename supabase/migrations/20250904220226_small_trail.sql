/*
  # Fix Dashboard Performance View Issues

  ## Root Cause Analysis
  
  1. **Incomplete database view**: The current `dashboard_performance_view` materialized view 
     is missing critical joins and calculations needed for comprehensive performance tracking
  
  2. **Missing joins**: Indicators are not properly linked to their metadata (processes, 
     criteria, issues, standards) causing incomplete data display
  
  3. **Overly restrictive filtering**: Current implementation excludes indicators without 
     values or with NULL relationships, hiding important tracking items
  
  ## Solution Overview
  
  This migration creates a robust, comprehensive dashboard view that:
  - Includes ALL indicators regardless of data completeness
  - Properly joins all related metadata tables
  - Calculates performance metrics with NULL-safe operations
  - Provides fallback values for missing data
  - Optimizes query performance with proper indexing
  
  ## Changes Made
  
  1. **Enhanced Materialized View**: Complete rebuild with proper joins
  2. **Performance Calculations**: NULL-safe calculations with fallbacks
  3. **Comprehensive Metadata**: Full indicator context from all related tables
  4. **Optimized Indexes**: Performance-focused indexing strategy
  5. **Refresh Function**: Automated view refresh mechanism
*/

-- Drop existing view if it exists
DROP MATERIALIZED VIEW IF EXISTS dashboard_performance_view;

-- Create comprehensive dashboard performance view
CREATE MATERIALIZED VIEW dashboard_performance_view AS
WITH indicator_metadata AS (
  -- Get complete indicator metadata with all relationships
  SELECT DISTINCT
    i.code as indicator_code,
    i.name as indicator_name,
    i.description as indicator_description,
    i.unit,
    i.type as indicator_type,
    i.axe,
    i.formule,
    i.frequence,
    
    -- Process information
    p.code as process_code,
    p.name as process_name,
    p.description as process_description,
    
    -- Criteria information (via sector/subsector relationships)
    COALESCE(
      (SELECT string_agg(DISTINCT c.name, ', ')
       FROM criteria c
       WHERE c.code = ANY(
         SELECT unnest(ssici.indicator_codes)
         FROM subsector_standards_issues_criteria_indicators ssici
         WHERE ssici.indicator_codes @> ARRAY[i.code]
       )),
      (SELECT string_agg(DISTINCT c.name, ', ')
       FROM criteria c
       WHERE c.code = ANY(
         SELECT unnest(ssici.indicator_codes)
         FROM sector_standards_issues_criteria_indicators ssici
         WHERE ssici.indicator_codes @> ARRAY[i.code]
       ))
    ) as criteria_names,
    
    -- Issues information
    COALESCE(
      (SELECT string_agg(DISTINCT iss.name, ', ')
       FROM issues iss
       WHERE iss.code = ANY(
         SELECT unnest(ssi.issue_codes)
         FROM subsector_standards_issues ssi
         WHERE EXISTS (
           SELECT 1 FROM subsector_standards_issues_criteria_indicators ssici
           WHERE ssici.subsector_name = ssi.subsector_name
           AND ssici.standard_name = ssi.standard_name
           AND ssici.indicator_codes @> ARRAY[i.code]
         )
       )),
      (SELECT string_agg(DISTINCT iss.name, ', ')
       FROM issues iss
       WHERE iss.code = ANY(
         SELECT unnest(ssi.issue_codes)
         FROM sector_standards_issues ssi
         WHERE EXISTS (
           SELECT 1 FROM sector_standards_issues_criteria_indicators ssici
           WHERE ssici.sector_name = ssi.sector_name
           AND ssici.standard_name = ssi.standard_name
           AND ssici.indicator_codes @> ARRAY[i.code]
         )
       ))
    ) as issue_names,
    
    -- Standards information
    COALESCE(
      (SELECT string_agg(DISTINCT s.name, ', ')
       FROM standards s
       WHERE s.code = ANY(
         SELECT unnest(ss.standard_codes)
         FROM subsector_standards ss
         WHERE EXISTS (
           SELECT 1 FROM subsector_standards_issues_criteria_indicators ssici
           WHERE ssici.subsector_name = ss.subsector_name
           AND ssici.indicator_codes @> ARRAY[i.code]
         )
       )),
      (SELECT string_agg(DISTINCT s.name, ', ')
       FROM standards s
       WHERE s.code = ANY(
         SELECT unnest(ss.standard_codes)
         FROM sector_standards ss
         WHERE EXISTS (
           SELECT 1 FROM sector_standards_issues_criteria_indicators ssici
           WHERE ssici.sector_name = ss.sector_name
           AND ssici.indicator_codes @> ARRAY[i.code]
         )
       ))
    ) as standard_names
    
  FROM indicators i
  CROSS JOIN processes p
  WHERE i.code = ANY(p.indicator_codes)
),

monthly_aggregations AS (
  -- Calculate monthly aggregations with NULL-safe operations
  SELECT 
    iv.organization_name,
    iv.process_code,
    iv.indicator_code,
    iv.year,
    
    -- Monthly values with NULL handling
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
    
    -- Calculate total value based on formula
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(iv.value), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(iv.value), 0)
      WHEN im.formule = 'max' THEN COALESCE(MAX(iv.value), 0)
      WHEN im.formule = 'min' THEN COALESCE(MIN(iv.value), 0)
      WHEN im.formule = 'dernier_mois' THEN COALESCE(
        (SELECT iv2.value 
         FROM indicator_values iv2 
         WHERE iv2.organization_name = iv.organization_name
         AND iv2.indicator_code = iv.indicator_code
         AND iv2.year = iv.year
         ORDER BY iv2.month DESC 
         LIMIT 1), 0)
      ELSE COALESCE(SUM(iv.value), 0)
    END as valeur_totale,
    
    -- Previous year value for comparison
    COALESCE(
      (SELECT 
        CASE 
          WHEN im.formule = 'somme' THEN SUM(iv_prev.value)
          WHEN im.formule = 'moyenne' THEN AVG(iv_prev.value)
          WHEN im.formule = 'max' THEN MAX(iv_prev.value)
          WHEN im.formule = 'min' THEN MIN(iv_prev.value)
          WHEN im.formule = 'dernier_mois' THEN 
            (SELECT iv_prev2.value 
             FROM indicator_values iv_prev2 
             WHERE iv_prev2.organization_name = iv.organization_name
             AND iv_prev2.indicator_code = iv.indicator_code
             AND iv_prev2.year = iv.year - 1
             ORDER BY iv_prev2.month DESC 
             LIMIT 1)
          ELSE SUM(iv_prev.value)
        END
       FROM indicator_values iv_prev
       WHERE iv_prev.organization_name = iv.organization_name
       AND iv_prev.indicator_code = iv.indicator_code
       AND iv_prev.year = iv.year - 1), 0) as valeur_precedente,
    
    -- Latest update timestamp
    MAX(iv.updated_at) as last_updated
    
  FROM indicator_values iv
  JOIN indicator_metadata im ON iv.indicator_code = im.indicator_code 
    AND iv.process_code = im.process_code
  GROUP BY 
    iv.organization_name, 
    iv.process_code, 
    iv.indicator_code, 
    iv.year,
    im.formule
),

target_values AS (
  -- Calculate target values (placeholder - adjust based on your target system)
  SELECT 
    organization_name,
    indicator_code,
    year,
    -- Default target calculation - adjust based on business rules
    CASE 
      WHEN indicator_code LIKE '%emission%' THEN valeur_precedente * 0.95 -- 5% reduction target
      WHEN indicator_code LIKE '%energy%' THEN valeur_precedente * 0.90 -- 10% reduction target
      WHEN indicator_code LIKE '%waste%' THEN valeur_precedente * 0.85 -- 15% reduction target
      ELSE valeur_precedente * 1.05 -- 5% improvement target
    END as valeur_cible
  FROM monthly_aggregations
)

-- Main query combining all data
SELECT 
  ma.organization_name,
  ma.process_code,
  ma.indicator_code,
  ma.year,
  
  -- Metadata columns
  im.axe,
  COALESCE(im.issue_names, 'Non défini') as enjeux,
  COALESCE(im.standard_names, 'Non défini') as normes,
  COALESCE(im.criteria_names, 'Non défini') as criteres,
  COALESCE(im.process_name, 'Processus inconnu') as processus,
  COALESCE(im.indicator_name, im.indicator_code) as indicateur,
  COALESCE(im.unit, '') as unite,
  COALESCE(im.frequence, 'mensuelle') as frequence,
  COALESCE(im.indicator_type, 'primaire') as type,
  COALESCE(im.formule, 'somme') as formule,
  
  -- Monthly values
  ma.janvier,
  ma.fevrier,
  ma.mars,
  ma.avril,
  ma.mai,
  ma.juin,
  ma.juillet,
  ma.aout,
  ma.septembre,
  ma.octobre,
  ma.novembre,
  ma.decembre,
  
  -- Calculated values
  ma.valeur_totale,
  ma.valeur_precedente,
  COALESCE(tv.valeur_cible, 0) as valeur_cible,
  
  -- Performance calculations with NULL safety
  CASE 
    WHEN ma.valeur_precedente > 0 THEN 
      ROUND(((ma.valeur_totale - ma.valeur_precedente) / ma.valeur_precedente * 100)::numeric, 2)
    ELSE 0
  END as variation,
  
  CASE 
    WHEN COALESCE(tv.valeur_cible, 0) > 0 THEN 
      ROUND((ma.valeur_totale / tv.valeur_cible * 100)::numeric, 2)
    ELSE 0
  END as performance,
  
  -- Average value for trend analysis
  CASE 
    WHEN ma.janvier + ma.fevrier + ma.mars + ma.avril + ma.mai + ma.juin + 
         ma.juillet + ma.aout + ma.septembre + ma.octobre + ma.novembre + ma.decembre > 0
    THEN ROUND(((ma.janvier + ma.fevrier + ma.mars + ma.avril + ma.mai + ma.juin + 
                 ma.juillet + ma.aout + ma.septembre + ma.octobre + ma.novembre + ma.decembre) / 12.0)::numeric, 2)
    ELSE 0
  END as valeur_moyenne,
  
  ma.last_updated

FROM monthly_aggregations ma
JOIN indicator_metadata im ON ma.indicator_code = im.indicator_code 
  AND ma.process_code = im.process_code
LEFT JOIN target_values tv ON ma.organization_name = tv.organization_name 
  AND ma.indicator_code = tv.indicator_code 
  AND ma.year = tv.year

-- Include ALL indicators, even those without values
UNION ALL

SELECT 
  oi.organization_name,
  p.code as process_code,
  i.code as indicator_code,
  EXTRACT(YEAR FROM CURRENT_DATE)::integer as year,
  
  -- Metadata columns
  i.axe,
  COALESCE(im.issue_names, 'Non défini') as enjeux,
  COALESCE(im.standard_names, 'Non défini') as normes,
  COALESCE(im.criteria_names, 'Non défini') as criteres,
  p.name as processus,
  i.name as indicateur,
  COALESCE(i.unit, '') as unite,
  COALESCE(i.frequence, 'mensuelle') as frequence,
  COALESCE(i.type, 'primaire') as type,
  COALESCE(i.formule, 'somme') as formule,
  
  -- Empty monthly values for indicators without data
  0 as janvier, 0 as fevrier, 0 as mars, 0 as avril,
  0 as mai, 0 as juin, 0 as juillet, 0 as aout,
  0 as septembre, 0 as octobre, 0 as novembre, 0 as decembre,
  
  -- Zero values for calculations
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
LEFT JOIN indicator_metadata im ON i.code = im.indicator_code AND p.code = im.process_code
WHERE NOT EXISTS (
  -- Only include if no actual data exists for current year
  SELECT 1 FROM indicator_values iv 
  WHERE iv.organization_name = oi.organization_name
  AND iv.indicator_code = i.code
  AND iv.process_code = p.code
  AND iv.year = EXTRACT(YEAR FROM CURRENT_DATE)::integer
)

ORDER BY organization_name, process_code, indicator_code, year;

-- Create indexes for optimal performance
CREATE INDEX IF NOT EXISTS idx_dashboard_performance_view_org_year 
ON dashboard_performance_view (organization_name, year);

CREATE INDEX IF NOT EXISTS idx_dashboard_performance_view_process 
ON dashboard_performance_view (process_code);

CREATE INDEX IF NOT EXISTS idx_dashboard_performance_view_indicator 
ON dashboard_performance_view (indicator_code);

CREATE INDEX IF NOT EXISTS idx_dashboard_performance_view_axe 
ON dashboard_performance_view (axe);

CREATE INDEX IF NOT EXISTS idx_dashboard_performance_view_performance 
ON dashboard_performance_view (performance) WHERE performance > 0;

-- Create function to refresh the materialized view
CREATE OR REPLACE FUNCTION refresh_dashboard_performance_view()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Refresh the materialized view with error handling
  BEGIN
    REFRESH MATERIALIZED VIEW dashboard_performance_view;
    
    -- Log successful refresh
    INSERT INTO system_logs (action, details, created_at) 
    VALUES ('dashboard_view_refresh', 'Successfully refreshed dashboard_performance_view', NOW())
    ON CONFLICT DO NOTHING;
    
  EXCEPTION WHEN OTHERS THEN
    -- Log error but don't fail
    INSERT INTO system_logs (action, details, error_message, created_at) 
    VALUES (
      'dashboard_view_refresh_error', 
      'Failed to refresh dashboard_performance_view',
      SQLERRM,
      NOW()
    ) ON CONFLICT DO NOTHING;
    
    RAISE NOTICE 'Dashboard view refresh failed: %', SQLERRM;
  END;
END;
$$;

-- Create system logs table if it doesn't exist (for monitoring)
CREATE TABLE IF NOT EXISTS system_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  action text NOT NULL,
  details text,
  error_message text,
  created_at timestamptz DEFAULT now()
);

-- Create trigger to auto-refresh view when indicator_values change
CREATE OR REPLACE FUNCTION trigger_refresh_dashboard_view()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  -- Schedule async refresh to avoid blocking the main transaction
  PERFORM pg_notify('refresh_dashboard_view', NEW.organization_name);
  RETURN COALESCE(NEW, OLD);
END;
$$;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS refresh_dashboard_on_indicator_update ON indicator_values;

-- Create new trigger
CREATE TRIGGER refresh_dashboard_on_indicator_update
  AFTER INSERT OR UPDATE OR DELETE ON indicator_values
  FOR EACH STATEMENT
  EXECUTE FUNCTION trigger_refresh_dashboard_view();

-- Create fallback view for emergency use
CREATE OR REPLACE VIEW dashboard_performance_view_fallback AS
SELECT 
  iv.organization_name,
  iv.process_code,
  iv.indicator_code,
  iv.year,
  
  -- Basic metadata with fallbacks
  COALESCE(i.axe, 'Non défini') as axe,
  'Enjeux non définis' as enjeux,
  'Normes non définies' as normes,
  'Critères non définis' as criteres,
  COALESCE(p.name, 'Processus inconnu') as processus,
  COALESCE(i.name, iv.indicator_code) as indicateur,
  COALESCE(i.unit, '') as unite,
  COALESCE(i.frequence, 'mensuelle') as frequence,
  COALESCE(i.type, 'primaire') as type,
  COALESCE(i.formule, 'somme') as formule,
  
  -- Simple monthly aggregation
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
  
  COALESCE(SUM(iv.value), 0) as valeur_totale,
  0 as valeur_precedente,
  0 as valeur_cible,
  0 as variation,
  0 as performance,
  COALESCE(AVG(iv.value), 0) as valeur_moyenne,
  MAX(iv.updated_at) as last_updated

FROM indicator_values iv
LEFT JOIN indicators i ON iv.indicator_code = i.code
LEFT JOIN processes p ON iv.process_code = p.code
GROUP BY 
  iv.organization_name, 
  iv.process_code, 
  iv.indicator_code, 
  iv.year,
  i.axe, i.name, i.unit, i.frequence, i.type, i.formule, p.name
ORDER BY iv.organization_name, iv.process_code, iv.indicator_code, iv.year;

-- Grant necessary permissions
GRANT SELECT ON dashboard_performance_view TO authenticated;
GRANT SELECT ON dashboard_performance_view_fallback TO authenticated;
GRANT EXECUTE ON FUNCTION refresh_dashboard_performance_view() TO authenticated;

-- Initial refresh of the materialized view
SELECT refresh_dashboard_performance_view();

-- Create monitoring function to check view health
CREATE OR REPLACE FUNCTION check_dashboard_view_health()
RETURNS TABLE (
  view_name text,
  row_count bigint,
  last_refresh timestamptz,
  status text
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    'dashboard_performance_view'::text,
    (SELECT count(*) FROM dashboard_performance_view)::bigint,
    (SELECT MAX(last_updated) FROM dashboard_performance_view),
    CASE 
      WHEN (SELECT count(*) FROM dashboard_performance_view) > 0 THEN 'healthy'
      ELSE 'empty'
    END::text;
END;
$$;

GRANT EXECUTE ON FUNCTION check_dashboard_view_health() TO authenticated;