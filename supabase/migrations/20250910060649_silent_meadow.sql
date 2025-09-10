/*
  # Add unit column to indicator_values table

  1. New Column
    - `unit` (text, nullable) - Unit of measurement for the indicator value

  2. Changes
    - Add unit column to indicator_values table to store measurement units
    - Column is nullable to maintain compatibility with existing data
*/

-- Add unit column to indicator_values table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'indicator_values' AND column_name = 'unit'
  ) THEN
    ALTER TABLE indicator_values ADD COLUMN unit text;
  END IF;
END $$;