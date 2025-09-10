/*
  # Fix indicator_values missing columns

  1. Table Structure Updates
    - Add missing columns for proper identification
    - Add automatic key generation
    - Add proper constraints and defaults

  2. Triggers and Functions
    - Auto-populate missing keys
    - Set default year/month values
    - Ensure data consistency

  3. Index Optimization
    - Add performance indexes
    - Optimize for common queries
*/

-- First, add missing columns if they don't exist
DO $$
BEGIN
  -- Add business_line_key if missing
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'indicator_values' AND column_name = 'business_line_key'
  ) THEN
    ALTER TABLE indicator_values ADD COLUMN business_line_key TEXT NOT NULL DEFAULT '';
  END IF;

  -- Add subsidiary_key if missing
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'indicator_values' AND column_name = 'subsidiary_key'
  ) THEN
    ALTER TABLE indicator_values ADD COLUMN subsidiary_key TEXT NOT NULL DEFAULT '';
  END IF;

  -- Add site_key if missing
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'indicator_values' AND column_name = 'site_key'
  ) THEN
    ALTER TABLE indicator_values ADD COLUMN site_key TEXT NOT NULL DEFAULT '';
  END IF;

  -- Add year if missing
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'indicator_values' AND column_name = 'year'
  ) THEN
    ALTER TABLE indicator_values ADD COLUMN year INTEGER NOT NULL DEFAULT EXTRACT(YEAR FROM CURRENT_DATE);
  END IF;

  -- Add month if missing
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'indicator_values' AND column_name = 'month'
  ) THEN
    ALTER TABLE indicator_values ADD COLUMN month INTEGER NOT NULL DEFAULT EXTRACT(MONTH FROM CURRENT_DATE);
  END IF;

  -- Add unit if missing
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'indicator_values' AND column_name = 'unit'
  ) THEN
    ALTER TABLE indicator_values ADD COLUMN unit TEXT;
  END IF;

  -- Add period_id if missing
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'indicator_values' AND column_name = 'period_id'
  ) THEN
    ALTER TABLE indicator_values ADD COLUMN period_id UUID REFERENCES collection_periods(id);
  END IF;
END $$;

-- Update existing records to have proper keys
UPDATE indicator_values 
SET 
  business_line_key = COALESCE(business_line_name, ''),
  subsidiary_key = COALESCE(subsidiary_name, ''),
  site_key = COALESCE(site_name, ''),
  year = COALESCE(year, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER),
  month = COALESCE(month, EXTRACT(MONTH FROM CURRENT_DATE)::INTEGER)
WHERE business_line_key = '' OR subsidiary_key = '' OR site_key = '' OR year IS NULL OR month IS NULL;

-- Add constraints for data validation
DO $$
BEGIN
  -- Year constraint
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_name = 'indicator_values' AND constraint_name = 'indicator_values_year_check'
  ) THEN
    ALTER TABLE indicator_values ADD CONSTRAINT indicator_values_year_check 
    CHECK (year >= 2020 AND year <= 2030);
  END IF;

  -- Month constraint
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_name = 'indicator_values' AND constraint_name = 'indicator_values_month_check'
  ) THEN
    ALTER TABLE indicator_values ADD CONSTRAINT indicator_values_month_check 
    CHECK (month >= 1 AND month <= 12);
  END IF;

  -- Status constraint
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_name = 'indicator_values' AND constraint_name = 'indicator_values_status_check'
  ) THEN
    ALTER TABLE indicator_values ADD CONSTRAINT indicator_values_status_check 
    CHECK (status IN ('draft', 'submitted', 'validated', 'rejected'));
  END IF;
END $$;

