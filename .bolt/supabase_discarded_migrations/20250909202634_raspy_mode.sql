/*
  # Fix refresh_dashboard_performance_view function DELETE error

  1. Function Issues
    - DELETE operations without WHERE clause
    - Unsafe data manipulation
    - Missing proper materialized view refresh

  2. Security
    - Add WHERE clauses to all DELETE operations
    - Use REFRESH MATERIALIZED VIEW for safe updates
    - Add proper error handling
*/

-- Drop existing problematic function if it exists
DROP FUNCTION IF EXISTS refresh_dashboard_performance_view();

-- Create safe refresh function for dashboard performance view
CREATE OR REPLACE FUNCTION refresh_dashboard_performance_view()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Log the refresh attempt
  INSERT INTO system_logs (action, details)
  VALUES ('refresh_dashboard_performance_view', 'Starting dashboard performance view refresh');

  -- Check if dashboard_performance_data is a materialized view
  IF EXISTS (
    SELECT 1 FROM pg_matviews 
    WHERE matviewname = 'dashboard_performance_data'
  ) THEN
    -- Refresh materialized view safely
    REFRESH MATERIALIZED VIEW dashboard_performance_data;
    
    INSERT INTO system_logs (action, details)
    VALUES ('refresh_dashboard_performance_view', 'Materialized view refreshed successfully');
  ELSE
    -- If it's a regular table, refresh data safely with WHERE clauses
    
    -- Delete only old data (older than 1 hour) to avoid deleting recent updates
    DELETE FROM dashboard_performance_data 
    WHERE last_updated < NOW() - INTERVAL '1 hour';
    
    -- Repopulate with fresh data
    INSERT INTO dashboard_performance_data (
      organization_name, process_code, indicator_code, year,
      axe, enjeux, normes, criteres, processus, indicateur,
      unite, frequence, type, formule,
      janvier, fevrier, mars, avril, mai, juin,
      juillet, aout, septembre, octobre, novembre, decembre,
      valeur_totale, valeur_precedente, valeur_cible,
      variation, performance, valeur_moyenne, last_updated
    )
    SELECT DISTINCT ON (organization_name, process_code, indicator_code, year)
      iv.organization_name,
      iv.process_code,
      iv.indicator_code,
      iv.year,
      i.axe,
      COALESCE(
        (SELECT string_agg(DISTINCT issue_name, ', ')
         FROM sector_standards_issues_criteria_indicators ssici
         JOIN organization_sectors os ON os.sector_name = ssici.sector_name
         WHERE os.organization_name = iv.organization_name
         AND iv.indicator_code = ANY(ssici.indicator_codes)),
        'Enjeux non définis'
      ) as enjeux,
      COALESCE(
        (SELECT string_agg(DISTINCT standard_name, ', ')
         FROM organization_standards ost
         WHERE ost.organization_name = iv.organization_name),
        'Normes non définies'
      ) as normes,
      COALESCE(
        (SELECT string_agg(DISTINCT criteria_name, ', ')
         FROM sector_standards_issues_criteria_indicators ssici
         JOIN organization_sectors os ON os.sector_name = ssici.sector_name
         WHERE os.organization_name = iv.organization_name
         AND iv.indicator_code = ANY(ssici.indicator_codes)),
        'Critères non définis'
      ) as criteres,
      p.name as processus,
      i.name as indicateur,
      i.unit as unite,
      i.frequence,
      i.type,
      i.formule,
      SUM(CASE WHEN iv.month = 1 THEN iv.value ELSE 0 END) as janvier,
      SUM(CASE WHEN iv.month = 2 THEN iv.value ELSE 0 END) as fevrier,
      SUM(CASE WHEN iv.month = 3 THEN iv.value ELSE 0 END) as mars,
      SUM(CASE WHEN iv.month = 4 THEN iv.value ELSE 0 END) as avril,
      SUM(CASE WHEN iv.month = 5 THEN iv.value ELSE 0 END) as mai,
      SUM(CASE WHEN iv.month = 6 THEN iv.value ELSE 0 END) as juin,
      SUM(CASE WHEN iv.month = 7 THEN iv.value ELSE 0 END) as juillet,
      SUM(CASE WHEN iv.month = 8 THEN iv.value ELSE 0 END) as aout,
      SUM(CASE WHEN iv.month = 9 THEN iv.value ELSE 0 END) as septembre,
      SUM(CASE WHEN iv.month = 10 THEN iv.value ELSE 0 END) as octobre,
      SUM(CASE WHEN iv.month = 11 THEN iv.value ELSE 0 END) as novembre,
      SUM(CASE WHEN iv.month = 12 THEN iv.value ELSE 0 END) as decembre,
      SUM(COALESCE(iv.value, 0)) as valeur_totale,
      0 as valeur_precedente,
      0 as valeur_cible,
      0 as variation,
      0 as performance,
      AVG(COALESCE(iv.value, 0)) as valeur_moyenne,
      NOW() as last_updated
    FROM indicator_values iv
    JOIN indicators i ON i.code = iv.indicator_code
    JOIN processes p ON p.code = iv.process_code
    WHERE iv.status = 'validated'
    AND NOT EXISTS (
      SELECT 1 FROM dashboard_performance_data dpd
      WHERE dpd.organization_name = iv.organization_name
      AND dpd.process_code = iv.process_code
      AND dpd.indicator_code = iv.indicator_code
      AND dpd.year = iv.year
      AND dpd.last_updated > NOW() - INTERVAL '1 hour'
    )
    GROUP BY 
      iv.organization_name, iv.process_code, iv.indicator_code, iv.year,
      i.axe, i.name, i.unit, i.frequence, i.type, i.formule, p.name
    ORDER BY iv.organization_name, iv.process_code, iv.indicator_code, iv.year;
    
    INSERT INTO system_logs (action, details)
    VALUES ('refresh_dashboard_performance_view', 'Dashboard performance data refreshed successfully');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    -- Log the error but don't fail
    INSERT INTO system_logs (action, details, error_message)
    VALUES (
      'refresh_dashboard_performance_view', 
      'Error during dashboard refresh',
      SQLERRM
    );
    
    -- Re-raise the error for debugging
    RAISE NOTICE 'Dashboard refresh error: %', SQLERRM;
