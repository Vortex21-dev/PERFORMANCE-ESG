/*
  # Création d'un groupe complet avec structure organisationnelle et utilisateurs

  1. Organisation
    - Nom: "GROUPE VISION DURABLE"
    - Type: group (avec filières et filiales)
    - Secteur: Services financiers et conseil

  2. Structure organisationnelle
    - 2 filières: "Conseil ESG" et "Audit & Certification"
    - 4 filiales: 2 par filière
    - 6 sites: répartis dans les filiales

  3. Utilisateurs
    - 1 administrateur client (enterprise)
    - 4 contributeurs (1 par filiale)
    - 2 validateurs (1 par filière)

  4. Processus et indicateurs
    - Attribution des processus aux utilisateurs
    - Configuration ESG complète
*/

-- ============================================================================
-- 1. CRÉATION DE L'ORGANISATION PRINCIPALE
-- ============================================================================

INSERT INTO organizations (
  name,
  organization_type,
  description,
  address,
  city,
  country,
  phone,
  email,
  website
) VALUES (
  'GROUPE VISION DURABLE',
  'group',
  'Groupe spécialisé dans le conseil en développement durable, l''audit ESG et la certification environnementale',
  '123 Boulevard de la Durabilité',
  'Abidjan',
  'Côte d''Ivoire',
  '+225 27 20 30 40 50',
  'contact@groupevisiondurable.ci',
  'https://www.groupevisiondurable.ci'
);

-- ============================================================================
-- 2. CRÉATION DES FILIÈRES (BUSINESS LINES)
-- ============================================================================

INSERT INTO business_lines (name, organization_name, description) VALUES
('Conseil ESG', 'GROUPE VISION DURABLE', 'Filière spécialisée dans le conseil en stratégie ESG et développement durable'),
('Audit & Certification', 'GROUPE VISION DURABLE', 'Filière dédiée à l''audit environnemental et à la certification ESG');

-- ============================================================================
-- 3. CRÉATION DES FILIALES
-- ============================================================================

INSERT INTO subsidiaries (
  name,
  organization_name,
  business_line_name,
  description,
  address,
  city,
  country,
  phone,
  email,
  website
) VALUES
-- Filiales de la filière Conseil ESG
(
  'VISION CONSEIL SARL',
  'GROUPE VISION DURABLE',
  'Conseil ESG',
  'Société de conseil en stratégie ESG et transformation durable',
  '45 Rue des Conseillers',
  'Abidjan',
  'Côte d''Ivoire',
  '+225 27 20 30 41 00',
  'conseil@visionconseil.ci',
  'https://conseil.groupevisiondurable.ci'
),
(
  'STRATÉGIE DURABLE SA',
  'GROUPE VISION DURABLE',
  'Conseil ESG',
  'Cabinet spécialisé en stratégie de développement durable',
  '78 Avenue de la Stratégie',
  'Yamoussoukro',
  'Côte d''Ivoire',
  '+225 30 64 20 30 00',
  'strategie@strategiedurable.ci',
  'https://strategie.groupevisiondurable.ci'
),
-- Filiales de la filière Audit & Certification
(
  'AUDIT VERT SARL',
  'GROUPE VISION DURABLE',
  'Audit & Certification',
  'Société d''audit environnemental et social',
  '12 Place de l''Audit',
  'Abidjan',
  'Côte d''Ivoire',
  '+225 27 20 30 42 00',
  'audit@auditvert.ci',
  'https://audit.groupevisiondurable.ci'
),
(
  'CERTIF ESG SA',
  'GROUPE VISION DURABLE',
  'Audit & Certification',
  'Organisme de certification ESG et développement durable',
  '56 Boulevard de la Certification',
  'San-Pédro',
  'Côte d''Ivoire',
  '+225 34 71 20 30 00',
  'certif@certifESG.ci',
  'https://certification.groupevisiondurable.ci'
);

-- ============================================================================
-- 4. CRÉATION DES SITES
-- ============================================================================

