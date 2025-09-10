/*
  # Réplication complète du module pilotage

  1. Suppression des tables existantes conflictuelles
  2. Création de la structure complète pour le module pilotage
  3. Configuration des politiques RLS optimisées
  4. Création des index de performance
  5. Insertion des données de test
  6. Fonctions et triggers essentiels

  Ce script recrée entièrement le module pilotage selon les spécifications.
*/

-- =====================================================
-- ÉTAPE 1: SUPPRESSION DES TABLES CONFLICTUELLES
-- =====================================================

-- Désactiver temporairement les contraintes de clés étrangères
SET session_replication_role = replica;

-- Supprimer les tables dans l'ordre inverse des dépendances
DROP TABLE IF EXISTS indicator_values CASCADE;
DROP TABLE IF EXISTS user_processes CASCADE;
DROP TABLE IF EXISTS collection_periods CASCADE;
DROP TABLE IF EXISTS organization_selections CASCADE;
DROP TABLE IF EXISTS sector_standards_issues_criteria_indicators CASCADE;
DROP TABLE IF EXISTS sector_standards_issues_criteria CASCADE;
DROP TABLE IF EXISTS sector_standards_issues CASCADE;
DROP TABLE IF EXISTS sector_standards CASCADE;
DROP TABLE IF EXISTS user_processus CASCADE;
DROP TABLE IF EXISTS processus CASCADE;
DROP TABLE IF EXISTS energy_types CASCADE;

-- Réactiver les contraintes
SET session_replication_role = DEFAULT;

-- =====================================================
-- ÉTAPE 2: CRÉATION DES TABLES DE BASE
-- =====================================================

-- Table des types d'énergie
CREATE TABLE IF NOT EXISTS energy_types (
  name TEXT NOT NULL,
  sector_name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (name, sector_name),
  FOREIGN KEY (sector_name) REFERENCES sectors(name) ON DELETE CASCADE
);

-- Table des processus (renommée pour éviter les conflits)
CREATE TABLE IF NOT EXISTS processus (
  code TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  criteres TEXT[] DEFAULT '{}',
  indicateurs TEXT[] DEFAULT '{}',
  organization_name TEXT DEFAULT 'TestFiliere',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des filières
CREATE TABLE IF NOT EXISTS filieres (
  name TEXT PRIMARY KEY,
  organization_name TEXT NOT NULL,
  location TEXT,
  manager TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  FOREIGN KEY (organization_name) REFERENCES organizations(name) ON DELETE CASCADE
);

-- Table des filiales
CREATE TABLE IF NOT EXISTS filiales (
  name TEXT PRIMARY KEY,
  organization_name TEXT NOT NULL,
  filiere_name TEXT,
  description TEXT,
  address TEXT NOT NULL,
  city TEXT NOT NULL,
  country TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT NOT NULL,
  website TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  FOREIGN KEY (organization_name) REFERENCES organizations(name) ON DELETE CASCADE,
  FOREIGN KEY (filiere_name) REFERENCES filieres(name) ON DELETE CASCADE
);

-- =====================================================
-- ÉTAPE 3: TABLES SPÉCIFIQUES AU PILOTAGE
-- =====================================================

-- Table des périodes de collecte
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
  UNIQUE (organization_name, year, period_type, period_number),
  FOREIGN KEY (organization_name) REFERENCES organizations(name) ON DELETE CASCADE
);

