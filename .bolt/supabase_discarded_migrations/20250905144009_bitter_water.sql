/*
  # Create site consolidation tables

  1. New Tables
    - `site_indicator_values_consolidated` - Table consolidée des valeurs d'indicateurs par site
    - `site_performance_summary` - Résumé de performance par site
    - `consolidated_indicator_metadata` - Métadonnées des indicateurs consolidés

  2. Functions
    - `consolidate_site_indicators()` - Fonction pour consolider les données des sites
    - `update_site_performance_summary()` - Fonction pour mettre à jour le résumé de performance
    - `refresh_consolidation_data()` - Fonction pour actualiser toutes les données consolidées

  3. Triggers
    - Triggers automatiques pour maintenir les données à jour

  4. Security
    - Enable RLS on all new tables
    - Add appropriate policies for data access
*/

-- Table pour les valeurs d'indicateurs consolidées par site
CREATE TABLE IF NOT EXISTS site_indicator_values_consolidated (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_name text NOT NULL,
  business_line_name text,
  subsidiary_name text,
  site_name text,
  process_code text NOT NULL,
  indicator_code text NOT NULL,
  year integer NOT NULL,
  month integer NOT NULL,
  
  -- Métadonnées de l'indicateur
  indicator_name text,
  unit text,
  axe text,
  type text,
  formule text DEFAULT 'somme',
  frequence text,
  
  -- Métadonnées du processus
  process_name text,
  process_description text,
  
  -- Métadonnées ESG
  enjeux text,
  normes text,
  criteres text,
  
  -- Valeurs mensuelles individuelles du site
  value_raw numeric DEFAULT 0,
  
  -- Valeurs consolidées (calculées selon la formule)
  value_consolidated numeric DEFAULT 0,
  
  -- Informations de consolidation
  sites_count integer DEFAULT 1,
  sites_list text[],
  
  -- Valeurs de référence
  target_value numeric DEFAULT 0,
  previous_year_value numeric DEFAULT 0,
  
  -- Calculs de performance
  variation numeric DEFAULT 0,
  performance numeric DEFAULT 0,
  
  -- Métadonnées
  last_updated timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  
  -- Contraintes
  CONSTRAINT site_indicator_values_consolidated_month_check CHECK (month >= 1 AND month <= 12),
  CONSTRAINT site_indicator_values_consolidated_year_check CHECK (year >= 2020 AND year <= 2050),
  CONSTRAINT site_indicator_values_consolidated_unique 
    UNIQUE (organization_name, site_name, process_code, indicator_code, year, month)
);

-- Table pour le résumé de performance par site
CREATE TABLE IF NOT EXISTS site_performance_summary (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  site_name text NOT NULL,
  organization_name text NOT NULL,
  business_line_name text,
  subsidiary_name text,
  
  -- Informations du site
  address text,
  city text,
  country text,
  
  -- Métriques de performance
  total_indicators integer DEFAULT 0,
  filled_indicators integer DEFAULT 0,
  completion_rate numeric DEFAULT 0,
  avg_performance numeric DEFAULT 0,
  
  -- Processus actifs
  active_processes integer DEFAULT 0,
  
  -- Métadonnées
  last_updated timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  
  -- Contraintes
  CONSTRAINT site_performance_summary_unique UNIQUE (site_name, organization_name),
  CONSTRAINT site_performance_summary_completion_rate_check CHECK (completion_rate >= 0 AND completion_rate <= 100),
  CONSTRAINT site_performance_summary_avg_performance_check CHECK (avg_performance >= 0)
);

