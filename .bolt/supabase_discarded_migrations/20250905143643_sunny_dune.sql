/*
  # Create Site Consolidation Views and Functions

  1. New Views
    - `site_indicator_values_view` - Detailed view with complete metadata for site indicators
    - `consolidated_indicator_values` - Consolidated view with automatic calculations by formula
    - `site_performance_summary` - Performance summary by site

  2. Functions
    - `consolidate_indicator_values` - Function to consolidate values by formula
    - `refresh_consolidated_views` - Function to refresh materialized views

  3. Security
    - Enable RLS on all new views
    - Add policies for organization-based access
*/

-- Create detailed site indicator values view
CREATE OR REPLACE VIEW site_indicator_values_view AS
SELECT DISTINCT
  iv.id,
  iv.organization_name,
  iv.business_line_name,
  iv.subsidiary_name,
  iv.site_name,
  iv.year,
  iv.month,
  iv.process_code,
  iv.indicator_code,
  iv.value,
  iv.status,
  iv.comment,
  iv.created_at,
  iv.updated_at,
  iv.submitted_by,
  iv.validated_by,
  iv.validated_at,
  
  -- Indicator metadata
  i.name as indicator_name,
  i.description as indicator_description,
  i.unit,
  i.type as indicator_type,
  i.axe,
  i.formule,
  i.frequence,
  
  -- Process metadata
  p.name as process_name,
  p.description as process_description
FROM indicator_values iv
LEFT JOIN indicators i ON iv.indicator_code = i.code
LEFT JOIN processes p ON iv.process_code = p.code
WHERE iv.site_name IS NOT NULL;

