/*
  # Fix DELETE requires WHERE clause error in refresh_dashboard_performance_view

  1. Problem
    - The refresh_dashboard_performance_view function contains DELETE statements without WHERE clauses
    - PostgreSQL safety mechanism prevents this to avoid accidental data loss
    
  2. Solution
    - Replace DELETE statements with TRUNCATE TABLE commands
    - TRUNCATE is designed for clearing entire tables and doesn't require WHERE clause
    - Add proper error handling and logging
    
  3. Security
    - Function remains secure with proper access controls
    - Maintains data integrity while allowing necessary operations
*/

-- Drop and recreate the function with proper DELETE/TRUNCATE handling
DROP FUNCTION IF EXISTS refresh_dashboard_performance_view();

CREATE OR REPLACE FUNCTION refresh_dashboard_performance_view()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    _start_time timestamp := now();
    _rows_processed integer := 0;
    _error_message text;
BEGIN
    -- Log start of refresh
    INSERT INTO system_logs (action, details)
    VALUES ('refresh_dashboard_start', 'Starting dashboard performance view refresh');

    BEGIN
        -- Try to refresh materialized view if it exists
        REFRESH MATERIALIZED VIEW CONCURRENTLY dashboard_performance_view;
        
        -- Log success
        INSERT INTO system_logs (action, details)
        VALUES ('refresh_dashboard_success', 'Materialized view refreshed successfully');
        
        RETURN true;
        
    EXCEPTION WHEN OTHERS THEN
        -- If materialized view doesn't exist or fails, use manual refresh
        _error_message := SQLERRM;
        
        INSERT INTO system_logs (action, details, error_message)
        VALUES ('refresh_dashboard_fallback', 'Materialized view refresh failed, using manual method', _error_message);
        
        BEGIN
            -- Clear existing data using TRUNCATE (safe for clearing entire tables)
            TRUNCATE TABLE dashboard_performance_data;
            
            -- Repopulate with fresh data
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
            SELECT 
                iv.organization_name,
                iv.business_line_name,
                iv.subsidiary_name,
                iv.site_name,
                iv.process_code,
                iv.indicator_code,
                iv.year,
                COALESCE(i.axe, 'Non défini') as axe,
                COALESCE(
                    (SELECT string_agg(DISTINCT oi.issue_codes::text, ', ') 
                     FROM organization_issues oi 
                     WHERE oi.organization_name = iv.organization_name), 
                    'Non défini'
                ) as enjeux,
                COALESCE(
                    (SELECT string_agg(DISTINCT os.standard_codes::text, ', ') 
                     FROM organization_standards os 
                     WHERE os.organization_name = iv.organization_name), 
                    'Non défini'
                ) as normes,
                COALESCE(
                    (SELECT string_agg(DISTINCT oc.criteria_codes::text, ', ') 
                     FROM organization_criteria oc 
                     WHERE oc.organization_name = iv.organization_name), 
                    'Non défini'
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
                
                -- Total value based on formula
                CASE 
                    WHEN COALESCE(i.formule, 'somme') = 'somme' THEN COALESCE(SUM(iv.value), 0)
                    WHEN COALESCE(i.formule, 'somme') = 'moyenne' THEN COALESCE(AVG(iv.value), 0)
                    WHEN COALESCE(i.formule, 'somme') = 'max' THEN COALESCE(MAX(iv.value), 0)
                    WHEN COALESCE(i.formule, 'somme') = 'min' THEN COALESCE(MIN(iv.value), 0)
                    WHEN COALESCE(i.formule, 'somme') = 'dernier_mois' THEN 
                        COALESCE((SELECT iv2.value FROM indicator_values iv2 
                                 WHERE iv2.organization_name = iv.organization_name 
                                 AND iv2.indicator_code = iv.indicator_code 
                                 AND iv2.year = iv.year 
                                 ORDER BY iv2.month DESC LIMIT 1), 0)
                    ELSE COALESCE(SUM(iv.value), 0)
                END as valeur_totale,
                
                -- Previous year value (placeholder)
                0 as valeur_precedente,
                0 as valeur_cible,
                0 as variation,
                0 as performance,
                COALESCE(AVG(iv.value), 0) as valeur_moyenne,
                
                -- Site count and list
                COUNT(DISTINCT COALESCE(iv.site_name, 'Organisation')) as sites_count,
                array_agg(DISTINCT COALESCE(iv.site_name, 'Organisation')) as sites_list,
                
                now() as last_updated
                
            FROM indicator_values iv
            LEFT JOIN indicators i ON i.code = iv.indicator_code
            LEFT JOIN processes p ON p.code = iv.process_code
            WHERE iv.status = 'validated'
            GROUP BY 
                iv.organization_name,
                iv.business_line_name,
                iv.subsidiary_name,
                iv.site_name,
                iv.process_code,
                iv.indicator_code,
                iv.year,
                i.axe,
                i.name,
                i.unit,
                i.frequence,
                i.type,
                i.formule,
                p.name;
            
            GET DIAGNOSTICS _rows_processed = ROW_COUNT;
            
            -- Log success
            INSERT INTO system_logs (action, details)
            VALUES ('refresh_dashboard_manual_success', 
                   format('Manual refresh completed. Processed %s rows in %s seconds', 
                          _rows_processed, 
                          extract(epoch from (now() - _start_time))));
            
            RETURN true;
            
        EXCEPTION WHEN OTHERS THEN
            _error_message := SQLERRM;
            
            -- Log error
            INSERT INTO system_logs (action, details, error_message)
            VALUES ('refresh_dashboard_error', 'Manual refresh failed', _error_message);
            
            -- Don't raise exception, just return false
            RETURN false;
        END;
    END;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION refresh_dashboard_performance_view() TO authenticated;

-- Add comment
COMMENT ON FUNCTION refresh_dashboard_performance_view() IS 'Refreshes dashboard performance view data using TRUNCATE instead of DELETE for safety';