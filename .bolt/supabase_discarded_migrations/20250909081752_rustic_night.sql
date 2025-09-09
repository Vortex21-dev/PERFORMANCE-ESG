/*
  # Fix DELETE operation WHERE clause error

  1. Problem Analysis
    - DELETE operation on indicator_values table fails with "DELETE requires a WHERE clause"
    - Error occurs despite ID filter being present in the URL
    - Likely caused by RLS policies or triggers

  2. Solutions
    - Review and fix RLS policies for DELETE operations
    - Check for problematic triggers
    - Ensure proper WHERE clause handling
*/

-- First, let's check current RLS policies on indicator_values table
-- and fix any that might be causing issues with DELETE operations

-- Drop and recreate problematic RLS policies for DELETE operations
DROP POLICY IF EXISTS "Contributors can manage their assigned indicators" ON indicator_values;
DROP POLICY IF EXISTS "Validators can validate their assigned indicators" ON indicator_values;

-- Recreate the policies with proper DELETE handling
CREATE POLICY "Contributors can manage their assigned indicators"
  ON indicator_values
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles p
      LEFT JOIN user_processes up ON up.email = p.email
      WHERE p.email = (jwt() ->> 'email')
        AND (
          p.role = 'admin'
          OR (
            p.role = 'contributor'
            AND indicator_values.process_code = ANY(COALESCE(up.process_codes, ARRAY[]::text[]))
          )
          OR p.role IN ('enterprise', 'validator')
        )
        AND (
          (p.organization_level = 'organization' AND p.organization_name = indicator_values.organization_name)
          OR (p.organization_level = 'business_line' AND p.business_line_name = indicator_values.business_line_name)
          OR (p.organization_level = 'subsidiary' AND p.subsidiary_name = indicator_values.subsidiary_name)
          OR (p.organization_level = 'site' AND p.site_name = indicator_values.site_name)
          OR p.role = 'admin'
        )
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles p
      LEFT JOIN user_processes up ON up.email = p.email
      WHERE p.email = (jwt() ->> 'email')
        AND (
          p.role = 'admin'
          OR (
            p.role = 'contributor'
            AND indicator_values.process_code = ANY(COALESCE(up.process_codes, ARRAY[]::text[]))
          )
          OR p.role IN ('enterprise', 'validator')
        )
        AND (
          (p.organization_level = 'organization' AND p.organization_name = indicator_values.organization_name)
          OR (p.organization_level = 'business_line' AND p.business_line_name = indicator_values.business_line_name)
          OR (p.organization_level = 'subsidiary' AND p.subsidiary_name = indicator_values.subsidiary_name)
          OR (p.organization_level = 'site' AND p.site_name = indicator_values.site_name)
          OR p.role = 'admin'
        )
    )
  );

CREATE POLICY "Validators can validate their assigned indicators"
  ON indicator_values
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles p
      LEFT JOIN user_processes up ON up.email = p.email
      WHERE p.email = (jwt() ->> 'email')
        AND p.role = 'validator'
        AND indicator_values.process_code = ANY(COALESCE(up.process_codes, ARRAY[]::text[]))
        AND (
          (p.organization_level = 'organization' AND p.organization_name = indicator_values.organization_name)
          OR (p.organization_level = 'business_line' AND p.business_line_name = indicator_values.business_line_name)
          OR (p.organization_level = 'subsidiary' AND p.subsidiary_name = indicator_values.subsidiary_name)
          OR (p.organization_level = 'site' AND p.site_name = indicator_values.site_name)
        )
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles p
      LEFT JOIN user_processes up ON up.email = p.email
      WHERE p.email = (jwt() ->> 'email')
        AND p.role = 'validator'
        AND indicator_values.process_code = ANY(COALESCE(up.process_codes, ARRAY[]::text[]))
        AND (
          (p.organization_level = 'organization' AND p.organization_name = indicator_values.organization_name)
          OR (p.organization_level = 'business_line' AND p.business_line_name = indicator_values.business_line_name)
          OR (p.organization_level = 'subsidiary' AND p.subsidiary_name = indicator_values.subsidiary_name)
          OR (p.organization_level = 'site' AND p.site_name = indicator_values.site_name)
        )
    )
  );

-- Check if there are any triggers that might be causing DELETE issues
-- and fix the consolidation trigger to handle DELETE operations properly
DROP TRIGGER IF EXISTS trigger_update_consolidation_on_indicator_change ON indicator_values;

CREATE OR REPLACE FUNCTION trigger_consolidation_update()
RETURNS TRIGGER AS $$
BEGIN
  -- Only trigger consolidation for validated data
  IF TG_OP = 'DELETE' THEN
    -- For DELETE operations, use OLD record
    IF OLD.status = 'validated' THEN
      PERFORM refresh_site_indicator_consolidation(OLD.organization_name);
    END IF;
    RETURN OLD;
  ELSE
    -- For INSERT/UPDATE operations, use NEW record
    IF NEW.status = 'validated' OR (TG_OP = 'UPDATE' AND OLD.status != NEW.status AND NEW.status = 'validated') THEN
      PERFORM refresh_site_indicator_consolidation(NEW.organization_name);
    END IF;
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Recreate the trigger with proper DELETE handling
CREATE TRIGGER trigger_update_consolidation_on_indicator_change
  AFTER INSERT OR UPDATE OR DELETE ON indicator_values
  FOR EACH ROW
  EXECUTE FUNCTION trigger_consolidation_update();

-- Add a function to safely delete indicator values with proper logging
CREATE OR REPLACE FUNCTION safe_delete_indicator_value(indicator_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  -- Log the deletion attempt
  INSERT INTO system_logs (action, details)
  VALUES ('DELETE_INDICATOR_VALUE_ATTEMPT', 'Attempting to delete indicator value: ' || indicator_id::text);
  
  -- Perform the deletion with explicit WHERE clause
  DELETE FROM indicator_values 
  WHERE id = indicator_id;
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  
  -- Log the result
  INSERT INTO system_logs (action, details)
  VALUES ('DELETE_INDICATOR_VALUE_RESULT', 'Deleted ' || deleted_count || ' rows for indicator: ' || indicator_id::text);
  
  RETURN deleted_count > 0;
EXCEPTION WHEN OTHERS THEN
  -- Log any errors
  INSERT INTO system_logs (action, details, error_message)
  VALUES ('DELETE_INDICATOR_VALUE_ERROR', 'Error deleting indicator: ' || indicator_id::text, SQLERRM);
  
  RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION safe_delete_indicator_value(UUID) TO authenticated;