-- Table des valeurs d'indicateurs (CŒUR DU MODULE PILOTAGE)
CREATE TABLE IF NOT EXISTS indicator_values (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  period_id UUID,
  organization_name TEXT NOT NULL,
  filiere_name TEXT,
  filiale_name TEXT,
  site_name TEXT,
  processus_code TEXT NOT NULL,
  indicator_code TEXT NOT NULL,
  year INTEGER NOT NULL,
  month INTEGER NOT NULL CHECK (month >= 1 AND month <= 12),
  value NUMERIC,
  unit TEXT,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'submitted', 'validated', 'rejected')),
  comment TEXT,
  submitted_by TEXT,
  submitted_at TIMESTAMPTZ,
  validated_by TEXT,
  validated_at TIMESTAMPTZ,
  criteria_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Contraintes de hiérarchie simplifiées
  CONSTRAINT indicator_values_hierarchy_check CHECK (
    (organization_name IS NOT NULL) AND
    (
      -- Niveau organisation seul
      (filiere_name IS NULL AND filiale_name IS NULL AND site_name IS NULL) OR
      -- Niveau filière
      (filiere_name IS NOT NULL AND filiale_name IS NULL AND site_name IS NULL) OR
      -- Niveau filiale
      (filiere_name IS NOT NULL AND filiale_name IS NOT NULL AND site_name IS NULL) OR
      -- Niveau site
      (filiere_name IS NOT NULL AND filiale_name IS NOT NULL AND site_name IS NOT NULL)
    )
  ),
  
  FOREIGN KEY (organization_name) REFERENCES organizations(name) ON DELETE CASCADE,
  FOREIGN KEY (period_id) REFERENCES collection_periods(id) ON DELETE CASCADE,
  FOREIGN KEY (processus_code) REFERENCES processus(code) ON DELETE CASCADE,
  FOREIGN KEY (indicator_code) REFERENCES indicators(code) ON DELETE CASCADE,
  FOREIGN KEY (filiere_name) REFERENCES filieres(name) ON DELETE CASCADE,
  FOREIGN KEY (filiale_name) REFERENCES filiales(name) ON DELETE CASCADE,
  FOREIGN KEY (site_name) REFERENCES sites(name) ON DELETE CASCADE,
  FOREIGN KEY (submitted_by) REFERENCES profiles(email),
  FOREIGN KEY (validated_by) REFERENCES profiles(email)
);

-- Table d'association utilisateur-processus
CREATE TABLE IF NOT EXISTS user_processus (
  email TEXT NOT NULL,
  processus_code TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (email, processus_code),
  FOREIGN KEY (email) REFERENCES profiles(email) ON DELETE CASCADE,
  FOREIGN KEY (processus_code) REFERENCES processus(code) ON DELETE CASCADE
);

-- Table des sélections d'organisation
CREATE TABLE IF NOT EXISTS organization_selections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_name TEXT NOT NULL,
  sector_name TEXT,
  energy_type_name TEXT,
  standard_names TEXT[] DEFAULT '{}',
  issue_names TEXT[] DEFAULT '{}',
  criteria_names TEXT[] DEFAULT '{}',
  indicator_names TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  FOREIGN KEY (organization_name) REFERENCES organizations(name) ON DELETE CASCADE,
  FOREIGN KEY (sector_name) REFERENCES sectors(name) ON DELETE SET NULL
);

-- =====================================================
-- ÉTAPE 4: TABLES D'ASSOCIATION SECTEUR-ÉNERGIE
-- =====================================================

-- Table des associations secteur-standards
CREATE TABLE IF NOT EXISTS sector_standards (
  sector_name TEXT NOT NULL,
  energy_type_name TEXT NOT NULL,
  standard_codes TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (sector_name, energy_type_name),
  FOREIGN KEY (sector_name) REFERENCES sectors(name) ON DELETE CASCADE
);

-- Table des associations secteur-standards-enjeux
CREATE TABLE IF NOT EXISTS sector_standards_issues (
  sector_name TEXT NOT NULL,
  energy_type_name TEXT NOT NULL,
  standard_name TEXT NOT NULL,
  issue_codes TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (sector_name, energy_type_name, standard_name),
  FOREIGN KEY (sector_name) REFERENCES sectors(name) ON DELETE CASCADE
);

