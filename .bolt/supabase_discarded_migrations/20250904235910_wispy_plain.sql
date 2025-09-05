/*
  # Add comprehensive ESG indicators from detailed spreadsheet

  1. New Tables
    - Updates `indicators` table with comprehensive ESG indicators
    - Updates `processes` table with ESG processes
    - Updates `indicator_values` table with sample data

  2. Security
    - Maintains existing RLS policies
    - Preserves data integrity

  3. Changes
    - Adds 80+ detailed ESG indicators from reference spreadsheet
    - Creates 6 ESG processes with indicator assignments
    - Adds sample data for GROUPE VISION DURABLE
*/

-- Insert comprehensive ESG indicators
INSERT INTO indicators (code, name, description, unit, type, axe, formule, frequence) VALUES
-- B1 - Informations générales
('B1_CA', 'Chiffre d''affaires', 'Revenus sous forme de ventes nettes plus les revenus des investissements financiers et des ventes d''actifs. Les ventes nettes peuvent être calculées comme les revenus bruts des produits et de services moins les retours, les remises et les ristournes.', 'FCFA', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
('B1_SITES', 'Sites', 'Sites où la production est réalisée', 'Nbre', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
('B1_FOURN', 'Fournisseurs de produits et services', 'Organisation ou personne fournissant un produit ou service à SIPCA annuellement', 'Nbre', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
('B1_AIDE_FIN', 'Aide financière reçue du gouvernement', 'Aide financière reçue du gouvernement', 'FCFA', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
('B1_IMPOTS', 'Impôts et taxes versées auprès des ministères et organismes publics', 'Impôt et taxes versés', 'FCFA', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
('B1_RAPPORTS', 'Types de rapports élaborés', 'Nombre de types de rapports élaborés', 'Nbre', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
('B1_FINAL_RAPP', 'Taux de finalisation des rapports', 'Nbre de rapports finalisés/ rapports totaux', 'Nbre', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('B1_LABELS', 'Nombre de labels ESG Obtenus', 'Nombre de labels ESG Obtenus', 'Nbre', 'primaire', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('B1_TAXO_UE', '% CA produits alignés Taxonomie UE', '% du chiffre d''affaires', 'Nbre', 'calculé', 'Environnement', 'dernier_mois', 'mensuelle'),
('B1_CA_GEO', 'Chiffre d''affaires par marché géographique', 'Part du chiffre d''affaires par marché géographique', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('B1_FOURN_DIR', 'Nombre total de fournisseurs directs', 'Nombre total de fournisseurs directs', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
('B1_ACHAT_STRAT', 'Part des achats auprès de fournisseurs stratégiques (top 10 ou top 20)', '% du volume d''achats réalisés auprès de fournisseurs stratégiques', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('B1_ACHAT_TOT', 'Total des Achats réalisés', 'Total des Achats réalisés', 'KFCFA', 'calculé', 'Gouvernance', 'somme', 'mensuelle'),
('B1_CA_ACHAT', '% du chiffre d''affaires issu des achats réalisés', 'Total des achats réalisé / Chiffre d''affaires', 'KFCFA', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('B1_ACHAT_NAT', 'Achats auprès des fournisseurs nationaux', 'Achats auprès des fournisseurs nationaux', 'KFCFA', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),

-- C1 - Stratégie et modèle d'affaires
('C1_ACHAT_LOC', 'Part des achats réalisés auprès des fournisseurs locaux', 'Total des achats réalisé auprès des fournisseurs locaux / Total des achats réalisés', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('C1_FOURN_ESG', 'Part de fournisseurs engagés dans objectifs ESG', 'Part de fournisseurs engagés dans objectifs ESG', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('C1_CRIT_ESG', 'Taux d''intégration des critères ESG dans les appels d''offre', 'Taux d''intégration des critères ESG dans les appels d''offre', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('C1_ACHAT_REG', 'Part des achats locaux / régionaux', 'Volume d''achats locaux/ Volume d''chats régionaux', '%', 'calculé', 'Gouvernance', 'somme', 'mensuelle'),
('C1_FOURN_EVAL', 'Part de fournisseurs évalués sur critères ESG', 'Fournisseurs évalués sur critères ESG/ Nombre total de fournisseurs', '%', 'calculé', 'Gouvernance', 'somme', 'mensuelle'),
('C1_AUDIT_FOURN', 'Nombre d''audits ESG réalisés chez fournisseurs', 'Nombre d''audits ESG réalisés chez fournisseurs', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
('C1_CONF_FOURN', 'Taux de conformité ESG des fournisseurs audités', 'Nombre de fournisseurs audités conformes ESG/ Nombre total de fournisseurs audités', '%', 'calculé', 'Gouvernance', 'somme', 'mensuelle'),
('C1_RESIL_CONT', 'Nombre de résiliations de contrats pour non-conformité ESG', 'Nombre de résiliations de contrats pour non-conformité ESG', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
('C1_CA_DUR', 'Part du CA provenant d''activités durables (taxonomie verte UE)', 'Part du CA provenant d''activités durables (taxonomie verte UE)', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('C1_INVEST_ESG', 'Projets d''investissement alignés sur les objectifs ESG', 'Projets d''investissement alignés sur les objectifs ESG', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('C1_RD_DUR', 'Part des dépenses R&D orientées vers solutions durables', 'Part des dépenses R&D orientées vers solutions durables', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('C1_REMUN_DIR', 'Rémunération des dirigeants liée aux objectifs de durabilité', 'Montant variable lié à des objectifs ESG/ Rémunération totale', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),

-- C3 - Instance de gouvernance
('C3_MEMBRES', 'Membres au Conseil d''Administration', 'Membres du Conseil d''administration', 'Nombre', 'primaire', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('C3_FEMMES_CA', 'Femmes dans le Conseil d''Administration', 'Femmes administratrices au Conseil d''Administration', 'Nombre', 'primaire', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('C3_PART_FEMMES', 'Part des femmes dans le Conseil d''Administration', 'Total des Femmes dans le Conseil d''Administration/ Total des Membres au Conseil d''Administration', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('C3_COMITE_DIR', 'Membres du Comité de Direction', 'Membres du Comité de Direction', 'Nombre', 'primaire', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('C3_FEMMES_DIR', 'Femme dans le Comité de Direction', 'Nombre de femme dans Comité de Direction (CODIR, COSIL)', 'Nombre', 'primaire', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('C3_ACT_ENV', 'Actions d''identification des non-conformités environnementales', 'Audits, Evaluations, Inspections... effectués pour déterminer les non-conformités environnementales', 'Nombre', 'primaire', 'Environnement', 'somme', 'mensuelle'),
('C3_ACT_SOC', 'Actions d''identification des non-conformités socio-économiques', 'Audits, Evaluations, Inspections... effectués pour déterminer les non-conformités sociales concernant les travailleurs et la chaîne de valeurs', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('C3_DIAG_TOT', 'Total des diagnostics menés pour détecter les non-conformités', 'Total des Diagnostics menés pour détecter les non-conformités environnementales et des diagnostics menés pour détecter les non-conformités socio-économiques', 'Nombre', 'calculé', 'Gouvernance', 'somme', 'mensuelle'),
('C3_AUDIT_DD', 'Sites ayant effectué un audit interne DD', 'Sites ayant effectué un auto-diagnostic RSE', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
('C3_PART_AUDIT', 'Part des sites ayant effectué un audit interne DD', 'Total des Sites ayant effectué un auto-diagnostic RSE / Total des Sites de production', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),

-- Gouvernance étendue (G1-G6)
('G1_ISO9001', 'Sites certifiés ISO 9001', 'Sites certifiés ISO 9001', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
('G1_PART_ISO9001', 'Part des sites certifiés ISO 9001', 'Total des Sites certifiés ISO 9001/ Total des Sites de production', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('G2_ISO14001', 'Sites certifiés ISO 14001', 'Sites certifiés ISO 14001', 'Nombre', 'primaire', 'Environnement', 'somme', 'mensuelle'),
('G2_PART_ISO14001', 'Part des sites certifiés ISO 14001', 'Sites certifiés ISO 14001/ Total des sites de production', '%', 'calculé', 'Environnement', 'dernier_mois', 'mensuelle'),
('G3_ISO45001', 'Sites certifiés ISO 45001', 'Sites certifiés ISO 45001', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('G3_PART_ISO45001', 'Part des sites certifiés ISO 45001', 'Sites certifiés ISO 45001/ Total des sites de production', '%', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('G4_CONFLITS', 'Conflits d''intérêt déclarés', 'Situations où une personne est confrontée à choisir entre les exigences de sa profession/entreprise/mandat', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
('G4_CONDAMN', 'Nombre de condamnations pour violation des lois anti-corruption durant la période de reporting', 'Nombre de condamnations pour violation des lois anti-corruption durant la période de reporting', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
('G4_AMENDES', 'Montant total des amendes pour violation des lois anti-corruption durant la période de reporting', 'Montant total des amendes pour violation des lois anti-corruption durant la période de reporting', 'FCFA', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
('G5_CONSULT', 'Nombre total de consultations / dialogues formels avec parties prenantes', 'Nombre total de consultations / dialogues formels avec parties prenantes', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('G5_PARTICIP', 'Taux de participation des parties prenantes invitées', 'Nombre de parties prénantes participant aux consultations / Nombre total de parties prénantes invitées', '%', 'calculé', 'Social', 'somme', 'mensuelle'),
('G5_RECOMMAND', 'Part des recommandations / attentes intégrées dans la stratégie', 'Nombre total de recommandations / attentes intégrées dans la stratégie/ Nombre total de recommandations / attentes', '%', 'calculé', 'Social', 'somme', 'mensuelle'),
('G5_PROJETS', 'Nombre de projets ou actions co-construits avec parties prenantes', 'Nombre de projets ou actions co-construits avec parties prenantes', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('G5_CONFLITS_PP', 'Nombre de conflits ou litiges avec parties prenantes', 'Nombre de conflits ou litiges avec parties prenantes', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('G6_ENJEUX_STRAT', 'Part d''enjeux intégrés aux objectifs stratégiques', 'Nombre d''enjeux intégrés aux objectifs stratégiques/ Nombre total d''enjeux de matérialités', '%', 'calculé', 'Gouvernance', 'somme', 'mensuelle'),
('G6_REUNIONS', 'Taux de réalisation des réunions du comité de durabilité', 'Nombre de réunions du comité de durabilité réalisées/ Nombre total de réunions du comité de durabilité prévues', '%', 'calculé', 'Gouvernance', 'somme', 'mensuelle'),
('G6_DECISIONS', 'Part des décisions stratégiques impliquant des critères ESG', 'Nombre de décisions stratégiques impliquant des critères ESG/ Nombre total de décisions stratégiques', '%', 'calculé', 'Gouvernance', 'somme', 'mensuelle'),
('G6_IRO_ACTIONS', 'Taux de mise en œuvre des actions faces aux IRO', 'Nombre d''actions faces aux IRO mises en œuvre/ Nombre total d''actions faces aux IRO prévues', '%', 'calculé', 'Gouvernance', 'somme', 'mensuelle'),
('G6_MARCHES', 'Taux d''accès à de nouvelles opportunités de marchés verts', 'Nombre de nouvelles opportunités de marchés verts/ Nombre d''opportunités de marché', '%', 'calculé', 'Gouvernance', 'somme', 'mensuelle'),
('G6_ODD_ALIGN', 'Part des objectifs DD de l''entreprise alignés avec les ODD pertinents', 'Nombre d''objectifs DD de l''entreprise alignés avec les ODD pertinents/ Nombre total d''objectifs DD', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('G6_PLANNING', 'Taux de respect du calendrier de mise en œuvre des actions DD', 'Nombre de projets DD réalisés selon le planning initial/ Nombre total de projets DD réalisés selon le planning', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('G6_OBJECTIFS', 'Taux d''atteinte des objectifs DD', 'Nombre d''objectifs DD atteints dans le délai prévu/ Nombre total d''objectifs DD atteints', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('G6_VERIF_DATA', 'Taux de vérification des données collectées', 'Nombre de données auditées ou contrôlées/ total collecté', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('G6_ERREURS', 'Taux d''erreurs détectées sur les données collectées', 'Nombre de données incorrectes ou manquantes après vérification/ Nombre total de données vérifiées', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('G6_COUV_SITES', 'Pourcentage de sites / filiales couverts par la collecte des données', 'Nombre total inclus dans la collecte de données DD/ Nombre total de site', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('G6_COUV_PROC', 'Pourcentage des postes / processus concernés par la collecte des données', 'Nombre de postes/ processus participant à la collecte/ Nombre total de postes/ processus', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('G6_ACCESS_PP', 'Accessibilité des données aux parties prenantes internes', 'Nombre de données accessibles aux équipes concernées/ Nombre total de données', '%', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('G6_MAJ_DATA', 'Taux de mise à jour des données', 'Nombre de données mises à jour dans les délais prévus/ Nombre total de données mises à jour', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('G6_PLAINTES', 'Plaintes reçues des clients', 'Plaintes de clients reçues (enregistrées dans le système de gestion de la qualité)', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('G6_TRAIT_PLAINT', 'Taux de traitement des plaintes', 'Nombre de plaintes traitées dans les délais prévus/ Nombre total de plaintes traitées', '%', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('G6_SATISF_PLAINT', 'Taux de satisfaction des plaignants', 'Nombre de plaignants satisfaits du traitement (enquête ou feedback)/ Nombre total de plaintes traitées', '%', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('G6_PLAINT_COMP', 'Proportion des plaintes compensées', 'Nombre de plaintes ayant fait l''objet de compensation/ Nombre total de plainte traitées', '%', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('G6_AMENDES_SANCT', 'Nombre d''amendes ou sanctions reçues', 'Nombre d''amendes ou sanctions reçues', 'Nbre', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
('G6_MONT_AMENDES', 'Montant total des amendes payées', 'Montant total des amendes payées', 'FCFA', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
('G6_PROC_COURS', 'Nombre de procédures en cours', 'Nombre de procédures en cours', 'Nbre', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
('G6_MESURES_CORR', 'Taux de mise en œuvre des mesures correctives après sanction', 'Nombre de mesures correctives après sanction mise en œuvres/ Nombre total de de mesures correctives planifiées', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('G6_FOURN_DILIG', 'Taux de fournisseurs évalués à une due diligence', 'Nombre de fournisseurs soumis à une due diligence environnementale, sociale ou de gouvernance/ Nombre total de fournisseurs', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('G6_CONTROLES', 'Nombre de contrôles internes réalisés', 'Nombre de contrôles internes réalisés : audits, inspections ou vérifications documentées', 'Nbre', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
('G6_CORRECT_NC', 'Taux de correction des non-conformités', 'Nombre de non-conformités résolues dans le délai prévu/ Nombre total de non-conformités résolues', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('G6_BUDGET_DD', 'Budget alloué au pilotage DD', 'Valeur des dépenses affectées au développement du plan stratégique développement durable du Groupe', 'FCFA', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),

-- S1 - Emplois et main d'œuvre (Personnel)
('S1_CDI_INDEF', 'Collaborateurs avec un contrat à durée indéterminée (CDI)', 'Collaborateurs à la fin d''année ayant contrat de travail à durée indéterminée, pour un travail à temps plein ou à temps partiel', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_CDD_DET', 'Collaborateurs avec un contrat à durée déterminée (CDD, CDDi)', 'Collaborateurs à la fin d''année ayant un contrat de travail, pour un travail à temps plein ou à temps partiel, qui prend fin à l''expiration d''une période déterminée ou à l''achèvement d''une tâche spécifique', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_TOTAL_COLLAB', 'Total des collaborateurs', 'Total des collaborateurs (CDI + CDD + CDDi)', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('S1_CDI_PART', 'Part des collaborateurs possédant un contrat à durée indéterminée', 'Total des collaborateurs avec un contrat de travail à durée indéterminée/ Total des collaborateurs', '%', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('S1_SOUS_TRAIT', 'Collaborateurs sous-traitants', 'Personnes qui effectuent un travail régulier sur place mais non considérées comme collaborateurs de SIPCA en vertu de la législation ou de la pratique nationale (contrat de travail)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_TOTAL_TRAV', 'Total des collaborateurs (Total des collaborateurs+collaborateurs sous-traitants)', 'Total des collaborateurs + collaborateurs Sous-traitants', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('S1_FEMMES', 'Collaborateurs femmes', 'Employées femmes quel que soit leur contrat de travail (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_HOMMES', 'Collaborateurs hommes', 'Employées hommes quel que soit leur contrat de travail (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_OUVRIERS', 'Ouvriers', 'Ouvriers et main-d''œuvre dans la production (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_EMPLOYES', 'Employés', 'Fonctions administratives et techniciens (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_MAITRISE', 'Agents de maîtrise', 'Agents de maîtrise (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_CADRES', 'Cadres', 'Cadres (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_FEMMES_OUV', 'Femmes ouvrières', 'Femmes ouvrières (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_FEMMES_EMP', 'Femmes employées', 'Femmes employées administratif et techniciens (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_FEMMES_MAIT', 'Femmes agents de maîtrise', 'Femmes agents de maîtrise (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_FEMMES_CAD', 'Femmes cadres', 'Femmes cadres (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_HOMMES_OUV', 'Hommes ouvriers', 'Hommes ouvriers', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('S1_HOMMES_EMP', 'Hommes employés', 'Hommes employés administratif et techniciens', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('S1_HOMMES_MAIT', 'Hommes agents de maîtrise', 'Hommes agents de maîtrise', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('S1_HOMMES_CAD', 'Hommes cadres', 'Hommes cadres', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('S1_COLLAB_30', 'Collaborateurs dont l''âge ≤ 30 ans', 'Employées âge inférieur à 30 ans (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_COLLAB_30_50', 'Collaborateurs dont l''âge >= 30 et <= 50 ans', 'Employées âge supérieur ou égal à 30 ans et inférieur ou égal à 50 ans (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_COLLAB_50', 'Collaborateurs dont l''âge > 50 ans', 'Employées âge supérieur à 50 ans (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_FEMMES_30', 'Femmes dont l''âge ≤ 30 ans', 'Femmes âge inférieur à 30 ans (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_FEMMES_30_50', 'Femmes dont l''âge >= 30 et <= 50 ans', 'Femmes âge supérieur ou égal à 30 ans et inférieur ou égal à 50 ans (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_FEMMES_50', 'Femmes dont l''âge > 50 ans', 'Femmes âge supérieur à 50 ans (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('S1_HOMMES_30', 'Hommes dont l''âge ≤ 30 ans', 'Hommes dont l''âge ≤ 30 ans', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('S1_HOMMES_30_50', 'Hommes dont l''âge >= 30 et <= 50 ans', 'Hommes dont l''âge >= 30 et <=50 ans', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('S1_HOMMES_50', 'Hommes dont l''âge > 50 ans', 'Hommes dont l''âge > 50 ans', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('S1_EMBAUCHE_30', 'Embauches de l''année dont l''âge < 30 ans', 'Embauches - nouveaux collaborateurs dont l''âge < 30 ans (possédant un contrat CDI ou CDDi) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('S1_EMBAUCHE_30_50', 'Embauches de l''année dont l''âge >= 30 et <= 50 ans', 'Embauches - nouveaux collaborateurs dont l''âge >= 30 et <= 50 ans (possédant un contrat CDI ou CDDi) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('S1_EMBAUCHE_50', 'Embauches de l''année dont l''âge > 50 ans', 'Embauches - nouveaux collaborateurs dont l''âge > 50 ans (possédant un contrat CDI ou CDDi) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('S1_MOBILITE', 'Mobilité interne', 'Arrivée d''un autre site ou d''une autre filiale pour raison de Mobilité', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('S1_EMBAUCHE_F30', 'Embauches de l''année femmes dont l''âge < 30 ans', 'Embauches - nouveaux collaborateurs femmes dont l''âge < 30 ans (possédant un contrat CDI ou CDDi) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('S1_EMBAUCHE_F30_50', 'Embauches de l''année femmes dont l''âge >= 30 et <= 50 ans', 'Embauches - nouveaux collaborateurs femmes ayant un âge >= 30 et <= 50 ans (possédant un contrat CDI ou CDDi) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('S1_EMBAUCHE_F50', 'Embauches de l''année femmes dont l''âge > 50 ans', 'Embauches - nouveaux collaborateurs femmes dont l''âge > 50 ans (possédant un contrat CDI ou CDDi) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('S1_TOTAL_EMB_F', 'Total des embauches de l''année pour les femmes', 'Total des embauches de l''année femmes par classe d''âge', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('S1_EMBAUCHE_H30', 'Embauches de l''année hommes dont l''âge < 30 ans', 'Embauches - nouveaux collaborateurs hommes dont l''âge < 30 ans (possédant un contrat CDI ou CDDi) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('S1_EMBAUCHE_H30_50', 'Embauches de l''année hommes dont l''âge >= 30 et <= 50 ans', 'Embauches - nouveaux collaborateurs hommes ayant un âge >= 30 et <= 50 ans (possédant un contrat CDI ou CDDi) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('S1_EMBAUCHE_H50', 'Embauches de l''année hommes dont l''âge > 50 ans', 'Embauches - nouveaux collaborateurs hommes dont l''âge > 50 ans (possédant un contrat CDI ou CDDi) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('S1_TOTAL_EMB_H', 'Total des embauches de l''année pour les hommes', 'Total des embauches de l''année hommes par classe d''âge', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('S1_TOTAL_EMB', 'Total des embauches de l''année', 'Embauches de l''année hommes et femmes', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('S1_TOTAL_ENTREES', 'Total des entrées de l''année', 'Total des entrées = Total des embauches + mobilité interne', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('S1_DEMISS_OUV', 'Démissions ouvrières', 'Démissions ouvrières', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('S1_DEMISS_EMP', 'Démissions employés', 'Démissions employés administratif et techniciens', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('S1_DEMISS_MAIT', 'Démissions agents de maîtrise', 'Démissions agents de maîtrise', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('S1_DEMISS_CAD', 'Démissions cadres', 'Démissions cadres', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('S1_TOTAL_DEMISS', 'Total des démissions', 'Total des démissions', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('S1_RETRAITE', 'Retraite (anticipée, raison médicale, date normale)', 'Départs pour raison de Retraite (anticipée, raison médicale, date normale)', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('S1_DEPART_NEG', 'Départs négociés', 'Départs pour raison de Départs négociés', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('S1_LICENC', 'Licenciements (économiques, faute grave,...)', 'Départs pour raison de Licenciements économiques ou fautes', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('S1_ABANDON', 'Abandon de postes', 'Départs pour raison d''Abandon de postes', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('S1_FIN_CDD', 'Départs liés à une fin de contrat CDD', 'Départs liés à une fin de contrat CDD', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('S1_DECES', 'Décès', 'Départs pour raison de Décès', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('S1_TOTAL_DEP', 'Total des départs de l''année', 'Total des départs de l''année', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('S1_DEP_H', 'Total départ collaborateurs hommes', 'Nombres d''hommes en CDI/CDD ayant quitté leur emploi, volontairement ou non (durant l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('S1_DEP_F', 'Total départ collaborateurs femmes', 'Nombres de femmes en CDI/CDD ayant quitté leur emploi, volontairement ou non (durant l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('S1_MOBILITE_EXT', 'Mobilité externe', 'Départs pour raison de Mobilité sur un autre site ou filiales', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('S1_TOTAL_SORT', 'Total des sorties de l''année', 'Total des sorties = Total des départs de l''année + Mobilité externe', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('S1_TURNOVER_H', 'Turnover Hommes', 'Total des Employées hommes ayant quitté l''organisation au cours de l''année/ Total des employées hommes', 'Ratio', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('S1_TURNOVER_F', 'Turnover Femmes', 'Total des Employées femmes ayant quitté l''organisation au cours de l''année/ Total des employées femmes', 'Ratio', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('S1_INCIDENTS', 'Nombre d''incidents majeurs dans la chaîne de valeur affectant la production ou la livraison', 'Nombre d''incidents majeurs dans la chaîne de valeur affectant la production ou la livraison', 'Nbre', 'primaire', 'Social', 'somme', 'mensuelle'),
('S1_PLANS_MITIG', 'Nombre de plans de mitigation des risques de rupture de la chaîne de valeur mis en place', 'Nombre de plans de mitigation des risques de rupture de la chaîne de valeur mis en place', 'Nbre', 'primaire', 'Social', 'somme', 'mensuelle'),

-- B10 - Rémunération et négociation collective
('B10_SAL_ENTREE', 'Salaire d''entrée dans le Groupe', 'Salaire d''embauche le plus bas dans le Groupe SIPCA (annuel)', 'FCFA', 'primaire', 'Social', 'moyenne', 'mensuelle'),
('B10_SAL_MIN', 'Salaire minimum légal et local', 'Salaire minimum local selon la réglementation (annuel)', 'FCFA', 'primaire', 'Social', 'moyenne', 'mensuelle'),
('B10_RATIO_SAL', 'Salaire d''entrée comparé au salaire local', 'Ratio du salaire d''entrée standard par sexe, par rapport au salaire minimum local applicable', 'Ratio', 'calculé', 'Social', 'moyenne', 'mensuelle'),
('B10_REMUN_H', 'Rémunération totale - Hommes', 'Total annuel de la rémunération versée aux hommes', 'FCFA', 'primaire', 'Social', 'somme', 'mensuelle'),
('B10_REMUN_F', 'Rémunération totale - Femmes', 'Total annuel de la rémunération versée aux femmes', 'FCFA', 'primaire', 'Social', 'somme', 'mensuelle'),
('B10_TOTAL_REMUN', 'TOTAL Rémunérations - Hommes+Femmes', 'Total annuel de la rémunération versée aux hommes et aux femmes', 'FCFA', 'calculé', 'Social', 'somme', 'mensuelle'),
('B10_RATIO_CA', 'Ratio Rémunération / Chiffre d''affaires', 'Total Rémunération annuelle Hommes + Femmes / 1000 / Chiffre d''affaires', 'FCFA', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('B10_CROISS_REMUN', 'Taux de croissance de la Rémunération', 'Taux de croissance de la Rémunération', 'FCFA', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('B10_REMUN_MOY_H', 'Rémunération annuelle moyenne - Homme', 'Rémunération annuelle moyenne par homme', 'FCFA', 'calculé', 'Social', 'moyenne', 'mensuelle'),
('B10_REMUN_MOY_F', 'Rémunération annuelle moyenne - Femme', 'Rémunération annuelle moyenne par femme', 'FCFA', 'calculé', 'Social', 'moyenne', 'mensuelle'),
('B10_REMUN_MOY_TOT', 'Rémunération annuelle moyenne - Total collaborateur', 'Rémunération annuelle moyenne par collaborateur', 'FCFA', 'calculé', 'Social', 'moyenne', 'mensuelle'),
('B10_EGAL_SAL', 'Égalité salariale entre les hommes et les femmes TOUTES CATÉGORIES', 'Ratio entre la rémunération annuelle moyenne des femmes et la rémunération annuelle moyenne des femmes', 'Ratio', 'calculé', 'Social', 'moyenne', 'mensuelle')
ON CONFLICT (code) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  unit = EXCLUDED.unit,
  type = EXCLUDED.type,
  axe = EXCLUDED.axe,
  formule = EXCLUDED.formule,
  frequence = EXCLUDED.frequence,
  updated_at = now();

-- Insert or update processes with unique codes
INSERT INTO processes (code, name, description, indicator_codes, organization_name) VALUES
('INFO_GEN', 'Informations Générales', 'Collecte des informations générales de l''entreprise', 
 ARRAY['B1_CA', 'B1_SITES', 'B1_FOURN', 'B1_AIDE_FIN', 'B1_IMPOTS', 'B1_RAPPORTS', 'B1_FINAL_RAPP', 'B1_LABELS', 'B1_TAXO_UE', 'B1_CA_GEO', 'B1_FOURN_DIR', 'B1_ACHAT_STRAT', 'B1_ACHAT_TOT', 'B1_CA_ACHAT', 'B1_ACHAT_NAT'], 
 'GROUPE VISION DURABLE'),
('STRAT_AFF', 'Stratégie et Modèle d''Affaires', 'Suivi de la stratégie et du modèle d''affaires ESG', 
 ARRAY['C1_ACHAT_LOC', 'C1_FOURN_ESG', 'C1_CRIT_ESG', 'C1_ACHAT_REG', 'C1_FOURN_EVAL', 'C1_AUDIT_FOURN', 'C1_CONF_FOURN', 'C1_RESIL_CONT', 'C1_CA_DUR', 'C1_INVEST_ESG', 'C1_RD_DUR', 'C1_REMUN_DIR'], 
 'GROUPE VISION DURABLE'),
('GOUVERNANCE', 'Instance de Gouvernance', 'Suivi des instances de gouvernance et conformité', 
 ARRAY['C3_MEMBRES', 'C3_FEMMES_CA', 'C3_PART_FEMMES', 'C3_COMITE_DIR', 'C3_FEMMES_DIR', 'C3_ACT_ENV', 'C3_ACT_SOC', 'C3_DIAG_TOT', 'C3_AUDIT_DD', 'C3_PART_AUDIT'], 
 'GROUPE VISION DURABLE'),
('GOUV_ETENDUE', 'Gouvernance Étendue', 'Gouvernance étendue et certifications', 
 ARRAY['G1_ISO9001', 'G1_PART_ISO9001', 'G2_ISO14001', 'G2_PART_ISO14001', 'G3_ISO45001', 'G3_PART_ISO45001', 'G4_CONFLITS', 'G4_CONDAMN', 'G4_AMENDES', 'G5_CONSULT', 'G5_PARTICIP', 'G5_RECOMMAND', 'G5_PROJETS', 'G5_CONFLITS_PP', 'G6_ENJEUX_STRAT', 'G6_REUNIONS', 'G6_DECISIONS', 'G6_IRO_ACTIONS', 'G6_MARCHES', 'G6_ODD_ALIGN', 'G6_PLANNING', 'G6_OBJECTIFS', 'G6_VERIF_DATA', 'G6_ERREURS', 'G6_COUV_SITES', 'G6_COUV_PROC', 'G6_ACCESS_PP', 'G6_MAJ_DATA', 'G6_PLAINTES', 'G6_TRAIT_PLAINT', 'G6_SATISF_PLAINT', 'G6_PLAINT_COMP', 'G6_AMENDES_SANCT', 'G6_MONT_AMENDES', 'G6_PROC_COURS', 'G6_MESURES_CORR', 'G6_FOURN_DILIG', 'G6_CONTROLES', 'G6_CORRECT_NC', 'G6_BUDGET_DD'], 
 'GROUPE VISION DURABLE'),
('RH_EMPLOI', 'Ressources Humaines - Emploi', 'Gestion des ressources humaines et emploi', 
 ARRAY['S1_CDI_INDEF', 'S1_CDD_DET', 'S1_TOTAL_COLLAB', 'S1_CDI_PART', 'S1_SOUS_TRAIT', 'S1_TOTAL_TRAV', 'S1_FEMMES', 'S1_HOMMES', 'S1_OUVRIERS', 'S1_EMPLOYES', 'S1_MAITRISE', 'S1_CADRES', 'S1_FEMMES_OUV', 'S1_FEMMES_EMP', 'S1_FEMMES_MAIT', 'S1_FEMMES_CAD', 'S1_HOMMES_OUV', 'S1_HOMMES_EMP', 'S1_HOMMES_MAIT', 'S1_HOMMES_CAD', 'S1_COLLAB_30', 'S1_COLLAB_30_50', 'S1_COLLAB_50', 'S1_FEMMES_30', 'S1_FEMMES_30_50', 'S1_FEMMES_50', 'S1_HOMMES_30', 'S1_HOMMES_30_50', 'S1_HOMMES_50', 'S1_EMBAUCHE_30', 'S1_EMBAUCHE_30_50', 'S1_EMBAUCHE_50', 'S1_MOBILITE', 'S1_EMBAUCHE_F30', 'S1_EMBAUCHE_F30_50', 'S1_EMBAUCHE_F50', 'S1_TOTAL_EMB_F', 'S1_EMBAUCHE_H30', 'S1_EMBAUCHE_H30_50', 'S1_EMBAUCHE_H50', 'S1_TOTAL_EMB_H', 'S1_TOTAL_EMB', 'S1_TOTAL_ENTREES', 'S1_DEMISS_OUV', 'S1_DEMISS_EMP', 'S1_DEMISS_MAIT', 'S1_DEMISS_CAD', 'S1_TOTAL_DEMISS', 'S1_RETRAITE', 'S1_DEPART_NEG', 'S1_LICENC', 'S1_ABANDON', 'S1_FIN_CDD', 'S1_DECES', 'S1_TOTAL_DEP', 'S1_DEP_H', 'S1_DEP_F', 'S1_MOBILITE_EXT', 'S1_TOTAL_SORT', 'S1_TURNOVER_H', 'S1_TURNOVER_F', 'S1_INCIDENTS', 'S1_PLANS_MITIG'], 
 'GROUPE VISION DURABLE'),
('REMUNERATION', 'Rémunération et Négociation Collective', 'Suivi des rémunérations et négociations collectives', 
 ARRAY['B10_SAL_ENTREE', 'B10_SAL_MIN', 'B10_RATIO_SAL', 'B10_REMUN_H', 'B10_REMUN_F', 'B10_TOTAL_REMUN', 'B10_RATIO_CA', 'B10_CROISS_REMUN', 'B10_REMUN_MOY_H', 'B10_REMUN_MOY_F', 'B10_REMUN_MOY_TOT', 'B10_EGAL_SAL'], 
 'GROUPE VISION DURABLE')
ON CONFLICT (code) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  indicator_codes = EXCLUDED.indicator_codes,
  organization_name = EXCLUDED.organization_name,
  updated_at = now();

-- Insert sample indicator values for testing (January-March 2025)
INSERT INTO indicator_values (
  organization_name, business_line_name, subsidiary_name, site_name, 
  process_code, indicator_code, year, month, value, status, 
  business_line_key, subsidiary_key, site_key
) VALUES
-- B1 - Informations générales (Site Conseil Plateau)
('GROUPE VISION DURABLE', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau', 'INFO_GEN', 'B1_CA', 2025, 1, 15000000, 'validated', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau', 'INFO_GEN', 'B1_SITES', 2025, 1, 1, 'validated', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau', 'INFO_GEN', 'B1_FOURN', 2025, 1, 25, 'validated', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau', 'INFO_GEN', 'B1_AIDE_FIN', 2025, 1, 500000, 'validated', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau', 'INFO_GEN', 'B1_IMPOTS', 2025, 1, 2250000, 'validated', 'Conseil ESG', 'Vision Conseil SARL', 'Site Conseil Plateau'),

-- C1 - Stratégie (Site Stratégie Centre)
('GROUPE VISION DURABLE', 'Conseil ESG', 'Stratégie Durable SARL', 'Site Stratégie Centre', 'STRAT_AFF', 'C1_ACHAT_LOC', 2025, 1, 65, 'validated', 'Conseil ESG', 'Stratégie Durable SARL', 'Site Stratégie Centre'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Stratégie Durable SARL', 'Site Stratégie Centre', 'STRAT_AFF', 'C1_FOURN_ESG', 2025, 1, 80, 'validated', 'Conseil ESG', 'Stratégie Durable SARL', 'Site Stratégie Centre'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Stratégie Durable SARL', 'Site Stratégie Centre', 'STRAT_AFF', 'C1_CRIT_ESG', 2025, 1, 90, 'validated', 'Conseil ESG', 'Stratégie Durable SARL', 'Site Stratégie Centre'),

-- C3 - Gouvernance (Site Audit Marcory)
('GROUPE VISION DURABLE', 'Audit & Certification', 'Audit Vert SARL', 'Site Audit Marcory', 'GOUVERNANCE', 'C3_MEMBRES', 2025, 1, 9, 'validated', 'Audit & Certification', 'Audit Vert SARL', 'Site Audit Marcory'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'Audit Vert SARL', 'Site Audit Marcory', 'GOUVERNANCE', 'C3_FEMMES_CA', 2025, 1, 4, 'validated', 'Audit & Certification', 'Audit Vert SARL', 'Site Audit Marcory'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'Audit Vert SARL', 'Site Audit Marcory', 'GOUVERNANCE', 'C3_PART_FEMMES', 2025, 1, 44, 'validated', 'Audit & Certification', 'Audit Vert SARL', 'Site Audit Marcory'),

-- S1 - RH (Site Certification San-Pédro)
('GROUPE VISION DURABLE', 'Audit & Certification', 'Certif ESG SARL', 'Site Certification San-Pédro', 'RH_EMPLOI', 'S1_CDI_INDEF', 2025, 1, 45, 'validated', 'Audit & Certification', 'Certif ESG SARL', 'Site Certification San-Pédro'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'Certif ESG SARL', 'Site Certification San-Pédro', 'RH_EMPLOI', 'S1_CDD_DET', 2025, 1, 8, 'validated', 'Audit & Certification', 'Certif ESG SARL', 'Site Certification San-Pédro'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'Certif ESG SARL', 'Site Certification San-Pédro', 'RH_EMPLOI', 'S1_FEMMES', 2025, 1, 28, 'validated', 'Audit & Certification', 'Certif ESG SARL', 'Site Certification San-Pédro'),
('GROUPE VISION DURABLE', 'Audit & Certification', 'Certif ESG SARL', 'Site Certification San-Pédro', 'RH_EMPLOI', 'S1_HOMMES', 2025, 1, 25, 'validated', 'Audit & Certification', 'Certif ESG SARL', 'Site Certification San-Pédro'),

-- B10 - Rémunération (Siège Abidjan)
('GROUPE VISION DURABLE', 'Conseil ESG', 'Vision Conseil SARL', 'Siège Abidjan', 'REMUNERATION', 'B10_SAL_ENTREE', 2025, 1, 180000, 'validated', 'Conseil ESG', 'Vision Conseil SARL', 'Siège Abidjan'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Vision Conseil SARL', 'Siège Abidjan', 'REMUNERATION', 'B10_SAL_MIN', 2025, 1, 60000, 'validated', 'Conseil ESG', 'Vision Conseil SARL', 'Siège Abidjan'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Vision Conseil SARL', 'Siège Abidjan', 'REMUNERATION', 'B10_REMUN_H', 2025, 1, 12500000, 'validated', 'Conseil ESG', 'Vision Conseil SARL', 'Siège Abidjan'),
('GROUPE VISION DURABLE', 'Conseil ESG', 'Vision Conseil SARL', 'Siège Abidjan', 'REMUNERATION', 'B10_REMUN_F', 2025, 1, 11800000, 'validated', 'Conseil ESG', 'Vision Conseil SARL', 'Siège Abidjan')
ON CONFLICT (organization_name, business_line_key, subsidiary_key, site_key, process_code, indicator_code, year, month) 
DO UPDATE SET
  value = EXCLUDED.value,
  status = EXCLUDED.status,
  updated_at = now();

-- Update organization indicators for GROUPE VISION DURABLE
INSERT INTO organization_indicators (organization_name, indicator_codes) VALUES
('GROUPE VISION DURABLE', ARRAY[
  'B1_CA', 'B1_SITES', 'B1_FOURN', 'B1_AIDE_FIN', 'B1_IMPOTS', 'B1_RAPPORTS', 'B1_FINAL_RAPP', 'B1_LABELS', 'B1_TAXO_UE', 'B1_CA_GEO', 'B1_FOURN_DIR', 'B1_ACHAT_STRAT', 'B1_ACHAT_TOT', 'B1_CA_ACHAT', 'B1_ACHAT_NAT',
  'C1_ACHAT_LOC', 'C1_FOURN_ESG', 'C1_CRIT_ESG', 'C1_ACHAT_REG', 'C1_FOURN_EVAL', 'C1_AUDIT_FOURN', 'C1_CONF_FOURN', 'C1_RESIL_CONT', 'C1_CA_DUR', 'C1_INVEST_ESG', 'C1_RD_DUR', 'C1_REMUN_DIR',
  'C3_MEMBRES', 'C3_FEMMES_CA', 'C3_PART_FEMMES', 'C3_COMITE_DIR', 'C3_FEMMES_DIR', 'C3_ACT_ENV', 'C3_ACT_SOC', 'C3_DIAG_TOT', 'C3_AUDIT_DD', 'C3_PART_AUDIT',
  'G1_ISO9001', 'G1_PART_ISO9001', 'G2_ISO14001', 'G2_PART_ISO14001', 'G3_ISO45001', 'G3_PART_ISO45001', 'G4_CONFLITS', 'G4_CONDAMN', 'G4_AMENDES', 'G5_CONSULT', 'G5_PARTICIP', 'G5_RECOMMAND', 'G5_PROJETS', 'G5_CONFLITS_PP', 'G6_ENJEUX_STRAT', 'G6_REUNIONS', 'G6_DECISIONS', 'G6_IRO_ACTIONS', 'G6_MARCHES', 'G6_ODD_ALIGN', 'G6_PLANNING', 'G6_OBJECTIFS', 'G6_VERIF_DATA', 'G6_ERREURS', 'G6_COUV_SITES', 'G6_COUV_PROC', 'G6_ACCESS_PP', 'G6_MAJ_DATA', 'G6_PLAINTES', 'G6_TRAIT_PLAINT', 'G6_SATISF_PLAINT', 'G6_PLAINT_COMP', 'G6_AMENDES_SANCT', 'G6_MONT_AMENDES', 'G6_PROC_COURS', 'G6_MESURES_CORR', 'G6_FOURN_DILIG', 'G6_CONTROLES', 'G6_CORRECT_NC', 'G6_BUDGET_DD',
  'S1_CDI_INDEF', 'S1_CDD_DET', 'S1_TOTAL_COLLAB', 'S1_CDI_PART', 'S1_SOUS_TRAIT', 'S1_TOTAL_TRAV', 'S1_FEMMES', 'S1_HOMMES', 'S1_OUVRIERS', 'S1_EMPLOYES', 'S1_MAITRISE', 'S1_CADRES', 'S1_FEMMES_OUV', 'S1_FEMMES_EMP', 'S1_FEMMES_MAIT', 'S1_FEMMES_CAD', 'S1_HOMMES_OUV', 'S1_HOMMES_EMP', 'S1_HOMMES_MAIT', 'S1_HOMMES_CAD', 'S1_COLLAB_30', 'S1_COLLAB_30_50', 'S1_COLLAB_50', 'S1_FEMMES_30', 'S1_FEMMES_30_50', 'S1_FEMMES_50', 'S1_HOMMES_30', 'S1_HOMMES_30_50', 'S1_HOMMES_50', 'S1_EMBAUCHE_30', 'S1_EMBAUCHE_30_50', 'S1_EMBAUCHE_50', 'S1_MOBILITE', 'S1_EMBAUCHE_F30', 'S1_EMBAUCHE_F30_50', 'S1_EMBAUCHE_F50', 'S1_TOTAL_EMB_F', 'S1_EMBAUCHE_H30', 'S1_EMBAUCHE_H30_50', 'S1_EMBAUCHE_H50', 'S1_TOTAL_EMB_H', 'S1_TOTAL_EMB', 'S1_TOTAL_ENTREES', 'S1_DEMISS_OUV', 'S1_DEMISS_EMP', 'S1_DEMISS_MAIT', 'S1_DEMISS_CAD', 'S1_TOTAL_DEMISS', 'S1_RETRAITE', 'S1_DEPART_NEG', 'S1_LICENC', 'S1_ABANDON', 'S1_FIN_CDD', 'S1_DECES', 'S1_TOTAL_DEP', 'S1_DEP_H', 'S1_DEP_F', 'S1_MOBILITE_EXT', 'S1_TOTAL_SORT', 'S1_TURNOVER_H', 'S1_TURNOVER_F', 'S1_INCIDENTS', 'S1_PLANS_MITIG',
  'B10_SAL_ENTREE', 'B10_SAL_MIN', 'B10_RATIO_SAL', 'B10_REMUN_H', 'B10_REMUN_F', 'B10_TOTAL_REMUN', 'B10_RATIO_CA', 'B10_CROISS_REMUN', 'B10_REMUN_MOY_H', 'B10_REMUN_MOY_F', 'B10_REMUN_MOY_TOT', 'B10_EGAL_SAL'
])
ON CONFLICT (organization_name) DO UPDATE SET
  indicator_codes = EXCLUDED.indicator_codes,
  updated_at = now();

-- Add SWOT analysis for the organization
INSERT INTO swot_analysis (organization_name, type, description) VALUES
('GROUPE VISION DURABLE', 'strength', 'Expertise reconnue en conseil ESG et audit environnemental'),
('GROUPE VISION DURABLE', 'strength', 'Équipe multidisciplinaire expérimentée'),
('GROUPE VISION DURABLE', 'strength', 'Présence géographique étendue en Côte d''Ivoire'),
('GROUPE VISION DURABLE', 'strength', 'Certifications ISO multiples'),
('GROUPE VISION DURABLE', 'weakness', 'Dépendance aux marchés locaux'),
('GROUPE VISION DURABLE', 'weakness', 'Ressources limitées pour l''expansion internationale'),
('GROUPE VISION DURABLE', 'weakness', 'Digitalisation des processus en cours'),
('GROUPE VISION DURABLE', 'opportunity', 'Croissance du marché ESG en Afrique de l''Ouest'),
('GROUPE VISION DURABLE', 'opportunity', 'Nouvelles réglementations CSRD créent de la demande'),
('GROUPE VISION DURABLE', 'opportunity', 'Partenariats avec organisations internationales'),
('GROUPE VISION DURABLE', 'opportunity', 'Développement de solutions digitales ESG'),
('GROUPE VISION DURABLE', 'threat', 'Concurrence accrue des cabinets internationaux'),
('GROUPE VISION DURABLE', 'threat', 'Évolution rapide des standards ESG'),
('GROUPE VISION DURABLE', 'threat', 'Instabilité économique régionale')
ON CONFLICT (organization_name, type, description) DO NOTHING;