-- Table pour les métadonnées des indicateurs consolidés
CREATE TABLE IF NOT EXISTS consolidated_indicator_metadata (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_name text NOT NULL,
  indicator_code text NOT NULL,
  process_code text NOT NULL,
  
  -- Métadonnées de l'indicateur
  indicator_name text,
  unit text,
  axe text,
  type text,
  formule text DEFAULT 'somme',
  frequence text,
  
  -- Métadonnées du processus
  process_name text,
  process_description text,
  
  -- Métadonnées ESG (agrégées)
  enjeux text,
  normes text,
  criteres text,
  
  -- Sites concernés
  applicable_sites text[],
  sites_count integer DEFAULT 0,
  
  -- Métadonnées
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  
  -- Contraintes
  CONSTRAINT consolidated_indicator_metadata_unique 
    UNIQUE (organization_name, indicator_code, process_code)
);

-- Indexes pour optimiser les performances
CREATE INDEX IF NOT EXISTS idx_site_indicator_values_consolidated_org_year_month 
  ON site_indicator_values_consolidated (organization_name, year, month);

CREATE INDEX IF NOT EXISTS idx_site_indicator_values_consolidated_site_indicator 
  ON site_indicator_values_consolidated (site_name, indicator_code);

CREATE INDEX IF NOT EXISTS idx_site_indicator_values_consolidated_process 
  ON site_indicator_values_consolidated (process_code);

CREATE INDEX IF NOT EXISTS idx_site_indicator_values_consolidated_axe 
  ON site_indicator_values_consolidated (axe);

CREATE INDEX IF NOT EXISTS idx_site_performance_summary_org 
  ON site_performance_summary (organization_name);

CREATE INDEX IF NOT EXISTS idx_consolidated_indicator_metadata_org 
  ON consolidated_indicator_metadata (organization_name);

-- Enable RLS
ALTER TABLE site_indicator_values_consolidated ENABLE ROW LEVEL SECURITY;
ALTER TABLE site_performance_summary ENABLE ROW LEVEL SECURITY;
ALTER TABLE consolidated_indicator_metadata ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can access their organization consolidated data"
  ON site_indicator_values_consolidated
  FOR ALL
  TO authenticated
  USING (
    organization_name IN (
      SELECT organization_name 
      FROM profiles 
      WHERE email = auth.jwt() ->> 'email'
    )
  );

CREATE POLICY "Users can access their organization site performance"
  ON site_performance_summary
  FOR ALL
  TO authenticated
  USING (
    organization_name IN (
      SELECT organization_name 
      FROM profiles 
      WHERE email = auth.jwt() ->> 'email'
    )
  );

CREATE POLICY "Users can access their organization indicator metadata"
  ON consolidated_indicator_metadata
  FOR ALL
  TO authenticated
  USING (
    organization_name IN (
      SELECT organization_name 
      FROM profiles 
      WHERE email = auth.jwt() ->> 'email'
    )
  );

-- Fonction pour consolider les indicateurs par site
CREATE OR REPLACE FUNCTION consolidate_site_indicators(
  org_name text,
  target_year integer,
  target_month integer
) RETURNS void AS $$
DECLARE
  site_record RECORD;
  indicator_record RECORD;
  consolidated_value numeric;
  sites_involved text[];
  sites_count_val integer;