-- Table des associations secteur-standards-enjeux-critères
CREATE TABLE IF NOT EXISTS sector_standards_issues_criteria (
  sector_name TEXT NOT NULL,
  energy_type_name TEXT NOT NULL,
  standard_name TEXT NOT NULL,
  issue_name TEXT NOT NULL,
  criteria_codes TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (sector_name, energy_type_name, standard_name, issue_name),
  FOREIGN KEY (sector_name) REFERENCES sectors(name) ON DELETE CASCADE
);

-- Table des associations secteur-standards-enjeux-critères-indicateurs
CREATE TABLE IF NOT EXISTS sector_standards_issues_criteria_indicators (
  sector_name TEXT NOT NULL,
  energy_type_name TEXT NOT NULL,
  standard_name TEXT NOT NULL,
  criteria_name TEXT NOT NULL,
  issue_name TEXT NOT NULL,
  indicator_codes TEXT[] DEFAULT '{}',
  unit TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (sector_name, energy_type_name, standard_name, criteria_name, issue_name),
  FOREIGN KEY (sector_name) REFERENCES sectors(name) ON DELETE CASCADE
);

-- =====================================================
-- ÉTAPE 5: MISE À JOUR DES TABLES EXISTANTES
-- =====================================================

-- Ajouter des colonnes manquantes aux indicateurs
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'indicators' AND column_name = 'processus_code') THEN
    ALTER TABLE indicators ADD COLUMN processus_code TEXT;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'indicators' AND column_name = 'enjeux') THEN
    ALTER TABLE indicators ADD COLUMN enjeux TEXT;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'indicators' AND column_name = 'normes') THEN
    ALTER TABLE indicators ADD COLUMN normes TEXT;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'indicators' AND column_name = 'critere') THEN
    ALTER TABLE indicators ADD COLUMN critere TEXT;
  END IF;
END $$;

-- Ajouter des colonnes manquantes aux sites
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sites' AND column_name = 'filiere_name') THEN
    ALTER TABLE sites ADD COLUMN filiere_name TEXT;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sites' AND column_name = 'filiale_name') THEN
    ALTER TABLE sites ADD COLUMN filiale_name TEXT;
  END IF;
END $$;

-- Ajouter des colonnes manquantes aux profils
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'filiere_name') THEN
    ALTER TABLE profiles ADD COLUMN filiere_name TEXT;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'filiale_name') THEN
    ALTER TABLE profiles ADD COLUMN filiale_name TEXT;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'original_role') THEN
    ALTER TABLE profiles ADD COLUMN original_role TEXT;
  END IF;
END $$;

-- Mettre à jour les contraintes de rôle
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.check_constraints WHERE constraint_name = 'profiles_role_check') THEN
    ALTER TABLE profiles DROP CONSTRAINT profiles_role_check;
  END IF;
  
  ALTER TABLE profiles ADD CONSTRAINT profiles_role_check 
    CHECK (role IN ('admin', 'guest', 'contributeur', 'validateur', 'admin_client', 'enterprise', 'contributor', 'validator'));
END $$;

-- =====================================================
-- ÉTAPE 6: INDEX DE PERFORMANCE
-- =====================================================

-- Index critiques pour le module pilotage
CREATE INDEX IF NOT EXISTS idx_indicator_values_period ON indicator_values(period_id);
CREATE INDEX IF NOT EXISTS idx_indicator_values_status ON indicator_values(status);
CREATE INDEX IF NOT EXISTS idx_indicator_values_org ON indicator_values(organization_name);
CREATE INDEX IF NOT EXISTS idx_indicator_values_site ON indicator_values(site_name);
CREATE INDEX IF NOT EXISTS idx_indicator_values_processus ON indicator_values(processus_code);
CREATE INDEX IF NOT EXISTS idx_indicator_values_indicator ON indicator_values(indicator_code);
CREATE INDEX IF NOT EXISTS idx_indicator_values_year_month ON indicator_values(year, month);

