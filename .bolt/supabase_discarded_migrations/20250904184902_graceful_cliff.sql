/*
  # Ajout des indicateurs ESG détaillés

  1. Nouveaux Indicateurs
    - Indicateurs B1 (Informations générales) : 15 indicateurs
    - Indicateurs C1 (Stratégie et modèle d'affaires) : 25 indicateurs  
    - Indicateurs C3 (Instance de gouvernance) : 20 indicateurs
    - Indicateurs S1 (Personnel de l'entreprise) : 45 indicateurs
    - Indicateurs B10 (Rémunération) : 30 indicateurs

  2. Nouveaux Processus
    - Informations Générales
    - Stratégie et Modèle d'Affaires
    - Instance de Gouvernance
    - Ressources Humaines
    - Finance

  3. Mise à jour
    - Ajout des codes et définitions détaillées
    - Association aux axes ESG appropriés
    - Configuration des formules de calcul
*/

-- Insertion des nouveaux indicateurs B1 - Informations générales
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES
('B1_CA', 'Chiffre d''affaires', 'Revenus sous forme de ventes nettes plus les revenus des investissements financiers et des ventes d''actifs. Les ventes nettes peuvent être calculées comme les revenus bruts des produits et de services moins les retours, les remises et les ristournes.', 'FCFA', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('B1_SITES', 'Sites', 'Sites où la production est réalisée', 'Nbre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('B1_FOURNISSEURS', 'Fournisseurs de produits et services', 'Organisation ou personne fournissant un produit ou service à SIPCA annuellement', 'Nbre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('B1_AIDE_FINANCIERE', 'Aide financière reçue du gouvernement', 'Aide financière reçue du gouvernement', 'FCFA', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('B1_IMPOTS_TAXES', 'Impôts et taxes versées auprès des ministères et organismes publics', 'Impôt et taxes versées auprès des ministères et organismes publics', 'FCFA', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('B1_TYPES_RAPPORTS', 'Types de rapports élaborés', 'Nombre de types de rapports élaborés', 'Nbre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('B1_TAUX_FINALISATION', 'Taux de finalisation des rapports', 'Nbre de rapports finalisés/ rapports totaux', 'Nbre', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('B1_LABELS_ESG', 'Nombre de labels ESG Obtenus', 'Nombre de labels ESG Obtenus', 'Nbre', 'primaire', 'Gouvernance', 'dernier_mois', 'annuelle'),
('B1_CA_PRODUITS_UE', '% CA produits alignés Taxonomie UE', '% du chiffre d''affaires', '%', 'calculé', 'Environnement', 'dernier_mois', 'annuelle'),
('B1_CA_MARCHE_GEO', 'Chiffre d''affaires par marché géographique', 'Part du chiffre d''affaires par marché géographique', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('B1_FOURNISSEURS_DIRECTS', 'Nombre total de fournisseurs directs', 'Nombre total de fournisseurs directs', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('B1_ACHATS_STRATEGIQUES', 'Part des achats auprès de fournisseurs stratégiques (top 10 ou top 20)', '% du volume d''achats réalisés auprès de fournisseurs stratégiques', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('B1_ACHATS_REALISES', 'Total des Achats réalisés', 'Total des Achats réalisés', 'KFCFA', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('B1_CA_ACHATS', '% du chiffre d''affaires issu des achats réalisés', 'Total des achats réalisé / Chiffre d''affaires', 'KFCFA', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('B1_ACHATS_NATIONAUX', 'Achats auprès des fournisseurs nationaux', 'Achats auprès des fournisseurs nationaux', 'KFCFA', 'primaire', 'Gouvernance', 'somme', 'annuelle');

-- Insertion des indicateurs C1 - Stratégie et modèle d'affaires
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES
('C1_FOURNISSEURS_ESG', 'Part de fournisseurs engagés dans objectifs ESG', 'Part de fournisseurs engagés dans objectifs ESG', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('C1_INTEGRATION_ESG', 'Taux d''intégration des critères ESG dans les appels d''offre', 'Taux d''intégration des critères ESG dans les appels d''offre', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('C1_ACHATS_LOCAUX', 'Part des achats locaux / régionaux', 'Volume d''achats locaux/ Volume d''chats régionaux', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('C1_FOURNISSEURS_ESG_EVAL', 'Part de fournisseurs évalués sur critères ESG', 'Fournisseurs évalués sur critères ESG/ Nombre total de fournisseurs', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('C1_AUDITS_ESG', 'Nombre d''audits ESG réalisés chez fournisseurs', 'Nombre d''audits ESG réalisés chez fournisseurs', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('C1_CONFORMITE_ESG', 'Taux de conformité ESG des fournisseurs audités', 'Nombre de fournisseurs audités conformes ESG/ Nombre total de fournisseurs audités', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('C1_RESILIATIONS_ESG', 'Nombre de résiliations de contrats pour non-conformité ESG', 'Nombre de résiliations de contrats pour non-conformité ESG', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('C1_CA_ACTIVITES_DURABLES', 'Part du CA provenant d''activités durables (taxonomie verte UE)', 'Part du CA provenant d''activités durables (taxonomie verte UE)', '%', 'calculé', 'Environnement', 'dernier_mois', 'annuelle'),
('C1_INVESTISSEMENT_ESG', 'Projets d''investissement alignés sur les objectifs ESG', 'Projets d''investissement alignés sur les objectifs ESG', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('C1_DEPENSES_RD_DURABLES', 'Part des dépenses R&D orientées vers solutions durables', 'Part des dépenses R&D orientées vers solutions durables', '%', 'calculé', 'Environnement', 'dernier_mois', 'annuelle'),
('C1_REMUNERATION_ESG', 'Rémunération des dirigeants liée aux objectifs de durabilité', 'Montant variable lié à des objectifs ESG/ Rémunération totale', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle');

-- Insertion des indicateurs C3 - Instance de gouvernance
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES
('C3_MEMBRES_CONSEIL', 'Membres au Conseil d''Administration', 'Membres du Conseil d''Administration', 'Nombre', 'primaire', 'Gouvernance', 'dernier_mois', 'annuelle'),
('C3_FEMMES_CONSEIL', 'Femmes dans le Conseil d''Administration', 'Femmes administratrices au Conseil d''Administration', 'Nombre', 'primaire', 'Gouvernance', 'dernier_mois', 'annuelle'),
('C3_PART_FEMMES_CONSEIL', 'Part des femmes dans le Conseil d''Administration', 'Total des Femmes dans le Conseil d''Administration/ Total des Membres au Conseil d''Administration', '%', 'calculé', 'Social', 'dernier_mois', 'annuelle'),
('C3_MEMBRES_COMITE', 'Membres du Comité de Direction', 'Membres du Comité de Direction', 'Nombre', 'primaire', 'Gouvernance', 'dernier_mois', 'annuelle'),
('C3_FEMMES_COMITE', 'Femme dans le Comité de Direction', 'Nombre de femme dans Comité de Direction (CODIR, COSIJ)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'annuelle'),
('C3_ACTIONS_ENV_ID', 'Actions d''identification des non-conformités environnementales', 'Audits, Evaluations, inspections, effectués pour déterminer les non-conformités environnementales', 'Nombre', 'primaire', 'Environnement', 'somme', 'mensuelle'),
('C3_ACTIONS_SOCIO_ID', 'Actions d''identification des non-conformités socio-économiques', 'Audits, Evaluations, inspections, effectués pour déterminer les non-conformités sociales concernant les travailleurs et la chaîne de valeurs', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('C3_DIAGNOSTICS_TOTAL', 'Total des diagnostics menés pour détecter les non-conformités', 'Total des Diagnostics menés pour détecter les non-conformités environnementales et des diagnostics menés pour détecter les non-conformités socio-économiques', 'Nombre', 'calculé', 'Gouvernance', 'somme', 'mensuelle'),
('C3_SITES_AUDIT_DD', 'Sites ayant effectué un audit interne DD', 'Sites ayant effectué un auto-diagnostic RSE', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('C3_PART_SITES_AUDIT', 'Part des sites ayant effectué un audit interne DD', 'Total des Sites ayant effectué un auto-diagnostic RSE / Total des Sites de production', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle');

-- Insertion des indicateurs S1 - Personnel de l'entreprise (sélection des principaux)
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES
('S1_CDI_HOMMES', 'Collaborateurs avec un contrat à durée indéterminée (CDI)', 'Collaborateurs à la fin d''année ayant contrat de travail à durée indéterminée, pour un travail à temps plein ou à temps partiel.', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_CDD_HOMMES', 'Collaborateurs avec un contrat à durée déterminée (CDD, CDDi)', 'Collaborateurs à la fin d''année ayant contrat de travail, pour un travail à temps plein ou à temps partiel, au grand fin à l''expiration d''une période déterminée ou à l''achèvement d''une tâche spécifique.', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_TOTAL_COLLABORATEURS', 'Total des collaborateurs', 'Total des collaborateurs (CDI + CDD + CDDi)', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('S1_PART_CDI', 'Part des collaborateurs possédant un contrat à durée indéterminée', 'Total des collaborateurs avec un contrat de travail à durée indéterminée/ Total des collaborateurs', '%', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('S1_SOUS_TRAITANTS', 'collaborateurs sous-traitants', 'Personnes qui effectuent un travail régulier sur place, mais non considérées comme collaborateurs de SIPCA en vertu de la législation ou de la pratique nationale (contrat de travail).', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_TOTAL_AVEC_ST', 'Total des collaborateurs (Total des collaborateurs+collaborateurs sous-traitants)', 'Total des collaborateurs + collaborateurs Sous-traitants', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('S1_FEMMES_TOTAL', 'Collaborateurs femmes', 'Employées femmes quel que soit leur contrat de travail (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_HOMMES_TOTAL', 'Collaborateurs hommes', 'Employées hommes quel que soit leur contrat de travail (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_OUVRIERS_TOTAL', 'Ouvriers', 'Ouvriers et main-d''œuvre dans la production (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_EMPLOYES_TOTAL', 'Employés', 'Fonctions administratives et techniciens (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_AGENTS_MAITRISE', 'Agents de maîtrise', 'Agents de maîtrise (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_CADRES_TOTAL', 'Cadres', 'Cadres (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_FEMMES_OUVRIERES', 'Femmes ouvrières', 'Femmes ouvrières (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_FEMMES_EMPLOYEES', 'Femmes employées', 'Femmes employées administratif et techniciens (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_FEMMES_AGENTS', 'Femmes agents de maîtrise', 'Femmes agents de maîtrise (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_FEMMES_CADRES', 'Femmes cadres', 'Femmes cadres (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_HOMMES_OUVRIERS', 'Hommes ouvriers', 'Hommes ouvriers', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('S1_HOMMES_EMPLOYES', 'Hommes employés', 'Hommes employés administratif et techniciens', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('S1_HOMMES_AGENTS', 'Hommes agents de maîtrise', 'Hommes agents de maîtrise', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('S1_HOMMES_CADRES', 'Hommes cadres', 'Hommes cadres', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('S1_EMBAUCHES_30', 'Embauches de l''année dont l''âge < 30 ans', 'Embauches - nouveaux collaborateurs dont l''âge < 30 ans [possédant un contrat CDI ou CDDi] qui rejoignent le groupe pour la première fois au cours de l''année de reporting.', 'Nombre', 'primaire', 'Social', 'somme', 'annuelle');

-- Insertion des indicateurs B10 - Rémunération (sélection des principaux)
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES
('B10_SALAIRE_ENTREE', 'Salaire d''entrée dans le Groupe', 'Salaire d''embauche le plus bas dans le Groupe SIPCA (annuel)', 'FCFA', 'primaire', 'Social', 'moyenne', 'annuelle'),
('B10_SALAIRE_MINIMUM', 'Salaire minimum légal et local', 'Salaire minimum local selon la réglementation (annuel)', 'FCFA', 'primaire', 'Social', 'moyenne', 'annuelle'),
('B10_RATIO_SALAIRE', 'Salaire d''entrée comparé au salaire local', 'Ratio du salaire d''entrée standard par pays, par rapport au salaire minimum local selon la réglementation', 'Ratio', 'calculé', 'Social', 'moyenne', 'annuelle'),
('B10_REMUNERATION_HOMMES', 'Rémunération totale - Hommes', 'Total annuel de la rémunération versée aux hommes', 'FCFA', 'primaire', 'Social', 'somme', 'annuelle'),
('B10_REMUNERATION_FEMMES', 'Rémunération totale - Femmes', 'Total annuel de la rémunération versée aux femmes', 'FCFA', 'primaire', 'Social', 'somme', 'annuelle'),
('B10_TOTAL_REMUNERATIONS', 'TOTAL Rémunerations - Hommes+Femmes', 'Total annuel de la rémunération versée aux hommes et aux femmes', 'FCFA', 'calculé', 'Social', 'somme', 'annuelle'),
('B10_RATIO_REMUNERATION', 'Ratio Rémunération / Chiffre d''affaires.', 'Total Rémunération annuelle Hommes + Femmes / 1000 / Chiffre d''affaires', 'FCFA', 'calculé', 'Social', 'dernier_mois', 'annuelle'),
('B10_CROISSANCE_REMUNERATION', 'Taux de croissance de la Rémunération', 'Taux de croissance de la Rémunération', 'FCFA', 'calculé', 'Social', 'dernier_mois', 'annuelle'),
('B10_REMUNERATION_MOY_HOMME', 'Rémunération annuelle moyenne - Homme', 'Rémunération annuelle moyenne par homme', 'FCFA', 'calculé', 'Social', 'moyenne', 'annuelle'),
('B10_REMUNERATION_MOY_FEMME', 'Rémunération annuelle moyenne - Femme', 'Rémunération annuelle moyenne par femme', 'FCFA', 'calculé', 'Social', 'moyenne', 'annuelle'),
('B10_REMUNERATION_MOY_TOTAL', 'Rémunération annuelle moyenne - Total collaborateur', 'Rémunération annuelle moyenne par collaborateur', 'FCFA', 'calculé', 'Social', 'moyenne', 'annuelle'),
('B10_EGALITE_SALARIALE', 'Égalité salariale entre les hommes et les femmes TOUTES CATÉGORIES', 'Ratio entre la rémunération annuelle moyenne des femmes et la rémunération annuelle moyenne des femmes', 'Ratio', 'calculé', 'Social', 'moyenne', 'annuelle');

-- Création des nouveaux processus
INSERT INTO processes (code, name, description, indicator_codes, organization_name) VALUES
('INFO_GEN', 'Informations Générales', 'Processus de collecte des informations générales de l''entreprise', 
 ARRAY['B1_CA', 'B1_SITES', 'B1_FOURNISSEURS', 'B1_AIDE_FINANCIERE', 'B1_IMPOTS_TAXES', 'B1_TYPES_RAPPORTS', 'B1_TAUX_FINALISATION', 'B1_LABELS_ESG', 'B1_CA_PRODUITS_UE', 'B1_CA_MARCHE_GEO', 'B1_FOURNISSEURS_DIRECTS', 'B1_ACHATS_STRATEGIQUES', 'B1_ACHATS_REALISES', 'B1_CA_ACHATS', 'B1_ACHATS_NATIONAUX'], 
 'GROUPE VISION DURABLE'),

('STRATEGIE', 'Stratégie et Modèle d''Affaires', 'Processus de gestion de la stratégie et du modèle d''affaires ESG', 
 ARRAY['C1_FOURNISSEURS_ESG', 'C1_INTEGRATION_ESG', 'C1_ACHATS_LOCAUX', 'C1_FOURNISSEURS_ESG_EVAL', 'C1_AUDITS_ESG', 'C1_CONFORMITE_ESG', 'C1_RESILIATIONS_ESG', 'C1_CA_ACTIVITES_DURABLES', 'C1_INVESTISSEMENT_ESG', 'C1_DEPENSES_RD_DURABLES', 'C1_REMUNERATION_ESG'], 
 'GROUPE VISION DURABLE'),

('GOUVERNANCE', 'Instance de Gouvernance', 'Processus de gouvernance et de supervision', 
 ARRAY['C3_MEMBRES_CONSEIL', 'C3_FEMMES_CONSEIL', 'C3_PART_FEMMES_CONSEIL', 'C3_MEMBRES_COMITE', 'C3_FEMMES_COMITE', 'C3_ACTIONS_ENV_ID', 'C3_ACTIONS_SOCIO_ID', 'C3_DIAGNOSTICS_TOTAL', 'C3_SITES_AUDIT_DD', 'C3_PART_SITES_AUDIT'], 
 'GROUPE VISION DURABLE'),

('RH', 'Ressources Humaines', 'Processus de gestion des ressources humaines et du personnel', 
 ARRAY['S1_CDI_HOMMES', 'S1_CDD_HOMMES', 'S1_TOTAL_COLLABORATEURS', 'S1_PART_CDI', 'S1_SOUS_TRAITANTS', 'S1_TOTAL_AVEC_ST', 'S1_FEMMES_TOTAL', 'S1_HOMMES_TOTAL', 'S1_OUVRIERS_TOTAL', 'S1_EMPLOYES_TOTAL', 'S1_AGENTS_MAITRISE', 'S1_CADRES_TOTAL', 'S1_FEMMES_OUVRIERES', 'S1_FEMMES_EMPLOYEES', 'S1_FEMMES_AGENTS', 'S1_FEMMES_CADRES', 'S1_HOMMES_OUVRIERS', 'S1_HOMMES_EMPLOYES', 'S1_HOMMES_AGENTS', 'S1_HOMMES_CADRES', 'S1_EMBAUCHES_30'], 
 'GROUPE VISION DURABLE'),

('FINANCE', 'Finances et Rémunération', 'Processus de gestion financière et de rémunération', 
 ARRAY['B10_SALAIRE_ENTREE', 'B10_SALAIRE_MINIMUM', 'B10_RATIO_SALAIRE', 'B10_REMUNERATION_HOMMES', 'B10_REMUNERATION_FEMMES', 'B10_TOTAL_REMUNERATIONS', 'B10_RATIO_REMUNERATION', 'B10_CROISSANCE_REMUNERATION', 'B10_REMUNERATION_MOY_HOMME', 'B10_REMUNERATION_MOY_FEMME', 'B10_REMUNERATION_MOY_TOTAL', 'B10_EGALITE_SALARIALE'], 
 'GROUPE VISION DURABLE');

-- Mise à jour des indicateurs de l'organisation
INSERT INTO organization_indicators (organization_name, indicator_codes) VALUES
('GROUPE VISION DURABLE', ARRAY[
  'B1_CA', 'B1_SITES', 'B1_FOURNISSEURS', 'B1_AIDE_FINANCIERE', 'B1_IMPOTS_TAXES', 'B1_TYPES_RAPPORTS', 'B1_TAUX_FINALISATION', 'B1_LABELS_ESG', 'B1_CA_PRODUITS_UE', 'B1_CA_MARCHE_GEO', 'B1_FOURNISSEURS_DIRECTS', 'B1_ACHATS_STRATEGIQUES', 'B1_ACHATS_REALISES', 'B1_CA_ACHATS', 'B1_ACHATS_NATIONAUX',
  'C1_FOURNISSEURS_ESG', 'C1_INTEGRATION_ESG', 'C1_ACHATS_LOCAUX', 'C1_FOURNISSEURS_ESG_EVAL', 'C1_AUDITS_ESG', 'C1_CONFORMITE_ESG', 'C1_RESILIATIONS_ESG', 'C1_CA_ACTIVITES_DURABLES', 'C1_INVESTISSEMENT_ESG', 'C1_DEPENSES_RD_DURABLES', 'C1_REMUNERATION_ESG',
  'C3_MEMBRES_CONSEIL', 'C3_FEMMES_CONSEIL', 'C3_PART_FEMMES_CONSEIL', 'C3_MEMBRES_COMITE', 'C3_FEMMES_COMITE', 'C3_ACTIONS_ENV_ID', 'C3_ACTIONS_SOCIO_ID', 'C3_DIAGNOSTICS_TOTAL', 'C3_SITES_AUDIT_DD', 'C3_PART_SITES_AUDIT',
  'S1_CDI_HOMMES', 'S1_CDD_HOMMES', 'S1_TOTAL_COLLABORATEURS', 'S1_PART_CDI', 'S1_SOUS_TRAITANTS', 'S1_TOTAL_AVEC_ST', 'S1_FEMMES_TOTAL', 'S1_HOMMES_TOTAL', 'S1_OUVRIERS_TOTAL', 'S1_EMPLOYES_TOTAL', 'S1_AGENTS_MAITRISE', 'S1_CADRES_TOTAL', 'S1_FEMMES_OUVRIERES', 'S1_FEMMES_EMPLOYEES', 'S1_FEMMES_AGENTS', 'S1_FEMMES_CADRES', 'S1_HOMMES_OUVRIERS', 'S1_HOMMES_EMPLOYES', 'S1_HOMMES_AGENTS', 'S1_HOMMES_CADRES', 'S1_EMBAUCHES_30',
  'B10_SALAIRE_ENTREE', 'B10_SALAIRE_MINIMUM', 'B10_RATIO_SALAIRE', 'B10_REMUNERATION_HOMMES', 'B10_REMUNERATION_FEMMES', 'B10_TOTAL_REMUNERATIONS', 'B10_RATIO_REMUNERATION', 'B10_CROISSANCE_REMUNERATION', 'B10_REMUNERATION_MOY_HOMME', 'B10_REMUNERATION_MOY_FEMME', 'B10_REMUNERATION_MOY_TOTAL', 'B10_EGALITE_SALARIALE'
])
ON CONFLICT (organization_name) DO UPDATE SET
indicator_codes = EXCLUDED.indicator_codes,
updated_at = now();

-- Ajout de données d'exemple pour quelques indicateurs clés
INSERT INTO indicator_values (
  organization_name, business_line_name, subsidiary_name, site_name, 
  process_code, indicator_code, year, month, value, status
) VALUES
-- Données pour le site Conseil Plateau
('GROUPE VISION DURABLE', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau', 'INFO_GEN', 'B1_CA', 2025, 1, 15000000, 'validated'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau', 'INFO_GEN', 'B1_SITES', 2025, 1, 1, 'validated'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau', 'INFO_GEN', 'B1_FOURNISSEURS', 2025, 1, 25, 'validated'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau', 'RH', 'S1_TOTAL_COLLABORATEURS', 2025, 1, 45, 'validated'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau', 'RH', 'S1_FEMMES_TOTAL', 2025, 1, 22, 'validated'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau', 'RH', 'S1_HOMMES_TOTAL', 2025, 1, 23, 'validated'),

-- Données pour le site Stratégie Centre
('GROUPE VISION DURABLE', 'Conseil ESG', 'Stratégie Durable SA', 'Site Stratégie Centre', 'INFO_GEN', 'B1_CA', 2025, 1, 12000000, 'validated'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Stratégie Durable SA', 'Site Stratégie Centre', 'INFO_GEN', 'B1_SITES', 2025, 1, 1, 'validated'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Stratégie Durable SA', 'Site Stratégie Centre', 'RH', 'S1_TOTAL_COLLABORATEURS', 2025, 1, 38, 'validated'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Stratégie Durable SA', 'Site Stratégie Centre', 'RH', 'S1_FEMMES_TOTAL', 2025, 1, 20, 'validated'),

-- Données pour le site Audit Marcory
('GROUPE VISION DURABLE', 'Audit & Certification', 'Audit Vert SARL', 'Site Audit Marcory', 'INFO_GEN', 'B1_CA', 2025, 1, 18000000, 'validated'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'Audit Vert SARL', 'Site Audit Marcory', 'RH', 'S1_TOTAL_COLLABORATEURS', 2025, 1, 52, 'validated'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'Audit Vert SARL', 'Site Audit Marcory', 'RH', 'S1_FEMMES_TOTAL', 2025, 1, 28, 'validated'),

-- Données pour le site Certification San-Pédro
('GROUPE VISION DURABLE', 'Audit & Certification', 'Certif ESG SA', 'Site Certification San-Pédro', 'INFO_GEN', 'B1_CA', 2025, 1, 14000000, 'validated'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'Certif ESG SA', 'Site Certification San-Pédro', 'RH', 'S1_TOTAL_COLLABORATEURS', 2025, 1, 35, 'validated'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'Certif ESG SA', 'Site Certification San-Pédro', 'RH', 'S1_FEMMES_TOTAL', 2025, 1, 18, 'validated');

-- Ajout de données pour les mois suivants (février et mars)
INSERT INTO indicator_values (
  organization_name, business_line_name, subsidiary_name, site_name, 
  process_code, indicator_code, year, month, value, status
) VALUES
-- Février 2025
('GROUPE VISION DURABLE', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau', 'INFO_GEN', 'B1_CA', 2025, 2, 16500000, 'validated'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau', 'RH', 'S1_TOTAL_COLLABORATEURS', 2025, 2, 47, 'validated'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Stratégie Durable SA', 'Site Stratégie Centre', 'INFO_GEN', 'B1_CA', 2025, 2, 13200000, 'validated'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'Audit Vert SARL', 'Site Audit Marcory', 'INFO_GEN', 'B1_CA', 2025, 2, 19800000, 'validated'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'Certif ESG SA', 'Site Certification San-Pédro', 'INFO_GEN', 'B1_CA', 2025, 2, 15400000, 'validated'),

-- Mars 2025
('GROUPE VISION DURABLE', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau', 'INFO_GEN', 'B1_CA', 2025, 3, 17200000, 'validated'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau', 'RH', 'S1_TOTAL_COLLABORATEURS', 2025, 3, 48, 'validated'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Stratégie Durable SA', 'Site Stratégie Centre', 'INFO_GEN', 'B1_CA', 2025, 3, 14100000, 'validated'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'Audit Vert SARL', 'Site Audit Marcory', 'INFO_GEN', 'B1_CA', 2025, 3, 20500000, 'validated'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'Certif ESG SA', 'Site Certification San-Pédro', 'INFO_GEN', 'B1_CA', 2025, 3, 16200000, 'validated');

-- Mise à jour des processus utilisateurs pour les nouveaux processus
UPDATE user_processes 
SET process_codes = ARRAY['INFO_GEN', 'RH']
WHERE email = 'contrib.conseil@visionconseil.ci';

UPDATE user_processes 
SET process_codes = ARRAY['STRATEGIE', 'RH']
WHERE email = 'contrib.strategie@strategiedurable.ci';

UPDATE user_processes 
SET process_codes = ARRAY['GOUVERNANCE', 'FINANCE']
WHERE email = 'contrib.audit@auditvert.ci';

UPDATE user_processes 
SET process_codes = ARRAY['FINANCE', 'RH']
WHERE email = 'contrib.certif@certifESG.ci';

UPDATE user_processes 
SET process_codes = ARRAY['INFO_GEN', 'STRATEGIE', 'RH']
WHERE email = 'valid.conseil@groupevisiondurable.ci';

UPDATE user_processes 
SET process_codes = ARRAY['GOUVERNANCE', 'FINANCE', 'RH']
WHERE email = 'valid.audit@groupevisiondurable.ci';