INSERT INTO sites (
  name,
  organization_name,
  business_line_name,
  subsidiary_name,
  description,
  address,
  city,
  country,
  phone,
  email
) VALUES
-- Sites de VISION CONSEIL SARL
(
  'Site Conseil Plateau',
  'GROUPE VISION DURABLE',
  'Conseil ESG',
  'VISION CONSEIL SARL',
  'Bureau principal de conseil ESG au Plateau',
  '45 Rue des Conseillers, Plateau',
  'Abidjan',
  'Côte d''Ivoire',
  '+225 27 20 30 41 01',
  'plateau@visionconseil.ci'
),
(
  'Site Conseil Cocody',
  'GROUPE VISION DURABLE',
  'Conseil ESG',
  'VISION CONSEIL SARL',
  'Antenne de conseil ESG à Cocody',
  '23 Boulevard de Cocody',
  'Abidjan',
  'Côte d''Ivoire',
  '+225 27 20 30 41 02',
  'cocody@visionconseil.ci'
),
-- Sites de STRATÉGIE DURABLE SA
(
  'Site Stratégie Centre',
  'GROUPE VISION DURABLE',
  'Conseil ESG',
  'STRATÉGIE DURABLE SA',
  'Centre de stratégie durable à Yamoussoukro',
  '78 Avenue de la Stratégie',
  'Yamoussoukro',
  'Côte d''Ivoire',
  '+225 30 64 20 30 01',
  'centre@strategiedurable.ci'
),
-- Sites d'AUDIT VERT SARL
(
  'Site Audit Marcory',
  'GROUPE VISION DURABLE',
  'Audit & Certification',
  'AUDIT VERT SARL',
  'Centre d''audit environnemental à Marcory',
  '12 Place de l''Audit, Marcory',
  'Abidjan',
  'Côte d''Ivoire',
  '+225 27 20 30 42 01',
  'marcory@auditvert.ci'
),
(
  'Site Audit Treichville',
  'GROUPE VISION DURABLE',
  'Audit & Certification',
  'AUDIT VERT SARL',
  'Laboratoire d''analyse environnementale',
  '89 Rue de l''Environnement',
  'Abidjan',
  'Côte d''Ivoire',
  '+225 27 20 30 42 02',
  'labo@auditvert.ci'
),
-- Sites de CERTIF ESG SA
(
  'Site Certification San-Pédro',
  'GROUPE VISION DURABLE',
  'Audit & Certification',
  'CERTIF ESG SA',
  'Centre de certification ESG',
  '56 Boulevard de la Certification',
  'San-Pédro',
  'Côte d''Ivoire',
  '+225 34 71 20 30 01',
  'sanpedro@certifESG.ci'
);

-- ============================================================================
-- 5. CRÉATION DES UTILISATEURS DANS AUTH ET TABLES
-- ============================================================================

-- Insertion dans la table users
INSERT INTO users (email, nom, prenom, fonction) VALUES
-- Administrateur client
('admin.esg@groupevisiondurable.ci', 'KOUASSI', 'Marie-Claire', 'Directrice ESG Groupe'),

-- Contributeurs (1 par filiale)
('contrib.conseil@visionconseil.ci', 'DIABATE', 'Kouadio', 'Responsable Données ESG'),
('contrib.strategie@strategiedurable.ci', 'TRAORE', 'Aminata', 'Analyste ESG'),
('contrib.audit@auditvert.ci', 'KONE', 'Seydou', 'Auditeur Environnemental'),
('contrib.certif@certifESG.ci', 'OUATTARA', 'Fatou', 'Responsable Certification'),

-- Validateurs (1 par filière)
('valid.conseil@groupevisiondurable.ci', 'BAMBA', 'Jean-Baptiste', 'Directeur Conseil ESG'),
('valid.audit@groupevisiondurable.ci', 'SANGARE', 'Aïcha', 'Directrice Audit & Certification');