-- Index composites pour requêtes complexes
CREATE INDEX IF NOT EXISTS idx_indicator_values_site_period ON indicator_values(site_name, year, month);
CREATE INDEX IF NOT EXISTS idx_indicator_values_org_status ON indicator_values(organization_name, status);
CREATE INDEX IF NOT EXISTS idx_indicator_values_processus_status ON indicator_values(processus_code, status);

-- Index pour collection_periods
CREATE INDEX IF NOT EXISTS idx_collection_periods_org ON collection_periods(organization_name);
CREATE INDEX IF NOT EXISTS idx_collection_periods_status ON collection_periods(status);
CREATE INDEX IF NOT EXISTS idx_collection_periods_year ON collection_periods(year);

-- Index pour user_processus
CREATE INDEX IF NOT EXISTS idx_user_processus_email ON user_processus(email);
CREATE INDEX IF NOT EXISTS idx_user_processus_processus ON user_processus(processus_code);

-- Index pour processus
CREATE INDEX IF NOT EXISTS idx_processus_organization ON processus(organization_name);
CREATE INDEX IF NOT EXISTS idx_processus_indicateurs ON processus USING gin(indicateurs);

-- =====================================================
-- ÉTAPE 7: POLITIQUES RLS OPTIMISÉES
-- =====================================================

-- Activer RLS sur les tables sensibles
ALTER TABLE collection_periods ENABLE ROW LEVEL SECURITY;
ALTER TABLE indicator_values ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_processus ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_selections ENABLE ROW LEVEL SECURITY;
ALTER TABLE processus ENABLE ROW LEVEL SECURITY;
ALTER TABLE filieres ENABLE ROW LEVEL SECURITY;
ALTER TABLE filiales ENABLE ROW LEVEL SECURITY;

-- Politiques pour indicator_values (CRITIQUES POUR LE PILOTAGE)
CREATE POLICY "Enable read access for authenticated users" ON indicator_values
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Enable insert for contributors and validators" ON indicator_values
  FOR INSERT TO authenticated 
  WITH CHECK (
    auth.jwt() ->> 'email' IN (
      SELECT email FROM profiles 
      WHERE role IN ('contributeur', 'validateur', 'admin', 'admin_client', 'contributor', 'validator')
    )
  );

CREATE POLICY "Enable update for contributors and validators" ON indicator_values
  FOR UPDATE TO authenticated 
  USING (
    auth.jwt() ->> 'email' IN (
      SELECT email FROM profiles 
      WHERE role IN ('contributeur', 'validateur', 'admin', 'admin_client', 'contributor', 'validator')
    )
  );

CREATE POLICY "Enable delete for admins only" ON indicator_values
  FOR DELETE TO authenticated 
  USING (
    auth.jwt() ->> 'email' IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  );

-- Politiques pour collection_periods
CREATE POLICY "Enable read access for authenticated users" ON collection_periods
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Enable full access for admin users" ON collection_periods
  FOR ALL TO authenticated 
  USING (
    auth.jwt() ->> 'email' IN (
      SELECT email FROM profiles WHERE role IN ('admin', 'admin_client')
    )
  )
  WITH CHECK (
    auth.jwt() ->> 'email' IN (
      SELECT email FROM profiles WHERE role IN ('admin', 'admin_client')
    )
  );

-- Politiques pour user_processus
CREATE POLICY "Enable full access for admin users" ON user_processus
  FOR ALL TO authenticated 
  USING (
    auth.jwt() ->> 'email' IN (
      SELECT email FROM profiles WHERE role IN ('admin', 'admin_client')
    )
  )
  WITH CHECK (
    auth.jwt() ->> 'email' IN (
      SELECT email FROM profiles WHERE role IN ('admin', 'admin_client')
    )
  );

CREATE POLICY "Enable read access for authenticated users" ON user_processus
  FOR SELECT TO authenticated USING (true);

