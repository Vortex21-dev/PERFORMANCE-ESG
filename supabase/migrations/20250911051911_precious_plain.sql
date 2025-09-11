/*
  # Add unit column to indicator_values table

  1. Changes
    - Add `unit` column to `indicator_values` table
    - Set default value to empty string
    - Add index for performance

  2. Security
    - No RLS changes needed as table already has proper policies
*/

-- Add unit column to indicator_values table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'indicator_values' 
    AND column_name = 'unit'
    AND table_schema = 'public'
  ) THEN
    ALTER TABLE public.indicator_values 
    ADD COLUMN unit text DEFAULT '' NOT NULL;
    
    -- Add index for performance
    CREATE INDEX IF NOT EXISTS idx_indicator_values_unit 
    ON public.indicator_values(unit);
    
    -- Update existing records to have proper units from indicators table
    UPDATE public.indicator_values 
    SET unit = COALESCE(
      (SELECT i.unit FROM public.indicators i WHERE i.code = indicator_values.indicator_code),
      ''
    )
    WHERE unit = '' OR unit IS NULL;
  END IF;
END $$;