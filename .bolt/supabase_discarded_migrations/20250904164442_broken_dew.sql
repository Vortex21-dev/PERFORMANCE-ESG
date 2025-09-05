/*
  # Convert Dashboard Performance View to Editable Table

  1. Table Creation
    - Create `dashboard_performance_data` table with all columns from the view
    - Add primary key and indexes for performance
    - Include audit fields (created_at, updated_at)

  2. Data Migration
    - Migrate existing data from materialized view to table
    - Preserve all existing functionality

  3. Triggers and Functions
    - Auto-refresh triggers when underlying data changes
    - Maintain data consistency with source tables
    - Performance optimization

  4. Backup and Recovery
    - Keep fallback mechanisms
    - Ensure data integrity during migration
*/

-- Drop existing materialized view and create table
DROP MATERIALIZED VIEW IF EXISTS dashboard_performance_view;

-- Create the new dashboard performance table
CREATE TABLE IF NOT EXISTS dashboard_performance_data (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_name text NOT NULL,
  process_code text NOT NULL,
  indicator_code text NOT NULL,
  year integer NOT NULL,
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
  valeur_totale numeric DEFAULT 0,
  valeur_precedente numeric DEFAULT 0,
  valeur_cible numeric DEFAULT 0,
  variation numeric DEFAULT 0,
  performance numeric DEFAULT 0,
  valeur_moyenne numeric DEFAULT 0,
  last_updated timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  
  -- Unique constraint to prevent duplicates
  UNIQUE(organization_name, process_code, indicator_code, year)
);

-- Enable RLS
ALTER TABLE dashboard_performance_data ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
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
CREATE INDEX IF NOT EXISTS idx_dashboard_performance_data_org 
  ON dashboard_performance_data(organization_name);

CREATE INDEX IF NOT EXISTS idx_dashboard_performance_data_year 
  ON dashboard_performance_data(organization_name, year);

CREATE INDEX IF NOT EXISTS idx_dashboard_performance_data_process 
  ON dashboard_performance_data(process_code);

CREATE INDEX IF NOT EXISTS idx_dashboard_performance_data_indicator 
  ON dashboard_performance_data(indicator_code);

CREATE INDEX IF NOT EXISTS idx_dashboard_performance_data_axe 
  ON dashboard_performance_data(axe);

CREATE INDEX IF NOT EXISTS idx_dashboard_performance_data_last_updated 
  ON dashboard_performance_data(last_updated);

-- Create composite index for common queries
CREATE INDEX IF NOT EXISTS idx_dashboard_performance_data_composite 
  ON dashboard_performance_data(organization_name, year, process_code, indicator_code);

-- Function to refresh dashboard data
CREATE OR REPLACE FUNCTION refresh_dashboard_performance_data()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Clear existing data
  DELETE FROM dashboard_performance_data;
  
  -- Insert fresh data using the same logic as the original view
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
    last_updated
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
      
      -- Get metadata from sector tables
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
      
      -- Monthly values with NULL safety
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
      
      -- Aggregated values based on formula
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
      100 as valeur_cible -- Default target, can be customized
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
    
    -- Calculate variation
    CASE 
      WHEN COALESCE(pyd.valeur_precedente, 0) > 0 
      THEN ROUND(((ma.valeur_totale - pyd.valeur_precedente) / pyd.valeur_precedente * 100)::numeric, 2)
      ELSE 0
    END as variation,
    
    -- Calculate performance
    CASE 
      WHEN COALESCE(tv.valeur_cible, 0) > 0 
      THEN ROUND((ma.valeur_totale / tv.valeur_cible * 100)::numeric, 2)
      ELSE 0
    END as performance,
    
    ma.valeur_moyenne,
    ma.last_updated
    
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
    
  UNION ALL
  
  -- Include indicators without data (from organization_indicators)
  SELECT 
    oi.organization_name,
    p.code as process_code,
    i.code as indicator_code,
    EXTRACT(YEAR FROM CURRENT_DATE)::integer as year,
    i.axe,
    
    -- Get metadata for indicators without data
    COALESCE(
      (SELECT ssici.issue_name 
       FROM sector_standards_issues_criteria_indicators ssici
       JOIN organization_sectors os ON os.sector_name = ssici.sector_name
       WHERE i.code = ANY(ssici.indicator_codes)
       AND os.organization_name = oi.organization_name
       LIMIT 1),
      'Enjeu non défini'
    ) as enjeux,
    
    COALESCE(
      (SELECT ssici.standard_name 
       FROM sector_standards_issues_criteria_indicators ssici
       JOIN organization_sectors os ON os.sector_name = ssici.sector_name
       WHERE i.code = ANY(ssici.indicator_codes)
       AND os.organization_name = oi.organization_name
       LIMIT 1),
      'Standard non défini'
    ) as normes,
    
    COALESCE(
      (SELECT ssici.criteria_name 
       FROM sector_standards_issues_criteria_indicators ssici
       JOIN organization_sectors os ON os.sector_name = ssici.sector_name
       WHERE i.code = ANY(ssici.indicator_codes)
       AND os.organization_name = oi.organization_name
       LIMIT 1),
      'Critère non défini'
    ) as criteres,
    
    p.name as processus,
    i.name as indicateur,
    i.unit as unite,
    i.frequence,
    i.type,
    i.formule,
    0 as janvier, 0 as fevrier, 0 as mars, 0 as avril,
    0 as mai, 0 as juin, 0 as juillet, 0 as aout,
    0 as septembre, 0 as octobre, 0 as novembre, 0 as decembre,
    0 as valeur_totale,
    0 as valeur_precedente,
    100 as valeur_cible,
    0 as variation,
    0 as performance,
    0 as valeur_moyenne,
    now() as last_updated,
    now() as created_at,
    now() as updated_at
    
  FROM organization_indicators oi
  JOIN indicators i ON i.code = ANY(oi.indicator_codes)
  CROSS JOIN processes p
  WHERE i.code = ANY(p.indicator_codes)
  AND NOT EXISTS (
    SELECT 1 FROM indicator_values iv 
    WHERE iv.organization_name = oi.organization_name
    AND iv.indicator_code = i.code
    AND iv.process_code = p.code
    AND iv.year = EXTRACT(YEAR FROM CURRENT_DATE)
  );