-- Politiques pour processus
CREATE POLICY "Enable read access for authenticated users" ON processus
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Enable full access for admin users" ON processus
  FOR ALL TO authenticated 
  USING (
    auth.jwt() ->> 'email' IN (
      SELECT email FROM profiles WHERE role IN ('admin', 'admin_client')
    )
  )
  WITH CHECK (
    auth.jwt() ->> 'email' IN (
      SELECT email FROM profiles WHERE role IN ('admin', 'admin_client')
    )
  );

-- Politiques pour organization_selections
CREATE POLICY "Enable read access for authenticated users" ON organization_selections
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Enable full access for admin users" ON organization_selections
  FOR ALL TO authenticated 
  USING (
    auth.jwt() ->> 'email' IN (
      SELECT email FROM profiles WHERE role IN ('admin', 'admin_client')
    )
  )
  WITH CHECK (
    auth.jwt() ->> 'email' IN (
      SELECT email FROM profiles WHERE role IN ('admin', 'admin_client')
    )
  );

-- =====================================================
-- ÉTAPE 8: FONCTIONS ET TRIGGERS ESSENTIELS
-- =====================================================

-- Fonction pour mettre à jour updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers pour updated_at
CREATE TRIGGER IF NOT EXISTS update_indicator_values_updated_at
  BEFORE UPDATE ON indicator_values
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER IF NOT EXISTS update_collection_periods_updated_at
  BEFORE UPDATE ON collection_periods
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER IF NOT EXISTS update_processus_updated_at
  BEFORE UPDATE ON processus
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- =====================================================
-- ÉTAPE 9: DONNÉES DE TEST MINIMALES
-- =====================================================

-- Insérer des types d'énergie
INSERT INTO energy_types (name, sector_name) VALUES 
  ('Électricité', 'Industrie'),
  ('Gaz Naturel', 'Industrie'),
  ('Énergies Renouvelables', 'Industrie'),
  ('Carburants', 'Transport'),
  ('Électricité', 'Transport')
ON CONFLICT (name, sector_name) DO NOTHING;

-- Insérer des processus de test
INSERT INTO processus (code, name, description, indicateurs, organization_name) VALUES 
  ('PROC001', 'Processus Énergétique Principal', 'Gestion de l''énergie principale', ARRAY['IND001', 'IND002'], 'TestFiliere'),
  ('PROC002', 'Processus Environnemental', 'Gestion des impacts environnementaux', ARRAY['IND003'], 'TestFiliere'),
  ('PROC003', 'Processus de Maintenance', 'Maintenance des équipements énergétiques', ARRAY['IND004'], 'TestFiliere')
ON CONFLICT (code) DO NOTHING;

-- Mettre à jour les indicateurs avec les codes de processus
UPDATE indicators 
SET processus_code = 'PROC001',
    enjeux = 'Efficacité énergétique',
    normes = 'ISO 50001',
    critere = 'Consommation'
WHERE code IN ('IND001', 'IND002');

UPDATE indicators 
SET processus_code = 'PROC002',
    enjeux = 'Impact environnemental',
    normes = 'ISO 14001',
    critere = 'Émissions'
WHERE code = 'IND003';

-- Insérer des indicateurs de test si ils n'existent pas
INSERT INTO indicators (code, name, description, unit, frequence, processus_code, enjeux, normes, critere) VALUES 
  ('IND001', 'Consommation électrique totale', 'Consommation totale d''électricité', 'kWh', 'mensuelle', 'PROC001', 'Efficacité énergétique', 'ISO 50001', 'Consommation'),
  ('IND002', 'Efficacité énergétique', 'Ratio de performance énergétique', '%', 'mensuelle', 'PROC001', 'Efficacité énergétique', 'ISO 50001', 'Performance'),
  ('IND003', 'Émissions CO2', 'Émissions de dioxyde de carbone', 'tCO2', 'mensuelle', 'PROC002', 'Impact environnemental', 'ISO 14001', 'Émissions'),
  ('IND004', 'Taux de disponibilité', 'Disponibilité des équipements', '%', 'mensuelle', 'PROC003', 'Maintenance', 'ISO 55000', 'Disponibilité')