BEGIN
  -- Vider les données existantes pour cette période
  DELETE FROM site_indicator_values_consolidated 
  WHERE organization_name = org_name 
    AND year = target_year 
    AND month = target_month;

  -- Pour chaque combinaison indicateur/processus de l'organisation
  FOR indicator_record IN
    SELECT DISTINCT 
      iv.process_code,
      iv.indicator_code,
      i.name as indicator_name,
      i.unit,
      i.axe,
      i.type,
      i.formule,
      i.frequence,
      p.name as process_name,
      p.description as process_description
    FROM indicator_values iv
    JOIN indicators i ON iv.indicator_code = i.code
    JOIN processes p ON iv.process_code = p.code
    WHERE iv.organization_name = org_name
      AND iv.year = target_year
      AND iv.month = target_month
      AND iv.value IS NOT NULL
  LOOP
    -- Récupérer toutes les valeurs des sites pour cet indicateur
    SELECT 
      CASE 
        WHEN indicator_record.formule = 'somme' THEN COALESCE(SUM(iv.value), 0)
        WHEN indicator_record.formule = 'moyenne' THEN COALESCE(AVG(iv.value), 0)
        WHEN indicator_record.formule = 'max' THEN COALESCE(MAX(iv.value), 0)
        WHEN indicator_record.formule = 'min' THEN COALESCE(MIN(iv.value), 0)
        WHEN indicator_record.formule = 'dernier_mois' THEN COALESCE(
          (SELECT iv2.value FROM indicator_values iv2 
           WHERE iv2.organization_name = org_name
             AND iv2.indicator_code = indicator_record.indicator_code
             AND iv2.process_code = indicator_record.process_code
             AND iv2.year = target_year
             AND iv2.month = target_month
             AND iv2.value IS NOT NULL
           ORDER BY iv2.updated_at DESC
           LIMIT 1), 0)
        ELSE COALESCE(SUM(iv.value), 0)
      END,
      array_agg(DISTINCT iv.site_name) FILTER (WHERE iv.site_name IS NOT NULL),
      COUNT(DISTINCT iv.site_name) FILTER (WHERE iv.site_name IS NOT NULL)
    INTO consolidated_value, sites_involved, sites_count_val
    FROM indicator_values iv
    WHERE iv.organization_name = org_name
      AND iv.indicator_code = indicator_record.indicator_code
      AND iv.process_code = indicator_record.process_code
      AND iv.year = target_year
      AND iv.month = target_month
      AND iv.value IS NOT NULL;

    -- Insérer les données consolidées pour chaque site impliqué
    FOR site_record IN
      SELECT DISTINCT 
        iv.site_name,
        iv.business_line_name,
        iv.subsidiary_name,
        iv.value as site_value
      FROM indicator_values iv
      WHERE iv.organization_name = org_name
        AND iv.indicator_code = indicator_record.indicator_code
        AND iv.process_code = indicator_record.process_code
        AND iv.year = target_year
        AND iv.month = target_month
        AND iv.value IS NOT NULL
    LOOP
      INSERT INTO site_indicator_values_consolidated (
        organization_name,
        business_line_name,
        subsidiary_name,
        site_name,
        process_code,
        indicator_code,
        year,
        month,
        indicator_name,
        unit,
        axe,
        type,
        formule,
        frequence,
        process_name,
        process_description,
        value_raw,
        value_consolidated,
        sites_count,
        sites_list
      ) VALUES (
        org_name,
        site_record.business_line_name,
        site_record.subsidiary_name,
        site_record.site_name,
        indicator_record.process_code,
        indicator_record.indicator_code,
        target_year,
        target_month,
        indicator_record.indicator_name,
        indicator_record.unit,
        indicator_record.axe,
        indicator_record.type,
        indicator_record.formule,
        indicator_record.frequence,
        indicator_record.process_name,
        indicator_record.process_description,
        site_record.site_value,
        consolidated_value,
        sites_count_val,
        sites_involved
      );
    END LOOP;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour mettre à jour le résumé de performance des sites