-- Create or replace function to auto-populate keys
CREATE OR REPLACE FUNCTION set_indicator_value_keys()
RETURNS TRIGGER AS $$
BEGIN
  -- Set default year and month if not provided
  IF NEW.year IS NULL THEN
    NEW.year := EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER;
  END IF;
  
  IF NEW.month IS NULL THEN
    NEW.month := EXTRACT(MONTH FROM CURRENT_DATE)::INTEGER;
  END IF;

  -- Set keys based on hierarchy
  NEW.business_line_key := COALESCE(NEW.business_line_name, '');
  NEW.subsidiary_key := COALESCE(NEW.subsidiary_name, '');
  NEW.site_key := COALESCE(NEW.site_name, '');

  -- Set period_id if not provided (find or create active period)
  IF NEW.period_id IS NULL THEN
    SELECT id INTO NEW.period_id
    FROM collection_periods
    WHERE organization_name = NEW.organization_name
      AND year = NEW.year
      AND period_type = 'month'
      AND period_number = NEW.month
      AND status = 'open'
    LIMIT 1;
    
    -- If no period found, create one
    IF NEW.period_id IS NULL THEN
      INSERT INTO collection_periods (
        organization_name,
        year,
        period_type,
        period_number,
        start_date,
        end_date,
        status
      ) VALUES (
        NEW.organization_name,
        NEW.year,
        'month',
        NEW.month,
        DATE(NEW.year || '-' || LPAD(NEW.month::TEXT, 2, '0') || '-01'),
        (DATE(NEW.year || '-' || LPAD(NEW.month::TEXT, 2, '0') || '-01') + INTERVAL '1 month - 1 day')::DATE,
        'open'
      )
      ON CONFLICT (organization_name, year, period_type, period_number) DO NOTHING
      RETURNING id INTO NEW.period_id;
      
      -- If still null due to conflict, get the existing one
      IF NEW.period_id IS NULL THEN
        SELECT id INTO NEW.period_id
        FROM collection_periods
        WHERE organization_name = NEW.organization_name
          AND year = NEW.year
          AND period_type = 'month'
          AND period_number = NEW.month
        LIMIT 1;
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS set_indicator_value_keys_trigger ON indicator_values;

-- Create trigger to auto-populate keys
CREATE TRIGGER set_indicator_value_keys_trigger
  BEFORE INSERT OR UPDATE ON indicator_values
  FOR EACH ROW EXECUTE FUNCTION set_indicator_value_keys();

-- Create performance indexes
CREATE INDEX IF NOT EXISTS idx_indicator_values_composite_key 
ON indicator_values (organization_name, business_line_key, subsidiary_key, site_key, process_code, indicator_code, year, month);

CREATE INDEX IF NOT EXISTS idx_indicator_values_year_month 
ON indicator_values (year, month);

CREATE INDEX IF NOT EXISTS idx_indicator_values_process_indicator 
ON indicator_values (process_code, indicator_code);

CREATE INDEX IF NOT EXISTS idx_indicator_values_status_org 
ON indicator_values (status, organization_name);

CREATE INDEX IF NOT EXISTS idx_indicator_values_site_year_month 
ON indicator_values (site_name, year, month, status);

-- Add unique constraint to prevent duplicates
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

-- Insert test data for collection periods
INSERT INTO collection_periods (organization_name, year, period_type, period_number, start_date, end_date, status)
VALUES 
  ('TestFiliere', 2024, 'month', 1, '2024-01-01', '2024-01-31', 'open'),
  ('TestFiliere', 2024, 'month', 2, '2024-02-01', '2024-02-29', 'open'),
  ('TestFiliere', 2024, 'month', 3, '2024-03-01', '2024-03-31', 'open'),
  ('TestFiliere', 2024, 'month', 4, '2024-04-01', '2024-04-30', 'open'),
  ('TestFiliere', 2024, 'month', 5, '2024-05-01', '2024-05-31', 'open'),
  ('TestFiliere', 2024, 'month', 6, '2024-06-01', '2024-06-30', 'open'),
  ('TestFiliere', 2024, 'month', 7, '2024-07-01', '2024-07-31', 'open'),
  ('TestFiliere', 2024, 'month', 8, '2024-08-01', '2024-08-31', 'open'),
  ('TestFiliere', 2024, 'month', 9, '2024-09-01', '2024-09-30', 'open'),
  ('TestFiliere', 2024, 'month', 10, '2024-10-01', '2024-10-31', 'open'),
  ('TestFiliere', 2024, 'month', 11, '2024-11-01', '2024-11-30', 'open'),
  ('TestFiliere', 2024, 'month', 12, '2024-12-01', '2024-12-31', 'open')
ON CONFLICT (organization_name, year, period_type, period_number) DO NOTHING;

-- Update existing indicator_values to have proper keys if they're missing
UPDATE indicator_values 
SET 
  business_line_key = COALESCE(business_line_name, ''),
  subsidiary_key = COALESCE(subsidiary_name, ''),
  site_key = COALESCE(site_name, ''),
  year = COALESCE(year, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER),
  month = COALESCE(month, EXTRACT(MONTH FROM CURRENT_DATE)::INTEGER)
WHERE business_line_key IS NULL OR subsidiary_key IS NULL OR site_key IS NULL 
   OR year IS NULL OR month IS NULL;