-- Création des profils utilisateurs
INSERT INTO profiles (
  email,
  role,
  organization_name,
  organization_level,
  business_line_name,
  subsidiary_name,
  site_name
) VALUES
-- Administrateur client (niveau organisation)
(
  'admin.esg@groupevisiondurable.ci',
  'enterprise',
  'GROUPE VISION DURABLE',
  'organization',
  NULL,
  NULL,
  NULL
),

-- Contributeurs (niveau site)
(
  'contrib.conseil@visionconseil.ci',
  'contributor',
  'GROUPE VISION DURABLE',
  'site',
  'Conseil ESG',
  'VISION CONSEIL SARL',
  'Site Conseil Plateau'
),
(
  'contrib.strategie@strategiedurable.ci',
  'contributor',
  'GROUPE VISION DURABLE',
  'site',
  'Conseil ESG',
  'STRATÉGIE DURABLE SA',
  'Site Stratégie Centre'
),
(
  'contrib.audit@auditvert.ci',
  'contributor',
  'GROUPE VISION DURABLE',
  'site',
  'Audit & Certification',
  'AUDIT VERT SARL',
  'Site Audit Marcory'
),
(
  'contrib.certif@certifESG.ci',
  'contributor',
  'GROUPE VISION DURABLE',
  'site',
  'Audit & Certification',
  'CERTIF ESG SA',
  'Site Certification San-Pédro'
),

-- Validateurs (niveau filière)
(
  'valid.conseil@groupevisiondurable.ci',
  'validator',
  'GROUPE VISION DURABLE',
  'business_line',
  'Conseil ESG',
  NULL,
  NULL
),
(
  'valid.audit@groupevisiondurable.ci',
  'validator',
  'GROUPE VISION DURABLE',
  'business_line',
  'Audit & Certification',
  NULL,
  NULL
);

-- ============================================================================
-- 6. CONFIGURATION ESG DE L'ORGANISATION
-- ============================================================================

-- Secteur d'activité
INSERT INTO organization_sectors (organization_name, sector_name, subsector_name) VALUES
('GROUPE VISION DURABLE', 'Services financiers', 'Conseil en investissement');

-- Normes appliquées
INSERT INTO organization_standards (organization_name, standard_codes) VALUES
('GROUPE VISION DURABLE', ARRAY['GRI', 'CSRD', 'ISO14001', 'ISO26000', 'TCFD']);

-- Enjeux ESG
INSERT INTO organization_issues (organization_name, issue_codes) VALUES
('GROUPE VISION DURABLE', ARRAY['CLIMATE_CHANGE', 'ENERGY_MGMT', 'WASTE_MGMT', 'EMPLOYEE_DEV', 'ETHICS', 'GOVERNANCE']);

-- Critères d'évaluation
INSERT INTO organization_criteria (organization_name, criteria_codes) VALUES
('GROUPE VISION DURABLE', ARRAY['GHG_EMISSIONS', 'ENERGY_CONSUMPTION', 'WASTE_REDUCTION', 'TRAINING_HOURS', 'ETHICS_VIOLATIONS', 'BOARD_DIVERSITY']);

-- Indicateurs de performance
INSERT INTO organization_indicators (organization_name, indicator_codes) VALUES
('GROUPE VISION DURABLE', ARRAY['ENV_001', 'ENV_002', 'ENV_003', 'SOC_001', 'SOC_002', 'GOV_001', 'GOV_002']);

-- ============================================================================
-- 7. CRÉATION DES PROCESSUS
-- ============================================================================

INSERT INTO processes (code, name, description, indicator_codes, organization_name) VALUES
('ENV_001', 'Gestion des Émissions GES', 'Processus de suivi et réduction des émissions de gaz à effet de serre', ARRAY['ENV_001', 'ENV_002'], 'GROUPE VISION DURABLE'),
('SOC_002', 'Formation et Développement', 'Processus de formation continue et développement des compétences', ARRAY['SOC_001', 'SOC_002'], 'GROUPE VISION DURABLE'),
('GOV_001', 'Gouvernance et Éthique', 'Processus de gouvernance d''entreprise et respect de l''éthique', ARRAY['GOV_001', 'GOV_002'], 'GROUPE VISION DURABLE'),
('ENV_003', 'Gestion des Déchets', 'Processus de gestion et réduction des déchets', ARRAY['ENV_003'], 'GROUPE VISION DURABLE');

