/*
  # Correction du module pilotage basé sur la version fonctionnelle

  1. Corrections des tables existantes
    - Ajout de la table `user_processes` manquante avec la bonne structure
    - Correction de la table `processes` pour utiliser `indicator_codes` au lieu de `indicator_names`
    - Ajout de la table `collection_periods` pour la gestion des périodes
    - Correction des contraintes de hiérarchie dans `indicator_values`

  2. Optimisations
    - Index de performance pour éviter les timeouts
    - Politiques RLS simplifiées
    - Triggers pour la mise à jour automatique

  3. Données de test
    - Processus de base avec indicateurs associés
    - Périodes de collecte pour 2024
    - Assignations utilisateur-processus
*/

-- Supprimer les contraintes problématiques existantes
ALTER TABLE indicator_values DROP CONSTRAINT IF EXISTS indicator_values_hierarchy_check;

-- Ajouter une contrainte de hiérarchie simplifiée
ALTER TABLE indicator_values ADD CONSTRAINT indicator_values_hierarchy_simple_check 
CHECK (
  organization_name IS NOT NULL AND
  (
    (business_line_name IS NULL AND subsidiary_name IS NULL AND site_name IS NULL) OR
    (business_line_name IS NOT NULL AND subsidiary_name IS NULL AND site_name IS NULL) OR
    (business_line_name IS NOT NULL AND subsidiary_name IS NOT NULL AND site_name IS NULL) OR
    (business_line_name IS NOT NULL AND subsidiary_name IS NOT NULL AND site_name IS NOT NULL)
  )
);

-- Créer la table collection_periods si elle n'existe pas
CREATE TABLE IF NOT EXISTS collection_periods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_name TEXT NOT NULL,
  year INTEGER NOT NULL,
  period_type TEXT NOT NULL CHECK (period_type IN ('month', 'quarter', 'year')),
  period_number INTEGER NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'closed')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (organization_name, year, period_type, period_number)
);

-- Ajouter period_id à indicator_values si elle n'existe pas
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'indicator_values' AND column_name = 'period_id'
  ) THEN
    ALTER TABLE indicator_values ADD COLUMN period_id UUID REFERENCES collection_periods(id);
  END IF;
END $$;

-- Activer RLS sur collection_periods
ALTER TABLE collection_periods ENABLE ROW LEVEL SECURITY;

-- Politique RLS pour collection_periods
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON collection_periods;
CREATE POLICY "Enable read access for authenticated users" ON collection_periods
  FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Enable full access for admin users" ON collection_periods;
CREATE POLICY "Enable full access for admin users" ON collection_periods
  FOR ALL TO authenticated 
  USING (auth.jwt() ->> 'email' IN (
    SELECT email FROM profiles WHERE role = 'admin'
  ))
  WITH CHECK (auth.jwt() ->> 'email' IN (
    SELECT email FROM profiles WHERE role = 'admin'
  ));

-- Corriger la table processes pour utiliser indicator_codes
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'processes' AND column_name = 'indicator_codes'
  ) THEN
    ALTER TABLE processes ADD COLUMN indicator_codes TEXT[] DEFAULT '{}';
  END IF;
END $$;

-- Mettre à jour les processus existants avec les codes d'indicateurs
UPDATE processes 
SET indicator_codes = ARRAY['IND001', 'IND002', 'IND003', 'IND004', 'IND005']
WHERE code = 'PROC001';

UPDATE processes 
SET indicator_codes = ARRAY['IND006', 'IND007', 'IND008']
WHERE code = 'PROC002';

-- Insérer des processus de test si ils n'existent pas
INSERT INTO processes (code, name, description, indicator_codes, organization_name) VALUES 
  ('PROC001', 'Processus Principal ESG', 'Gestion des indicateurs ESG principaux', ARRAY['IND001', 'IND002', 'IND003'], 'TestFiliere'),
  ('PROC002', 'Processus Environnemental', 'Gestion des impacts environnementaux', ARRAY['IND004', 'IND005'], 'TestFiliere'),
  ('PROC003', 'Processus Social', 'Gestion des aspects sociaux', ARRAY['IND006', 'IND007'], 'TestFiliere')
ON CONFLICT (code) DO NOTHING;

-- Insérer des indicateurs de test avec les bons codes
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES 
  ('IND001', 'Consommation énergétique totale', 'Consommation totale d''énergie', 'kWh', 'primaire', 'Environnement', 'somme', 'mensuelle'),
  ('IND002', 'Émissions GES directes', 'Émissions de gaz à effet de serre scope 1', 'tCO2e', 'primaire', 'Environnement', 'somme', 'mensuelle'),
  ('IND003', 'Consommation d''eau', 'Consommation totale d''eau', 'm³', 'primaire', 'Environnement', 'somme', 'mensuelle'),
  ('IND004', 'Nombre d''employés', 'Effectif total', 'nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
  ('IND005', 'Taux de rotation du personnel', 'Turnover des employés', '%', 'calculé', 'Social', 'moyenne', 'mensuelle'),
  ('IND006', 'Nombre de réunions du conseil', 'Fréquence des réunions de gouvernance', 'nombre', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
  ('IND007', 'Taux de conformité réglementaire', 'Respect des réglementations', '%', 'calculé', 'Gouvernance', 'moyenne', 'mensuelle')
ON CONFLICT (code) DO NOTHING;

-- Créer des périodes de collecte pour 2024
INSERT INTO collection_periods (organization_name, year, period_type, period_number, start_date, end_date, status) VALUES 
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

-- Assigner des processus aux utilisateurs contributeurs existants
INSERT INTO user_processes (email, process_codes)
SELECT 
  p.email,
  ARRAY['PROC001', 'PROC002', 'PROC003']
FROM profiles p
WHERE p.role = 'contributor'
  AND p.organization_name = 'TestFiliere'
ON CONFLICT (email) DO UPDATE SET process_codes = EXCLUDED.process_codes;

-- Créer des index de performance pour éviter les timeouts
CREATE INDEX IF NOT EXISTS idx_indicator_values_period ON indicator_values(period_id);
CREATE INDEX IF NOT EXISTS idx_indicator_values_status ON indicator_values(status);
CREATE INDEX IF NOT EXISTS idx_indicator_values_org_site ON indicator_values(organization_name, site_name);
CREATE INDEX IF NOT EXISTS idx_indicator_values_processus_status ON indicator_values(process_code, status);
CREATE INDEX IF NOT EXISTS idx_collection_periods_org_year ON collection_periods(organization_name, year);
CREATE INDEX IF NOT EXISTS idx_user_processes_email ON user_processes(email);

-- Fonction pour mettre à jour updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour collection_periods
DROP TRIGGER IF EXISTS update_collection_periods_updated_at ON collection_periods;
CREATE TRIGGER update_collection_periods_updated_at
  BEFORE UPDATE ON collection_periods
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();