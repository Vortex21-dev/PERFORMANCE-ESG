/*
  # Fix Double Materiality Matrix Sequential IDs

  1. Changes
    - Remove auto-increment from id column
    - Make id a regular integer that we control manually
    - Reset existing IDs to be sequential per organization (1, 2, 3...)
    - Update constraints to work with manual ID management

  2. Security
    - Maintain existing RLS policies
    - Preserve all data integrity
*/

-- First, let's create a backup of the current data
CREATE TEMP TABLE double_materiality_backup AS 
SELECT * FROM double_materiality_matrix;

-- Drop the existing table and recreate without auto-increment
DROP TABLE IF EXISTS double_materiality_matrix CASCADE;

-- Recreate the table with manual ID control
CREATE TABLE double_materiality_matrix (
  id integer NOT NULL,
  organization_name text NOT NULL,
  issue_name text NOT NULL,
  type text NOT NULL,
  impact_score integer NOT NULL,
  financial_score integer NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT double_materiality_matrix_pkey PRIMARY KEY (id),
  CONSTRAINT double_materiality_matrix_type_check CHECK ((type = ANY (ARRAY['Env'::text, 'Soc'::text, 'Gouv'::text]))),
  CONSTRAINT double_materiality_matrix_impact_score_check CHECK (((impact_score >= 1) AND (impact_score <= 5))),
  CONSTRAINT double_materiality_matrix_financial_score_check CHECK (((financial_score >= 1) AND (financial_score <= 5))),
  CONSTRAINT double_materiality_matrix_organization_name_fkey FOREIGN KEY (organization_name) REFERENCES organizations(name) ON DELETE CASCADE
);

-- Create indexes
CREATE INDEX idx_materiality_org ON double_materiality_matrix USING btree (organization_name);
CREATE INDEX idx_materiality_scores ON double_materiality_matrix USING btree (impact_score, financial_score);
CREATE INDEX idx_materiality_type ON double_materiality_matrix USING btree (type);

-- Enable RLS
ALTER TABLE double_materiality_matrix ENABLE ROW LEVEL SECURITY;

-- Recreate RLS policies
CREATE POLICY "Admins can manage" ON double_materiality_matrix
  FOR ALL
  TO public
  USING ((jwt() ->> 'email'::text) IN ( SELECT profiles.email
   FROM profiles
  WHERE (profiles.role = ANY (ARRAY['admin'::text, 'enterprise'::text]))))
  WITH CHECK ((jwt() ->> 'email'::text) IN ( SELECT profiles.email
   FROM profiles
  WHERE (profiles.role = ANY (ARRAY['admin'::text, 'enterprise'::text]))));

CREATE POLICY "Users can view their org" ON double_materiality_matrix
  FOR SELECT
  TO public
  USING (organization_name = current_setting('app.current_org'::text, true));

-- Recreate the trigger for updated_at
CREATE OR REPLACE FUNCTION update_materiality_ts()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON double_materiality_matrix
  FOR EACH ROW
  EXECUTE FUNCTION update_materiality_ts();

-- Restore data with sequential IDs per organization
DO $$
DECLARE
  org_record RECORD;
  row_record RECORD;
  new_id integer;
BEGIN
  -- For each organization, assign sequential IDs starting from 1
  FOR org_record IN 
    SELECT DISTINCT organization_name 
    FROM double_materiality_backup 
    ORDER BY organization_name
  LOOP
    new_id := 1;
    
    -- Insert rows for this organization with sequential IDs
    FOR row_record IN 
      SELECT * 
      FROM double_materiality_backup 
      WHERE organization_name = org_record.organization_name 
      ORDER BY id
    LOOP
      INSERT INTO double_materiality_matrix (
        id,
        organization_name,
        issue_name,
        type,
        impact_score,
        financial_score,
        created_at,
        updated_at
      ) VALUES (
        new_id,
        row_record.organization_name,
        row_record.issue_name,
        row_record.type,
        row_record.impact_score,
        row_record.financial_score,
        row_record.created_at,
        row_record.updated_at
      );
      
      new_id := new_id + 1;
    END LOOP;
  END LOOP;
END $$;

-- Drop the backup table
DROP TABLE double_materiality_backup;