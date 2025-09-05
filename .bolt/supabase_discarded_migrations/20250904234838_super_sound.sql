/*
  # Ajout des indicateurs ESG complets selon le référentiel CSRD/GRI

  1. Nouveaux Secteurs et Standards
    - Secteur "Services ESG" avec sous-secteur "Conseil et Audit"
    - Standards ISO 26000, CSRD, GRI, ISO 14001, ISO 45001

  2. Nouveaux Enjeux ESG
    - Informations générales (B1)
    - Stratégie et modèle d'affaires (C1)
    - Instance de gouvernance (C3)
    - Emplois et main d'œuvre (S1)
    - Rémunération et négociation collective (B10)

  3. Nouveaux Critères
    - Caractéristiques de l'entreprise
    - Type de rapport, Labels ESG
    - Relations commerciales
    - Stratégie d'affaire et durabilité
    - Instance de gouvernance
    - Leadership et responsabilité
    - Transparence et anti-corruption
    - Parties prenantes et matérialité
    - Organisation et structure DD
    - Mesure et collecte des données
    - Plaintes et réclamations
    - Diligence raisonnable
    - Finances et investissements
    - Personnel de l'entreprise
    - Continuité d'activité

  4. Indicateurs détaillés (80+ indicateurs)
    - Informations générales : 15 indicateurs
    - Stratégie et modèle : 11 indicateurs  
    - Gouvernance : 10 indicateurs
    - Ressources humaines : 45+ indicateurs
    - Rémunération : 12 indicateurs

  5. Processus métier
    - 5 processus principaux avec indicateurs assignés
    - Attribution aux utilisateurs selon les rôles

  6. Données d'exemple
    - Valeurs réalistes pour janvier-mars 2025
    - Répartition sur les sites du groupe
    - Statuts de validation appropriés
*/

-- 1. SECTEURS ET SOUS-SECTEURS
INSERT INTO sectors (name) VALUES 
('Services ESG')
ON CONFLICT (name) DO NOTHING;

INSERT INTO subsectors (name, sector_name) VALUES 
('Conseil et Audit ESG', 'Services ESG')
ON CONFLICT (name) DO NOTHING;

-- 2. STANDARDS
INSERT INTO standards (code, name, description) VALUES 
('ISO26000', 'ISO 26000', 'Lignes directrices relatives à la responsabilité sociétale'),
('CSRD', 'CSRD', 'Corporate Sustainability Reporting Directive'),
('GRI', 'GRI', 'Global Reporting Initiative'),
('ISO14001', 'ISO 14001', 'Système de management environnemental'),
('ISO45001', 'ISO 45001', 'Système de management de la santé et sécurité au travail')
ON CONFLICT (code) DO NOTHING;

-- 3. ENJEUX ESG
INSERT INTO issues (code, name, description) VALUES 
('B1', 'Informations générales', 'Informations générales sur l''entreprise et ses activités'),
('C1', 'Stratégie et modèle d''affaires', 'Stratégie d''affaire affectant les questions de durabilité'),
('C3', 'Instance de gouvernance', 'Instances de gouvernance et structure de direction'),
('S1', 'Emplois et main d''œuvre', 'Personnel de l''entreprise, emploi, dialogue social et liberté d''association'),
('B10', 'Rémunération et négociation collective', 'Rémunération et négociation collective'),
('G1', 'Leadership et responsabilité', 'Leadership et responsabilité en matière de durabilité'),
('G2', 'Transparence et anti-corruption', 'Conduite des affaires et éthique des affaires'),
('G3', 'Parties prenantes et matérialité', 'Engagement des parties prenantes et matérialité'),
('G4', 'Organisation et structure DD', 'Organisation et stratégie DD'),
('G5', 'Mesure et collecte des données', 'Mesure et collecte des données ESG'),
('S2', 'Plaintes et réclamations', 'Plaintes, réclamations, compensations et amendes'),
('G6', 'Diligence raisonnable', 'Diligence raisonnable, contrôle et certification'),
('B2', 'Finances et investissements', 'Finances et investissements durables'),
('S3', 'Continuité d''activité', 'Continuité d''activité et gestion des risques sociaux')
ON CONFLICT (code) DO NOTHING;

-- 4. CRITÈRES
INSERT INTO criteria (code, name, description) VALUES 
('CARACT_ENT', 'Caractéristiques de l''entreprise', 'Informations de base sur l''organisation'),
('TYPE_RAPPORT', 'Type de rapport', 'Nature et portée du rapport de durabilité'),
('LABELS_ESG', 'Labels ESG obtenus', 'Certifications et labels ESG obtenus'),
('PRODUITS_SERVICES', 'Produits/Services', 'Description des produits et services'),
('MARCHES_IMP', 'Marchés importants', 'Principaux marchés et zones géographiques'),
('REL_COMMERCIALES', 'Relations commerciales', 'Relations avec les partenaires commerciaux'),
('STRAT_AFFAIRE', 'Stratégie d''affaire affectant les questions de durabilité', 'Intégration de la durabilité dans la stratégie'),
('INSTANCE_GOUV', 'Instance de gouvernance', 'Structure de gouvernance et de supervision'),
('POLITIQUE_CHARTE', 'Politique et charte', 'Politiques et chartes de durabilité'),
('TRANSPARENCE', 'Transparence et anti-corruption', 'Mesures de transparence et lutte contre la corruption'),
('CONDAMNATIONS', 'Condamnations et amendes', 'Sanctions et pénalités reçues'),
('PARTIES_PRENANTES', 'Parties prenantes (attentes, dialogue)', 'Engagement et dialogue avec les parties prenantes'),
('ENJEUX_MAT', 'Enjeux et matérialités', 'Analyse de matérialité et enjeux prioritaires'),
('ORG_STRUCTURE', 'Organisation et structure DD', 'Organisation interne pour le développement durable'),
('IRO', 'IRO', 'Impacts, Risques et Opportunités'),
('MESURE_DONNEES', 'Mesure et collecte des données', 'Systèmes de mesure et collecte des données ESG'),
('PLAINTES_RECL', 'Plaintes et réclamations', 'Gestion des plaintes et réclamations'),
('DILIGENCE', 'Diligence raisonnable', 'Processus de diligence raisonnable'),
('CONFORMITE', 'Conformité et certification', 'Conformité réglementaire et certifications'),
('FINANCES', 'Finances et investissements', 'Investissements et financement durables'),
('PERSONNEL', 'Personnel de l''entreprise, emploi, dialogue social et liberté d''association', 'Gestion des ressources humaines et dialogue social'),
('CONTINUITE', 'Continuité d''activité', 'Plans de continuité et gestion des risques')
ON CONFLICT (code) DO NOTHING;

-- 5. INDICATEURS DÉTAILLÉS