-- ============================================================================
-- 8. ATTRIBUTION DES PROCESSUS AUX UTILISATEURS
-- ============================================================================

INSERT INTO user_processes (email, process_codes) VALUES
-- Contributeurs avec leurs processus spécifiques
('contrib.conseil@visionconseil.ci', ARRAY['ENV_001', 'SOC_002']),
('contrib.strategie@strategiedurable.ci', ARRAY['GOV_001', 'SOC_002']),
('contrib.audit@auditvert.ci', ARRAY['ENV_001', 'ENV_003']),
('contrib.certif@certifESG.ci', ARRAY['ENV_003', 'GOV_001']),

-- Validateurs avec tous les processus de leur filière
('valid.conseil@groupevisiondurable.ci', ARRAY['ENV_001', 'SOC_002', 'GOV_001']),
('valid.audit@groupevisiondurable.ci', ARRAY['ENV_001', 'ENV_003', 'GOV_001']);

-- ============================================================================
-- 9. DONNÉES D'EXEMPLE POUR LES INDICATEURS
-- ============================================================================

-- Insertion de quelques valeurs d'indicateurs pour l'année en cours
INSERT INTO indicator_values (
  organization_name,
  business_line_name,
  subsidiary_name,
  site_name,
  process_code,
  indicator_code,
  year,
  month,
  value,
  status,
  submitted_by
) VALUES
-- Site Conseil Plateau - Émissions GES
('GROUPE VISION DURABLE', 'Conseil ESG', 'VISION CONSEIL SARL', 'Site Conseil Plateau', 'ENV_001', 'ENV_001', 2025, 1, 450.5, 'validated', 'contrib.conseil@visionconseil.ci'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'VISION CONSEIL SARL', 'Site Conseil Plateau', 'ENV_001', 'ENV_001', 2025, 2, 425.3, 'validated', 'contrib.conseil@visionconseil.ci'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'VISION CONSEIL SARL', 'Site Conseil Plateau', 'ENV_001', 'ENV_001', 2025, 3, 398.7, 'submitted', 'contrib.conseil@visionconseil.ci'),

-- Site Audit Marcory - Gestion des déchets
('GROUPE VISION DURABLE', 'Audit & Certification', 'AUDIT VERT SARL', 'Site Audit Marcory', 'ENV_003', 'ENV_003', 2025, 1, 75.2, 'validated', 'contrib.audit@auditvert.ci'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'AUDIT VERT SARL', 'Site Audit Marcory', 'ENV_003', 'ENV_003', 2025, 2, 68.9, 'validated', 'contrib.audit@auditvert.ci'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'AUDIT VERT SARL', 'Site Audit Marcory', 'ENV_003', 'ENV_003', 2025, 3, 72.1, 'draft', 'contrib.audit@auditvert.ci'),

-- Formation - heures de formation
('GROUPE VISION DURABLE', 'Conseil ESG', 'VISION CONSEIL SARL', 'Site Conseil Plateau', 'SOC_002', 'SOC_001', 2025, 1, 34.0, 'validated', 'contrib.conseil@visionconseil.ci'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'STRATÉGIE DURABLE SA', 'Site Stratégie Centre', 'SOC_002', 'SOC_001', 2025, 1, 28.5, 'validated', 'contrib.strategie@strategiedurable.ci'),

-- Gouvernance - violations éthiques
('GROUPE VISION DURABLE', 'Conseil ESG', 'STRATÉGIE DURABLE SA', 'Site Stratégie Centre', 'GOV_001', 'GOV_001', 2025, 1, 0.0, 'validated', 'contrib.strategie@strategiedurable.ci'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'CERTIF ESG SA', 'Site Certification San-Pédro', 'GOV_001', 'GOV_001', 2025, 1, 0.0, 'validated', 'contrib.certif@certifESG.ci');