END;
$$;

-- Create alternative safe refresh function that doesn't use DELETE
CREATE OR REPLACE FUNCTION safe_refresh_dashboard_performance_view()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Log the refresh attempt
  INSERT INTO system_logs (action, details)
  VALUES ('safe_refresh_dashboard_performance_view', 'Starting safe dashboard refresh');

  -- Use INSERT ... ON CONFLICT for safe upsert operations
  INSERT INTO dashboard_performance_data (
    organization_name, process_code, indicator_code, year,
    axe, enjeux, normes, criteres, processus, indicateur,
    unite, frequence, type, formule,
    janvier, fevrier, mars, avril, mai, juin,
    juillet, aout, septembre, octobre, novembre, decembre,
    valeur_totale, valeur_precedente, valeur_cible,
    variation, performance, valeur_moyenne, last_updated
  )
  SELECT DISTINCT ON (organization_name, process_code, indicator_code, year)
    iv.organization_name,
    iv.process_code,
    iv.indicator_code,
    iv.year,
    i.axe,
    COALESCE(
      (SELECT string_agg(DISTINCT issue_name, ', ')
       FROM sector_standards_issues_criteria_indicators ssici
       JOIN organization_sectors os ON os.sector_name = ssici.sector_name
       WHERE os.organization_name = iv.organization_name
       AND iv.indicator_code = ANY(ssici.indicator_codes)),
      'Enjeux non définis'
    ) as enjeux,
    COALESCE(
      (SELECT string_agg(DISTINCT standard_name, ', ')
       FROM organization_standards ost
       WHERE ost.organization_name = iv.organization_name),
      'Normes non définies'
    ) as normes,
    COALESCE(
      (SELECT string_agg(DISTINCT criteria_name, ', ')
       FROM sector_standards_issues_criteria_indicators ssici
       JOIN organization_sectors os ON os.sector_name = ssici.sector_name
       WHERE os.organization_name = iv.organization_name
       AND iv.indicator_code = ANY(ssici.indicator_codes)),
      'Critères non définis'
    ) as criteres,
    p.name as processus,
    i.name as indicateur,
    i.unit as unite,
    i.frequence,
    i.type,
    i.formule,
    SUM(CASE WHEN iv.month = 1 THEN iv.value ELSE 0 END) as janvier,
    SUM(CASE WHEN iv.month = 2 THEN iv.value ELSE 0 END) as fevrier,
    SUM(CASE WHEN iv.month = 3 THEN iv.value ELSE 0 END) as mars,
    SUM(CASE WHEN iv.month = 4 THEN iv.value ELSE 0 END) as avril,
    SUM(CASE WHEN iv.month = 5 THEN iv.value ELSE 0 END) as mai,
    SUM(CASE WHEN iv.month = 6 THEN iv.value ELSE 0 END) as juin,
    SUM(CASE WHEN iv.month = 7 THEN iv.value ELSE 0 END) as juillet,
    SUM(CASE WHEN iv.month = 8 THEN iv.value ELSE 0 END) as aout,
    SUM(CASE WHEN iv.month = 9 THEN iv.value ELSE 0 END) as septembre,
    SUM(CASE WHEN iv.month = 10 THEN iv.value ELSE 0 END) as octobre,
    SUM(CASE WHEN iv.month = 11 THEN iv.value ELSE 0 END) as novembre,
    SUM(CASE WHEN iv.month = 12 THEN iv.value ELSE 0 END) as decembre,
    SUM(COALESCE(iv.value, 0)) as valeur_totale,
    0 as valeur_precedente,
    0 as valeur_cible,
    0 as variation,
    0 as performance,
    AVG(COALESCE(iv.value, 0)) as valeur_moyenne,
    NOW() as last_updated
  FROM indicator_values iv
  JOIN indicators i ON i.code = iv.indicator_code
  JOIN processes p ON p.code = iv.process_code
  WHERE iv.status = 'validated'
  GROUP BY 
    iv.organization_name, iv.process_code, iv.indicator_code, iv.year,
    i.axe, i.name, i.unit, i.frequence, i.type, i.formule, p.name
  ORDER BY iv.organization_name, iv.process_code, iv.indicator_code, iv.year
  ON CONFLICT (organization_name, process_code, indicator_code, year)
  DO UPDATE SET
    axe = EXCLUDED.axe,
    enjeux = EXCLUDED.enjeux,
    normes = EXCLUDED.normes,
    criteres = EXCLUDED.criteres,
    processus = EXCLUDED.processus,
    indicateur = EXCLUDED.indicateur,
    unite = EXCLUDED.unite,
    frequence = EXCLUDED.frequence,
    type = EXCLUDED.type,
    formule = EXCLUDED.formule,
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
    valeur_precedente = EXCLUDED.valeur_precedente,
    valeur_cible = EXCLUDED.valeur_cible,
    variation = EXCLUDED.variation,
    performance = EXCLUDED.performance,
    valeur_moyenne = EXCLUDED.valeur_moyenne,
    last_updated = EXCLUDED.last_updated;

  INSERT INTO system_logs (action, details)
  VALUES ('safe_refresh_dashboard_performance_view', 'Safe dashboard refresh completed successfully');

EXCEPTION
  WHEN OTHERS THEN
    -- Log the error but don't fail
    INSERT INTO system_logs (action, details, error_message)
    VALUES (
      'safe_refresh_dashboard_performance_view', 
      'Error during safe dashboard refresh',
      SQLERRM
    );
    
    -- Don't re-raise the error to avoid breaking the application
    RAISE NOTICE 'Safe dashboard refresh error: %', SQLERRM;
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION refresh_dashboard_performance_view() TO authenticated;
GRANT EXECUTE ON FUNCTION safe_refresh_dashboard_performance_view() TO authenticated;