ON CONFLICT (code) DO NOTHING;

-- Créer des filières de test
INSERT INTO filieres (name, organization_name, location, manager) VALUES 
  ('Filière Production', 'TestFiliere', 'Site Principal', 'Manager Production'),
  ('Filière Maintenance', 'TestFiliere', 'Site Technique', 'Manager Maintenance')
ON CONFLICT (name) DO NOTHING;

-- Créer des filiales de test
INSERT INTO filiales (name, organization_name, filiere_name, description, address, city, country, phone, email) VALUES 
  ('Filiale Nord', 'TestFiliere', 'Filière Production', 'Filiale région Nord', '123 Rue Nord', 'Lille', 'France', '+33123456789', 'nord@testfiliere.com'),
  ('Filiale Sud', 'TestFiliere', 'Filière Production', 'Filiale région Sud', '456 Rue Sud', 'Marseille', 'France', '+33987654321', 'sud@testfiliere.com')
ON CONFLICT (name) DO NOTHING;

-- Mettre à jour les sites existants avec la hiérarchie
UPDATE sites 
SET filiere_name = 'Filière Production',
    filiale_name = 'Filiale Nord'
WHERE name = 'Test F2' AND organization_name = 'TestFiliere';

-- Créer des périodes de collecte de test
INSERT INTO collection_periods (organization_name, year, period_type, period_number, start_date, end_date, status) VALUES 
  ('TestFiliere', 2024, 'month', 1, '2024-01-01', '2024-01-31', 'open'),
  ('TestFiliere', 2024, 'month', 2, '2024-02-01', '2024-02-29', 'open'),
  ('TestFiliere', 2024, 'month', 3, '2024-03-01', '2024-03-31', 'open'),
  ('TestFiliere', 2024, 'month', 12, '2024-12-01', '2024-12-31', 'open')
ON CONFLICT (organization_name, year, period_type, period_number) DO NOTHING;

-- Créer des sélections d'organisation de test
INSERT INTO organization_selections (organization_name, sector_name, energy_type_name, indicator_names) VALUES 
  ('TestFiliere', 'Industrie', 'Électricité', ARRAY['Consommation électrique totale', 'Efficacité énergétique', 'Émissions CO2', 'Taux de disponibilité'])
ON CONFLICT DO NOTHING;

-- =====================================================
-- ÉTAPE 10: VUES POUR LE PILOTAGE
-- =====================================================

-- Vue pour les indicateurs avec métadonnées complètes
CREATE OR REPLACE VIEW pilotage_indicators_view AS
SELECT 
  iv.id,
  iv.organization_name,
  iv.filiere_name,
  iv.filiale_name,
  iv.site_name,
  iv.processus_code,
  iv.indicator_code,
  iv.year,
  iv.month,
  iv.value,
  iv.unit,
  iv.status,
  iv.comment,
  iv.submitted_by,
  iv.submitted_at,
  iv.validated_by,
  iv.validated_at,
  iv.created_at,
  iv.updated_at,
  
  -- Métadonnées des indicateurs
  i.name as indicator_name,
  i.description as indicator_description,
  i.enjeux,
  i.normes,
  i.critere,
  i.frequence,
  
  -- Métadonnées des processus
  p.name as processus_name,
  p.description as processus_description,
  
  -- Calcul de la période
  CASE 
    WHEN iv.month BETWEEN 1 AND 3 THEN 'T1'
    WHEN iv.month BETWEEN 4 AND 6 THEN 'T2'
    WHEN iv.month BETWEEN 7 AND 9 THEN 'T3'
    ELSE 'T4'
  END as trimestre,
  
  -- Statut de la période
  CASE 
    WHEN iv.month = EXTRACT(MONTH FROM CURRENT_DATE) AND iv.year = EXTRACT(YEAR FROM CURRENT_DATE) THEN 'current'
    WHEN iv.year = EXTRACT(YEAR FROM CURRENT_DATE) AND iv.month < EXTRACT(MONTH FROM CURRENT_DATE) THEN 'past'
    ELSE 'future'
  END as period_status

