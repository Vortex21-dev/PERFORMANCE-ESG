/*
  # Add double_materialite to module_type enum

  1. Changes
    - Add 'double_materialite' value to the module_type enum
    - This allows the content_modules table to accept this module type

  2. Security
    - No RLS changes needed, just enum extension
*/

-- Add the missing enum value to module_type
ALTER TYPE module_type ADD VALUE IF NOT EXISTS 'double_materialite';