CREATE OR REPLACE FUNCTION update_site_performance_summary(org_name text) RETURNS void AS $$
BEGIN
  -- Vider les données existantes
  DELETE FROM site_performance_summary WHERE organization_name = org_name;
  
  -- Insérer les nouvelles données
  INSERT INTO site_performance_summary (
    site_name,
    organization_name,
    business_line_name,
    subsidiary_name,
    address,
    city,
    country,
    total_indicators,
    filled_indicators,
    completion_rate,
    avg_performance,
    active_processes
  )
  SELECT 
    s.name as site_name,
    s.organization_name,
    s.business_line_name,
    s.subsidiary_name,
    s.address,
    s.city,
    s.country,
    COALESCE(site_stats.total_indicators, 0) as total_indicators,
    COALESCE(site_stats.filled_indicators, 0) as filled_indicators,
    CASE 
      WHEN COALESCE(site_stats.total_indicators, 0) > 0 
      THEN (COALESCE(site_stats.filled_indicators, 0)::numeric / site_stats.total_indicators) * 100
      ELSE 0
    END as completion_rate,
    COALESCE(site_stats.avg_performance, 0) as avg_performance,
    COALESCE(site_stats.active_processes, 0) as active_processes
  FROM sites s
  LEFT JOIN (
    SELECT 
      iv.site_name,
      COUNT(DISTINCT iv.indicator_code) as total_indicators,
      COUNT(DISTINCT CASE WHEN iv.value IS NOT NULL THEN iv.indicator_code END) as filled_indicators,
      AVG(CASE 
        WHEN iv.value IS NOT NULL AND iv.value > 0 
        THEN LEAST(100, (iv.value / NULLIF(target_values.target_value, 0)) * 100)
        ELSE 0 
      END) as avg_performance,
      COUNT(DISTINCT iv.process_code) as active_processes
    FROM indicator_values iv
    LEFT JOIN (
      SELECT 
        indicator_code,
        AVG(CASE WHEN value > 0 THEN value * 1.1 ELSE 100 END) as target_value
      FROM indicator_values 
      WHERE year = EXTRACT(YEAR FROM CURRENT_DATE) - 1
      GROUP BY indicator_code
    ) target_values ON iv.indicator_code = target_values.indicator_code
    WHERE iv.year = EXTRACT(YEAR FROM CURRENT_DATE)
      AND iv.organization_name = org_name
    GROUP BY iv.site_name
  ) site_stats ON s.name = site_stats.site_name
  WHERE s.organization_name = org_name;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour actualiser toutes les données de consolidation
CREATE OR REPLACE FUNCTION refresh_consolidation_data(
  org_name text,
  target_year integer DEFAULT NULL,
  target_month integer DEFAULT NULL
) RETURNS void AS $$
DECLARE
  year_to_process integer;
  month_to_process integer;
BEGIN
  -- Utiliser l'année et le mois actuels par défaut
  year_to_process := COALESCE(target_year, EXTRACT(YEAR FROM CURRENT_DATE)::integer);
  month_to_process := COALESCE(target_month, EXTRACT(MONTH FROM CURRENT_DATE)::integer);
  
  -- Consolider les indicateurs
  PERFORM consolidate_site_indicators(org_name, year_to_process, month_to_process);
  
  -- Mettre à jour le résumé de performance
  PERFORM update_site_performance_summary(org_name);
  
  -- Mettre à jour les métadonnées des indicateurs consolidés
  DELETE FROM consolidated_indicator_metadata WHERE organization_name = org_name;
  
  INSERT INTO consolidated_indicator_metadata (
    organization_name,
    indicator_code,
    process_code,
    indicator_name,
    unit,
    axe,
    type,
    formule,
    frequence,
    process_name,
    process_description,
    enjeux,
    normes,
    criteres,
    applicable_sites,
    sites_count
  )
  SELECT DISTINCT
    org_name,
    sic.indicator_code,
    sic.process_code,
    sic.indicator_name,
    sic.unit,
    sic.axe,
    sic.type,
    sic.formule,
    sic.frequence,
    sic.process_name,
    sic.process_description,
    sic.enjeux,
    sic.normes,
    sic.criteres,
    array_agg(DISTINCT sic.site_name) as applicable_sites,
    COUNT(DISTINCT sic.site_name) as sites_count
  FROM site_indicator_values_consolidated sic
  WHERE sic.organization_name = org_name
    AND sic.year = year_to_process
    AND sic.month = month_to_process
  GROUP BY 
    sic.indicator_code,
    sic.process_code,
    sic.indicator_name,
    sic.unit,
    sic.axe,
    sic.type,
    sic.formule,
    sic.frequence,
    sic.process_name,
    sic.process_description,
    sic.enjeux,
    sic.normes,
    sic.criteres;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour obtenir les données consolidées avec métadonnées complètes
