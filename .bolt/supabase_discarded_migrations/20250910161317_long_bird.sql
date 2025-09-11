/*
  # Fix indicator_values table structure

  1. Table Updates
    - Add missing identification columns to indicator_values
    - Add proper constraints and indexes
    - Update existing data to have proper keys

  2. Security
    - Maintain existing RLS policies
    - Add policies for new columns

  3. Performance
    - Add indexes for new composite keys
    - Optimize query performance
*/

-- Add missing columns to indicator_values table
DO $$
BEGIN
  -- Add business_line_key if not exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'indicator_values' AND column_name = 'business_line_key'
  ) THEN
    ALTER TABLE indicator_values ADD COLUMN business_line_key TEXT NOT NULL DEFAULT '';
  END IF;

  -- Add subsidiary_key if not exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'indicator_values' AND column_name = 'subsidiary_key'
  ) THEN
    ALTER TABLE indicator_values ADD COLUMN subsidiary_key TEXT NOT NULL DEFAULT '';
  END IF;

  -- Add site_key if not exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'indicator_values' AND column_name = 'site_key'
  ) THEN
    ALTER TABLE indicator_values ADD COLUMN site_key TEXT NOT NULL DEFAULT '';
  END IF;

  -- Add year column if not exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'indicator_values' AND column_name = 'year'
  ) THEN
    ALTER TABLE indicator_values ADD COLUMN year INTEGER;
  END IF;

  -- Add month column if not exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'indicator_values' AND column_name = 'month'
  ) THEN
    ALTER TABLE indicator_values ADD COLUMN month INTEGER;
  END IF;
END $$;

-- Update existing records to have proper key values
UPDATE indicator_values SET
  business_line_key = COALESCE(business_line_name, ''),
  subsidiary_key = COALESCE(subsidiary_name, ''),
  site_key = COALESCE(site_name, ''),
  year = COALESCE(year, EXTRACT(YEAR FROM created_at)::INTEGER),
  month = COALESCE(month, EXTRACT(MONTH FROM created_at)::INTEGER)
WHERE business_line_key = '' OR subsidiary_key = '' OR site_key = '' OR year IS NULL OR month IS NULL;

-- Add constraints for year and month
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_name = 'indicator_values' AND constraint_name = 'indicator_values_month_check'
  ) THEN
    ALTER TABLE indicator_values ADD CONSTRAINT indicator_values_month_check 
    CHECK (month >= 1 AND month <= 12);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_name = 'indicator_values' AND constraint_name = 'indicator_values_year_check'
  ) THEN
    ALTER TABLE indicator_values ADD CONSTRAINT indicator_values_year_check 
    CHECK (year >= 2020 AND year <= 2030);
  END IF;
END $$;

-- Create unique constraint for proper identification
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_name = 'indicator_values' AND constraint_name = 'indicator_values_unique_composite'
  ) THEN
    ALTER TABLE indicator_values ADD CONSTRAINT indicator_values_unique_composite 
    UNIQUE (organization_name, business_line_key, subsidiary_key, site_key, process_code, indicator_code, year, month);
  END IF;
END $$;

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_indicator_values_composite_key 
ON indicator_values (organization_name, business_line_key, subsidiary_key, site_key);

CREATE INDEX IF NOT EXISTS idx_indicator_values_year_month 
ON indicator_values (year, month);

CREATE INDEX IF NOT EXISTS idx_indicator_values_process_indicator 
ON indicator_values (process_code, indicator_code);

-- Create function to automatically set key values
CREATE OR REPLACE FUNCTION set_indicator_value_keys()
RETURNS TRIGGER AS $$
BEGIN
  -- Set business_line_key
  NEW.business_line_key = COALESCE(NEW.business_line_name, '');
  
  -- Set subsidiary_key
  NEW.subsidiary_key = COALESCE(NEW.subsidiary_name, '');
  
  -- Set site_key
  NEW.site_key = COALESCE(NEW.site_name, '');
  
  -- Set year and month if not provided
  IF NEW.year IS NULL THEN
    NEW.year = EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER;
  END IF;
  
  IF NEW.month IS NULL THEN
    NEW.month = EXTRACT(MONTH FROM CURRENT_DATE)::INTEGER;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically set keys
DROP TRIGGER IF EXISTS set_indicator_value_keys_trigger ON indicator_values;
CREATE TRIGGER set_indicator_value_keys_trigger
  BEFORE INSERT OR UPDATE ON indicator_values
  FOR EACH ROW EXECUTE FUNCTION set_indicator_value_keys();

-- Update existing RLS policies to work with new structure
DROP POLICY IF EXISTS "Contributors can manage their assigned indicators" ON indicator_values;
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
      p.role = 'admin' OR
      (p.role = 'contributor' AND indicator_values.process_code = ANY(COALESCE(up.process_codes, ARRAY[]::text[]))) OR
      p.role IN ('enterprise', 'validator')
    )
    AND (
      (p.organization_level = 'organization' AND p.organization_name = indicator_values.organization_name) OR
      (p.organization_level = 'business_line' AND p.business_line_name = indicator_values.business_line_name) OR
      (p.organization_level = 'subsidiary' AND p.subsidiary_name = indicator_values.subsidiary_name) OR
      (p.organization_level = 'site' AND p.site_name = indicator_values.site_name) OR
      p.role = 'admin'
    )
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM profiles p
    LEFT JOIN user_processes up ON up.email = p.email
    WHERE p.email = (jwt() ->> 'email')
    AND (
      p.role = 'admin' OR
      (p.role = 'contributor' AND indicator_values.process_code = ANY(COALESCE(up.process_codes, ARRAY[]::text[]))) OR
      p.role IN ('enterprise', 'validator')
    )
    AND (
      (p.organization_level = 'organization' AND p.organization_name = indicator_values.organization_name) OR
      (p.organization_level = 'business_line' AND p.business_line_name = indicator_values.business_line_name) OR
      (p.organization_level = 'subsidiary' AND p.subsidiary_name = indicator_values.subsidiary_name) OR
      (p.organization_level = 'site' AND p.site_name = indicator_values.site_name) OR
      p.role = 'admin'
    )
  )
);