-- B1 - Informations générales
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES 
('CA_TOTAL', 'Chiffre d''affaires', 'Revenus sous forme de ventes nettes plus les revenus des investissements financiers et des ventes d''actifs. Les ventes nettes sont les ventes déductibles comme les retours, les remises et les rabais.', 'kCFA', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('SITES_TOTAL', 'Sites', 'Sites où la production est réalisée', 'Nbre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('FOURNISSEURS', 'Fournisseurs de produits et services', 'Organisation ou personne fournissant un produit ou service à SIPCA annuellement', 'Nbre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('AIDE_FINANCIERE', 'Aide financière reçue du gouvernement', 'Aide financière reçue du gouvernement', 'FCFA', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('IMPOTS_TAXES', 'Impôts et taxes versées auprès des ministères et organismes publics', 'Impôt et taxes versées', 'FCFA', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('TYPES_RAPPORTS', 'Types de rapports élaborés', 'Nombre de types de rapports élaborés', 'Nbre', 'primaire', 'Gouvernance', 'dernier_mois', 'annuelle'),
('TAUX_FINALISATION', 'Taux de finalisation des rapports', 'Nbre de rapports finalisés/ rapports totaux', 'Nbre', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('LABELS_ESG', 'Nombre de labels ESG Obtenus', 'Nombre de labels ESG Obtenus', 'Nbre', 'primaire', 'Gouvernance', 'dernier_mois', 'annuelle'),
('PRODUITS_TAXONOMIE', '% CA produits alignés Taxonomie UE', '% du chiffre d''affaires', 'Nbre', 'calculé', 'Environnement', 'dernier_mois', 'annuelle'),
('CA_GEOGRAPHIQUE', 'Chiffre d''affaires par marché géographique', 'Part du chiffre d''affaires par marché géographique', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('FOURNISSEURS_DIRECTS', 'Nombre total de fournisseurs directs', 'Nombre total de fournisseurs directs', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('ACHATS_STRATEGIQUES', 'Part des achats auprès de fournisseurs stratégiques (top 10 ou top 20)', '% du volume d''achats réalisés auprès de fournisseurs stratégiques', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('ACHATS_REALISES', 'Total des Achats réalisés', 'Total des Achats réalisés', 'kFCFA', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('CA_ACHATS', '% du chiffre d''affaires issu des achats réalisés', 'Total des achats réalisé / Chiffre d''affaires', 'kFCFA', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('ACHATS_NATIONAUX', 'Achats auprès des fournisseurs nationaux', 'Achats auprès des fournisseurs nationaux', 'kFCFA', 'primaire', 'Gouvernance', 'somme', 'annuelle')
ON CONFLICT (code) DO NOTHING;

-- C1 - Stratégie et modèle d'affaires
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES 
('ACHATS_LOCAUX', 'Part des achats réalisés auprès des fournisseurs locaux', 'Total des achats réalisé auprès des fournisseurs locaux / Total des achats réalisés', '%', 'calculé', 'Social', 'dernier_mois', 'annuelle'),
('FOURNISSEURS_ESG', 'Part de fournisseurs engagés dans objectifs ESG', 'Part de fournisseurs engagés dans objectifs ESG', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('INTEGRATION_ESG', 'Taux d''intégration des critères ESG dans les appels d''offre', 'Taux d''intégration des critères ESG dans les appels d''offre', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('ACHATS_LOCAUX_REG', 'Part des achats locaux / régionaux', 'Volume d''achats locaux/ Volume d''chats régionaux', '%', 'calculé', 'Social', 'somme', 'annuelle'),
('FOURNISSEURS_EVALUES', 'Part de fournisseurs évalués sur critères ESG', 'Fournisseurs évalués sur critères ESG/ Nombre total de fournisseurs', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('AUDITS_ESG', 'Nombre d''audits ESG réalisés chez fournisseurs', 'Nombre d''audits ESG réalisés chez fournisseurs', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('CONFORMITE_FOURNISSEURS', 'Taux de conformité ESG des fournisseurs audités', 'Nombre de fournisseurs audités conformes ESG/ Nombre total de fournisseurs audités', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('RESILIATIONS_NON_CONF', 'Nombre de résiliations de contrats pour non-conformité ESG', 'Nombre de résiliations de contrats pour non-conformité ESG', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('CA_ACTIVITES_DURABLES', 'Part du CA provenant d''activités durables (taxonomie verte UE)', 'Part du CA provenant d''activités durables (taxonomie verte UE)', '%', 'calculé', 'Environnement', 'dernier_mois', 'annuelle'),
('PROJETS_INVESTISSEMENT', 'Projets d''investissement alignés sur les objectifs ESG', 'Projets d''investissement alignés sur les objectifs ESG', '%', 'calculé', 'Environnement', 'dernier_mois', 'annuelle'),
('DEPENSES_RD_DURABLES', 'Part des dépenses R&D orientées vers solutions durables', 'Part des dépenses R&D orientées vers solutions durables', '%', 'calculé', 'Environnement', 'dernier_mois', 'annuelle'),
('REMUNERATION_DIRIGEANTS', 'Rémunération des dirigeants liée aux objectifs de durabilité', 'Montant variable lié à des objectifs ESG/ Rémunération totale', '%', 'calculé', 'Social', 'dernier_mois', 'annuelle')
ON CONFLICT (code) DO NOTHING;

-- C3 - Instance de gouvernance
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES 
('MEMBRES_CONSEIL', 'Membres au Conseil d''Administration', 'Membres du Conseil d''Administration', 'Nombre', 'primaire', 'Gouvernance', 'dernier_mois', 'annuelle'),
('FEMMES_CONSEIL', 'Femmes dans le Conseil d''Administration', 'Femmes administratrices au Conseil d''Administration', 'Nombre', 'primaire', 'Gouvernance', 'dernier_mois', 'annuelle'),
('PART_FEMMES_CONSEIL', 'Part des femmes dans le Conseil d''Administration', 'Total des Femmes dans le Conseil d''Administration/ Total des Membres au Conseil d''Administration', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('MEMBRES_COMITE', 'Membres du Comité de Direction', 'Membres du Comité de Direction', 'Nombre', 'primaire', 'Gouvernance', 'dernier_mois', 'annuelle'),
('FEMMES_COMITE', 'Femme dans le Comité de Direction', 'Nombre de femme dans Comité de Direction (CODIR, COSIL)', 'Nombre', 'primaire', 'Gouvernance', 'dernier_mois', 'annuelle'),
('ACTIONS_NON_CONF_ENV', 'Actions d''identification des non-conformités environnementales', 'Audits, Evaluations, Inspections... effectués pour déterminer les non-conformités environnementales', 'Nombre', 'primaire', 'Environnement', 'somme', 'mensuelle'),
('ACTIONS_NON_CONF_SOC', 'Actions d''identification des non-conformités socio-économiques', 'Audits, Evaluations, Inspections... effectués pour déterminer les non-conformités sociales concernant les travailleurs et la chaîne de valeurs', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('DIAGNOSTICS_NON_CONF', 'Total des diagnostics menés pour détecter les non-conformités', 'Total des Diagnostics menés pour détecter les non-conformités environnementales et des diagnostics menés pour détecter les non-conformités socio-économiques', 'Nombre', 'calculé', 'Gouvernance', 'somme', 'mensuelle'),
('SITES_AUDIT_INTERNE', 'Sites ayant effectué un audit interne DD', 'Sites ayant effectué un auto-diagnostic RSE', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('PART_SITES_AUDIT', 'Part des sites ayant effectué un audit interne DD', 'Total des Sites ayant effectué un auto-diagnostic RSE / Total des Sites de production', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle')
ON CONFLICT (code) DO NOTHING;

-- G1 - Leadership et responsabilité
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES 
('SITES_ISO9001', 'Sites certifiés ISO 9001', 'Sites certifiés ISO 9001', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('PART_SITES_ISO9001', 'Part des sites certifiés ISO 9001', 'Total des Sites certifiés ISO 9001/ Total des Sites de production', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('SITES_ISO14001', 'Sites certifiés ISO 14001', 'Sites certifiés ISO 14001', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('PART_SITES_ISO14001', 'Part des sites certifiés ISO 14001', 'Sites certifiés ISO 14001/ Total des sites de production', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('SITES_ISO45001', 'Sites certifiés ISO 45001', 'Sites certifiés ISO 45001', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('PART_SITES_ISO45001', 'Part des sites certifiés ISO 45001', 'Sites certifiés ISO 45001/ Total des sites de production', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle')
ON CONFLICT (code) DO NOTHING;

-- G2 - Transparence et anti-corruption
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES 
('CONFLITS_INTERETS', 'Conflits d''intérêt déclarés', 'Situations où une personne est confrontée à choisir entre les exigences de sa profession/entreprise/fonction', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('CONDAMNATIONS_CORRUPTION', 'Nombre de condamnations pour violation des lois anti-corruption durant la période de reporting', 'Nombre de condamnations pour violation des lois anti-corruption durant la période de reporting', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('AMENDES_CORRUPTION', 'Montant total des amendes pour violation des lois anti-corruption durant la période de reporting', 'Montant total des amendes pour violation des lois anti-corruption durant la période de reporting', 'FCFA', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('CONSULTATIONS_FORMELLES', 'Nombre total de consultations / dialogues formels avec parties prenantes', 'Nombre total de consultations / dialogues formels avec parties prenantes', 'Nombre', 'primaire', 'Social', 'somme', 'annuelle'),
('TAUX_PARTICIPATION_PP', 'Taux de participation des parties prenantes invitées', 'Nombre de parties prénanates participant aux consultations / Nombre total de parties prénanates invitées', '%', 'calculé', 'Social', 'somme', 'annuelle')
ON CONFLICT (code) DO NOTHING;

-- G3 - Parties prenantes et matérialité
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES 
('RECOMMANDATIONS_PP', 'Part des recommandations / attentes intégrées dans la stratégie', 'Nombre de recommandations / attentes intégrées dans la stratégie/ Nombre total de recommandations / attentes', '%', 'calculé', 'Social', 'somme', 'annuelle'),
('PROJETS_COCONSTRUITS', 'Nombre de projets ou actions co-construits avec parties prenantes', 'Nombre de projets ou actions co-construits avec parties prenantes', 'Nombre', 'primaire', 'Social', 'somme', 'annuelle'),
('CONFLITS_LITIGES', 'Nombre de conflits ou litiges avec parties prenantes', 'Nombre de conflits ou litiges avec parties prenantes', 'Nombre', 'primaire', 'Social', 'somme', 'annuelle'),
('ENJEUX_STRATEGIQUES', 'Part d''enjeux intégrés aux objectifs stratégiques', 'Nombre d''enjeux intégrés aux objectifs stratégiques/ Nombre total d''enjeux de matérialités', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('REUNIONS_DURABILITE', 'Taux de réalisation des réunions du comité de durabilité', 'Nombre de réunions du comité de durabilité réalisées/ Nombre total de réunions du comité de durabilité prévues', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle')
ON CONFLICT (code) DO NOTHING;

-- G4 - Organisation et structure DD
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES 
('DECISIONS_ESG', 'Part des décisions stratégiques impliquant des critères ESG', 'Nombre de décisions stratégiques impliquant des critères ESG/ Nombre total de décisions stratégiques', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('ACTIONS_IRO', 'Taux de mise en œuvre des actions faces aux IRO', 'Nombre d''actions faces aux IRO mises en œuvre/ Nombre total d''actions faces aux IRO prévues', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('MARCHES_VERTS', 'Taux d''accès à de nouvelles opportunités de marchés verts', 'Nombre de nouvelles opportunités de marchés verts/ Nombre total d''opportunités de marché', '%', 'calculé', 'Environnement', 'somme', 'annuelle'),
('OBJECTIFS_ODD', 'Part des objectifs DD de l''entreprise alignés avec les ODD pertinents', 'Nombre d''objectifs DD de l''entreprise alignés avec les ODD pertinents/ Nombre total d''objectifs DD', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('CALENDRIER_ACTIONS', 'Taux de respect du calendrier de mise en œuvre des actions DD', 'Nombre de projets DD réalisés selon le planning initial/ Nombre total de projets DD réalisés selon le planning', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('OBJECTIFS_DD_ATTEINTS', 'Taux d''atteinte des objectifs DD', 'Nombre d''objectifs DD atteints dans le délai prévu/ Nombre total d''objectifs DD atteints', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle')
ON CONFLICT (code) DO NOTHING;

-- G5 - Mesure et collecte des données
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES 
('VERIFICATION_DONNEES', 'Taux de vérification des données collectées', 'Nombre de données auditées ou contrôlées/ total collecté', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('ERREURS_DONNEES', 'Taux d''erreurs détectées sur les données collectées', 'Nombre de données incorrectes ou manquantes après vérification/ Nombre total de données vérifiées', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('SITES_COLLECTE', 'Pourcentage de sites / filiales couverts par la collecte des données', 'Nombre total inclus dans la collecte de données DD/ Nombre total de site', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('PROCESSUS_COLLECTE', 'Pourcentage des postes / processus concernés par la collecte des données', 'Nombre de postes/ processus participant à la collecte/ Nombre total de postes/ processus', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('ACCESSIBILITE_DONNEES', 'Accessibilité des données aux parties prenantes internes', 'Nombre de données accessibles aux équipes concernées/ Nombre total de données', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('MAJ_DONNEES', 'Taux de mise à jour des données', 'Nombre de données mises à jour dans les délais prévus/ Nombre total de données mises à jour', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle')
ON CONFLICT (code) DO NOTHING;

-- S2 - Plaintes et réclamations
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES 
('PLAINTES_CLIENTS', 'Plaintes reçues des clients', 'Plaintes de clients reçues (enregistrées dans le système et communiquées lors de l''examen de la gestion de la qualité)', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('TRAITEMENT_PLAINTES', 'Taux de traitement des plaintes', 'Nombre de plaintes traitées dans les délais prévus/ Nombre total de plaintes traitées', '%', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('SATISFACTION_PLAIGNANTS', 'Taux de satisfaction des plaignants', 'Nombre de plaignants satisfaits du traitement (enquête ou feedback)/ Nombre total de plaintes traitées', '%', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('PLAINTES_COMPENSEES', 'Proportion des plaintes compensées', 'Nombre de plaintes ayant fait l''objet d''une compensation/ Nombre total de plainte traitées', '%', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('AMENDES_SANCTIONS', 'Nombre d''amendes ou sanctions reçues', 'Nombre d''amendes ou sanctions reçues', 'Nbre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('MONTANT_AMENDES', 'Montant total des amendes payées', 'Montant total des amendes payées', 'FCFA', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('PROCEDURES_COURS', 'Nombre de procédures en cours', 'Nombre de procédures en cours', 'Nbre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('MESURES_CORRECTIVES', 'Taux de mise en œuvre des mesures correctives après sanction', 'Nombre de mesures correctives après sanction mise en œuvres/ Nombre total de de mesures correctives planifiées', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle')
ON CONFLICT (code) DO NOTHING;

-- G6 - Diligence raisonnable
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES 
('FOURNISSEURS_DILIGENCE', 'Taux de fournisseurs évalués à une due diligence', 'Nombre de fournisseurs soumis à une due diligence environnementale, sociale ou de gouvernance/ Nombre total de fournisseurs', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('CONTROLES_INTERNES', 'Nombre de contrôles internes réalisés', 'Nombre de contrôles internes réalisés : audits, inspections ou vérifications documentées', 'Nbre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('CORRECTION_NON_CONF', 'Taux de correction des non-conformités', 'Nombre de non-conformités résolues dans le délai prévu/ Nombre total de non-conformités résolues', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle')
ON CONFLICT (code) DO NOTHING;

-- B2 - Finances et investissements
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES 
('BUDGET_PILOTAGE_DD', 'Budget alloué au pilotage DD', 'Valeur des dépenses affectées au développement du plan stratégique développement durable du Groupe', 'FCFA', 'primaire', 'Gouvernance', 'somme', 'annuelle')
ON CONFLICT (code) DO NOTHING;

-- S1 - Personnel de l'entreprise (Collaborateurs)
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES 
('COLLAB_CDI', 'Collaborateurs avec un contrat à durée indéterminée (CDI)', 'Collaborateurs à la fin d''année ayant un contrat de travail à durée indéterminée, pour un travail à temps plein ou à temps partiel', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('COLLAB_CDD', 'Collaborateurs avec un contrat à durée déterminée (CDD, CDDn)', 'Collaborateurs à la fin d''année ayant un contrat de travail, pour un travail à temps plein ou à temps partiel, qui prend fin à l''expiration d''une période déterminée ou à l''achèvement d''une tâche spécifique', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('TOTAL_COLLABORATEURS', 'Total des collaborateurs', 'Total des collaborateurs (CDI + CDD + CDDn)', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('PART_COLLAB_CDI', 'Part des collaborateurs possédant un contrat à durée indéterminée', 'Total des collaborateurs avec un contrat de travail à durée indéterminée/ Total des collaborateurs', '%', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('COLLAB_SOUS_TRAITANTS', 'Collaborateurs sous-traitants', 'Personnes qui effectuent un travail régulier sur place mais non considérées comme collaborateurs de SIPCA en vertu de la législation ou de la pratique nationale (par ex. contrat de travail)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('TOTAL_COLLAB_SOUS_TRAIT', 'Total des collaborateurs (Total des collaborateurs+collaborateurs sous-traitants)', 'Total des collaborateurs + collaborateurs Sous-traitants', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('COLLAB_FEMMES', 'Collaborateurs femmes', 'Employées femmes quel que soit leur contrat de travail (CDI, CDD, CDDn)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('COLLAB_HOMMES', 'Collaborateurs hommes', 'Employées hommes quel que soit leur contrat de travail (CDI, CDD, CDDn)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('OUVRIERS', 'Ouvriers', 'Ouvriers et main-d''œuvre dans la production (CDI, CDD, CDDn)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('EMPLOYES', 'Employés', 'Fonctions administratives et techniciens (CDI, CDD, CDDn)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('AGENTS_MAITRISE', 'Agents de maîtrise', 'Agents de maîtrise (CDI, CDD, CDDn)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('CADRES', 'Cadres', 'Cadres (CDI, CDD, CDDn)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle')
ON CONFLICT (code) DO NOTHING;

-- S1 - Personnel par genre et catégorie
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES 
('FEMMES_OUVRIERES', 'Femmes ouvrières', 'Femmes ouvrières (CDI, CDD, CDDn)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('FEMMES_EMPLOYEES', 'Femmes employés', 'Femmes employées administratif et techniciens (CDI, CDD, CDDn)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('FEMMES_AGENTS_MAITRISE', 'Femmes agents de maîtrise', 'Femmes agents de maîtrise (CDI, CDD, CDDn)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('FEMMES_CADRES', 'Femmes cadres', 'Femmes cadres (CDI, CDD, CDDn)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('HOMMES_OUVRIERS', 'Hommes ouvriers', 'Hommes ouvriers', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('HOMMES_EMPLOYEES', 'Hommes employés', 'Hommes employés administratif et techniciens', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('HOMMES_AGENTS_MAITRISE', 'Hommes agents de maîtrise', 'Hommes agents de maîtrise', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('HOMMES_CADRES', 'Hommes cadres', 'Hommes cadres', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle')
ON CONFLICT (code) DO NOTHING;

-- S1 - Embauches par tranche d'âge
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES 
('COLLAB_30_ANS', 'Collaborateurs dont l''âge ≤ 30 ans', 'Employées âge inférieur à 30 ans (CDI, CDD, CDDn)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('COLLAB_30_50_ANS', 'Collaborateurs dont l''âge >= 30 et <= 50 ans', 'Employées âge supérieur ou égal à 30 ans et inférieur ou égal à 50 ans (CDI, CDD, CDDn)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('COLLAB_50_ANS', 'Collaborateurs dont l''âge > 50 ans', 'Employées âge supérieur à 50 ans (CDI, CDD, CDDn)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('FEMMES_30_ANS', 'Femmes dont l''âge ≤ 30 ans', 'Femmes âge inférieur à 30 ans (CDI, CDD, CDDn)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('FEMMES_30_50_ANS', 'Femmes dont l''âge >= 30 et <= 50 ans', 'Femmes âge supérieur ou égal à 30 ans et inférieur ou égal à 30 ans (CDI, CDD, CDDn)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('FEMMES_50_ANS', 'Femmes dont l''âge > 50 ans', 'Femmes âge supérieur à 50 ans (CDI, CDD, CDDn)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('HOMMES_30_ANS', 'Hommes dont l''âge ≤ 30 ans', 'Hommes dont l''âge ≤ 30 ans', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('HOMMES_30_50_ANS', 'Hommes dont l''âge >= 30 et <= 50 ans', 'Hommes dont l''âge >= 30 et <=50 ans', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('HOMMES_50_ANS', 'Hommes dont l''âge > 50 ans', 'Hommes dont l''âge > 50 ans', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle')
ON CONFLICT (code) DO NOTHING;

-- S1 - Embauches de l'année
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES 
('EMBAUCHES_30_ANS', 'Embauches de l''année dont l''âge ≤ 30 ans', 'Embauches - nouveaux collaborateurs dont l''âge ≤ 30 ans (possédant un contrat CDI ou CDD) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('EMBAUCHES_30_50_ANS', 'Embauches de l''année dont l''âge >= 30 et <= 50 ans', 'Embauches - nouveaux collaborateurs dont l''âge >= 30 et <= 50 ans (possédant un contrat CDI ou CDD) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('EMBAUCHES_50_ANS', 'Embauches de l''année dont l''âge > 50 ans', 'Embauches - nouveaux collaborateurs dont l''âge > 50 ans (possédant un contrat CDI ou CDD) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('MOBILITE_INTERNE', 'Mobilité interne', 'Arrivée d''un autre site ou d''une autre filiale pour raison de Mobilité', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('EMBAUCHES_FEMMES_30', 'Embauches de l''année femmes dont l''âge ≤ 30 ans', 'Embauches - nouveaux collaborateurs femmes dont l''âge ≤ 30 ans (possédant un contrat CDI ou CDD) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('EMBAUCHES_FEMMES_30_50', 'Embauches de l''année femmes dont l''âge >= 30 et <= 50 ans', 'Embauches - nouveaux collaborateurs femmes ayant un âge >= 30 et <= 50 ans (possédant un contrat CDI ou CDD) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('EMBAUCHES_FEMMES_50', 'Embauches de l''année femmes dont l''âge > 50 ans', 'Embauches - nouveaux collaborateurs femmes dont l''âge > 50 ans (possédant un contrat CDI ou CDD) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('TOTAL_EMBAUCHES_FEMMES', 'Total des embauches de l''année pour les femmes', 'Total des embauches de l''année femmes par classe d''âge', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('EMBAUCHES_HOMMES_30', 'Embauches de l''année hommes dont l''âge ≤ 30 ans', 'Embauches - nouveaux collaborateurs hommes dont l''âge ≤ 30 ans (possédant un contrat CDI ou CDD) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('EMBAUCHES_HOMMES_30_50', 'Embauches de l''année hommes dont l''âge >= 30 et <= 50 ans', 'Embauches - nouveaux collaborateurs hommes ayant un âge >= 30 et <= 50 ans (possédant un contrat CDI ou CDD) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('EMBAUCHES_HOMMES_50', 'Embauches de l''année hommes dont l''âge > 50 ans', 'Embauches - nouveaux collaborateurs hommes dont l''âge > 50 ans (possédant un contrat CDI ou CDD) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('TOTAL_EMBAUCHES_HOMMES', 'Total des embauches de l''année pour les hommes', 'Total des embauches de l''année hommes par classe d''âge', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('TOTAL_EMBAUCHES', 'Total des embauches de l''année', 'Embauches de l''année hommes et femmes', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('TOTAL_ENTREES', 'Total des entrées de l''année', 'Total des entrées + Total des embauches + mobilité interne', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle')
ON CONFLICT (code) DO NOTHING;

-- S1 - Départs et sorties
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES 
('DEMISSIONS_OUVRIERS', 'Démissions ouvrières', 'Démissions ouvrières', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('DEMISSIONS_EMPLOYES', 'Démissions employés', 'Démissions employés administratif et techniciens', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('DEMISSIONS_AGENTS', 'Démissions agents de maîtrise', 'Démissions agents de maîtrise', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('DEMISSIONS_CADRES', 'Démissions cadres', 'Démissions cadres', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('TOTAL_DEMISSIONS', 'Total des démissions', 'Total des démissions', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('RETRAITE_NORMALE', 'Retraite (anticipée, raison médicale, date normale)', 'Départs pour raison de Retraite (anticipée, raison médicale, date normale)', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('DEPARTS_NEGOCIES', 'Départs négociés', 'Départs pour raison de Départs négociés', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('LICENCIEMENTS', 'Licenciements (économiques, faute grave,...)', 'Départs pour raison de Licenciements économiques ou fautes', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('ABANDON_POSTES', 'Abandon de postes', 'Départs pour raison de Abandon de postes', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('DEPARTS_FIN_CDD', 'Départs liés à une fin de contrat CDD', 'Départs liés à une fin de contrat CDD', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('DECES', 'Décès', 'Départs pour raison de Décès', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('TOTAL_DEPARTS', 'Total des départs de l''année', 'Total des départs de l''année', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('DEPARTS_HOMMES', 'Total départ collaborateurs hommes', 'Nombres d''hommes en CDI/CDD ayant quitté leur emploi, volontairement ou non durant l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('DEPARTS_FEMMES', 'Total départ collaborateurs femmes', 'Nombres de femmes en CDI/CDD ayant quitté leur emploi, volontairement ou non durant l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle')
ON CONFLICT (code) DO NOTHING;

-- S1 - Mobilité et turnover
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES 
('MOBILITE_EXTERNE', 'Mobilité externe', 'Départs pour raison de Mobilité sur un autre site ou filiales', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('TOTAL_SORTIES', 'Total des sorties de l''année', 'Total des sorties = Total des départs de l''année + Mobilité externe', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('TURNOVER_HOMMES', 'Turnover Hommes', 'Total des Employées hommes ayant quitté l''organisation au cours de l''année/ Total des employées hommes', 'Ratio', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('TURNOVER_FEMMES', 'Turnover Femmes', 'Total des Employées femmes ayant quitté l''organisation au cours de l''année/ Total des employées femmes', 'Ratio', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('INCIDENTS_CHAINE_VALEUR', 'Nombre d''incidents majeurs dans la chaîne de valeur affectant la production ou la livraison', 'Nombre d''incidents majeurs dans la chaîne de valeur affectant la production ou la livraison', 'Nbre', 'primaire', 'Social', 'somme', 'mensuelle'),
('PLANS_MITIGATION', 'Nombre de plans de mitigation des risques de rupture de la chaîne de valeur mis en place', 'Nombre de plans de mitigation des risques de rupture de la chaîne de valeur mis en place', 'Nbre', 'primaire', 'Social', 'somme', 'mensuelle')
ON CONFLICT (code) DO NOTHING;

-- B10 - Rémunération et négociation collective
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES 
('SALAIRE_ENTREE_GROUPE', 'Salaire d''entrée dans le Groupe', 'Salaire d''embauche le plus bas dans le Groupe SIPCA (annuel)', 'FCFA', 'primaire', 'Social', 'moyenne', 'annuelle'),
('SALAIRE_MINIMUM_LOCAL', 'Salaire minimum légal et local', 'Salaire minimum local selon la réglementation (annuel)', 'FCFA', 'primaire', 'Social', 'moyenne', 'annuelle'),
('SALAIRE_ENTREE_VS_LOCAL', 'Salaire d''entrée comparé au salaire local', 'Ratio du salaire d''entrée standard par pays, par rapport au salaire minimum local applicable dans ce pays', 'Ratio', 'calculé', 'Social', 'moyenne', 'annuelle'),
('REMUNERATION_HOMMES', 'Rémunération totale - Hommes', 'Total annuel de la rémunération versée aux hommes', 'FCFA', 'primaire', 'Social', 'somme', 'annuelle'),
('REMUNERATION_FEMMES', 'Rémunération totale - Femmes', 'Total annuel de la rémunération versée aux femmes', 'FCFA', 'primaire', 'Social', 'somme', 'annuelle'),
('TOTAL_REMUNERATIONS', 'TOTAL Rémunérations - Hommes+Femmes', 'Total annuel de la rémunération versée aux hommes et aux femmes', 'FCFA', 'calculé', 'Social', 'somme', 'annuelle'),
('RATIO_REMUNERATION', 'Ratio Rémunération / Chiffre d''affaires', 'Total Rémunération annuelle Hommes + Femmes / 1000 / Chiffre d''affaires', 'FCFA', 'calculé', 'Social', 'moyenne', 'annuelle'),
('TAUX_CROISSANCE_REM', 'Taux de croissance de la Rémunération', 'Taux de croissance de la Rémunération', 'FCFA', 'calculé', 'Social', 'moyenne', 'annuelle'),
('REM_MOYENNE_HOMME', 'Rémunération annuelle moyenne - Homme', 'Rémunération annuelle moyenne par homme', 'FCFA', 'calculé', 'Social', 'moyenne', 'annuelle'),
('REM_MOYENNE_FEMME', 'Rémunération annuelle moyenne - Femme', 'Rémunération annuelle moyenne par femme', 'FCFA', 'calculé', 'Social', 'moyenne', 'annuelle'),
('REM_MOYENNE_TOTAL', 'Rémunération annuelle moyenne - Total collaborateur', 'Rémunération annuelle moyenne par collaborateur', 'FCFA', 'calculé', 'Social', 'moyenne', 'annuelle'),
('EGALITE_SALARIALE', 'Égalité salariale entre les hommes et les femmes TOUTES CATÉGORIES', 'Ratio entre la rémunération annuelle moyenne des femmes et la rémunération annuelle moyenne des femmes', 'Ratio', 'calculé', 'Social', 'moyenne', 'annuelle')
ON CONFLICT (code) DO NOTHING;

-- 6. RELATIONS SECTEUR-STANDARDS
INSERT INTO sector_standards (sector_name, standard_codes) VALUES 
('Services ESG', ARRAY['ISO26000', 'CSRD', 'GRI', 'ISO14001', 'ISO45001'])
ON CONFLICT (sector_name) DO UPDATE SET standard_codes = EXCLUDED.standard_codes;

-- 7. RELATIONS SECTEUR-ENJEUX
INSERT INTO sector_standards_issues (sector_name, standard_name, issue_codes) VALUES 
('Services ESG', 'ISO26000', ARRAY['B1', 'C1', 'C3', 'S1', 'B10']),
('Services ESG', 'CSRD', ARRAY['B1', 'C1', 'C3', 'S1', 'B10', 'G1', 'G2', 'G3']),
('Services ESG', 'GRI', ARRAY['B1', 'C1', 'C3', 'S1', 'B10', 'G1', 'G2', 'G3', 'G4', 'G5']),
('Services ESG', 'ISO14001', ARRAY['G1', 'G5']),
('Services ESG', 'ISO45001', ARRAY['S1', 'S2'])
ON CONFLICT (sector_name, standard_name) DO UPDATE SET issue_codes = EXCLUDED.issue_codes;

-- 8. RELATIONS ENJEUX-CRITÈRES
INSERT INTO sector_standards_issues_criteria (sector_name, standard_name, issue_name, criteria_codes) VALUES 
('Services ESG', 'ISO26000', 'Informations générales', ARRAY['CARACT_ENT', 'TYPE_RAPPORT', 'LABELS_ESG', 'PRODUITS_SERVICES', 'MARCHES_IMP']),
('Services ESG', 'CSRD', 'Stratégie et modèle d''affaires', ARRAY['REL_COMMERCIALES', 'STRAT_AFFAIRE']),
('Services ESG', 'GRI', 'Instance de gouvernance', ARRAY['INSTANCE_GOUV']),
('Services ESG', 'ISO26000', 'Leadership et responsabilité', ARRAY['POLITIQUE_CHARTE']),
('Services ESG', 'CSRD', 'Transparence et anti-corruption', ARRAY['TRANSPARENCE', 'CONDAMNATIONS']),
('Services ESG', 'GRI', 'Parties prenantes et matérialité', ARRAY['PARTIES_PRENANTES', 'ENJEUX_MAT']),
('Services ESG', 'ISO26000', 'Organisation et structure DD', ARRAY['ORG_STRUCTURE', 'IRO']),
('Services ESG', 'CSRD', 'Mesure et collecte des données', ARRAY['MESURE_DONNEES']),
('Services ESG', 'GRI', 'Plaintes et réclamations', ARRAY['PLAINTES_RECL']),
('Services ESG', 'ISO26000', 'Diligence raisonnable', ARRAY['DILIGENCE', 'CONFORMITE']),
('Services ESG', 'CSRD', 'Finances et investissements', ARRAY['FINANCES']),
('Services ESG', 'GRI', 'Emplois et main d''œuvre', ARRAY['PERSONNEL']),
('Services ESG', 'ISO45001', 'Continuité d''activité', ARRAY['CONTINUITE']),
('Services ESG', 'GRI', 'Rémunération et négociation collective', ARRAY['PERSONNEL'])
ON CONFLICT (sector_name, standard_name) DO UPDATE SET criteria_codes = EXCLUDED.criteria_codes;

-- 9. RELATIONS CRITÈRES-INDICATEURS
INSERT INTO sector_standards_issues_criteria_indicators (sector_name, standard_name, issue_name, criteria_name, indicator_codes, unit) VALUES 
('Services ESG', 'ISO26000', 'Informations générales', 'Caractéristiques de l''entreprise', ARRAY['CA_TOTAL', 'SITES_TOTAL', 'FOURNISSEURS', 'AIDE_FINANCIERE', 'IMPOTS_TAXES'], ''),
('Services ESG', 'ISO26000', 'Informations générales', 'Type de rapport', ARRAY['TYPES_RAPPORTS', 'TAUX_FINALISATION'], ''),
('Services ESG', 'ISO26000', 'Informations générales', 'Labels ESG obtenus', ARRAY['LABELS_ESG', 'PRODUITS_TAXONOMIE'], ''),
('Services ESG', 'ISO26000', 'Informations générales', 'Produits/Services', ARRAY['CA_GEOGRAPHIQUE', 'FOURNISSEURS_DIRECTS'], ''),
('Services ESG', 'ISO26000', 'Informations générales', 'Marchés importants', ARRAY['ACHATS_STRATEGIQUES', 'ACHATS_REALISES', 'CA_ACHATS', 'ACHATS_NATIONAUX'], ''),
('Services ESG', 'CSRD', 'Stratégie et modèle d''affaires', 'Relations commerciales', ARRAY['ACHATS_LOCAUX', 'FOURNISSEURS_ESG', 'INTEGRATION_ESG', 'ACHATS_LOCAUX_REG', 'FOURNISSEURS_EVALUES', 'AUDITS_ESG', 'CONFORMITE_FOURNISSEURS', 'RESILIATIONS_NON_CONF'], ''),
('Services ESG', 'CSRD', 'Stratégie et modèle d''affaires', 'Stratégie d''affaire affectant les questions de durabilité', ARRAY['CA_ACTIVITES_DURABLES', 'PROJETS_INVESTISSEMENT', 'DEPENSES_RD_DURABLES', 'REMUNERATION_DIRIGEANTS'], ''),
('Services ESG', 'GRI', 'Instance de gouvernance', 'Instance de gouvernance', ARRAY['MEMBRES_CONSEIL', 'FEMMES_CONSEIL', 'PART_FEMMES_CONSEIL', 'MEMBRES_COMITE', 'FEMMES_COMITE', 'ACTIONS_NON_CONF_ENV', 'ACTIONS_NON_CONF_SOC', 'DIAGNOSTICS_NON_CONF', 'SITES_AUDIT_INTERNE', 'PART_SITES_AUDIT'], ''),
('Services ESG', 'ISO26000', 'Leadership et responsabilité', 'Politique et charte', ARRAY['SITES_ISO9001', 'PART_SITES_ISO9001', 'SITES_ISO14001', 'PART_SITES_ISO14001', 'SITES_ISO45001', 'PART_SITES_ISO45001'], ''),
('Services ESG', 'CSRD', 'Transparence et anti-corruption', 'Transparence et anti-corruption', ARRAY['CONFLITS_INTERETS'], ''),
('Services ESG', 'CSRD', 'Transparence et anti-corruption', 'Condamnations et amendes', ARRAY['CONDAMNATIONS_CORRUPTION', 'AMENDES_CORRUPTION'], ''),
('Services ESG', 'GRI', 'Parties prenantes et matérialité', 'Parties prenantes (attentes, dialogue)', ARRAY['CONSULTATIONS_FORMELLES', 'TAUX_PARTICIPATION_PP', 'RECOMMANDATIONS_PP', 'PROJETS_COCONSTRUITS', 'CONFLITS_LITIGES'], ''),
('Services ESG', 'GRI', 'Parties prenantes et matérialité', 'Enjeux et matérialités', ARRAY['ENJEUX_STRATEGIQUES'], ''),
('Services ESG', 'ISO26000', 'Organisation et structure DD', 'Organisation et structure DD', ARRAY['REUNIONS_DURABILITE', 'DECISIONS_ESG'], ''),
('Services ESG', 'ISO26000', 'Organisation et structure DD', 'IRO', ARRAY['ACTIONS_IRO', 'MARCHES_VERTS', 'OBJECTIFS_ODD', 'CALENDRIER_ACTIONS', 'OBJECTIFS_DD_ATTEINTS'], ''),
('Services ESG', 'CSRD', 'Mesure et collecte des données', 'Mesure et collecte des données', ARRAY['VERIFICATION_DONNEES', 'ERREURS_DONNEES', 'SITES_COLLECTE', 'PROCESSUS_COLLECTE', 'ACCESSIBILITE_DONNEES', 'MAJ_DONNEES'], ''),
('Services ESG', 'GRI', 'Plaintes et réclamations', 'Plaintes et réclamations', ARRAY['PLAINTES_CLIENTS', 'TRAITEMENT_PLAINTES', 'SATISFACTION_PLAIGNANTS', 'PLAINTES_COMPENSEES', 'AMENDES_SANCTIONS', 'MONTANT_AMENDES', 'PROCEDURES_COURS', 'MESURES_CORRECTIVES'], ''),
('Services ESG', 'ISO26000', 'Diligence raisonnable', 'Diligence raisonnable', ARRAY['FOURNISSEURS_DILIGENCE'], ''),
('Services ESG', 'ISO26000', 'Diligence raisonnable', 'Conformité et certification', ARRAY['CONTROLES_INTERNES', 'CORRECTION_NON_CONF'], ''),
('Services ESG', 'CSRD', 'Finances et investissements', 'Finances et investissements', ARRAY['BUDGET_PILOTAGE_DD'], ''),
('Services ESG', 'GRI', 'Emplois et main d''œuvre', 'Personnel de l''entreprise, emploi, dialogue social et liberté d''association', ARRAY['COLLAB_CDI', 'COLLAB_CDD', 'TOTAL_COLLABORATEURS', 'PART_COLLAB_CDI', 'COLLAB_SOUS_TRAITANTS', 'TOTAL_COLLAB_SOUS_TRAIT', 'COLLAB_FEMMES', 'COLLAB_HOMMES', 'OUVRIERS', 'EMPLOYES', 'AGENTS_MAITRISE', 'CADRES', 'FEMMES_OUVRIERES', 'FEMMES_EMPLOYEES', 'FEMMES_AGENTS_MAITRISE', 'FEMMES_CADRES', 'HOMMES_OUVRIERS', 'HOMMES_EMPLOYEES', 'HOMMES_AGENTS_MAITRISE', 'HOMMES_CADRES', 'COLLAB_30_ANS', 'COLLAB_30_50_ANS', 'COLLAB_50_ANS', 'FEMMES_30_ANS', 'FEMMES_30_50_ANS', 'FEMMES_50_ANS', 'HOMMES_30_ANS', 'HOMMES_30_50_ANS', 'HOMMES_50_ANS', 'EMBAUCHES_30_ANS', 'EMBAUCHES_30_50_ANS', 'EMBAUCHES_50_ANS', 'MOBILITE_INTERNE', 'EMBAUCHES_FEMMES_30', 'EMBAUCHES_FEMMES_30_50', 'EMBAUCHES_FEMMES_50', 'TOTAL_EMBAUCHES_FEMMES', 'EMBAUCHES_HOMMES_30', 'EMBAUCHES_HOMMES_30_50', 'EMBAUCHES_HOMMES_50', 'TOTAL_EMBAUCHES_HOMMES', 'TOTAL_EMBAUCHES', 'TOTAL_ENTREES', 'DEMISSIONS_OUVRIERS', 'DEMISSIONS_EMPLOYES', 'DEMISSIONS_AGENTS', 'DEMISSIONS_CADRES', 'TOTAL_DEMISSIONS', 'RETRAITE_NORMALE', 'DEPARTS_NEGOCIES', 'LICENCIEMENTS', 'ABANDON_POSTES', 'DEPARTS_FIN_CDD', 'DECES', 'TOTAL_DEPARTS', 'DEPARTS_HOMMES', 'DEPARTS_FEMMES', 'MOBILITE_EXTERNE', 'TOTAL_SORTIES', 'TURNOVER_HOMMES', 'TURNOVER_FEMMES', 'INCIDENTS_CHAINE_VALEUR', 'PLANS_MITIGATION'], ''),
('Services ESG', 'ISO45001', 'Continuité d''activité', 'Continuité d''activité', ARRAY['INCIDENTS_CHAINE_VALEUR', 'PLANS_MITIGATION'], ''),
('Services ESG', 'GRI', 'Rémunération et négociation collective', 'Personnel de l''entreprise, emploi, dialogue social et liberté d''association', ARRAY['SALAIRE_ENTREE_GROUPE', 'SALAIRE_MINIMUM_LOCAL', 'SALAIRE_ENTREE_VS_LOCAL', 'REMUNERATION_HOMMES', 'REMUNERATION_FEMMES', 'TOTAL_REMUNERATIONS', 'RATIO_REMUNERATION', 'TAUX_CROISSANCE_REM', 'REM_MOYENNE_HOMME', 'REM_MOYENNE_FEMME', 'REM_MOYENNE_TOTAL', 'EGALITE_SALARIALE'], '')
ON CONFLICT (sector_name, standard_name) DO UPDATE SET criteria_codes = EXCLUDED.criteria_codes;

-- 10. PROCESSUS MÉTIER
INSERT INTO processes (code, name, description, indicator_codes, organization_name) VALUES 
('INFO_GEN', 'Informations Générales', 'Collecte des informations générales de l''entreprise', ARRAY['CA_TOTAL', 'SITES_TOTAL', 'FOURNISSEURS', 'AIDE_FINANCIERE', 'IMPOTS_TAXES', 'TYPES_RAPPORTS', 'TAUX_FINALISATION', 'LABELS_ESG', 'PRODUITS_TAXONOMIE', 'CA_GEOGRAPHIQUE', 'FOURNISSEURS_DIRECTS', 'ACHATS_STRATEGIQUES', 'ACHATS_REALISES', 'CA_ACHATS', 'ACHATS_NATIONAUX'], 'GROUPE VISION DURABLE'),
('STRATEGIE', 'Stratégie et Modèle d''Affaires', 'Suivi de la stratégie et du modèle d''affaires durable', ARRAY['ACHATS_LOCAUX', 'FOURNISSEURS_ESG', 'INTEGRATION_ESG', 'ACHATS_LOCAUX_REG', 'FOURNISSEURS_EVALUES', 'AUDITS_ESG', 'CONFORMITE_FOURNISSEURS', 'RESILIATIONS_NON_CONF', 'CA_ACTIVITES_DURABLES', 'PROJETS_INVESTISSEMENT', 'DEPENSES_RD_DURABLES', 'REMUNERATION_DIRIGEANTS'], 'GROUPE VISION DURABLE'),
('GOUVERNANCE', 'Instance de Gouvernance', 'Suivi de la gouvernance et des instances de direction', ARRAY['MEMBRES_CONSEIL', 'FEMMES_CONSEIL', 'PART_FEMMES_CONSEIL', 'MEMBRES_COMITE', 'FEMMES_COMITE', 'ACTIONS_NON_CONF_ENV', 'ACTIONS_NON_CONF_SOC', 'DIAGNOSTICS_NON_CONF', 'SITES_AUDIT_INTERNE', 'PART_SITES_AUDIT', 'SITES_ISO9001', 'PART_SITES_ISO9001', 'SITES_ISO14001', 'PART_SITES_ISO14001', 'SITES_ISO45001', 'PART_SITES_ISO45001', 'CONFLITS_INTERETS', 'CONDAMNATIONS_CORRUPTION', 'AMENDES_CORRUPTION'], 'GROUPE VISION DURABLE'),
('RH_SOCIAL', 'Ressources Humaines et Social', 'Gestion des ressources humaines et aspects sociaux', ARRAY['COLLAB_CDI', 'COLLAB_CDD', 'TOTAL_COLLABORATEURS', 'PART_COLLAB_CDI', 'COLLAB_SOUS_TRAITANTS', 'TOTAL_COLLAB_SOUS_TRAIT', 'COLLAB_FEMMES', 'COLLAB_HOMMES', 'OUVRIERS', 'EMPLOYES', 'AGENTS_MAITRISE', 'CADRES', 'FEMMES_OUVRIERES', 'FEMMES_EMPLOYEES', 'FEMMES_AGENTS_MAITRISE', 'FEMMES_CADRES', 'HOMMES_OUVRIERS', 'HOMMES_EMPLOYEES', 'HOMMES_AGENTS_MAITRISE', 'HOMMES_CADRES', 'COLLAB_30_ANS', 'COLLAB_30_50_ANS', 'COLLAB_50_ANS', 'FEMMES_30_ANS', 'FEMMES_30_50_ANS', 'FEMMES_50_ANS', 'HOMMES_30_ANS', 'HOMMES_30_50_ANS', 'HOMMES_50_ANS', 'EMBAUCHES_30_ANS', 'EMBAUCHES_30_50_ANS', 'EMBAUCHES_50_ANS', 'MOBILITE_INTERNE', 'EMBAUCHES_FEMMES_30', 'EMBAUCHES_FEMMES_30_50', 'EMBAUCHES_FEMMES_50', 'TOTAL_EMBAUCHES_FEMMES', 'EMBAUCHES_HOMMES_30', 'EMBAUCHES_HOMMES_30_50', 'EMBAUCHES_HOMMES_50', 'TOTAL_EMBAUCHES_HOMMES', 'TOTAL_EMBAUCHES', 'TOTAL_ENTREES', 'DEMISSIONS_OUVRIERS', 'DEMISSIONS_EMPLOYES', 'DEMISSIONS_AGENTS', 'DEMISSIONS_CADRES', 'TOTAL_DEMISSIONS', 'RETRAITE_NORMALE', 'DEPARTS_NEGOCIES', 'LICENCIEMENTS', 'ABANDON_POSTES', 'DEPARTS_FIN_CDD', 'DECES', 'TOTAL_DEPARTS', 'DEPARTS_HOMMES', 'DEPARTS_FEMMES', 'MOBILITE_EXTERNE', 'TOTAL_SORTIES', 'TURNOVER_HOMMES', 'TURNOVER_FEMMES', 'INCIDENTS_CHAINE_VALEUR', 'PLANS_MITIGATION', 'CONSULTATIONS_FORMELLES', 'TAUX_PARTICIPATION_PP', 'RECOMMANDATIONS_PP', 'PROJETS_COCONSTRUITS', 'CONFLITS_LITIGES', 'PLAINTES_CLIENTS', 'TRAITEMENT_PLAINTES', 'SATISFACTION_PLAIGNANTS', 'PLAINTES_COMPENSEES', 'AMENDES_SANCTIONS', 'MONTANT_AMENDES', 'PROCEDURES_COURS', 'MESURES_CORRECTIVES'], ''),
('Services ESG', 'GRI', 'Rémunération et négociation collective', 'Personnel de l''entreprise, emploi, dialogue social et liberté d''association', ARRAY['SALAIRE_ENTREE_GROUPE', 'SALAIRE_MINIMUM_LOCAL', 'SALAIRE_ENTREE_VS_LOCAL', 'REMUNERATION_HOMMES', 'REMUNERATION_FEMMES', 'TOTAL_REMUNERATIONS', 'RATIO_REMUNERATION', 'TAUX_CROISSANCE_REM', 'REM_MOYENNE_HOMME', 'REM_MOYENNE_FEMME', 'REM_MOYENNE_TOTAL', 'EGALITE_SALARIALE'], '')
ON CONFLICT (sector_name, standard_name, issue_name, criteria_name) DO UPDATE SET indicator_codes = EXCLUDED.indicator_codes;

-- 11. CONFIGURATION ORGANISATION
INSERT INTO organization_sectors (organization_name, sector_name, subsector_name) VALUES 
('GROUPE VISION DURABLE', 'Services ESG', 'Conseil et Audit ESG')
ON CONFLICT (organization_name) DO UPDATE SET 
  sector_name = EXCLUDED.sector_name,
  subsector_name = EXCLUDED.subsector_name;

INSERT INTO organization_standards (organization_name, standard_codes) VALUES 
('GROUPE VISION DURABLE', ARRAY['ISO26000', 'CSRD', 'GRI', 'ISO14001', 'ISO45001'])
ON CONFLICT (organization_name) DO UPDATE SET standard_codes = EXCLUDED.standard_codes;

INSERT INTO organization_issues (organization_name, issue_codes) VALUES 
('GROUPE VISION DURABLE', ARRAY['B1', 'C1', 'C3', 'S1', 'B10', 'G1', 'G2', 'G3', 'G4', 'G5', 'S2', 'G6', 'B2', 'S3'])
ON CONFLICT (organization_name) DO UPDATE SET issue_codes = EXCLUDED.issue_codes;

INSERT INTO organization_criteria (organization_name, criteria_codes) VALUES 
('GROUPE VISION DURABLE', ARRAY['CARACT_ENT', 'TYPE_RAPPORT', 'LABELS_ESG', 'PRODUITS_SERVICES', 'MARCHES_IMP', 'REL_COMMERCIALES', 'STRAT_AFFAIRE', 'INSTANCE_GOUV', 'POLITIQUE_CHARTE', 'TRANSPARENCE', 'CONDAMNATIONS', 'PARTIES_PRENANTES', 'ENJEUX_MAT', 'ORG_STRUCTURE', 'IRO', 'MESURE_DONNEES', 'PLAINTES_RECL', 'DILIGENCE', 'CONFORMITE', 'FINANCES', 'PERSONNEL', 'CONTINUITE'])
ON CONFLICT (organization_name) DO UPDATE SET criteria_codes = EXCLUDED.criteria_codes;

-- Récupérer tous les codes d'indicateurs
DO $$
DECLARE
    all_indicator_codes text[];
BEGIN
    SELECT array_agg(code) INTO all_indicator_codes FROM indicators WHERE code LIKE 'CA_TOTAL' OR code LIKE 'SITES_%' OR code LIKE 'FOURNISSEURS%' OR code LIKE 'AIDE_%' OR code LIKE 'IMPOTS_%' OR code LIKE 'TYPES_%' OR code LIKE 'TAUX_%' OR code LIKE 'LABELS_%' OR code LIKE 'PRODUITS_%' OR code LIKE 'CA_%' OR code LIKE 'ACHATS_%' OR code LIKE 'INTEGRATION_%' OR code LIKE 'AUDITS_%' OR code LIKE 'CONFORMITE_%' OR code LIKE 'RESILIATIONS_%' OR code LIKE 'PROJETS_%' OR code LIKE 'DEPENSES_%' OR code LIKE 'REMUNERATION_%' OR code LIKE 'MEMBRES_%' OR code LIKE 'FEMMES_%' OR code LIKE 'PART_%' OR code LIKE 'ACTIONS_%' OR code LIKE 'DIAGNOSTICS_%' OR code LIKE 'SITES_%' OR code LIKE 'CONFLITS_%' OR code LIKE 'CONDAMNATIONS_%' OR code LIKE 'AMENDES_%' OR code LIKE 'CONSULTATIONS_%' OR code LIKE 'RECOMMANDATIONS_%' OR code LIKE 'PROJETS_%' OR code LIKE 'ENJEUX_%' OR code LIKE 'REUNIONS_%' OR code LIKE 'DECISIONS_%' OR code LIKE 'MARCHES_%' OR code LIKE 'OBJECTIFS_%' OR code LIKE 'CALENDRIER_%' OR code LIKE 'VERIFICATION_%' OR code LIKE 'ERREURS_%' OR code LIKE 'PROCESSUS_%' OR code LIKE 'ACCESSIBILITE_%' OR code LIKE 'MAJ_%' OR code LIKE 'PLAINTES_%' OR code LIKE 'TRAITEMENT_%' OR code LIKE 'SATISFACTION_%' OR code LIKE 'MESURES_%' OR code LIKE 'DILIGENCE_%' OR code LIKE 'CONTROLES_%' OR code LIKE 'CORRECTION_%' OR code LIKE 'BUDGET_%' OR code LIKE 'COLLAB_%' OR code LIKE 'TOTAL_%' OR code LIKE 'OUVRIERS' OR code LIKE 'EMPLOYES' OR code LIKE 'AGENTS_%' OR code LIKE 'CADRES' OR code LIKE 'HOMMES_%' OR code LIKE 'EMBAUCHES_%' OR code LIKE 'MOBILITE_%' OR code LIKE 'DEMISSIONS_%' OR code LIKE 'RETRAITE_%' OR code LIKE 'DEPARTS_%' OR code LIKE 'LICENCIEMENTS' OR code LIKE 'ABANDON_%' OR code LIKE 'DECES' OR code LIKE 'TURNOVER_%' OR code LIKE 'INCIDENTS_%' OR code LIKE 'PLANS_%' OR code LIKE 'SALAIRE_%' OR code LIKE 'REM_%' OR code LIKE 'EGALITE_%';
    
    INSERT INTO organization_indicators (organization_name, indicator_codes) VALUES 
    ('GROUPE VISION DURABLE', all_indicator_codes)
    ON CONFLICT (organization_name) DO UPDATE SET indicator_codes = EXCLUDED.indicator_codes;
END $$;

-- 12. DONNÉES D'EXEMPLE POUR TESTS
INSERT INTO indicator_values (
  organization_name, business_line_name, subsidiary_name, site_name,
  process_code, indicator_code, year, month, value, status, 
  business_line_key, subsidiary_key, site_key
) VALUES 
-- Informations générales - Site Conseil Plateau
('GROUPE VISION DURABLE', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau', 'INFO_GEN', 'CA_TOTAL', 2025, 1, 125000000, 'validated', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau', 'INFO_GEN', 'SITES_TOTAL', 2025, 1, 1, 'validated', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau', 'INFO_GEN', 'FOURNISSEURS', 2025, 1, 45, 'validated', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau'),

-- Stratégie - Site Stratégie Centre
('GROUPE VISION DURABLE', 'Conseil ESG', 'Stratégie Durable SA', 'Site Stratégie Centre', 'STRATEGIE', 'ACHATS_LOCAUX', 2025, 1, 75, 'validated', 'Conseil ESG', 'Stratégie Durable SA', 'Site Stratégie Centre'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Stratégie Durable SA', 'Site Stratégie Centre', 'STRATEGIE', 'FOURNISSEURS_ESG', 2025, 1, 85, 'validated', 'Conseil ESG', 'Stratégie Durable SA', 'Site Stratégie Centre'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Stratégie Durable SA', 'Site Stratégie Centre', 'STRATEGIE', 'INTEGRATION_ESG', 2025, 1, 90, 'validated', 'Conseil ESG', 'Stratégie Durable SA', 'Site Stratégie Centre'),

-- Gouvernance - Site Audit Marcory
('GROUPE VISION DURABLE', 'Audit & Certification', 'Audit Vert SARL', 'Site Audit Marcory', 'GOUVERNANCE', 'MEMBRES_CONSEIL', 2025, 1, 9, 'validated', 'Audit & Certification', 'Audit Vert SARL', 'Site Audit Marcory'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'Audit Vert SARL', 'Site Audit Marcory', 'GOUVERNANCE', 'FEMMES_CONSEIL', 2025, 1, 4, 'validated', 'Audit & Certification', 'Audit Vert SARL', 'Site Audit Marcory'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'Audit Vert SARL', 'Site Audit Marcory', 'GOUVERNANCE', 'PART_FEMMES_CONSEIL', 2025, 1, 44.4, 'validated', 'Audit & Certification', 'Audit Vert SARL', 'Site Audit Marcory'),

-- RH Social - Site Certification San-Pédro
('GROUPE VISION DURABLE', 'Audit & Certification', 'Certif ESG SA', 'Site Certification San-Pédro', 'RH_SOCIAL', 'COLLAB_CDI', 2025, 1, 85, 'validated', 'Audit & Certification', 'Certif ESG SA', 'Site Certification San-Pédro'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'Certif ESG SA', 'Site Certification San-Pédro', 'RH_SOCIAL', 'COLLAB_CDD', 2025, 1, 15, 'validated', 'Audit & Certification', 'Certif ESG SA', 'Site Certification San-Pédro'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'Certif ESG SA', 'Site Certification San-Pédro', 'RH_SOCIAL', 'TOTAL_COLLABORATEURS', 2025, 1, 100, 'validated', 'Audit & Certification', 'Certif ESG SA', 'Site Certification San-Pédro'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'Certif ESG SA', 'Site Certification San-Pédro', 'RH_SOCIAL', 'COLLAB_FEMMES', 2025, 1, 55, 'validated', 'Audit & Certification', 'Certif ESG SA', 'Site Certification San-Pédro'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'Certif ESG SA', 'Site Certification San-Pédro', 'RH_SOCIAL', 'COLLAB_HOMMES', 2025, 1, 45, 'validated', 'Audit & Certification', 'Certif ESG SA', 'Site Certification San-Pédro'),

-- Données février 2025
('GROUPE VISION DURABLE', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau', 'INFO_GEN', 'CA_TOTAL', 2025, 2, 135000000, 'validated', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Stratégie Durable SA', 'Site Stratégie Centre', 'STRATEGIE', 'ACHATS_LOCAUX', 2025, 2, 78, 'validated', 'Conseil ESG', 'Stratégie Durable SA', 'Site Stratégie Centre'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'Audit Vert SARL', 'Site Audit Marcory', 'GOUVERNANCE', 'PART_FEMMES_CONSEIL', 2025, 2, 44.4, 'validated', 'Audit & Certification', 'Audit Vert SARL', 'Site Audit Marcory'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'Certif ESG SA', 'Site Certification San-Pédro', 'RH_SOCIAL', 'TOTAL_COLLABORATEURS', 2025, 2, 102, 'validated', 'Audit & Certification', 'Certif ESG SA', 'Site Certification San-Pédro'),

-- Données mars 2025
('GROUPE VISION DURABLE', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau', 'INFO_GEN', 'CA_TOTAL', 2025, 3, 142000000, 'validated', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Stratégie Durable SA', 'Site Stratégie Centre', 'STRATEGIE', 'ACHATS_LOCAUX', 2025, 3, 82, 'validated', 'Conseil ESG', 'Stratégie Durable SA', 'Site Stratégie Centre'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'Audit Vert SARL', 'Site Audit Marcory', 'GOUVERNANCE', 'PART_FEMMES_CONSEIL', 2025, 3, 44.4, 'validated', 'Audit & Certification', 'Audit Vert SARL', 'Site Audit Marcory'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'Certif ESG SA', 'Site Certification San-Pédro', 'RH_SOCIAL', 'TOTAL_COLLABORATEURS', 2025, 3, 105, 'validated', 'Audit & Certification', 'Certif ESG SA', 'Site Certification San-Pédro')
ON CONFLICT (organization_name, business_line_key, subsidiary_key, site_key, process_code, indicator_code, year, month) DO NOTHING;

-- 13. ATTRIBUTION DES PROCESSUS AUX UTILISATEURS
INSERT INTO user_processes (email, process_codes) VALUES 
('contrib.conseil@visionconseil.ci', ARRAY['INFO_GEN', 'STRATEGIE']),
('contrib.strategie@strategiedurable.ci', ARRAY['STRATEGIE', 'GOUVERNANCE']),
('contrib.audit@auditvert.ci', ARRAY['GOUVERNANCE', 'RH_SOCIAL']),
('contrib.certif@certifESG.ci', ARRAY['RH_SOCIAL']),
('valid.conseil@groupevisiondurable.ci', ARRAY['INFO_GEN', 'STRATEGIE', 'GOUVERNANCE']),
('valid.audit@groupevisiondurable.ci', ARRAY['GOUVERNANCE', 'RH_SOCIAL'])
ON CONFLICT (email) DO UPDATE SET process_codes = EXCLUDED.process_codes;

-- 14. ANALYSE SWOT D'EXEMPLE
INSERT INTO swot_analysis (organization_name, type, description) VALUES 
('GROUPE VISION DURABLE', 'strength', 'Expertise reconnue en conseil ESG depuis 10 ans'),
('GROUPE VISION DURABLE', 'strength', 'Équipe multidisciplinaire expérimentée'),
('GROUPE VISION DURABLE', 'strength', 'Réseau de partenaires internationaux solide'),
('GROUPE VISION DURABLE', 'strength', 'Certifications ISO 26000 et GRI'),
('GROUPE VISION DURABLE', 'weakness', 'Dépendance au marché ivoirien'),
('GROUPE VISION DURABLE', 'weakness', 'Ressources limitées pour l''expansion'),
('GROUPE VISION DURABLE', 'weakness', 'Digitalisation des processus en retard'),
('GROUPE VISION DURABLE', 'opportunity', 'Nouvelle réglementation CSRD en Europe'),
('GROUPE VISION DURABLE', 'opportunity', 'Demande croissante pour les services ESG'),
('GROUPE VISION DURABLE', 'opportunity', 'Expansion vers les pays de la sous-région'),
('GROUPE VISION DURABLE', 'opportunity', 'Partenariats avec institutions financières'),
('GROUPE VISION DURABLE', 'threat', 'Concurrence accrue des cabinets internationaux'),
('GROUPE VISION DURABLE', 'threat', 'Évolution rapide des réglementations'),
('GROUPE VISION DURABLE', 'threat', 'Instabilité économique régionale')
ON CONFLICT DO NOTHING;