CREATE OR REPLACE FUNCTION get_consolidated_dashboard_data(
  org_name text,
  target_year integer,
  target_month integer DEFAULT NULL
) RETURNS TABLE (
  organization_name text,
  process_code text,
  indicator_code text,
  year integer,
  month integer,
  axe text,
  enjeux text,
  normes text,
  criteres text,
  processus text,
  indicateur text,
  unite text,
  frequence text,
  type text,
  formule text,
  value_consolidated numeric,
  sites_count integer,
  sites_list text[],
  target_value numeric,
  variation numeric,
  performance numeric,
  last_updated timestamptz
) AS $$
BEGIN
  -- Actualiser les données avant de les retourner
  PERFORM refresh_consolidation_data(org_name, target_year, target_month);
  
  RETURN QUERY
  SELECT 
    sic.organization_name,
    sic.process_code,
    sic.indicator_code,
    sic.year,
    sic.month,
    sic.axe,
    sic.enjeux,
    sic.normes,
    sic.criteres,
    sic.process_name as processus,
    sic.indicator_name as indicateur,
    sic.unit as unite,
    sic.frequence,
    sic.type,
    sic.formule,
    sic.value_consolidated,
    sic.sites_count,
    sic.sites_list,
    sic.target_value,
    sic.variation,
    sic.performance,
    sic.last_updated
  FROM site_indicator_values_consolidated sic
  WHERE sic.organization_name = org_name
    AND sic.year = target_year
    AND (target_month IS NULL OR sic.month = target_month)
  ORDER BY sic.process_code, sic.indicator_code, sic.month;
END;
$$ LANGUAGE plpgsql;

-- Triggers pour maintenir les données à jour
CREATE OR REPLACE FUNCTION trigger_consolidation_update() RETURNS trigger AS $$
BEGIN
  -- Actualiser les données de consolidation quand les valeurs d'indicateurs changent
  PERFORM refresh_consolidation_data(
    COALESCE(NEW.organization_name, OLD.organization_name),
    COALESCE(NEW.year, OLD.year),
    COALESCE(NEW.month, OLD.month)
  );
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Trigger sur indicator_values pour maintenir la consolidation à jour
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger 
    WHERE tgname = 'trigger_update_consolidation_on_indicator_change'
  ) THEN
    CREATE TRIGGER trigger_update_consolidation_on_indicator_change
      AFTER INSERT OR UPDATE OR DELETE ON indicator_values
      FOR EACH ROW
      EXECUTE FUNCTION trigger_consolidation_update();
  END IF;
END $$;

-- Trigger pour mettre à jour les timestamps
CREATE OR REPLACE FUNCTION update_consolidation_updated_at() RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger 
    WHERE tgname = 'site_indicator_values_consolidated_updated_at'
  ) THEN
    CREATE TRIGGER site_indicator_values_consolidated_updated_at
      BEFORE UPDATE ON site_indicator_values_consolidated
      FOR EACH ROW
      EXECUTE FUNCTION update_consolidation_updated_at();
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger 
    WHERE tgname = 'site_performance_summary_updated_at'
  ) THEN
    CREATE TRIGGER site_performance_summary_updated_at
      BEFORE UPDATE ON site_performance_summary
      FOR EACH ROW
      EXECUTE FUNCTION update_consolidation_updated_at();
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger 
    WHERE tgname = 'consolidated_indicator_metadata_updated_at'
  ) THEN
    CREATE TRIGGER consolidated_indicator_metadata_updated_at
      BEFORE UPDATE ON consolidated_indicator_metadata
      FOR EACH ROW
      EXECUTE FUNCTION update_consolidation_updated_at();
  END IF;
END $$;