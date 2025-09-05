/*
  # Fix duplicate key violation in dashboard refresh

  1. Problem
    - The refresh function creates duplicate entries for the same (organization_name, process_code, indicator_code, year) combination
    - This violates the unique constraint on the dashboard_performance_data table

  2. Solution
    - Use INSERT ... ON CONFLICT DO UPDATE (UPSERT) instead of plain INSERT
    - This will update existing records instead of creating duplicates
*/

-- Fix the refresh function to handle duplicates properly
CREATE OR REPLACE FUNCTION refresh_dashboard_performance_data()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Use UPSERT to handle duplicates instead of DELETE + INSERT
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
    last_updated,
    updated_at
  )
  WITH indicator_metadata_comprehensive AS (
    SELECT DISTINCT
      i.code as indicator_code,
      i.name as indicator_name,
      i.unit as indicator_unit,
      i.type as indicator_type,
      i.axe as indicator_axe,
      i.formule as indicator_formule,
      i.frequence as indicator_frequence,
      p.code as process_code,
      p.name as process_name,
      
      COALESCE(
        (SELECT ssici.standard_name 
         FROM sector_standards_issues_criteria_indicators ssici
         JOIN organization_sectors os ON os.sector_name = ssici.sector_name
         WHERE i.code = ANY(ssici.indicator_codes)
         AND os.organization_name IN (SELECT DISTINCT organization_name FROM indicator_values)
         LIMIT 1),
        (SELECT subsici.standard_name 
         FROM subsector_standards_issues_criteria_indicators subsici
         JOIN organization_sectors os ON os.subsector_name = subsici.subsector_name
         WHERE i.code = ANY(subsici.indicator_codes)
         AND os.organization_name IN (SELECT DISTINCT organization_name FROM indicator_values)
         LIMIT 1),
        'Standard non défini'
      ) as normes,
      
      COALESCE(
        (SELECT ssici.issue_name 
         FROM sector_standards_issues_criteria_indicators ssici
         JOIN organization_sectors os ON os.sector_name = ssici.sector_name
         WHERE i.code = ANY(ssici.indicator_codes)
         AND os.organization_name IN (SELECT DISTINCT organization_name FROM indicator_values)
         LIMIT 1),
        (SELECT subsici.issue_name 
         FROM subsector_standards_issues_criteria_indicators subsici
         JOIN organization_sectors os ON os.subsector_name = subsici.subsector_name
         WHERE i.code = ANY(subsici.indicator_codes)
         AND os.organization_name IN (SELECT DISTINCT organization_name FROM indicator_values)
         LIMIT 1),
        'Enjeu non défini'
      ) as enjeux,
      
      COALESCE(
        (SELECT ssici.criteria_name 
         FROM sector_standards_issues_criteria_indicators ssici
         JOIN organization_sectors os ON os.sector_name = ssici.sector_name
         WHERE i.code = ANY(ssici.indicator_codes)
         AND os.organization_name IN (SELECT DISTINCT organization_name FROM indicator_values)
         LIMIT 1),
        (SELECT subsici.criteria_name 
         FROM subsector_standards_issues_criteria_indicators subsici
         JOIN organization_sectors os ON os.subsector_name = subsici.subsector_name
         WHERE i.code = ANY(subsici.indicator_codes)
         AND os.organization_name IN (SELECT DISTINCT organization_name FROM indicator_values)
         LIMIT 1),
        'Critère non défini'
      ) as criteres
      
    FROM indicators i
    CROSS JOIN processes p
    WHERE i.code = ANY(p.indicator_codes)
  ),
  
  monthly_aggregations AS (
    SELECT 
      iv.organization_name,
      iv.process_code,
      iv.indicator_code,
      iv.year,
      im.indicator_name,
      im.indicator_unit,
      im.indicator_type,
      im.indicator_axe,
      im.indicator_formule,
      im.indicator_frequence,
      im.process_name,
      im.normes,
      im.enjeux,
      im.criteres,
      
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
      
      CASE 
        WHEN im.indicator_formule = 'somme' THEN COALESCE(SUM(iv.value), 0)
        WHEN im.indicator_formule = 'moyenne' THEN COALESCE(AVG(iv.value), 0)
        WHEN im.indicator_formule = 'max' THEN COALESCE(MAX(iv.value), 0)
        WHEN im.indicator_formule = 'min' THEN COALESCE(MIN(iv.value), 0)
        WHEN im.indicator_formule = 'dernier_mois' THEN 
          COALESCE((SELECT iv2.value FROM indicator_values iv2 
                   WHERE iv2.organization_name = iv.organization_name 
                   AND iv2.indicator_code = iv.indicator_code 
                   AND iv2.year = iv.year 
                   ORDER BY iv2.month DESC LIMIT 1), 0)
        ELSE COALESCE(SUM(iv.value), 0)
      END as valeur_totale,
      
      COALESCE(AVG(iv.value), 0) as valeur_moyenne,
      MAX(iv.updated_at) as last_updated
      
    FROM indicator_values iv
    JOIN indicator_metadata_comprehensive im 
      ON iv.indicator_code = im.indicator_code 
      AND iv.process_code = im.process_code
    GROUP BY 
      iv.organization_name,
      iv.process_code,
      iv.indicator_code,
      iv.year,
      im.indicator_name,
      im.indicator_unit,
      im.indicator_type,
      im.indicator_axe,
      im.indicator_formule,
      im.indicator_frequence,
      im.process_name,
      im.normes,
      im.enjeux,
      im.criteres
  ),
  
  previous_year_data AS (
    SELECT 
      organization_name,
      process_code,
      indicator_code,
      year + 1 as target_year,
      valeur_totale as valeur_precedente
    FROM monthly_aggregations
  ),
  
  target_values AS (
    SELECT 
      organization_name,
      process_code,
      indicator_code,
      year,
      100 as valeur_cible
    FROM monthly_aggregations
  )
  
  SELECT 
    ma.organization_name,
    ma.process_code,
    ma.indicator_code,
    ma.year,
    ma.indicator_axe as axe,
    ma.enjeux,
    ma.normes,
    ma.criteres,
    ma.process_name as processus,
    ma.indicator_name as indicateur,
    ma.indicator_unit as unite,
    ma.indicator_frequence as frequence,
    ma.indicator_type as type,
    ma.indicator_formule as formule,
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
    ma.valeur_totale,
    COALESCE(pyd.valeur_precedente, 0) as valeur_precedente,
    COALESCE(tv.valeur_cible, 100) as valeur_cible,
    
    CASE 
      WHEN COALESCE(pyd.valeur_precedente, 0) > 0 
      THEN ROUND(((ma.valeur_totale - pyd.valeur_precedente) / pyd.valeur_precedente * 100)::numeric, 2)
      ELSE 0
    END as variation,
    
    CASE 
      WHEN COALESCE(tv.valeur_cible, 0) > 0 
      THEN ROUND((ma.valeur_totale / tv.valeur_cible * 100)::numeric, 2)
      ELSE 0
    END as performance,
    
    ma.valeur_moyenne,
    ma.last_updated,
    now() as updated_at
    
  FROM monthly_aggregations ma
  LEFT JOIN previous_year_data pyd 
    ON ma.organization_name = pyd.organization_name
    AND ma.process_code = pyd.process_code
    AND ma.indicator_code = pyd.indicator_code
    AND ma.year = pyd.target_year
  LEFT JOIN target_values tv 
    ON ma.organization_name = tv.organization_name
    AND ma.process_code = tv.process_code
    AND ma.indicator_code = tv.indicator_code
    AND ma.year = tv.year

  -- Handle conflicts by updating existing records
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
    last_updated = EXCLUDED.last_updated,
    updated_at = now();

END;
$$;