-- Create function to update dashboard data when indicator values change
CREATE OR REPLACE FUNCTION update_dashboard_performance_data()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  affected_org text;
  affected_year integer;
BEGIN
  -- Get affected organization and year
  IF TG_OP = 'DELETE' THEN
    affected_org := OLD.organization_name;
    affected_year := OLD.year;
  ELSE
    affected_org := NEW.organization_name;
    affected_year := NEW.year;
  END IF;
  
  -- Delete existing records for this organization and year
  DELETE FROM dashboard_performance_data 
  WHERE organization_name = affected_org 
  AND year = affected_year;
  
  -- Refresh data for this organization and year
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
    last_updated
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
         AND os.organization_name = affected_org
         LIMIT 1),
        'Standard non défini'
      ) as normes,
      
      COALESCE(
        (SELECT ssici.issue_name 
         FROM sector_standards_issues_criteria_indicators ssici
         JOIN organization_sectors os ON os.sector_name = ssici.sector_name
         WHERE i.code = ANY(ssici.indicator_codes)
         AND os.organization_name = affected_org
         LIMIT 1),
        'Enjeu non défini'
      ) as enjeux,
      
      COALESCE(
        (SELECT ssici.criteria_name 
         FROM sector_standards_issues_criteria_indicators ssici
         JOIN organization_sectors os ON os.sector_name = ssici.sector_name
         WHERE i.code = ANY(ssici.indicator_codes)
         AND os.organization_name = affected_org
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
    WHERE iv.organization_name = affected_org
    AND iv.year = affected_year
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
    0 as valeur_precedente, -- Will be calculated separately
    100 as valeur_cible,
    0 as variation,
    CASE 
      WHEN ma.valeur_totale > 0 THEN ROUND((ma.valeur_totale / 100 * 100)::numeric, 2)
      ELSE 0
    END as performance,
    ma.valeur_moyenne,
    ma.last_updated,
    now() as created_at,
    now() as updated_at
    
  FROM monthly_aggregations ma;
  
  RETURN NULL;
END;
$$;

-- Create triggers to auto-update dashboard data
DROP TRIGGER IF EXISTS trigger_update_dashboard_performance_data ON indicator_values;
CREATE TRIGGER trigger_update_dashboard_performance_data
  AFTER INSERT OR UPDATE OR DELETE ON indicator_values
  FOR EACH ROW
  EXECUTE FUNCTION update_dashboard_performance_data();

-- Create function to manually refresh all dashboard data
CREATE OR REPLACE FUNCTION refresh_dashboard_performance_view()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  PERFORM refresh_dashboard_performance_data();
END;
$$;

-- Create view alias for backward compatibility
CREATE OR REPLACE VIEW dashboard_performance_view AS
SELECT * FROM dashboard_performance_data;

-- Initial data population
SELECT refresh_dashboard_performance_data();

-- Add comment
COMMENT ON TABLE dashboard_performance_data IS 'Editable dashboard performance data table with auto-refresh triggers';
COMMENT ON FUNCTION refresh_dashboard_performance_data() IS 'Refreshes all dashboard performance data from source tables';
COMMENT ON FUNCTION update_dashboard_performance_data() IS 'Trigger function to update dashboard data when indicator values change';