-- ============================================================================
-- 10. DONNÉES SWOT POUR L'ORGANISATION
-- ============================================================================

INSERT INTO swot_analysis (organization_name, type, description) VALUES
('GROUPE VISION DURABLE', 'strength', 'Expertise reconnue en conseil ESG depuis plus de 10 ans'),
('GROUPE VISION DURABLE', 'strength', 'Équipe multidisciplinaire de 45 consultants certifiés'),
('GROUPE VISION DURABLE', 'strength', 'Présence géographique étendue en Afrique de l''Ouest'),
('GROUPE VISION DURABLE', 'weakness', 'Dépendance aux réglementations gouvernementales'),
('GROUPE VISION DURABLE', 'weakness', 'Concurrence accrue des cabinets internationaux'),
('GROUPE VISION DURABLE', 'opportunity', 'Croissance du marché ESG en Afrique'),
('GROUPE VISION DURABLE', 'opportunity', 'Nouvelles réglementations CSRD créent de la demande'),
('GROUPE VISION DURABLE', 'threat', 'Évolution rapide des standards internationaux'),
('GROUPE VISION DURABLE', 'threat', 'Risque de pénurie de talents spécialisés ESG');

-- ============================================================================
-- RÉSUMÉ DES IDENTIFIANTS CRÉÉS
-- ============================================================================

/*
IDENTIFIANTS DE CONNEXION CRÉÉS :

👤 ADMINISTRATEUR CLIENT :
Email: admin.esg@groupevisiondurable.ci
Mot de passe: AdminESG2025!
Nom: KOUASSI Marie-Claire
Fonction: Directrice ESG Groupe
Niveau: Organisation complète

📝 CONTRIBUTEURS :
1. Email: contrib.conseil@visionconseil.ci
   Mot de passe: ContribConseil2025!
   Nom: DIABATE Kouadio
   Site: Site Conseil Plateau
   Processus: ENV_001, SOC_002

2. Email: contrib.strategie@strategiedurable.ci
   Mot de passe: ContribStrategie2025!
   Nom: TRAORE Aminata
   Site: Site Stratégie Centre
   Processus: GOV_001, SOC_002

3. Email: contrib.audit@auditvert.ci
   Mot de passe: ContribAudit2025!
   Nom: KONE Seydou
   Site: Site Audit Marcory
   Processus: ENV_001, ENV_003

4. Email: contrib.certif@certifESG.ci
   Mot de passe: ContribCertif2025!
   Nom: OUATTARA Fatou
   Site: Site Certification San-Pédro
   Processus: ENV_003, GOV_001

✅ VALIDATEURS :
1. Email: valid.conseil@groupevisiondurable.ci
   Mot de passe: ValidConseil2025!
   Nom: BAMBA Jean-Baptiste
   Filière: Conseil ESG
   Processus: ENV_001, SOC_002, GOV_001

2. Email: valid.audit@groupevisiondurable.ci
   Mot de passe: ValidAudit2025!
   Nom: SANGARE Aïcha
   Filière: Audit & Certification
   Processus: ENV_001, ENV_003, GOV_001

STRUCTURE ORGANISATIONNELLE :
📊 GROUPE VISION DURABLE
├── 🏢 Filière: Conseil ESG
│   ├── 🏭 VISION CONSEIL SARL
│   │   ├── 📍 Site Conseil Plateau
│   │   └── 📍 Site Conseil Cocody
│   └── 🏭 STRATÉGIE DURABLE SA
│       └── 📍 Site Stratégie Centre
└── 🏢 Filière: Audit & Certification
    ├── 🏭 AUDIT VERT SARL
    │   ├── 📍 Site Audit Marcory
    │   └── 📍 Site Audit Treichville
    └── 🏭 CERTIF ESG SA
        └── 📍 Site Certification San-Pédro
*/