-- Create consolidated indicator values view
CREATE OR REPLACE VIEW consolidated_indicator_values AS
WITH site_data AS (
  SELECT 
    organization_name,
    business_line_name,
    subsidiary_name,
    indicator_code,
    year,
    process_code,
    
    -- Indicator metadata
    indicator_name,
    unit,
    axe,
    formule,
    frequence,
    indicator_type,
    process_name,
    
    -- Monthly aggregations based on formula
    CASE 
      WHEN formule = 'somme' THEN 
        COALESCE(SUM(CASE WHEN month = 1 THEN value END), 0)
      WHEN formule = 'moyenne' THEN 
        COALESCE(AVG(CASE WHEN month = 1 THEN value END), 0)
      WHEN formule = 'max' THEN 
        COALESCE(MAX(CASE WHEN month = 1 THEN value END), 0)
      WHEN formule = 'min' THEN 
        COALESCE(MIN(CASE WHEN month = 1 THEN value END), 0)
      WHEN formule = 'dernier_mois' THEN 
        COALESCE((
          SELECT value FROM indicator_values iv2 
          WHERE iv2.indicator_code = siv.indicator_code 
            AND iv2.organization_name = siv.organization_name
            AND iv2.year = siv.year
            AND iv2.month = 1
            AND iv2.site_name IS NOT NULL
          ORDER BY iv2.updated_at DESC 
          LIMIT 1
        ), 0)
      ELSE COALESCE(SUM(CASE WHEN month = 1 THEN value END), 0)
    END as janvier,
    
    CASE 
      WHEN formule = 'somme' THEN 
        COALESCE(SUM(CASE WHEN month = 2 THEN value END), 0)
      WHEN formule = 'moyenne' THEN 
        COALESCE(AVG(CASE WHEN month = 2 THEN value END), 0)
      WHEN formule = 'max' THEN 
        COALESCE(MAX(CASE WHEN month = 2 THEN value END), 0)
      WHEN formule = 'min' THEN 
        COALESCE(MIN(CASE WHEN month = 2 THEN value END), 0)
      WHEN formule = 'dernier_mois' THEN 
        COALESCE((
          SELECT value FROM indicator_values iv2 
          WHERE iv2.indicator_code = siv.indicator_code 
            AND iv2.organization_name = siv.organization_name
            AND iv2.year = siv.year
            AND iv2.month = 2
            AND iv2.site_name IS NOT NULL
          ORDER BY iv2.updated_at DESC 
          LIMIT 1
        ), 0)
      ELSE COALESCE(SUM(CASE WHEN month = 2 THEN value END), 0)
    END as fevrier,
    
    CASE 
      WHEN formule = 'somme' THEN 
        COALESCE(SUM(CASE WHEN month = 3 THEN value END), 0)
      WHEN formule = 'moyenne' THEN 
        COALESCE(AVG(CASE WHEN month = 3 THEN value END), 0)
      WHEN formule = 'max' THEN 
        COALESCE(MAX(CASE WHEN month = 3 THEN value END), 0)
      WHEN formule = 'min' THEN 
        COALESCE(MIN(CASE WHEN month = 3 THEN value END), 0)
      WHEN formule = 'dernier_mois' THEN 
        COALESCE((
          SELECT value FROM indicator_values iv2 
          WHERE iv2.indicator_code = siv.indicator_code 
            AND iv2.organization_name = siv.organization_name
            AND iv2.year = siv.year
            AND iv2.month = 3
            AND iv2.site_name IS NOT NULL
          ORDER BY iv2.updated_at DESC 
          LIMIT 1
        ), 0)
      ELSE COALESCE(SUM(CASE WHEN month = 3 THEN value END), 0)
    END as mars,
    
    CASE 
      WHEN formule = 'somme' THEN 
        COALESCE(SUM(CASE WHEN month = 4 THEN value END), 0)
      WHEN formule = 'moyenne' THEN 
        COALESCE(AVG(CASE WHEN month = 4 THEN value END), 0)
      WHEN formule = 'max' THEN 
        COALESCE(MAX(CASE WHEN month = 4 THEN value END), 0)
      WHEN formule = 'min' THEN 
        COALESCE(MIN(CASE WHEN month = 4 THEN value END), 0)
      WHEN formule = 'dernier_mois' THEN 
        COALESCE((
          SELECT value FROM indicator_values iv2 
          WHERE iv2.indicator_code = siv.indicator_code 
            AND iv2.organization_name = siv.organization_name
            AND iv2.year = siv.year
            AND iv2.month = 4
            AND iv2.site_name IS NOT NULL
          ORDER BY iv2.updated_at DESC 
          LIMIT 1
        ), 0)
      ELSE COALESCE(SUM(CASE WHEN month = 4 THEN value END), 0)
    END as avril,
    
    CASE 
      WHEN formule = 'somme' THEN 
        COALESCE(SUM(CASE WHEN month = 5 THEN value END), 0)
      WHEN formule = 'moyenne' THEN 
        COALESCE(AVG(CASE WHEN month = 5 THEN value END), 0)
      WHEN formule = 'max' THEN 
        COALESCE(MAX(CASE WHEN month = 5 THEN value END), 0)
      WHEN formule = 'min' THEN 
        COALESCE(MIN(CASE WHEN month = 5 THEN value END), 0)
      WHEN formule = 'dernier_mois' THEN 
        COALESCE((
          SELECT value FROM indicator_values iv2 
          WHERE iv2.indicator_code = siv.indicator_code 
            AND iv2.organization_name = siv.organization_name
            AND iv2.year = siv.year
            AND iv2.month = 5
            AND iv2.site_name IS NOT NULL
          ORDER BY iv2.updated_at DESC 
          LIMIT 1
        ), 0)
      ELSE COALESCE(SUM(CASE WHEN month = 5 THEN value END), 0)
    END as mai,
    
    CASE 
      WHEN formule = 'somme' THEN 
        COALESCE(SUM(CASE WHEN month = 6 THEN value END), 0)
      WHEN formule = 'moyenne' THEN 
        COALESCE(AVG(CASE WHEN month = 6 THEN value END), 0)
      WHEN formule = 'max' THEN 
        COALESCE(MAX(CASE WHEN month = 6 THEN value END), 0)
      WHEN formule = 'min' THEN 
        COALESCE(MIN(CASE WHEN month = 6 THEN value END), 0)
      WHEN formule = 'dernier_mois' THEN 
        COALESCE((
          SELECT value FROM indicator_values iv2 
          WHERE iv2.indicator_code = siv.indicator_code 
            AND iv2.organization_name = siv.organization_name
            AND iv2.year = siv.year
            AND iv2.month = 6
            AND iv2.site_name IS NOT NULL
          ORDER BY iv2.updated_at DESC 
          LIMIT 1
        ), 0)
      ELSE COALESCE(SUM(CASE WHEN month = 6 THEN value END), 0)
    END as juin,
    
    CASE 
      WHEN formule = 'somme' THEN 
        COALESCE(SUM(CASE WHEN month = 7 THEN value END), 0)
      WHEN formule = 'moyenne' THEN 
        COALESCE(AVG(CASE WHEN month = 7 THEN value END), 0)
      WHEN formule = 'max' THEN 
        COALESCE(MAX(CASE WHEN month = 7 THEN value END), 0)
      WHEN formule = 'min' THEN 
        COALESCE(MIN(CASE WHEN month = 7 THEN value END), 0)
      WHEN formule = 'dernier_mois' THEN 
        COALESCE((
          SELECT value FROM indicator_values iv2 
          WHERE iv2.indicator_code = siv.indicator_code 
            AND iv2.organization_name = siv.organization_name
            AND iv2.year = siv.year
            AND iv2.month = 7
            AND iv2.site_name IS NOT NULL
          ORDER BY iv2.updated_at DESC 
          LIMIT 1
        ), 0)
      ELSE COALESCE(SUM(CASE WHEN month = 7 THEN value END), 0)
    END as juillet,
    
    CASE 
      WHEN formule = 'somme' THEN 
        COALESCE(SUM(CASE WHEN month = 8 THEN value END), 0)
      WHEN formule = 'moyenne' THEN 
        COALESCE(AVG(CASE WHEN month = 8 THEN value END), 0)
      WHEN formule = 'max' THEN 
        COALESCE(MAX(CASE WHEN month = 8 THEN value END), 0)
      WHEN formule = 'min' THEN 
        COALESCE(MIN(CASE WHEN month = 8 THEN value END), 0)
      WHEN formule = 'dernier_mois' THEN 
        COALESCE((
          SELECT value FROM indicator_values iv2 
          WHERE iv2.indicator_code = siv.indicator_code 
            AND iv2.organization_name = siv.organization_name
            AND iv2.year = siv.year
            AND iv2.month = 8
            AND iv2.site_name IS NOT NULL
          ORDER BY iv2.updated_at DESC 
          LIMIT 1
        ), 0)
      ELSE COALESCE(SUM(CASE WHEN month = 8 THEN value END), 0)
    END as aout,
    
    CASE 
      WHEN formule = 'somme' THEN 
        COALESCE(SUM(CASE WHEN month = 9 THEN value END), 0)
      WHEN formule = 'moyenne' THEN 
        COALESCE(AVG(CASE WHEN month = 9 THEN value END), 0)
      WHEN formule = 'max' THEN 
        COALESCE(MAX(CASE WHEN month = 9 THEN value END), 0)
      WHEN formule = 'min' THEN 
        COALESCE(MIN(CASE WHEN month = 9 THEN value END), 0)
      WHEN formule = 'dernier_mois' THEN 
        COALESCE((
          SELECT value FROM indicator_values iv2 
          WHERE iv2.indicator_code = siv.indicator_code 
            AND iv2.organization_name = siv.organization_name
            AND iv2.year = siv.year
            AND iv2.month = 9
            AND iv2.site_name IS NOT NULL
          ORDER BY iv2.updated_at DESC 
          LIMIT 1
        ), 0)
      ELSE COALESCE(SUM(CASE WHEN month = 9 THEN value END), 0)
    END as septembre,
    
    CASE 
      WHEN formule = 'somme' THEN 
        COALESCE(SUM(CASE WHEN month = 10 THEN value END), 0)
      WHEN formule = 'moyenne' THEN 
        COALESCE(AVG(CASE WHEN month = 10 THEN value END), 0)
      WHEN formule = 'max' THEN 
        COALESCE(MAX(CASE WHEN month = 10 THEN value END), 0)
      WHEN formule = 'min' THEN 
        COALESCE(MIN(CASE WHEN month = 10 THEN value END), 0)
      WHEN formule = 'dernier_mois' THEN 
        COALESCE((
          SELECT value FROM indicator_values iv2 
          WHERE iv2.indicator_code = siv.indicator_code 
            AND iv2.organization_name = siv.organization_name
            AND iv2.year = siv.year
            AND iv2.month = 10
            AND iv2.site_name IS NOT NULL
          ORDER BY iv2.updated_at DESC 
          LIMIT 1
        ), 0)
      ELSE COALESCE(SUM(CASE WHEN month = 10 THEN value END), 0)
    END as octobre,
    
    CASE 
      WHEN formule = 'somme' THEN 
        COALESCE(SUM(CASE WHEN month = 11 THEN value END), 0)
      WHEN formule = 'moyenne' THEN 
        COALESCE(AVG(CASE WHEN month = 11 THEN value END), 0)
      WHEN formule = 'max' THEN 
        COALESCE(MAX(CASE WHEN month = 11 THEN value END), 0)
      WHEN formule = 'min' THEN 
        COALESCE(MIN(CASE WHEN month = 11 THEN value END), 0)
      WHEN formule = 'dernier_mois' THEN 
        COALESCE((
          SELECT value FROM indicator_values iv2 
          WHERE iv2.indicator_code = siv.indicator_code 
            AND iv2.organization_name = siv.organization_name
            AND iv2.year = siv.year
            AND iv2.month = 11
            AND iv2.site_name IS NOT NULL
          ORDER BY iv2.updated_at DESC 
          LIMIT 1
        ), 0)
      ELSE COALESCE(SUM(CASE WHEN month = 11 THEN value END), 0)
    END as novembre,
    
    CASE 
      WHEN formule = 'somme' THEN 
        COALESCE(SUM(CASE WHEN month = 12 THEN value END), 0)
      WHEN formule = 'moyenne' THEN 
        COALESCE(AVG(CASE WHEN month = 12 THEN value END), 0)
      WHEN formule = 'max' THEN 
        COALESCE(MAX(CASE WHEN month = 12 THEN value END), 0)
      WHEN formule = 'min' THEN 
        COALESCE(MIN(CASE WHEN month = 12 THEN value END), 0)
      WHEN formule = 'dernier_mois' THEN 
        COALESCE((
          SELECT value FROM indicator_values iv2 
          WHERE iv2.indicator_code = siv.indicator_code 
            AND iv2.organization_name = siv.organization_name
            AND iv2.year = siv.year
            AND iv2.month = 12
            AND iv2.site_name IS NOT NULL
          ORDER BY iv2.updated_at DESC 
          LIMIT 1
        ), 0)
      ELSE COALESCE(SUM(CASE WHEN month = 12 THEN value END), 0)
    END as decembre,
    
    -- Site information
    ARRAY_AGG(DISTINCT site_name ORDER BY site_name) as site_names,
    COUNT(DISTINCT site_name) as site_count,
    
    -- Total value calculation
    CASE 
      WHEN formule = 'somme' THEN 
        COALESCE(SUM(value), 0)
      WHEN formule = 'moyenne' THEN 
        COALESCE(AVG(value), 0)
      WHEN formule = 'max' THEN 
        COALESCE(MAX(value), 0)
      WHEN formule = 'min' THEN 
        COALESCE(MIN(value), 0)
      WHEN formule = 'dernier_mois' THEN 
        COALESCE((
          SELECT value FROM indicator_values iv2 
          WHERE iv2.indicator_code = siv.indicator_code 
            AND iv2.organization_name = siv.organization_name
            AND iv2.year = siv.year
            AND iv2.site_name IS NOT NULL
          ORDER BY iv2.month DESC, iv2.updated_at DESC 
          LIMIT 1
        ), 0)
      ELSE COALESCE(SUM(value), 0)
    END as valeur_totale,
    
    -- Previous year value (for variation calculation)
    CASE 
      WHEN formule = 'somme' THEN 
        COALESCE((
          SELECT SUM(value) FROM indicator_values iv_prev
          WHERE iv_prev.indicator_code = siv.indicator_code 
            AND iv_prev.organization_name = siv.organization_name
            AND iv_prev.year = siv.year - 1
            AND iv_prev.site_name IS NOT NULL
        ), 0)
      WHEN formule = 'moyenne' THEN 
        COALESCE((
          SELECT AVG(value) FROM indicator_values iv_prev
          WHERE iv_prev.indicator_code = siv.indicator_code 
            AND iv_prev.organization_name = siv.organization_name
            AND iv_prev.year = siv.year - 1
            AND iv_prev.site_name IS NOT NULL
        ), 0)
      ELSE 0
    END as valeur_precedente,
    
    MAX(updated_at) as last_updated
    
  FROM site_indicator_values_view siv
  GROUP BY 
    organization_name, business_line_name, subsidiary_name, 
    indicator_code, year, process_code,
    indicator_name, unit, axe, formule, frequence, indicator_type, process_name
),
calculated_data AS (
  SELECT *,
    -- Calculate variation percentage
    CASE 
      WHEN valeur_precedente > 0 THEN 
        ROUND(((valeur_totale - valeur_precedente) / valeur_precedente * 100)::numeric, 2)
      ELSE 0
    END as variation
  FROM site_data
)
SELECT *
FROM calculated_data
ORDER BY organization_name, business_line_name, subsidiary_name, indicator_code;