FROM indicator_values iv
LEFT JOIN indicators i ON i.code = iv.indicator_code
LEFT JOIN processus p ON p.code = iv.processus_code;

-- =====================================================
-- ÉTAPE 11: FONCTIONS UTILITAIRES
-- =====================================================

-- Fonction pour créer une période de collecte automatiquement
CREATE OR REPLACE FUNCTION create_collection_period(
  org_name TEXT,
  target_year INTEGER,
  target_month INTEGER
) RETURNS UUID AS $$
DECLARE
  period_id UUID;
  start_date DATE;
  end_date DATE;
BEGIN
  -- Calculer les dates de début et fin
  start_date := DATE(target_year || '-' || LPAD(target_month::TEXT, 2, '0') || '-01');
  end_date := (start_date + INTERVAL '1 month' - INTERVAL '1 day')::DATE;
  
  -- Insérer la période
  INSERT INTO collection_periods (
    organization_name, 
    year, 
    period_type, 
    period_number, 
    start_date, 
    end_date, 
    status
  ) VALUES (
    org_name,
    target_year,
    'month',
    target_month,
    start_date,
    end_date,
    'open'
  )
  ON CONFLICT (organization_name, year, period_type, period_number) 
  DO UPDATE SET 
    start_date = EXCLUDED.start_date,
    end_date = EXCLUDED.end_date,
    status = EXCLUDED.status
  RETURNING id INTO period_id;
  
  RETURN period_id;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour obtenir les processus d'un utilisateur
