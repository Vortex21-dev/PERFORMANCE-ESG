/*
  # Fix refresh_dashboard_performance_view DELETE error

  1. Problem
    - The refresh_dashboard_performance_view function contains DELETE statements without WHERE clauses
    - PostgreSQL prevents this to avoid accidental data loss

  2. Solution
    - Replace unsafe DELETE statements with TRUNCATE or proper WHERE clauses
    - Use REFRESH MATERIALIZED VIEW if it's a materialized view
    - Add proper error handling
*/

-- Drop the existing function if it exists
DROP FUNCTION IF EXISTS refresh_dashboard_performance_view();

-- Create a safe version of the refresh function
CREATE OR REPLACE FUNCTION refresh_dashboard_performance_view()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Try to refresh materialized view first (if it exists)
  BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY dashboard_performance_view;
    RETURN;
  EXCEPTION 
    WHEN undefined_table THEN
      -- View doesn't exist as materialized view, continue with manual refresh
      NULL;
    WHEN OTHERS THEN
      -- Log error but continue
      INSERT INTO system_logs (action, details, error_message)
      VALUES ('refresh_dashboard_mv_failed', 'Materialized view refresh failed', SQLERRM);
  END;

  -- If materialized view refresh failed, try manual data refresh
  BEGIN
    -- Use TRUNCATE instead of DELETE (safer and faster)
    TRUNCATE TABLE dashboard_performance_data;
    
    -- Repopulate the table with fresh data
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
      janvier, fevrier, mars, avril, mai, juin,
      juillet, aout, septembre, octobre, novembre, decembre,
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
    SELECT DISTINCT
      iv.organization_name,
      iv.business_line_name,
      iv.subsidiary_name,
      iv.site_name,
      iv.process_code,
      iv.indicator_code,
      iv.year,
      COALESCE(i.axe, 'Non défini') as axe,
      COALESCE(
        CASE 
          WHEN os.sector_name IS NOT NULL THEN (
            SELECT string_agg(DISTINCT ssici.issue_name, ', ')
            FROM sector_standards_issues_criteria_indicators ssici
            WHERE ssici.sector_name = os.sector_name
          )
          WHEN os.subsector_name IS NOT NULL THEN (
            SELECT string_agg(DISTINCT sssici.issue_name, ', ')
            FROM subsector_standards_issues_criteria_indicators sssici
            WHERE sssici.subsector_name = os.subsector_name
          )
          ELSE 'Enjeux non définis'
        END,
        'Enjeux non définis'
      ) as enjeux,
      COALESCE(
        (SELECT string_agg(DISTINCT s.name, ', ')
         FROM organization_standards ost
         JOIN standards s ON s.code = ANY(ost.standard_codes)
         WHERE ost.organization_name = iv.organization_name),
        'Normes non définies'
      ) as normes,
      COALESCE(
        CASE 
          WHEN os.sector_name IS NOT NULL THEN (
            SELECT string_agg(DISTINCT ssici.criteria_name, ', ')
            FROM sector_standards_issues_criteria_indicators ssici
            WHERE ssici.sector_name = os.sector_name
          )
          WHEN os.subsector_name IS NOT NULL THEN (
            SELECT string_agg(DISTINCT sssici.criteria_name, ', ')
            FROM subsector_standards_issues_criteria_indicators sssici
            WHERE sssici.subsector_name = os.subsector_name
          )
          ELSE 'Critères non définis'
        END,
        'Critères non définis'
      ) as criteres,
      COALESCE(p.name, 'Processus inconnu') as processus,
      COALESCE(i.name, iv.indicator_code) as indicateur,
      COALESCE(i.unit, '') as unite,
      COALESCE(i.frequence, 'mensuelle') as frequence,
      COALESCE(i.type, 'primaire') as type,
      COALESCE(i.formule, 'somme') as formule,
      
      -- Monthly aggregations
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
      
      -- Calculated fields
      COALESCE(SUM(iv.value), 0) as valeur_totale,
      0 as valeur_precedente, -- TODO: Calculate from previous year
      0 as valeur_cible, -- TODO: Get from targets table
      0 as variation, -- TODO: Calculate variation
      0 as performance, -- TODO: Calculate performance
      COALESCE(AVG(iv.value), 0) as valeur_moyenne,
      COUNT(DISTINCT iv.site_name) as sites_count,
      array_agg(DISTINCT iv.site_name) FILTER (WHERE iv.site_name IS NOT NULL) as sites_list,
      NOW() as last_updated
      
    FROM indicator_values iv
    LEFT JOIN indicators i ON i.code = iv.indicator_code
    LEFT JOIN processes p ON p.code = iv.process_code
    LEFT JOIN organization_sectors os ON os.organization_name = iv.organization_name
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
      i.axe, i.name, i.unit, i.frequence, i.type, i.formule,
      p.name,
      os.sector_name,
      os.subsector_name;

    -- Log success
    INSERT INTO system_logs (action, details)
    VALUES ('refresh_dashboard_success', 'Dashboard performance data refreshed successfully');

  EXCEPTION WHEN OTHERS THEN
    -- Log error
    INSERT INTO system_logs (action, details, error_message)
    VALUES ('refresh_dashboard_error', 'Manual dashboard refresh failed', SQLERRM);
    
    -- Re-raise the error
    RAISE;
  END;
END;
$$;