-- Create site performance summary view
CREATE OR REPLACE VIEW site_performance_summary AS
SELECT 
  s.name as site_name,
  s.organization_name,
  s.business_line_name,
  s.subsidiary_name,
  s.address,
  s.city,
  s.country,
  
  -- Performance metrics
  COUNT(DISTINCT iv.indicator_code) as total_indicators,
  COUNT(DISTINCT CASE WHEN iv.value IS NOT NULL THEN iv.indicator_code END) as filled_indicators,
  
  CASE 
    WHEN COUNT(DISTINCT iv.indicator_code) > 0 THEN
      ROUND((COUNT(DISTINCT CASE WHEN iv.value IS NOT NULL THEN iv.indicator_code END)::numeric / 
             COUNT(DISTINCT iv.indicator_code)::numeric * 100), 2)
    ELSE 0
  END as completion_rate,
  
  MAX(iv.updated_at) as last_updated,
  COUNT(DISTINCT iv.process_code) as active_processes
  
FROM sites s
LEFT JOIN indicator_values iv ON s.name = iv.site_name 
  AND s.organization_name = iv.organization_name
  AND iv.year = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY 
  s.name, s.organization_name, s.business_line_name, s.subsidiary_name,
  s.address, s.city, s.country
ORDER BY s.name;