CREATE OR REPLACE FUNCTION get_user_processus(user_email TEXT)
RETURNS TABLE (
  processus_code TEXT,
  processus_name TEXT,
  processus_description TEXT,
  indicateurs TEXT[]
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.code,
    p.name,
    p.description,
    p.indicateurs
  FROM processus p
  JOIN user_processus up ON up.processus_code = p.code
  WHERE up.email = user_email;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour obtenir les indicateurs d'une organisation
CREATE OR REPLACE FUNCTION get_organization_indicators(org_name TEXT)
RETURNS TABLE (
  indicator_code TEXT,
  indicator_name TEXT,
  unit TEXT,
  processus_code TEXT,
  processus_name TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    i.code,
    i.name,
    i.unit,
    i.processus_code,
    p.name
  FROM indicators i
  LEFT JOIN processus p ON p.code = i.processus_code
  WHERE i.name = ANY(
    SELECT UNNEST(os.indicator_names)
    FROM organization_selections os
    WHERE os.organization_name = org_name
  );
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- ÉTAPE 12: DONNÉES DE TEST POUR VALIDATION
-- =====================================================

-- Créer un utilisateur contributeur de test
INSERT INTO users (email, nom, prenom, fonction, entreprise) VALUES 
  ('contributeur@test.com', 'Test', 'Contributeur', 'Responsable Énergie', 'TestFiliere')
ON CONFLICT (email) DO NOTHING;

INSERT INTO profiles (email, role, organization_name, site_name, filiere_name, filiale_name) VALUES 
  ('contributeur@test.com', 'contributeur', 'TestFiliere', 'Test F2', 'Filière Production', 'Filiale Nord')
ON CONFLICT (email) DO UPDATE SET 
  role = EXCLUDED.role,
  organization_name = EXCLUDED.organization_name,
  site_name = EXCLUDED.site_name,
  filiere_name = EXCLUDED.filiere_name,
  filiale_name = EXCLUDED.filiale_name;

-- Créer un utilisateur validateur de test
INSERT INTO users (email, nom, prenom, fonction, entreprise) VALUES 
  ('validateur@test.com', 'Test', 'Validateur', 'Manager Qualité', 'TestFiliere')
ON CONFLICT (email) DO NOTHING;

INSERT INTO profiles (email, role, organization_name, organization_level, filiere_name) VALUES 
  ('validateur@test.com', 'validateur', 'TestFiliere', 'organization', 'Filière Production')
ON CONFLICT (email) DO UPDATE SET 
  role = EXCLUDED.role,
  organization_name = EXCLUDED.organization_name,
  organization_level = EXCLUDED.organization_level,
  filiere_name = EXCLUDED.filiere_name;

-- Assigner des processus aux utilisateurs
INSERT INTO user_processus (email, processus_code) VALUES 
  ('contributeur@test.com', 'PROC001'),
  ('contributeur@test.com', 'PROC002'),
  ('validateur@test.com', 'PROC001'),
  ('validateur@test.com', 'PROC002'),
  ('validateur@test.com', 'PROC003')
ON CONFLICT (email, processus_code) DO NOTHING;

-- Créer quelques valeurs d'indicateurs de test
DO $$
DECLARE
  period_id UUID;
BEGIN
  -- Obtenir l'ID de la période courante
  SELECT id INTO period_id 
  FROM collection_periods 
  WHERE organization_name = 'TestFiliere' 
    AND year = 2024 
    AND period_number = 12 
  LIMIT 1;
  
  IF period_id IS NOT NULL THEN
    INSERT INTO indicator_values (
      period_id, 
      organization_name, 
      filiere_name, 
      filiale_name, 
      site_name, 
      processus_code, 
      indicator_code, 
      year, 
      month, 
      value, 
      unit, 
      status
    ) VALUES 
      (period_id, 'TestFiliere', 'Filière Production', 'Filiale Nord', 'Test F2', 'PROC001', 'IND001', 2024, 12, 1500.50, 'kWh', 'draft'),
      (period_id, 'TestFiliere', 'Filière Production', 'Filiale Nord', 'Test F2', 'PROC001', 'IND002', 2024, 12, 85.2, '%', 'draft'),
      (period_id, 'TestFiliere', 'Filière Production', 'Filiale Nord', 'Test F2', 'PROC002', 'IND003', 2024, 12, 12.8, 'tCO2', 'submitted')
    ON CONFLICT DO NOTHING;
  END IF;
END $$;

-- =====================================================
-- ÉTAPE 13: VALIDATION FINALE
-- =====================================================

-- Vérifier que toutes les tables sont créées
DO $$
DECLARE
  missing_tables TEXT[] := ARRAY[]::TEXT[];
  table_name TEXT;
BEGIN
  -- Liste des tables requises
  FOR table_name IN 
    SELECT unnest(ARRAY[
      'collection_periods',
      'indicator_values', 
      'user_processus',
      'processus',
      'organization_selections',
      'filieres',
      'filiales',
      'energy_types'
    ])
  LOOP
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.tables 
      WHERE table_schema = 'public' AND table_name = table_name
    ) THEN
      missing_tables := array_append(missing_tables, table_name);
    END IF;
  END LOOP;
  
  IF array_length(missing_tables, 1) > 0 THEN
    RAISE EXCEPTION 'Tables manquantes: %', array_to_string(missing_tables, ', ');
  ELSE
    RAISE NOTICE 'Toutes les tables requises sont créées avec succès';
  END IF;
END $$;

-- Vérifier les données de test
DO $$
DECLARE
  processus_count INTEGER;
  indicators_count INTEGER;
  users_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO processus_count FROM processus;
  SELECT COUNT(*) INTO indicators_count FROM indicators WHERE processus_code IS NOT NULL;
  SELECT COUNT(*) INTO users_count FROM profiles WHERE role IN ('contributeur', 'validateur');
  
  RAISE NOTICE 'Données de test créées: % processus, % indicateurs, % utilisateurs', 
    processus_count, indicators_count, users_count;
    
  IF processus_count = 0 OR indicators_count = 0 OR users_count = 0 THEN
    RAISE WARNING 'Certaines données de test sont manquantes';
  END IF;
END $$;