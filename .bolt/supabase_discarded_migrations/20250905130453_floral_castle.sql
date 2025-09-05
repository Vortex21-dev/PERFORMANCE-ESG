/*
  # Fix double_materiality_matrix ID sequence

  1. Changes
    - Reset the ID sequence to start from 1
    - Update existing IDs to be sequential starting from 1
  
  2. Security
    - No changes to RLS policies needed
*/

-- Create a temporary sequence to renumber IDs
DO $$
DECLARE
    rec RECORD;
    new_id INTEGER := 1;
BEGIN
    -- Create a temporary table to store the mapping
    CREATE TEMP TABLE id_mapping (old_id INTEGER, new_id INTEGER);
    
    -- Get all records ordered by current ID
    FOR rec IN 
        SELECT id FROM double_materiality_matrix ORDER BY id
    LOOP
        INSERT INTO id_mapping (old_id, new_id) VALUES (rec.id, new_id);
        new_id := new_id + 1;
    END LOOP;
    
    -- Update the IDs using the mapping
    UPDATE double_materiality_matrix 
    SET id = id_mapping.new_id 
    FROM id_mapping 
    WHERE double_materiality_matrix.id = id_mapping.old_id;
    
    -- Reset the sequence to continue from the last used ID
    PERFORM setval('double_materiality_matrix_id_seq', COALESCE(MAX(id), 1), true) 
    FROM double_materiality_matrix;
    
    DROP TABLE id_mapping;
END $$;