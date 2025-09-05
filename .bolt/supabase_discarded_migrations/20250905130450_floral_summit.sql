/*
  # Add status column to content_modules table

  1. Changes
    - Add status column to content_modules table with default value 'draft'
    - Update existing records to have 'draft' status
  
  2. Security
    - No changes to RLS policies needed
*/

-- Add status column to content_modules table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'content_modules' AND column_name = 'status'
  ) THEN
    ALTER TABLE content_modules ADD COLUMN status text DEFAULT 'draft' NOT NULL;
    
    -- Add check constraint for valid status values
    ALTER TABLE content_modules ADD CONSTRAINT content_modules_status_check 
    CHECK (status IN ('draft', 'published'));
  END IF;
END $$;