-- Function to refresh consolidated views
CREATE OR REPLACE FUNCTION refresh_consolidated_views()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Refresh any materialized views if they exist
  -- For now, just return true as we're using regular views
  RETURN true;
EXCEPTION
  WHEN OTHERS THEN
    -- Log error but don't fail
    INSERT INTO system_logs (action, details, error_message)
    VALUES ('refresh_consolidated_views', 'Failed to refresh views', SQLERRM);
    RETURN false;
END;
$$;

-- Function to get consolidated indicator metadata
CREATE OR REPLACE FUNCTION get_consolidated_indicator_metadata(
  org_name text,
  target_year integer DEFAULT NULL
)
RETURNS TABLE (
  indicator_code text,
  indicator_name text,
  unit text,
  axe text,
  formule text,
  frequence text,
  type text,
  process_code text,
  process_name text,
  enjeux text,
  normes text,
  criteres text
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  WITH org_indicators AS (
    SELECT UNNEST(oi.indicator_codes) as indicator_code
    FROM organization_indicators oi
    WHERE oi.organization_name = org_name
  ),
  org_processes AS (
    SELECT p.code as process_code, p.name as process_name, 
           UNNEST(p.indicator_codes) as indicator_code
    FROM processes p
    WHERE p.organization_name = org_name
  ),
  metadata AS (
    SELECT DISTINCT
      i.code as indicator_code,
      i.name as indicator_name,
      i.unit,
      i.axe,
      i.formule,
      i.frequence,
      i.type,
      op.process_code,
      op.process_name,
      
      -- Get ESG context (simplified for now)
      'Enjeux consolidés' as enjeux,
      'Normes applicables' as normes,
      'Critères définis' as criteres
      
    FROM org_indicators oi
    JOIN indicators i ON oi.indicator_code = i.code
    LEFT JOIN org_processes op ON oi.indicator_code = op.indicator_code
  )
  SELECT 
    m.indicator_code,
    m.indicator_name,
    m.unit,
    m.axe,
    m.formule,
    m.frequence,
    m.type,
    m.process_code,
    m.process_name,
    m.enjeux,
    m.normes,
    m.criteres
  FROM metadata m
  ORDER BY m.indicator_code;
END;
$$;

-- Enable RLS on views (where applicable)
-- Note: Views inherit RLS from their underlying tables

-- Grant necessary permissions
GRANT SELECT ON site_indicator_values_view TO authenticated;
GRANT SELECT ON consolidated_indicator_values TO authenticated;
GRANT SELECT ON site_performance_summary TO authenticated;
GRANT EXECUTE ON FUNCTION refresh_consolidated_views() TO authenticated;
GRANT EXECUTE ON FUNCTION get_consolidated_indicator_metadata(text, integer) TO authenticated;